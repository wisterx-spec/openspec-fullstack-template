#!/bin/bash
# OpenSpec Template Validation Script
# Usage: ./validate.sh

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    OpenSpec Template Validation                              ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

PASS_COUNT=0
TOTAL_CHECKS=20
ERRORS=()

# Helper function to add error
add_error() {
    ERRORS+=("$1")
}

# Check 1: Directory structure
echo "✓ Check 1/20: Verify directory structure"
REQUIRED_DIRS=("openspec" "openspec/schemas" "openspec/templates" "openspec/context")
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
echo "✓ Check 2/20: Verify core configuration files"
if [ -f "openspec/config.yaml" ] && [ -f "openspec/schemas/workflow.yaml" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Missing core configuration files"
fi

# Check 3: All templates exist
echo "✓ Check 3/20: Verify all template files"
TEMPLATES=("proposal.hbs" "contract.hbs" "design.hbs" "tasks.hbs" "infrastructure.hbs")
TEMPLATE_CHECK=true
for template in "${TEMPLATES[@]}"; do
    if [ ! -f "openspec/templates/$template" ]; then
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

# Check 4: Context files
echo "✓ Check 4/20: Verify context files"
if [ -f "openspec/context/project_summary.template.md" ] && \
   [ -f "openspec/context/tech_stack.template.md" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Missing context template files"
fi

# Check 5: 13-step workflow
echo "✓ Check 5/20: Verify 13-step workflow structure"
if grep -q "13-Step Contract-First Development Workflow" openspec/schemas/workflow.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "13-step workflow description missing"
fi

# Check 6: Core artifacts
echo "✓ Check 6/20: Verify core artifacts in workflow"
ARTIFACTS=("proposal" "spec" "design" "tasks")
ARTIFACT_CHECK=true
for artifact in "${ARTIFACTS[@]}"; do
    if ! grep -q "name: $artifact" openspec/schemas/workflow.yaml 2>/dev/null; then
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

# Check 7: Infrastructure artifact (optional)
echo "✓ Check 7/20: Verify infrastructure artifact"
if grep -q "name: infrastructure" openspec/schemas/workflow.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Infrastructure artifact missing"
fi

# Check 8: Dev mode configuration
echo "✓ Check 8/20: Verify dev_mode configuration"
if grep -q "dev_mode:" openspec/config.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "dev_mode configuration missing"
fi

# Check 9: Error code system
echo "✓ Check 9/20: Verify error code system"
if grep -q "1xxx\|2xxx\|3xxx\|4xxx\|5xxx" openspec/templates/infrastructure.hbs 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Error code system missing"
fi

# Check 10: StandardResp format
echo "✓ Check 10/20: Verify StandardResp format"
if grep -q "StandardResp" openspec/templates/contract.hbs openspec/templates/infrastructure.hbs 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "StandardResp format missing"
fi

# Check 11: Structured logging
echo "✓ Check 11/20: Verify structured logging"
if grep -q "trace_id" openspec/templates/infrastructure.hbs openspec/templates/contract.hbs 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Structured logging (trace_id) missing"
fi

# Check 12: Middleware architecture
echo "✓ Check 12/20: Verify middleware architecture"
if grep -q "Middleware Architecture" openspec/templates/infrastructure.hbs 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Middleware architecture documentation missing"
fi

# Check 13: Development modes
echo "✓ Check 13/20: Verify development modes"
MODES=("fullstack" "frontend-only" "backend-only" "middleware-only")
MODE_CHECK=true
for mode in "${MODES[@]}"; do
    if ! grep -q "\"$mode\"" openspec/templates/design.hbs 2>/dev/null; then
        add_error "Missing development mode: $mode"
        MODE_CHECK=false
    fi
done
if [ "$MODE_CHECK" = true ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
fi

# Check 14: Handlebars syntax
echo "✓ Check 14/20: Verify Handlebars syntax"
if grep -r "{{else if" openspec/templates/*.hbs 2>/dev/null; then
    echo "  ✗ FAIL"
    add_error "Invalid Handlebars 'else if' syntax found"
else
    echo "  ✓ PASS"
    ((PASS_COUNT++))
fi

# Check 15: Phase references
echo "✓ Check 15/20: Verify Phase 0-8 references"
PHASE_CHECK=true
for i in {0..8}; do
    if ! grep -q "Phase $i" openspec/schemas/workflow.yaml openspec/templates/tasks.hbs 2>/dev/null; then
        add_error "Missing Phase $i reference"
        PHASE_CHECK=false
    fi
done
if [ "$PHASE_CHECK" = true ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
fi

# Check 16: File references
echo "✓ Check 16/20: Verify file references"
if grep -q "infrastructure\.md" openspec/config.yaml 2>/dev/null && \
   grep -q "spec\.md" openspec/templates/design.hbs 2>/dev/null && \
   grep -q "design\.md" openspec/templates/tasks.hbs 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "File references inconsistent"
fi

# Check 17: Backward compatibility
echo "✓ Check 17/20: Verify backward compatibility"
if grep -q "optional: true" openspec/schemas/workflow.yaml 2>/dev/null; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "Infrastructure artifact should be optional"
fi

# Check 18: Documentation
echo "✓ Check 18/20: Verify documentation"
if [ -f "README.md" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "README.md missing"
fi

# Check 19: Init script
echo "✓ Check 19/20: Verify init script"
if [ -f "init.sh" ] && [ -x "init.sh" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "init.sh missing or not executable"
fi

# Check 20: Skills directory
echo "✓ Check 20/20: Verify skills directory"
if [ -d "skills" ] && [ "$(ls -A skills 2>/dev/null)" ]; then
    echo "  ✓ PASS"
    ((PASS_COUNT++))
else
    echo "  ✗ FAIL"
    add_error "skills directory missing or empty"
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
    echo "  2. Or copy openspec/ to your existing project"
    echo "  3. Run /opsx:onboard in Cursor to learn the workflow"
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
