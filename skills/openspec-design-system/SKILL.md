---
name: openspec-design-system
description: Generate a design system using ui-ux-pro-max. Use when creating frontend UI, generating design.md, or when user requests design system recommendations for their project.
license: MIT
compatibility: Requires Python 3.x
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.0.2"
---

Generate a design system based on project requirements using the ui-ux-pro-max reasoning engine.

**Input**: Project description, industry/product type, or keywords. Can be extracted from proposal.md if available.

**When to Use**:
- Before creating `design.md` (auto-triggered in Phase 2)
- When user asks for UI/UX recommendations
- When starting frontend development
- When user wants to update the design system

**Steps**

1. **Extract project context**

   If a change is active, read `proposal.md` to extract:
   - Project name (from change name or proposal title)
   - Product type/industry (from background, goals, or user stories)
   - Target audience
   - Key requirements

   If no change is active, ask the user:
   > "What type of product are you building? (e.g., SaaS dashboard, e-commerce, healthcare app)"

2. **Generate design system**

   Run the design system generator:
   ```bash
   python3 openspec/ui-ux-pro-max/scripts/search.py "<product-type-keywords>" --design-system --persist -p "<project-name>" -f markdown
   ```

   Example:
   ```bash
   python3 openspec/ui-ux-pro-max/scripts/search.py "beauty spa wellness" --design-system --persist -p "SerenitySpaMaster"
   ```

3. **Verify output**

   Check that `design-system/MASTER.md` was created:
   ```bash
   ls -la design-system/
   ```

4. **Show summary**

   Display key information from the generated design system:
   - Recommended UI style
   - Color palette (primary, secondary, CTA)
   - Typography pairing
   - Key effects to apply
   - Anti-patterns to avoid

**Output**

After completion, show:
```
## Design System Generated

**Project:** <project-name>
**Output:** design-system/MASTER.md

### Quick Reference
- **Style:** <style-name>
- **Colors:** Primary <hex> | Secondary <hex> | CTA <hex>
- **Typography:** <heading-font> / <body-font>
- **Key Effects:** <effects>

### Anti-Patterns (Avoid)
- <list of things to avoid>

Design system saved. Reference it in design.md or when implementing frontend components.
```

**Example Queries**

The generator understands these product types:
- SaaS, Micro SaaS, B2B Enterprise, Developer Tools
- AI/Chatbot Platform, Fintech/Banking, Healthcare
- E-commerce, Beauty/Spa, Restaurant, Real Estate
- Education, Gaming, Legal, Startup, Creative Agency
- Portfolio, Mental Health, Fitness, Travel

**Domain-Specific Search**

For targeted searches:
```bash
# Search UI styles
python3 openspec/ui-ux-pro-max/scripts/search.py "glassmorphism" --domain style

# Search color palettes
python3 openspec/ui-ux-pro-max/scripts/search.py "healthcare" --domain colors

# Search typography
python3 openspec/ui-ux-pro-max/scripts/search.py "elegant serif" --domain typography

# Search reasoning rules
python3 openspec/ui-ux-pro-max/scripts/search.py "fintech" --domain reasoning
```

**Guardrails**

- Always persist the design system to `design-system/MASTER.md`
- If project type is unclear, ask before generating
- Include the design system reference in `design.md` after generation
- Do not modify existing design systems without user confirmation
- If multiple industries apply, prioritize the primary business focus

**Integration with OpenSpec Workflow**

This skill is automatically invoked during Phase 2 (Design) when:
1. `openspec-continue-change` creates the `design` artifact
2. No `design-system/MASTER.md` exists yet

The generated design system is then referenced in the Design System Reference section of `design.md`.
