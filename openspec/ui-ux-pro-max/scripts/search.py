#!/usr/bin/env python3
"""
UI UX Pro Max - Design System Generator
Generates intelligent design systems based on project requirements.

Usage:
    python search.py "<query>" --design-system -p "<project-name>"
    python search.py "<query>" --design-system --persist -p "<project-name>"
    python search.py "<query>" --domain style
    python search.py "<query>" --domain colors
    python search.py "<query>" --domain typography
"""

import argparse
import csv
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from datetime import datetime


@dataclass
class Style:
    id: int
    name: str
    keywords: str
    best_for: str
    performance: str
    accessibility: str


@dataclass
class ColorPalette:
    id: int
    name: str
    industry: str
    primary: str
    secondary: str
    cta: str
    background: str
    text: str
    mood: str


@dataclass
class Typography:
    id: int
    heading_font: str
    body_font: str
    mood: str
    best_for: str
    google_fonts_url: str


@dataclass
class ReasoningRule:
    id: int
    product_type: str
    keywords: str
    recommended_pattern: str
    style_priority: str
    color_mood: str
    typography_mood: str
    key_effects: str
    anti_patterns: str


class DesignSystemGenerator:
    def __init__(self, data_dir: str):
        self.data_dir = Path(data_dir)
        self.styles: List[Style] = []
        self.colors: List[ColorPalette] = []
        self.typography: List[Typography] = []
        self.reasoning: List[ReasoningRule] = []
        self._load_data()

    def _load_data(self):
        """Load all CSV data files."""
        # Load styles
        styles_file = self.data_dir / "styles.csv"
        if styles_file.exists():
            with open(styles_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.styles.append(Style(
                        id=int(row["id"]),
                        name=row["name"],
                        keywords=row["keywords"],
                        best_for=row["best_for"],
                        performance=row["performance"],
                        accessibility=row["accessibility"]
                    ))

        # Load colors
        colors_file = self.data_dir / "colors.csv"
        if colors_file.exists():
            with open(colors_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.colors.append(ColorPalette(
                        id=int(row["id"]),
                        name=row["name"],
                        industry=row["industry"],
                        primary=row["primary"],
                        secondary=row["secondary"],
                        cta=row["cta"],
                        background=row["background"],
                        text=row["text"],
                        mood=row["mood"]
                    ))

        # Load typography
        typography_file = self.data_dir / "typography.csv"
        if typography_file.exists():
            with open(typography_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.typography.append(Typography(
                        id=int(row["id"]),
                        heading_font=row["heading_font"],
                        body_font=row["body_font"],
                        mood=row["mood"],
                        best_for=row["best_for"],
                        google_fonts_url=row["google_fonts_url"]
                    ))

        # Load reasoning rules
        reasoning_file = self.data_dir / "reasoning.csv"
        if reasoning_file.exists():
            with open(reasoning_file, "r", encoding="utf-8") as f:
                reader = csv.DictReader(f)
                for row in reader:
                    self.reasoning.append(ReasoningRule(
                        id=int(row["id"]),
                        product_type=row["product_type"],
                        keywords=row["keywords"],
                        recommended_pattern=row["recommended_pattern"],
                        style_priority=row["style_priority"],
                        color_mood=row["color_mood"],
                        typography_mood=row["typography_mood"],
                        key_effects=row["key_effects"],
                        anti_patterns=row["anti_patterns"]
                    ))

    def _calculate_relevance(self, query: str, text: str) -> float:
        """Simple BM25-like relevance scoring."""
        query_terms = query.lower().split()
        text_lower = text.lower()
        score = 0.0
        for term in query_terms:
            if term in text_lower:
                score += 1.0
                # Bonus for exact word match
                if f" {term} " in f" {text_lower} " or text_lower.startswith(term) or text_lower.endswith(term):
                    score += 0.5
        return score

    def find_reasoning_rule(self, query: str) -> Optional[ReasoningRule]:
        """Find the best matching reasoning rule for the query."""
        best_match = None
        best_score = 0.0
        
        for rule in self.reasoning:
            score = self._calculate_relevance(query, rule.keywords)
            score += self._calculate_relevance(query, rule.product_type)
            if score > best_score:
                best_score = score
                best_match = rule
        
        return best_match

    def find_style(self, style_name: str) -> Optional[Style]:
        """Find a style by name."""
        for style in self.styles:
            if style_name.lower() in style.name.lower():
                return style
        return None

    def find_colors(self, mood: str, industry: str = "") -> Optional[ColorPalette]:
        """Find colors matching mood and industry."""
        best_match = None
        best_score = 0.0
        
        for color in self.colors:
            score = self._calculate_relevance(mood, color.mood)
            if industry:
                score += self._calculate_relevance(industry, color.industry) * 2
            if score > best_score:
                best_score = score
                best_match = color
        
        return best_match

    def find_typography(self, mood: str) -> Optional[Typography]:
        """Find typography matching mood."""
        best_match = None
        best_score = 0.0
        
        for typo in self.typography:
            score = self._calculate_relevance(mood, typo.mood)
            score += self._calculate_relevance(mood, typo.best_for)
            if score > best_score:
                best_score = score
                best_match = typo
        
        return best_match

    def generate_design_system(self, query: str, project_name: str) -> Dict:
        """Generate a complete design system based on query."""
        # Find matching reasoning rule
        rule = self.find_reasoning_rule(query)
        
        if not rule:
            # Default to SaaS if no match
            rule = self.reasoning[0] if self.reasoning else None
        
        if not rule:
            return {"error": "No matching design system found"}
        
        # Get primary style
        primary_style_name = rule.style_priority.split(";")[0].strip()
        style = self.find_style(primary_style_name)
        
        # Get colors
        colors = self.find_colors(rule.color_mood, rule.product_type)
        
        # Get typography
        typography = self.find_typography(rule.typography_mood)
        
        return {
            "project_name": project_name,
            "product_type": rule.product_type,
            "pattern": rule.recommended_pattern,
            "style": {
                "name": style.name if style else primary_style_name,
                "keywords": style.keywords if style else "",
                "best_for": style.best_for if style else "",
                "performance": style.performance if style else "Good",
                "accessibility": style.accessibility if style else "WCAG AA"
            },
            "colors": {
                "name": colors.name if colors else "Default",
                "primary": colors.primary if colors else "#4F46E5",
                "secondary": colors.secondary if colors else "#818CF8",
                "cta": colors.cta if colors else "#10B981",
                "background": colors.background if colors else "#F9FAFB",
                "text": colors.text if colors else "#111827",
                "mood": colors.mood if colors else rule.color_mood
            },
            "typography": {
                "heading": typography.heading_font if typography else "Inter",
                "body": typography.body_font if typography else "Inter",
                "mood": typography.mood if typography else rule.typography_mood,
                "google_fonts_url": typography.google_fonts_url if typography else ""
            },
            "key_effects": rule.key_effects,
            "anti_patterns": rule.anti_patterns
        }

    def format_ascii(self, ds: Dict) -> str:
        """Format design system as ASCII art."""
        width = 90
        
        lines = []
        lines.append("+" + "-" * (width - 2) + "+")
        lines.append(f"|  TARGET: {ds['project_name']} - RECOMMENDED DESIGN SYSTEM".ljust(width - 1) + "|")
        lines.append("+" + "-" * (width - 2) + "+")
        lines.append("|".ljust(width - 1) + "|")
        
        # Pattern
        lines.append(f"|  PATTERN: {ds['pattern']}".ljust(width - 1) + "|")
        lines.append(f"|     Product Type: {ds['product_type']}".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Style
        lines.append(f"|  STYLE: {ds['style']['name']}".ljust(width - 1) + "|")
        lines.append(f"|     Keywords: {ds['style']['keywords'][:60]}...".ljust(width - 1) + "|")
        lines.append(f"|     Best For: {ds['style']['best_for'][:60]}...".ljust(width - 1) + "|")
        lines.append(f"|     Performance: {ds['style']['performance']} | Accessibility: {ds['style']['accessibility']}".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Colors
        lines.append("|  COLORS:".ljust(width - 1) + "|")
        lines.append(f"|     Primary:    {ds['colors']['primary']}".ljust(width - 1) + "|")
        lines.append(f"|     Secondary:  {ds['colors']['secondary']}".ljust(width - 1) + "|")
        lines.append(f"|     CTA:        {ds['colors']['cta']}".ljust(width - 1) + "|")
        lines.append(f"|     Background: {ds['colors']['background']}".ljust(width - 1) + "|")
        lines.append(f"|     Text:       {ds['colors']['text']}".ljust(width - 1) + "|")
        lines.append(f"|     Mood: {ds['colors']['mood']}".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Typography
        lines.append(f"|  TYPOGRAPHY: {ds['typography']['heading']} / {ds['typography']['body']}".ljust(width - 1) + "|")
        lines.append(f"|     Mood: {ds['typography']['mood']}".ljust(width - 1) + "|")
        if ds['typography']['google_fonts_url']:
            lines.append(f"|     Google Fonts: {ds['typography']['google_fonts_url'][:60]}...".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Key Effects
        lines.append("|  KEY EFFECTS:".ljust(width - 1) + "|")
        lines.append(f"|     {ds['key_effects'][:75]}".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Anti-Patterns
        lines.append("|  AVOID (Anti-patterns):".ljust(width - 1) + "|")
        lines.append(f"|     {ds['anti_patterns'][:75]}".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        # Checklist
        lines.append("|  PRE-DELIVERY CHECKLIST:".ljust(width - 1) + "|")
        lines.append("|     [ ] No emojis as icons (use SVG: Heroicons/Lucide)".ljust(width - 1) + "|")
        lines.append("|     [ ] cursor-pointer on all clickable elements".ljust(width - 1) + "|")
        lines.append("|     [ ] Hover states with smooth transitions (150-300ms)".ljust(width - 1) + "|")
        lines.append("|     [ ] Light mode: text contrast 4.5:1 minimum".ljust(width - 1) + "|")
        lines.append("|     [ ] Focus states visible for keyboard nav".ljust(width - 1) + "|")
        lines.append("|     [ ] prefers-reduced-motion respected".ljust(width - 1) + "|")
        lines.append("|     [ ] Responsive: 375px, 768px, 1024px, 1440px".ljust(width - 1) + "|")
        lines.append("|".ljust(width - 1) + "|")
        
        lines.append("+" + "-" * (width - 2) + "+")
        
        return "\n".join(lines)

    def format_markdown(self, ds: Dict) -> str:
        """Format design system as Markdown."""
        lines = []
        lines.append(f"# Design System: {ds['project_name']}")
        lines.append("")
        lines.append(f"> Generated by ui-ux-pro-max | {datetime.now().strftime('%Y-%m-%d')}")
        lines.append("")
        
        lines.append("## Overview")
        lines.append("")
        lines.append(f"- **Product Type**: {ds['product_type']}")
        lines.append(f"- **Recommended Pattern**: {ds['pattern']}")
        lines.append("")
        
        lines.append("## UI Style")
        lines.append("")
        lines.append(f"**{ds['style']['name']}**")
        lines.append("")
        lines.append(f"- **Keywords**: {ds['style']['keywords']}")
        lines.append(f"- **Best For**: {ds['style']['best_for']}")
        lines.append(f"- **Performance**: {ds['style']['performance']}")
        lines.append(f"- **Accessibility**: {ds['style']['accessibility']}")
        lines.append("")
        
        lines.append("## Color Palette")
        lines.append("")
        lines.append(f"**{ds['colors']['name']}** - {ds['colors']['mood']}")
        lines.append("")
        lines.append("| Token | Hex | Usage |")
        lines.append("|-------|-----|-------|")
        lines.append(f"| Primary | `{ds['colors']['primary']}` | Main brand color, primary actions |")
        lines.append(f"| Secondary | `{ds['colors']['secondary']}` | Supporting elements, secondary actions |")
        lines.append(f"| CTA | `{ds['colors']['cta']}` | Call-to-action buttons, success states |")
        lines.append(f"| Background | `{ds['colors']['background']}` | Page background, cards |")
        lines.append(f"| Text | `{ds['colors']['text']}` | Primary text color |")
        lines.append("")
        
        lines.append("### CSS Variables")
        lines.append("")
        lines.append("```css")
        lines.append(":root {")
        lines.append(f"  --color-primary: {ds['colors']['primary']};")
        lines.append(f"  --color-secondary: {ds['colors']['secondary']};")
        lines.append(f"  --color-cta: {ds['colors']['cta']};")
        lines.append(f"  --color-background: {ds['colors']['background']};")
        lines.append(f"  --color-text: {ds['colors']['text']};")
        lines.append("}")
        lines.append("```")
        lines.append("")
        
        lines.append("## Typography")
        lines.append("")
        lines.append(f"**{ds['typography']['heading']} / {ds['typography']['body']}**")
        lines.append("")
        lines.append(f"- **Mood**: {ds['typography']['mood']}")
        if ds['typography']['google_fonts_url']:
            lines.append(f"- **Google Fonts**: [{ds['typography']['heading']}]({ds['typography']['google_fonts_url']})")
        lines.append("")
        
        lines.append("### Font Import")
        lines.append("")
        lines.append("```html")
        lines.append(f'<link rel="preconnect" href="https://fonts.googleapis.com">')
        lines.append(f'<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>')
        lines.append(f'<link href="{ds["typography"]["google_fonts_url"]}" rel="stylesheet">')
        lines.append("```")
        lines.append("")
        
        lines.append("### CSS")
        lines.append("")
        lines.append("```css")
        lines.append(":root {")
        lines.append(f"  --font-heading: '{ds['typography']['heading']}', sans-serif;")
        lines.append(f"  --font-body: '{ds['typography']['body']}', sans-serif;")
        lines.append("}")
        lines.append("")
        lines.append("h1, h2, h3, h4, h5, h6 {")
        lines.append("  font-family: var(--font-heading);")
        lines.append("}")
        lines.append("")
        lines.append("body {")
        lines.append("  font-family: var(--font-body);")
        lines.append("}")
        lines.append("```")
        lines.append("")
        
        lines.append("## Key Effects")
        lines.append("")
        lines.append(f"{ds['key_effects']}")
        lines.append("")
        lines.append("```css")
        lines.append("/* Recommended transition */")
        lines.append(".interactive {")
        lines.append("  transition: all 200ms ease-in-out;")
        lines.append("}")
        lines.append("")
        lines.append(".interactive:hover {")
        lines.append("  transform: translateY(-2px);")
        lines.append("}")
        lines.append("```")
        lines.append("")
        
        lines.append("## Anti-Patterns (Avoid)")
        lines.append("")
        for pattern in ds['anti_patterns'].split(";"):
            lines.append(f"- {pattern.strip()}")
        lines.append("")
        
        lines.append("## Pre-Delivery Checklist")
        lines.append("")
        lines.append("- [ ] No emojis as icons (use SVG: Heroicons/Lucide)")
        lines.append("- [ ] `cursor-pointer` on all clickable elements")
        lines.append("- [ ] Hover states with smooth transitions (150-300ms)")
        lines.append("- [ ] Light mode: text contrast 4.5:1 minimum")
        lines.append("- [ ] Focus states visible for keyboard navigation")
        lines.append("- [ ] `prefers-reduced-motion` respected")
        lines.append("- [ ] Responsive breakpoints: 375px, 768px, 1024px, 1440px")
        lines.append("")
        
        return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="UI UX Pro Max - Design System Generator")
    parser.add_argument("query", help="Search query (e.g., 'beauty spa wellness')")
    parser.add_argument("--design-system", action="store_true", help="Generate full design system")
    parser.add_argument("-p", "--project", default="MyProject", help="Project name")
    parser.add_argument("-f", "--format", choices=["ascii", "markdown"], default="ascii", help="Output format")
    parser.add_argument("--persist", action="store_true", help="Save to design-system/MASTER.md")
    parser.add_argument("--domain", choices=["style", "colors", "typography", "reasoning"], help="Search specific domain")
    
    args = parser.parse_args()
    
    # Find data directory
    script_dir = Path(__file__).parent
    data_dir = script_dir.parent / "data"
    
    if not data_dir.exists():
        print(f"Error: Data directory not found at {data_dir}", file=sys.stderr)
        sys.exit(1)
    
    generator = DesignSystemGenerator(str(data_dir))
    
    if args.design_system:
        ds = generator.generate_design_system(args.query, args.project)
        
        if "error" in ds:
            print(f"Error: {ds['error']}", file=sys.stderr)
            sys.exit(1)
        
        if args.format == "markdown":
            output = generator.format_markdown(ds)
        else:
            output = generator.format_ascii(ds)
        
        print(output)
        
        if args.persist:
            # Create design-system directory
            output_dir = Path.cwd() / "design-system"
            output_dir.mkdir(exist_ok=True)
            
            # Write MASTER.md
            master_file = output_dir / "MASTER.md"
            with open(master_file, "w", encoding="utf-8") as f:
                f.write(generator.format_markdown(ds))
            
            print(f"\n✓ Design system saved to {master_file}")
    
    elif args.domain:
        # Domain-specific search
        if args.domain == "style":
            for style in generator.styles:
                if generator._calculate_relevance(args.query, f"{style.name} {style.keywords}") > 0:
                    print(f"{style.name}: {style.keywords[:60]}... ({style.accessibility})")
        elif args.domain == "colors":
            for color in generator.colors:
                if generator._calculate_relevance(args.query, f"{color.industry} {color.mood}") > 0:
                    print(f"{color.name} ({color.industry}): {color.primary} | {color.mood}")
        elif args.domain == "typography":
            for typo in generator.typography:
                if generator._calculate_relevance(args.query, f"{typo.mood} {typo.best_for}") > 0:
                    print(f"{typo.heading_font}/{typo.body_font}: {typo.mood}")
        elif args.domain == "reasoning":
            for rule in generator.reasoning:
                if generator._calculate_relevance(args.query, f"{rule.product_type} {rule.keywords}") > 0:
                    print(f"{rule.product_type}: {rule.recommended_pattern}")
    
    else:
        # Default: show design system
        ds = generator.generate_design_system(args.query, args.project)
        if "error" not in ds:
            print(generator.format_ascii(ds))


if __name__ == "__main__":
    main()
