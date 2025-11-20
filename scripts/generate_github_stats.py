#!/usr/bin/env python3
"""
Generate GitHub Stats SVG
Fetches user statistics from GitHub API and generates an SVG card similar to github-readme-stats.
"""
import os
import sys
import requests
from datetime import datetime, timedelta
import xml.etree.ElementTree as ET

def format_number(num):
    """Format number with K, M suffixes"""
    if num >= 1_000_000:
        return f"{num / 1_000_000:.1f}M"
    elif num >= 1_000:
        return f"{num / 1_000:.1f}K"
    return str(num)

def get_user_stats(username, token):
    """Fetch user statistics using GitHub GraphQL API"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v4+json"
    }
    
    # Calculate date range (all time)
    now = datetime.now()
    start_date = datetime(2010, 1, 1)  # GitHub started around 2008, but use 2010 as safe start
    
    # Query to get user stats
    query = """
    query($username: String!, $from: DateTime!, $to: DateTime!) {
      user(login: $username) {
        starredRepositories {
          totalCount
        }
        repositories(ownerAffiliations: OWNER, isFork: false) {
          totalCount
        }
        contributionsCollection(from: $from, to: $to) {
          totalCommitContributions
          totalIssueContributions
          totalPullRequestContributions
          totalPullRequestReviewContributions
          totalRepositoryContributions
          restrictedContributionsCount
        }
      }
    }
    """
    
    try:
        response = requests.post(
            "https://api.github.com/graphql",
            json={
                "query": query,
                "variables": {
                    "username": username,
                    "from": start_date.isoformat() + "Z",
                    "to": now.isoformat() + "Z"
                }
            },
            headers=headers
        )
        response.raise_for_status()
        data = response.json()
        
        if "errors" in data:
            print(f"GraphQL errors: {data['errors']}")
            return None
        
        if "data" not in data or "user" not in data["data"]:
            print("No user data found")
            return None
        
        user_data = data["data"]["user"]
        contributions = user_data["contributionsCollection"]
        
        # Calculate total stars (stars given to repositories)
        total_stars = user_data["starredRepositories"]["totalCount"]
        
        # Calculate total commits (including restricted/private)
        total_commits = contributions["totalCommitContributions"] + contributions.get("restrictedContributionsCount", 0)
        
        # Calculate total PRs
        total_prs = contributions["totalPullRequestContributions"]
        
        # Calculate total issues
        total_issues = contributions["totalIssueContributions"]
        
        # Calculate total contributions (all types)
        total_contributions = (
            contributions["totalCommitContributions"] +
            contributions["totalIssueContributions"] +
            contributions["totalPullRequestContributions"] +
            contributions["totalPullRequestReviewContributions"] +
            contributions.get("restrictedContributionsCount", 0)
        )
        
        return {
            "stars": total_stars,
            "commits": total_commits,
            "prs": total_prs,
            "issues": total_issues,
            "contributions": total_contributions
        }
    except Exception as e:
        print(f"Error fetching stats: {e}")
        return None

def get_total_stars_received(username, token):
    """Get total stars received across all repositories"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    total_stars = 0
    page = 1
    per_page = 100
    
    while True:
        try:
            response = requests.get(
                f"https://api.github.com/users/{username}/repos?per_page={per_page}&page={page}&type=all",
                headers=headers
            )
            response.raise_for_status()
            repos = response.json()
            
            if not repos:
                break
            
            for repo in repos:
                if not repo.get("fork"):
                    total_stars += repo.get("stargazers_count", 0)
            
            page += 1
            if len(repos) < per_page:
                break
        except Exception as e:
            print(f"Error fetching repositories: {e}")
            break
    
    return total_stars

def main():
    username = os.environ.get("GITHUB_USERNAME", "Andreas-Garcia")
    token = os.environ.get("GH_PAT") or os.environ.get("GITHUB_TOKEN")
    
    if not token:
        print("Error: No GitHub token found. Set GH_PAT or GITHUB_TOKEN environment variable.")
        sys.exit(1)
    
    print(f"Fetching GitHub stats for {username}...")
    
    # Get stats from GraphQL
    stats = get_user_stats(username, token)
    
    if not stats:
        print("Failed to fetch stats from GraphQL, trying REST API...")
        stats = {
            "stars": 0,
            "commits": 0,
            "prs": 0,
            "issues": 0,
            "contributions": 0
        }
    
    # Get total stars received (this requires REST API)
    print("Fetching total stars received...")
    total_stars_received = get_total_stars_received(username, token)
    stats["stars"] = total_stars_received
    
    print(f"Stats: {stats}")
    
    # Theme colors (matching radical theme)
    colors = {
        "bg": "#0d1117",
        "bg_card": "#161b22",
        "title": "#ff6e96",
        "text": "#c9d1d9",
        "icon": "#ff6e96",
        "border": "#30363d",
        "rank": "#58a6ff"
    }
    
    # Generate SVG
    svg_width = 495
    svg_height = 195
    
    svg = ET.Element("svg", {
        "width": str(svg_width),
        "height": str(svg_height),
        "xmlns": "http://www.w3.org/2000/svg"
    })
    
    # Background
    bg = ET.SubElement(svg, "rect", {
        "width": str(svg_width),
        "height": str(svg_height),
        "fill": colors["bg"],
        "rx": "8"
    })
    
    # Card background
    card = ET.SubElement(svg, "rect", {
        "x": "10",
        "y": "10",
        "width": str(svg_width - 20),
        "height": str(svg_height - 20),
        "fill": colors["bg_card"],
        "rx": "6",
        "stroke": colors["border"],
        "stroke-width": "1"
    })
    
    # Title
    title = ET.SubElement(svg, "text", {
        "x": str(svg_width // 2),
        "y": "35",
        "text-anchor": "middle",
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "18",
        "font-weight": "700",
        "fill": colors["title"]
    })
    title.text = f"{username}'s GitHub Stats"
    
    # Stats layout: 2 rows, 2 columns (matching github-readme-stats layout)
    stats_data = [
        ("Total Stars", stats["stars"], "⭐"),
        ("Total Commits", stats["commits"], "📝"),
        ("Total PRs", stats["prs"], "🔀"),
        ("Total Issues", stats["issues"], "🐛")
    ]
    
    # Layout configuration
    padding = 25
    start_y = 65
    item_width = (svg_width - 2 * padding) // 2
    item_height = 55
    spacing_x = 15
    spacing_y = 10
    
    for idx, (label, value, icon) in enumerate(stats_data):
        row = idx // 2
        col = idx % 2
        
        x = padding + col * (item_width + spacing_x)
        y = start_y + row * (item_height + spacing_y)
        
        # Icon (using emoji as text)
        icon_text = ET.SubElement(svg, "text", {
            "x": str(x + 5),
            "y": str(y + 25),
            "font-family": "Segoe UI Emoji, Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
            "font-size": "20",
            "fill": colors["icon"]
        })
        icon_text.text = icon
        
        # Label
        label_text = ET.SubElement(svg, "text", {
            "x": str(x + 35),
            "y": str(y + 20),
            "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
            "font-size": "12",
            "fill": colors["text"]
        })
        label_text.text = label
        
        # Value
        value_text = ET.SubElement(svg, "text", {
            "x": str(x + 35),
            "y": str(y + 40),
            "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
            "font-size": "22",
            "font-weight": "700",
            "fill": colors["title"]
        })
        value_text.text = format_number(value)
    
    # Save SVG
    tree = ET.ElementTree(svg)
    ET.indent(tree, space="  ")
    tree.write("github-stats.svg", encoding="utf-8", xml_declaration=True)
    
    print(f"\n=== Summary ===")
    print(f"Stars: {stats['stars']}")
    print(f"Commits: {stats['commits']}")
    print(f"PRs: {stats['prs']}")
    print(f"Issues: {stats['issues']}")
    print(f"Total Contributions: {stats['contributions']}")
    print(f"Generated github-stats.svg")

if __name__ == "__main__":
    main()

