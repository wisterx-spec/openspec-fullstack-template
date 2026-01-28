#!/bin/bash
# OpenSpec Fullstack Template - Initialization Script
# Usage: ./init.sh <project_name> [target_directory] [dev_mode]

set -e

PROJECT_NAME="${1:-MyProject}"
TARGET_DIR="${2:-.}"
DEV_MODE="${3:-fullstack}"

# Validate dev_mode
case "$DEV_MODE" in
    fullstack|frontend-only|backend-only|middleware-only)
        ;;
    *)
        echo "Error: Invalid dev_mode '$DEV_MODE'"
        echo "Valid options: fullstack, frontend-only, backend-only, middleware-only"
        exit 1
        ;;
esac

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║              OpenSpec Fullstack Template - Initialization                    ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Project Name: $PROJECT_NAME"
echo "Target Directory: $TARGET_DIR"
echo "Development Mode: $DEV_MODE"
echo ""

# Create directories
echo "Creating directory structure..."
mkdir -p "$TARGET_DIR/openspec/"{schemas,templates,context,specs,changes}
mkdir -p "$TARGET_DIR/.cursor/skills"

# Copy core files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Copying configuration files..."
cp "$SCRIPT_DIR/openspec/config.yaml" "$TARGET_DIR/openspec/"
cp "$SCRIPT_DIR/openspec/schemas/workflow.yaml" "$TARGET_DIR/openspec/schemas/"

echo "Copying templates..."
cp "$SCRIPT_DIR/openspec/templates/"*.hbs "$TARGET_DIR/openspec/templates/"

# Create context files from templates
echo "Creating context files..."
sed "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" \
    "$SCRIPT_DIR/openspec/context/project_summary.template.md" \
    > "$TARGET_DIR/openspec/context/project_summary.md"

cp "$SCRIPT_DIR/openspec/context/tech_stack.template.md" \
   "$TARGET_DIR/openspec/context/tech_stack.md"

# Update config with project name and dev_mode
echo "Configuring project settings..."
sed -i.bak "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" "$TARGET_DIR/openspec/config.yaml" && \
    rm "$TARGET_DIR/openspec/config.yaml.bak" 2>/dev/null || true

sed -i.bak "s/dev_mode: fullstack/dev_mode: $DEV_MODE/g" "$TARGET_DIR/openspec/config.yaml" && \
    rm "$TARGET_DIR/openspec/config.yaml.bak" 2>/dev/null || true

# Copy skills
echo "Installing Cursor Skills..."
cp -r "$SCRIPT_DIR/skills/"* "$TARGET_DIR/.cursor/skills/"

# Create .gitkeep files
touch "$TARGET_DIR/openspec/specs/.gitkeep"
touch "$TARGET_DIR/openspec/changes/.gitkeep"

# Copy documentation
echo "Copying documentation..."
cp "$SCRIPT_DIR/README.md" "$TARGET_DIR/README.openspec.md" 2>/dev/null || true
cp "$SCRIPT_DIR/USAGE_EXAMPLES.md" "$TARGET_DIR/USAGE_EXAMPLES.md" 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ OpenSpec initialized successfully for $PROJECT_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. 📝 Edit Project Context"
echo "   - openspec/context/project_summary.md - Fill in project details"
echo "   - openspec/context/tech_stack.md - Define your tech stack"
echo ""
echo "2. 🏗️  Generate Infrastructure (Recommended for new projects)"
echo "   In Cursor: /opsx:new infrastructure"
echo "   This creates: openspec/context/infrastructure.md"
echo ""
echo "3. 🚀 Start Development"
echo "   - Run /opsx:onboard to learn the workflow"
echo "   - Run /opsx:new <feature-name> to create your first feature"
echo ""
echo "📚 Documentation:"
echo "   - README.openspec.md - Complete usage guide"
echo "   - USAGE_EXAMPLES.md - 5 practical examples"
echo ""
echo "🔧 Development Mode: $DEV_MODE"
case "$DEV_MODE" in
    fullstack)
        echo "   - Complete frontend + backend + middleware development"
        ;;
    frontend-only)
        echo "   - Frontend development with Mock backend"
        echo "   - Use /opsx:new to generate specs with mock data"
        ;;
    backend-only)
        echo "   - Backend API development"
        echo "   - Test with Postman/curl"
        ;;
    middleware-only)
        echo "   - Infrastructure and middleware development"
        echo "   - Focus on auth, logging, error handling"
        ;;
esac
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
