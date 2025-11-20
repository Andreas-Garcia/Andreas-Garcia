#!/usr/bin/env python3
"""
Generate GitHub Streak Stats SVG
Fetches contribution data from GitHub API and generates an SVG visualization.
"""
import os
import sys
import requests
from datetime import datetime, timedelta
import xml.etree.ElementTree as ET

def main():
    # Get username from environment variable or use default
    username = os.environ.get("GITHUB_USERNAME", "Andreas-Garcia")
    # Use PAT if available, otherwise fall back to GITHUB_TOKEN
    token = os.environ.get("GH_PAT") or os.environ.get("GITHUB_TOKEN")
    
    if not token:
        print("Error: No GitHub token found. Set GH_PAT or GITHUB_TOKEN environment variable.")
        sys.exit(1)

    # GitHub's contribution calendar API limitation: max 1 year per query
    # To get all-time data, we query multiple 1-year ranges and combine them
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    query_template = """
    query($username: String!, $from: DateTime!, $to: DateTime!) {
      user(login: $username) {
        contributionsCollection(from: $from, to: $to) {
          contributionCalendar {
            totalContributions
            weeks {
              contributionDays {
                date
                contributionCount
              }
            }
          }
        }
      }
    }
    """

    # Query multiple 1-year ranges going back in time
    # Start from today and go back in 1-year increments
    all_weeks = []
    total_contributions = 0
    max_years_back = 10  # Query up to 10 years back

    now = datetime.now()
    to_date = (now + timedelta(days=1)).isoformat() + "Z"

    print(f"Querying contributions in 1-year ranges (going back up to {max_years_back} years)...")

    for year_offset in range(max_years_back):
        from_date_obj = now - timedelta(days=365 * (year_offset + 1))
        from_date = from_date_obj.isoformat() + "Z"
        
        # For the first query (most recent year), use today as end date
        # For older queries, use the start of the next year as end date
        if year_offset == 0:
            query_to_date = to_date
        else:
            query_to_date = (now - timedelta(days=365 * year_offset)).isoformat() + "Z"
        
        print(f"  Querying year {year_offset + 1}: {from_date[:10]} to {query_to_date[:10]}")
        
        try:
            response = requests.post(
                "https://api.github.com/graphql",
                json={
                    "query": query_template,
                    "variables": {
                        "username": username,
                        "from": from_date,
                        "to": query_to_date
                    }
                },
                headers=headers
            )
            
            response.raise_for_status()
            data = response.json()
            
            if "errors" in data:
                error_msg = data["errors"][0].get("message", "")
                if "must not exceed 1 year" in error_msg:
                    print(f"    ⚠ Date range too large, skipping")
                    continue
                print(f"    ⚠ GraphQL errors: {data['errors']}")
                continue
            
            contributions_collection = data["data"]["user"]["contributionsCollection"]
            calendar = contributions_collection["contributionCalendar"]
            year_weeks = calendar["weeks"]
            year_total = calendar["totalContributions"]
            
            if not year_weeks or year_total == 0:
                print(f"    No contributions found for this year, stopping")
                break
            
            all_weeks.extend(year_weeks)
            total_contributions = max(total_contributions, year_total)  # Use max as it might be cumulative
            print(f"    ✓ Found {year_total} contributions, {len(year_weeks)} weeks")
            
        except Exception as e:
            print(f"    ⚠ Error querying year {year_offset + 1}: {e}")
            if year_offset == 0:
                # If the first query fails, fall back to query without dates
                print("    Falling back to query without date restrictions...")
                query_no_dates = """
                query($username: String!) {
                  user(login: $username) {
                    contributionsCollection {
                      contributionCalendar {
                        totalContributions
                        weeks {
                          contributionDays {
                            date
                            contributionCount
                          }
                        }
                      }
                    }
                  }
                }
                """
                response2 = requests.post(
                    "https://api.github.com/graphql",
                    json={"query": query_no_dates, "variables": {"username": username}},
                    headers=headers
                )
                response2.raise_for_status()
                data2 = response2.json()
                if "errors" not in data2:
                    contributions_collection = data2["data"]["user"]["contributionsCollection"]
                    calendar = contributions_collection["contributionCalendar"]
                    all_weeks = calendar["weeks"]
                    total_contributions = calendar["totalContributions"]
                    print("    ✓ Fallback query successful")
                break
            else:
                # For older years, just skip if there's an error
                break

    if not all_weeks:
        raise Exception("No contribution data found")

    print(f"Successfully queried contributions: {len(all_weeks)} total weeks")

    # Combine all weeks and deduplicate by date (in case of overlaps)
    contributions_by_date = {}
    for week in all_weeks:
        for day in week["contributionDays"]:
            date_str = day["date"]
            try:
                date_obj = datetime.strptime(date_str, "%Y-%m-%d").date()
            except:
                date_obj = datetime.fromisoformat(date_str.replace("Z", "")).date()
            count = day["contributionCount"]
            # If date already exists, use the maximum count (handles overlaps)
            if date_obj in contributions_by_date:
                contributions_by_date[date_obj] = max(contributions_by_date[date_obj], count)
            else:
                contributions_by_date[date_obj] = count

    # Rebuild weeks structure from combined data
    # Group by week (starting from Monday)
    weeks = []
    if contributions_by_date:
        sorted_dates = sorted(contributions_by_date.keys())
        first_date = sorted_dates[0]
        # Find the Monday of the week containing the first date
        days_since_monday = first_date.weekday()
        week_start = first_date - timedelta(days=days_since_monday)
        
        current_week_start = week_start
        current_week_days = []
        
        for date_obj in sorted_dates:
            # If this date is beyond the current week, start a new week
            while date_obj >= current_week_start + timedelta(days=7):
                if current_week_days:
                    weeks.append({"contributionDays": current_week_days})
                current_week_start += timedelta(days=7)
                current_week_days = []
            
            # Add this day to the current week
            current_week_days.append({
                "date": date_obj.isoformat(),
                "contributionCount": contributions_by_date[date_obj]
            })
        
        # Add the last week
        if current_week_days:
            weeks.append({"contributionDays": current_week_days})

    # Recalculate total from combined data
    manual_total = sum(contributions_by_date.values())
    total_contributions = manual_total

    print(f"Combined data: {len(contributions_by_date)} unique days, {manual_total} total contributions")

    # Debug: Check which token is being used
    token_type = "PAT (GH_PAT)" if os.environ.get("GH_PAT") else "GITHUB_TOKEN (limited)"
    print(f"Using token type: {token_type}")

    # Verify token permissions by checking user info
    try:
        user_check = requests.get(
            "https://api.github.com/user",
            headers={"Authorization": f"Bearer {token}"}
        )
        user_check.raise_for_status()
        user_data = user_check.json()
        print(f"Authenticated as: {user_data.get('login', 'unknown')}")
        print(f"Token has repo access: {'repo' in str(user_check.headers.get('X-OAuth-Scopes', ''))}")
    except Exception as e:
        print(f"Warning: Could not verify token permissions: {e}")

    # Debug: Print contribution info
    print(f"Total contributions (combined): {total_contributions:,}")
    print(f"Number of weeks: {len(weeks)}")

    # Count total days with contributions
    total_days_with_contributions = sum(1 for count in contributions_by_date.values() if count > 0)
    print(f"Days with contributions: {total_days_with_contributions}")

    # Calculate current streak
    today = datetime.now().date()
    current_streak = 0
    longest_streak = 0

    # contributions_by_date is already built from combined data
    all_dates = sorted(contributions_by_date.keys())

    if not all_dates:
        raise Exception("No contribution data found")

    # all_dates is already sorted from the combined data
    most_recent_date = all_dates[-1]
    today = datetime.now().date()

    # Calculate current streak: count backwards from today
    # A streak continues as long as there are contributions on consecutive days
    # Start from today and go backwards day by day
    check_date = today

    # Count backwards from today
    # Stop if we go too far back (more than a reasonable time) or hit a day with no contributions
    max_days_back = 1000  # Safety limit
    days_checked = 0

    while days_checked < max_days_back:
        # If date is in our data
        if check_date in contributions_by_date:
            if contributions_by_date[check_date] > 0:
                # This day has contributions, add to streak and continue
                current_streak += 1
                check_date = check_date - timedelta(days=1)
                days_checked += 1
            else:
                # This day has 0 contributions, streak is broken
                break
        else:
            # Date is not in our data
            # If it's before our earliest date, stop
            if check_date < all_dates[0]:
                break
            # If it's today and not in data, it might be too early (check yesterday)
            if check_date == today:
                check_date = check_date - timedelta(days=1)
                days_checked += 1
                continue
            # Otherwise, this day had no contributions (not in our data), streak is broken
            break

    # Calculate longest streak: go through all dates chronologically
    temp_streak = 0
    for date_obj in sorted(contributions_by_date.keys()):
        if contributions_by_date[date_obj] > 0:
            temp_streak += 1
            longest_streak = max(longest_streak, temp_streak)
        else:
            temp_streak = 0

    print(f"Most recent contribution date: {most_recent_date}")
    print(f"Current streak: {current_streak} days")
    print(f"Longest streak: {longest_streak} days")

    # Calculate dates for display
    # Current streak start date
    current_streak_start = None
    if current_streak > 0:
        # Find the start date of current streak
        check_date = today
        days_back = 0
        while days_back < current_streak and check_date >= all_dates[0]:
            if check_date in contributions_by_date and contributions_by_date[check_date] > 0:
                current_streak_start = check_date
                check_date = check_date - timedelta(days=1)
                days_back += 1
            else:
                break
          
    # Longest streak dates (find the most recent longest streak)
    longest_streak_start = None
    longest_streak_end = None
    if longest_streak > 0:
        temp_streak = 0
        temp_start = None
        for date_obj in sorted(contributions_by_date.keys()):
            if contributions_by_date[date_obj] > 0:
                if temp_streak == 0:
                    temp_start = date_obj
                temp_streak += 1
                # Update if this matches the longest streak (will get the most recent one)
                if temp_streak == longest_streak:
                    longest_streak_start = temp_start
                    longest_streak_end = date_obj
            else:
                temp_streak = 0
                temp_start = None

    # Format dates for display
    def format_date(date_obj, include_year=True):
        if date_obj is None:
            return "N/A"
        if include_year:
            return date_obj.strftime("%b %d, %Y")
        else:
            return date_obj.strftime("%b %d")

    # Calculate date ranges
    current_streak_end = most_recent_date if current_streak > 0 else None
    current_streak_date_str = f"{format_date(current_streak_start, include_year=False)} - {format_date(current_streak_end, include_year=False)}" if current_streak_start and current_streak_end else "N/A"

    longest_streak_end_date = None
    if longest_streak > 0 and longest_streak_start:
        # Calculate end date of longest streak
        temp_streak = 0
        for date_obj in sorted(contributions_by_date.keys()):
            if contributions_by_date[date_obj] > 0:
                temp_streak += 1
                if temp_streak == longest_streak and date_obj >= longest_streak_start:
                    longest_streak_end_date = date_obj
            else:
                temp_streak = 0

    longest_streak_date_str = f"{format_date(longest_streak_start, include_year=False)} - {format_date(longest_streak_end_date, include_year=True)}" if longest_streak_start and longest_streak_end_date else format_date(longest_streak_start) if longest_streak_start else "N/A"

    # Get earliest contribution date for total contributions range
    earliest_date_str = format_date(all_dates[0]) if all_dates else "N/A"
    total_contributions_date_str = f"{earliest_date_str} - Present"

    # Theme colors (matching image design)
    colors = {
        "bg": "#0d1117",
        "text": "#ff6e96",
        "text_yellow": "#ffd700",
        "text_blue": "#58a6ff",
        "date": "#58a6ff",
        "title": "#ff6e96"
    }

    # Generate SVG with 3 columns - matching reference design
    svg_width = 700
    svg_height = 200
    column_width = svg_width // 3
    column_center_x = [column_width // 2, column_width + column_width // 2, 2 * column_width + column_width // 2]
    content_y_start = 115

    svg = ET.Element("svg", {
        "width": str(svg_width),
        "height": str(svg_height),
        "xmlns": "http://www.w3.org/2000/svg"
    })

    # Background with subtle gradient effect
    bg = ET.SubElement(svg, "rect", {
        "width": str(svg_width),
        "height": str(svg_height),
        "fill": colors["bg"],
        "rx": "8"
    })

    # Title with better styling - positioned higher to avoid overlap
    title = ET.SubElement(svg, "text", {
        "x": str(svg_width // 2),
        "y": "35",
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "28",
        "font-weight": "700",
        "fill": colors["title"],
        "letter-spacing": "0.5"
    })
    title.text = "GitHub Streak"

    # Vertical dividers between columns
    divider1 = ET.SubElement(svg, "line", {
        "x1": str(column_width),
        "y1": str(content_y_start - 20),
        "x2": str(column_width),
        "y2": str(content_y_start + 80),
        "stroke": colors["text"],
        "stroke-width": "1",
        "opacity": "0.3"
    })

    divider2 = ET.SubElement(svg, "line", {
        "x1": str(2 * column_width),
        "y1": str(content_y_start - 20),
        "x2": str(2 * column_width),
        "y2": str(content_y_start + 80),
        "stroke": colors["text"],
        "stroke-width": "1",
        "opacity": "0.3"
    })

    # Column 1: Total Contributions (left)
    col1_x = column_center_x[0]

    total_value = ET.SubElement(svg, "text", {
        "x": str(col1_x),
        "y": str(content_y_start),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "48",
        "font-weight": "700",
        "fill": colors["text"]
    })
    total_value.text = f"{total_contributions:,}"

    total_label = ET.SubElement(svg, "text", {
        "x": str(col1_x),
        "y": str(content_y_start + 35),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "14",
        "fill": colors["text"],
        "font-weight": "500"
    })
    total_label.text = "Total Contributions"

    total_date = ET.SubElement(svg, "text", {
        "x": str(col1_x),
        "y": str(content_y_start + 55),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "11",
        "fill": colors["date"]
    })
    total_date.text = total_contributions_date_str

    # Column 2: Current Streak (middle) - with circular element and flame
    col2_x = column_center_x[1]
    # Align circle center with the visual center of numbers in other columns
    # For 48px font, visual center is approximately 20px above baseline
    circle_center_y = content_y_start - 20
    circle_radius = 35

    # Draw circle for current streak
    circle = ET.SubElement(svg, "circle", {
        "cx": str(col2_x),
        "cy": str(circle_center_y),
        "r": str(circle_radius),
        "fill": "none",
        "stroke": colors["text"],
        "stroke-width": "6"
    })

    # Draw flame icon (simplified SVG path)
    flame_path = f"M {col2_x} {circle_center_y - circle_radius - 8} L {col2_x - 4} {circle_center_y - circle_radius - 2} L {col2_x} {circle_center_y - circle_radius + 2} L {col2_x + 4} {circle_center_y - circle_radius - 2} Z"
    flame = ET.SubElement(svg, "path", {
        "d": flame_path,
        "fill": colors["text"]
    })

    # Number inside circle (yellow) - centered vertically
    streak_value = ET.SubElement(svg, "text", {
        "x": str(col2_x),
        "y": str(circle_center_y),
        "text-anchor": "middle",
        "dominant-baseline": "central",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "36",
        "font-weight": "700",
        "fill": colors["text_yellow"]
    })
    streak_value.text = f"{current_streak}"

    streak_label = ET.SubElement(svg, "text", {
        "x": str(col2_x),
        "y": str(circle_center_y + circle_radius + 28),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "14",
        "fill": colors["text_yellow"],
        "font-weight": "500"
    })
    streak_label.text = "Current Streak"

    streak_date = ET.SubElement(svg, "text", {
        "x": str(col2_x),
        "y": str(circle_center_y + circle_radius + 48),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "11",
        "fill": colors["date"]
    })
    streak_date.text = current_streak_date_str

    # Column 3: Longest Streak (right)
    col3_x = column_center_x[2]

    longest_value = ET.SubElement(svg, "text", {
        "x": str(col3_x),
        "y": str(content_y_start),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "48",
        "font-weight": "700",
        "fill": colors["text"]
    })
    longest_value.text = f"{longest_streak}"

    longest_label = ET.SubElement(svg, "text", {
        "x": str(col3_x),
        "y": str(content_y_start + 35),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "14",
        "fill": colors["text"],
        "font-weight": "500"
    })
    longest_label.text = "Longest Streak"

    longest_date = ET.SubElement(svg, "text", {
        "x": str(col3_x),
        "y": str(content_y_start + 55),
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "11",
        "fill": colors["date"]
    })
    longest_date.text = longest_streak_date_str

    # Save SVG
    tree = ET.ElementTree(svg)
    ET.indent(tree, space="  ")
    tree.write("streak-stats.svg", encoding="utf-8", xml_declaration=True)

    print(f"Generated streak stats: {current_streak} day streak, {longest_streak} longest, {total_contributions} total")

if __name__ == "__main__":
    main()

