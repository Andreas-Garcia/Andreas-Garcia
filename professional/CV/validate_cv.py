#!/usr/bin/env python3
"""
CV Validation Script

Validates CV format according to cv_format_spec.md:
- Intro section: 570-580 characters (excluding all links in parentheses, including project links and FAIR links)
- Bullet points: ~95 characters each (excluding all links in parentheses, including project links and FAIR links)
"""

import re
import sys
from pathlib import Path


def extract_intro_section(lines):
    """Extract the intro section (2 paragraphs after title)."""
    # Find the title line (first non-empty line)
    title_idx = 0
    for i, line in enumerate(lines):
        if line.strip():
            title_idx = i
            break
    
    # Intro paragraphs are typically at index title_idx + 2 and title_idx + 4
    # (accounting for empty lines)
    para1_idx = title_idx + 2
    para2_idx = title_idx + 4
    
    if para1_idx < len(lines) and para2_idx < len(lines):
        return lines[para1_idx], lines[para2_idx]
    return None, None


def extract_bullet_points(lines):
    """Extract all bullet points from job experiences section."""
    bullet_points = []
    in_experience_section = False
    current_experience = None
    
    for i, line in enumerate(lines):
        # Check if we're entering an experience section
        if line.startswith('### [ICON]'):
            in_experience_section = True
            current_experience = line
            continue
        
        # Check if we're leaving an experience section
        if in_experience_section and (line.startswith('###') or line.startswith('Links:') or line.startswith('More Info:')):
            in_experience_section = False
            current_experience = None
            continue
        
        # Collect bullet points (non-empty lines that aren't dates or section headers)
        if in_experience_section and line.strip():
            # Skip date lines (they typically contain "–" or "|")
            if '–' in line or '|' in line or line.startswith('Déc.') or line.startswith('Oct.'):
                continue
            # Skip empty lines
            if not line.strip():
                continue
            bullet_points.append(line)
    
    return bullet_points


def remove_links(text):
    """Remove all links in parentheses from text (including project links and FAIR links)."""
    return re.sub(r'\s*\(https://[^)]+\)', '', text)


def validate_cv(cv_path):
    """Validate CV format and return results."""
    with open(cv_path, 'r', encoding='utf-8') as f:
        lines = f.read().split('\n')
    
    errors = []
    warnings = []
    
    # Validate intro section
    para1, para2 = extract_intro_section(lines)
    if para1 and para2:
        para1_no_links = remove_links(para1)
        para2_no_links = remove_links(para2)
        total_intro = len(para1_no_links) + len(para2_no_links)
        
        if not (570 <= total_intro <= 580):
            errors.append(
                f"Intro section: {total_intro} characters (target: 570-580) - "
                f"Off by {abs(total_intro - 575)} characters"
            )
    else:
        errors.append("Could not find intro section (2 paragraphs)")
    
    # Validate bullet points
    bullet_points = extract_bullet_points(lines)
    if not bullet_points:
        warnings.append("No bullet points found in job experiences section")
    else:
        for i, bp in enumerate(bullet_points, 1):
            bp_no_links = remove_links(bp)
            length = len(bp_no_links)
            if not (85 <= length <= 105):
                errors.append(
                    f"Bullet point {i}: {length} characters (target: 85-105) - "
                    f"Off by {abs(length - 95)} characters"
                )
    
    return errors, warnings


def main():
    """Main validation function."""
    if len(sys.argv) < 2:
        print("Usage: validate_cv.py <cv_file_path>")
        sys.exit(1)
    
    cv_path = Path(sys.argv[1])
    if not cv_path.exists():
        print(f"Error: File not found: {cv_path}")
        sys.exit(1)
    
    errors, warnings = validate_cv(cv_path)
    
    if warnings:
        for warning in warnings:
            print(f"⚠️  {warning}")
        print()
    
    if errors:
        print("❌ Validation FAILED:")
        for error in errors:
            print(f"  • {error}")
        sys.exit(1)
    else:
        print("✅ Validation PASSED")
        sys.exit(0)


if __name__ == '__main__':
    main()
