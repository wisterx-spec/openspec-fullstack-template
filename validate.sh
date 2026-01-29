#!/bin/bash
# OpenSpec Template Validation Script (Updated for workflow schema)
# Usage: ./validate.sh

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    OpenSpec Template Validation                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

PASS_COUNT=0
TOTAL_CHECKS=16
ERRORS=()

add_error() {
    ERRORS+=("$1")
}

# Check 1: Directory structure
echo "✓ Check 1/$TOTAL_CHECKS: Verify directory structure"
REQUIRED_DIRS=("openspec" "openspec/schemas/workflow" "openspec/schemas/workflow/templates" "openspec/context")
DIR_CHECK=true
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        add_error "Missing directory: $dir"
        DIR_CHECK=false
    fi
done
if [ "$DIR_CHECK" = true ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
fi

# Check 2: Core configuration files
echo "✓ Check 2/$TOTAL_CHECKS: Verify core configuration files"
if [ -f "openspec/config.yaml" ] && [ -f "openspec/schemas/workflow/schema.yaml" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Missing core configuration files (config.yaml or schema.yaml)"
fi

# Check 3: All templates exist (.md format)
echo "✓ Check 3/$TOTAL_CHECKS: Verify all template files"
TEMPLATES=("proposal.md" "spec.md" "design.md" "tasks.md" "infrastructure.md")
TEMPLATE_CHECK=true
for template in "${TEMPLATES[@]}"; do
    if [ ! -f "openspec/schemas/workflow/templates/$template" ]; then
        add_error "Missing template: $template"
        TEMPLATE_CHECK=false
    fi
done
if [ "$TEMPLATE_CHECK" = true ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
fi

# Check 4: Context template files
echo "✓ Check 4/$TOTAL_CHECKS: Verify context template files"
if [ -f "openspec/context/project_summary.template.md" ] && \
   [ -f "openspec/context/tech_stack.template.md" ] && \
   [ -f "openspec/context/infrastructure.template.md" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Missing context template files (project_summary, tech_stack, or infrastructure)"
fi

# Check 5: 13-step workflow in schema
echo "✓ Check 5/$TOTAL_CHECKS: Verify 13-step workflow description"
if grep -q "13-Step Contract-First" openspec/schemas/workflow/schema.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "13-step workflow description missing in schema.yaml"
fi

# Check 6: Core artifacts in schema
echo "✓ Check 6/$TOTAL_CHECKS: Verify core artifacts in schema"
ARTIFACTS=("proposal" "spec" "design" "tasks")
ARTIFACT_CHECK=true
for artifact in "${ARTIFACTS[@]}"; do
    if ! grep -q "id: $artifact" openspec/schemas/workflow/schema.yaml 2>/dev/null; then
        add_error "Missing artifact: $artifact"
        ARTIFACT_CHECK=false
    fi
done
if [ "$ARTIFACT_CHECK" = true ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
fi

# Check 7: Infrastructure artifact
echo "✓ Check 7/$TOTAL_CHECKS: Verify infrastructure artifact"
if grep -q "id: infrastructure" openspec/schemas/workflow/schema.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Infrastructure artifact missing"
fi

# Check 8: Config has schema field
echo "✓ Check 8/$TOTAL_CHECKS: Verify config schema field"
if grep -q "^schema: workflow" openspec/config.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "config.yaml must have 'schema: workflow'"
fi

# Check 9: Config has context
echo "✓ Check 9/$TOTAL_CHECKS: Verify config context"
if grep -q "^context:" openspec/config.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "config.yaml missing context section"
fi

# Check 10: Config has rules
echo "✓ Check 10/$TOTAL_CHECKS: Verify config rules"
if grep -q "^rules:" openspec/config.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "config.yaml missing rules section"
fi

# Check 11: 13-step tasks template
echo "✓ Check 11/$TOTAL_CHECKS: Verify 13-step structure in tasks template"
if grep -q "Phase 0" openspec/schemas/workflow/templates/tasks.md 2>/dev/null && \
   grep -q "Phase 8" openspec/schemas/workflow/templates/tasks.md 2>/dev/null && \
   grep -q "Step 13" openspec/schemas/workflow/templates/tasks.md 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "tasks.md missing 13-step structure (Phase 0-8, Step 13)"
fi

# Check 12: StandardResp in infrastructure template
echo "✓ Check 12/$TOTAL_CHECKS: Verify StandardResp format"
if grep -q "StandardResp" openspec/schemas/workflow/templates/infrastructure.md 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "StandardResp format missing in infrastructure.md"
fi

# Check 13: README exists
echo "✓ Check 13/$TOTAL_CHECKS: Verify README"
if [ -f "README.md" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "README.md missing"
fi

# Check 14: Init script
echo "✓ Check 14/$TOTAL_CHECKS: Verify init script"
if [ -f "init.sh" ] && [ -x "init.sh" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "init.sh missing or not executable"
fi

# Check 15: Skills directory
echo "✓ Check 15/$TOTAL_CHECKS: Verify skills directory"
if [ -d "skills" ] && [ "$(ls -A skills 2>/dev/null)" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "skills directory missing or empty"
fi

# Check 16: Init project script
echo "✓ Check 16/$TOTAL_CHECKS: Verify init-project script"
if [ -f "scripts/init-project.sh" ] && [ -x "scripts/init-project.sh" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "scripts/init-project.sh missing or not executable"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Validation Result: $PASS_COUNT/$TOTAL_CHECKS checks passed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $PASS_COUNT -eq $TOTAL_CHECKS ]; then
    echo ""
    echo "✅ ALL VALIDATION CHECKS PASSED!"
    echo ""
    echo "Your OpenSpec template is properly configured and ready to use."
    echo ""
    echo "Next steps:"
    echo "  1. Run ./init.sh <project_name> to initialize a new project"
    echo "  2. Or copy openspec/ and skills/ to your existing project"
    echo "  3. Use openspec CLI: openspec new change <name>"
    echo ""
    exit 0
else
    echo ""
    echo "⚠️  VALIDATION FAILED"
    echo ""
    echo "Errors found:"
    for error in "${ERRORS[@]}"; do
        echo "  - $error"
    done
    echo ""
    echo "Please fix the errors above and run validation again."
    echo ""
    exit 1
fi
