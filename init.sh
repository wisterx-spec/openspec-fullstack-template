#!/bin/bash
# OpenSpec Fullstack Template - Initialization Script
# Usage: ./init.sh <project_name> <target_directory>

set -e

PROJECT_NAME="${1:-MyProject}"
TARGET_DIR="${2:-.}"

echo "Initializing OpenSpec for: $PROJECT_NAME"
echo "Target directory: $TARGET_DIR"

# Create directories
mkdir -p "$TARGET_DIR/openspec/"{schemas,templates,context,specs,changes}
mkdir -p "$TARGET_DIR/.cursor/skills"

# Copy core files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cp "$SCRIPT_DIR/openspec/config.yaml" "$TARGET_DIR/openspec/"
cp "$SCRIPT_DIR/openspec/schemas/workflow.yaml" "$TARGET_DIR/openspec/schemas/"
cp "$SCRIPT_DIR/openspec/templates/"*.hbs "$TARGET_DIR/openspec/templates/"

# Create context files from templates
sed "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" \
    "$SCRIPT_DIR/openspec/context/project_summary.template.md" \
    > "$TARGET_DIR/openspec/context/project_summary.md"

cp "$SCRIPT_DIR/openspec/context/tech_stack.template.md" \
   "$TARGET_DIR/openspec/context/tech_stack.md"

# Update config with project name
sed -i '' "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" "$TARGET_DIR/openspec/config.yaml" 2>/dev/null || \
sed -i "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" "$TARGET_DIR/openspec/config.yaml"

# Copy skills
cp -r "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.cursor/skills/"

# Create .gitkeep files
touch "$TARGET_DIR/openspec/specs/.gitkeep"
touch "$TARGET_DIR/openspec/changes/.gitkeep"

echo ""
echo "✅ OpenSpec initialized for $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "1. Edit openspec/context/project_summary.md - fill in project details"
echo "2. Edit openspec/context/tech_stack.md - define your tech stack"
echo "3. Run /opsx:onboard to learn the workflow"
echo ""
