#!/bin/bash
# OpenSpec Fullstack Template - Initialization Script
# Usage: ./init.sh <project_name> [target_directory] [dev_mode]

set -e

PROJECT_NAME="${1:-MyProject}"
TARGET_DIR="${2:-.}"
DEV_MODE="${3:-fullstack}"

# Validate dev_mode
case "$DEV_MODE" in
    fullstack|frontend-only|backend-only|middleware-only|frontend-first-solo)
        ;;
    *)
        echo "Error: Invalid dev_mode '$DEV_MODE'"
        echo "Valid options: fullstack, frontend-only, backend-only, middleware-only, frontend-first-solo"
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

# Frontend-First mode: create additional directories and copy files
if [ "$DEV_MODE" = "frontend-first-solo" ] || [ "$DEV_MODE" = "fullstack" ] || [ "$DEV_MODE" = "frontend-only" ]; then
    echo "Setting up Frontend-First infrastructure..."

    # Create devtools/mocks directory structure
    mkdir -p "$TARGET_DIR/devtools/mocks/data"
    touch "$TARGET_DIR/devtools/mocks/data/.gitkeep"

    # Create design-system directory
    mkdir -p "$TARGET_DIR/design-system"

    # Copy API convention
    mkdir -p "$TARGET_DIR/openspec/conventions"
    cp "$SCRIPT_DIR/openspec/conventions/api-convention.md" "$TARGET_DIR/openspec/conventions/" 2>/dev/null || true

    # Copy Frontend-First specific skills
    for SKILL in openspec-ff-new openspec-ff-freeze openspec-ff-mock-to-spec openspec-ff-done; do
        if [ -d "$SCRIPT_DIR/skills/$SKILL" ]; then
            cp -r "$SCRIPT_DIR/skills/$SKILL" "$TARGET_DIR/.cursor/skills/"
        fi
    done

    # Copy Frontend-First agents
    mkdir -p "$TARGET_DIR/.cursor/agents"
    for AGENT in ff-verifier ff-contract-tester ff-spec-checker ff-build-checker ff-migrator; do
        if [ -f "$SCRIPT_DIR/.cursor/agents/$AGENT.md" ]; then
            cp "$SCRIPT_DIR/.cursor/agents/$AGENT.md" "$TARGET_DIR/.cursor/agents/"
        fi
    done

    # Copy Frontend-First scripts
    for SCRIPT_FILE in ff-compare-mock-spec.js ff-contract-test-runner.js ff-freeze-mock-version.js ff-check-no-mock-in-build.sh; do
        if [ -f "$SCRIPT_DIR/scripts/$SCRIPT_FILE" ]; then
            cp "$SCRIPT_DIR/scripts/$SCRIPT_FILE" "$TARGET_DIR/scripts/" 2>/dev/null || {
                mkdir -p "$TARGET_DIR/scripts"
                cp "$SCRIPT_DIR/scripts/$SCRIPT_FILE" "$TARGET_DIR/scripts/"
            }
        fi
    done
    chmod +x "$TARGET_DIR/scripts/ff-check-no-mock-in-build.sh" 2>/dev/null || true

    # Copy workflow documentation
    cp "$SCRIPT_DIR/FRONTEND_FIRST_WORKFLOW.md" "$TARGET_DIR/" 2>/dev/null || true
    cp "$SCRIPT_DIR/FRONTEND_FIRST_WORKFLOW_CN.md" "$TARGET_DIR/" 2>/dev/null || true
fi

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
        echo "   - Use /opsx:ff-new to create Frontend-First features"
        ;;
    frontend-first-solo)
        echo "   - Solo fullstack, UI-driven development"
        echo "   - 7-step Frontend-First workflow: UI → Mock → Spec → Backend"
        echo "   - Use /opsx:ff-new to create features"
        echo "   - See FRONTEND_FIRST_WORKFLOW.md for full guide"
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
