#!/usr/bin/env python3
import xml.etree.ElementTree as ET

# Test data (matching the image)
languages_data = [
    ("Python", 90.61),
    ("Shell", 6.85),
    ("PowerShell", 2.54)
]

# Language colors (matching common GitHub language colors)
lang_colors = {
    "Python": "#3776ab",
    "Shell": "#89e051",
    "PowerShell": "#012456",
}

# Theme colors (matching image design)
colors = {
    "bg": "#0d1117",
    "bg_card": "#161b22",
    "title": "#ff6e96",
    "text": "#c9d1d9",
    "border": "#30363d"
}

# Generate SVG
svg_width = 495
svg_height = 195
bar_height = 10
bar_y = 60
bar_x_start = 20
bar_width = svg_width - 40
legend_y_start = 90
legend_item_height = 25

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
title.text = "Most Used Languages"

# Draw stacked bar
current_x = bar_x_start

for lang, percentage in languages_data:
    segment_width = (bar_width * percentage) / 100
    lang_color = lang_colors.get(lang, "#3776ab")
    
    segment = ET.SubElement(svg, "rect", {
        "x": str(current_x),
        "y": str(bar_y),
        "width": str(segment_width),
        "height": str(bar_height),
        "fill": lang_color,
        "rx": "2"
    })

    current_x += segment_width

# Draw legend
legend_x = bar_x_start
legend_y = legend_y_start
items_per_row = 3
item_width = bar_width / items_per_row

for idx, (lang, percentage) in enumerate(languages_data):
    x_pos = legend_x + (idx * item_width)
    y_pos = legend_y

    # Color dot
    lang_color = lang_colors.get(lang, "#3776ab")
    dot = ET.SubElement(svg, "circle", {
        "cx": str(x_pos + 6),
        "cy": str(y_pos + 6),
        "r": "5",
        "fill": lang_color
    })

    # Language name and percentage
    lang_text = ET.SubElement(svg, "text", {
        "x": str(x_pos + 18),
        "y": str(y_pos + 10),
        "font-family": "Segoe UI, -apple-system, BlinkMacSystemFont, sans-serif",
        "font-size": "12",
        "fill": colors["text"]
    })
    lang_text.text = f"{lang} {percentage:.2f}%"

# Save SVG
tree = ET.ElementTree(svg)
ET.indent(tree, space="  ")
tree.write("test-languages-stats.svg", encoding="utf-8", xml_declaration=True)
tree.write("languages-stats.svg", encoding="utf-8", xml_declaration=True)

print("Generated test-languages-stats.svg and languages-stats.svg")
for lang, pct in languages_data:
    print(f"  {lang}: {pct:.2f}%")

