#!/usr/bin/env python3
from datetime import datetime, timedelta
import xml.etree.ElementTree as ET

# Test values
current_streak = 14
longest_streak = 19
total_contributions = 7446

# Test dates
today = datetime.now().date()
current_streak_start = today - timedelta(days=current_streak - 1)
most_recent_date = today
longest_streak_start = datetime(2024, 5, 21).date()
longest_streak_end = datetime(2024, 6, 8).date()
earliest_date = datetime(2020, 11, 22).date()

# Format dates for display
def format_date(date_obj, include_year=True):
    if date_obj is None:
        return "N/A"
    if include_year:
        return date_obj.strftime("%b %d, %Y")
    else:
        return date_obj.strftime("%b %d")

# Calculate date ranges
current_streak_date_str = f"{format_date(current_streak_start, include_year=False)} - {format_date(most_recent_date, include_year=False)}"
longest_streak_date_str = f"{format_date(longest_streak_start, include_year=False)} - {format_date(longest_streak_end, include_year=True)}"
earliest_date_str = format_date(earliest_date)
total_contributions_date_str = f"{earliest_date_str} - Present"

# Theme colors (GitHub design)
colors = {
    "bg": "#0d1117",
    "text": "#c9d1d9",
    "text_yellow": "#238636",
    "text_blue": "#58a6ff",
    "date": "#8b949e",
    "title": "#c9d1d9"
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

# Background
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
    "y": str(circle_center_y + circle_radius + 20),
    "text-anchor": "middle",
    "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
    "font-size": "14",
    "fill": colors["text_yellow"],
    "font-weight": "500"
})
streak_label.text = "Current Streak"

streak_date = ET.SubElement(svg, "text", {
    "x": str(col2_x),
    "y": str(circle_center_y + circle_radius + 40),
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
tree.write("test-streak-stats.svg", encoding="utf-8", xml_declaration=True)

print("Generated test-streak-stats.svg")
print(f"Current Streak: {current_streak}")
print(f"Longest Streak: {longest_streak}")
print(f"Total Contributions: {total_contributions:,}")

