# Testing Guide

This document describes how to test the OpenSpec Fullstack Template project.

## Quick Tests

### 1. Run Validation Script

```bash
./validate.sh
```

This runs 17 checks, including:
- Directory structure
- Core configuration files
- All template files
- Context template files (including infrastructure.template.md)
- 13-step workflow structure
- Schema configuration
- Executable init scripts
- **E2E/contract testing** presence in workflow tasks (see below)

**Expected**: All 17 checks should pass.

### Where Are E2E / Contract Tests?

This template is a **workflow template** and does not include application e2e test code. E2E and contract testing are defined in the **task list** and executed in your project:

| Location | Description |
|----------|-------------|
| **Task 4.2** (Phase 4, Step 8) | **Backend contract testing**: After skeleton API is done, verify response format matches `spec.md`, StandardResp, error codes, and trace_id. |
| **Task 5.6** (Phase 5, Step 10) | **Frontend-backend integration / E2E**: After connecting frontend to backend, run integration tests covering full user flows (end-to-end). |

**Check 17** in `./validate.sh` ensures `tasks.md` contains "Contract Testing" or "end-to-end"/"E2E". Add concrete e2e tests (e.g. Playwright/Cypress) in your project per Task 4.2 / Task 5.6.

### 2. Test Init Scripts

#### Full init script

```bash
mkdir -p /tmp/test-openspec-project
cd /tmp/test-openspec-project

/path/to/openspec-fullstack-template/init.sh TestProject . fullstack

ls -la openspec/context/
# Expect: project_summary.md, tech_stack.md

grep "TestProject" openspec/config.yaml
```

#### Interactive init script

```bash
cd openspec-fullstack-template

mkdir -p /tmp/test-init-project
cd /tmp/test-init-project

mkdir -p openspec/context
cp -r /path/to/openspec-fullstack-template/openspec/context/*.template.md openspec/context/

/path/to/openspec-fullstack-template/scripts/init-project.sh
# Follow prompts; choose whether to generate infrastructure.md
```

### 3. Test Cursor Skills

In Cursor, run:

```bash
/opsx:init-project
/opsx:new test-feature
/opsx:check-standards
/opsx:onboard
```

## Detailed Test Checklist

### Template files

```bash
for file in proposal.md spec.md design.md tasks.md infrastructure.md; do
  test -f "openspec/schemas/workflow/templates/$file" && echo "✓ $file" || echo "✗ $file missing"
done

for file in project_summary.template.md tech_stack.template.md infrastructure.template.md; do
  test -f "openspec/context/$file" && echo "✓ $file" || echo "✗ $file missing"
done
```

### Config files

```bash
python3 -c "import yaml; yaml.safe_load(open('openspec/config.yaml'))" && echo "✓ Valid YAML"
python3 -c "import yaml; yaml.safe_load(open('openspec/schemas/workflow/schema.yaml'))" && echo "✓ Valid YAML"
grep -q "schema: workflow" openspec/config.yaml && echo "✓ schema field present"
grep -q "^context:" openspec/config.yaml && echo "✓ context field present"
grep -q "^rules:" openspec/config.yaml && echo "✓ rules field present"
```

### Script executability

```bash
for script in init.sh validate.sh scripts/init-project.sh; do
  test -x "$script" && echo "✓ $script executable" || echo "✗ $script not executable"
done
```

### Workflow structure

```bash
grep -q "13-Step Contract-First" openspec/schemas/workflow/schema.yaml && echo "✓ 13-step workflow found"
grep -q "Phase 0" openspec/schemas/workflow/templates/tasks.md && echo "✓ Phase 0 found"
grep -q "Phase 8" openspec/schemas/workflow/templates/tasks.md && echo "✓ Phase 8 found"
grep -q "Step 13" openspec/schemas/workflow/templates/tasks.md && echo "✓ Step 13 found"
```

### Skills directory

```bash
REQUIRED_SKILLS=(
  "openspec-new-change"
  "openspec-continue-change"
  "openspec-ff-change"
  "openspec-apply-change"
  "openspec-check-standards"
  "openspec-verify-change"
  "openspec-archive-change"
  "openspec-onboard"
  "openspec-init-project"
)
for skill in "${REQUIRED_SKILLS[@]}"; do
  test -f "skills/$skill/SKILL.md" && echo "✓ $skill" || echo "✗ $skill missing"
done
```

## Integration Tests

### E2E-style flow

1. Init a project: `./init.sh E2ETestProject /tmp/e2e-test fullstack`
2. Verify files: `cd /tmp/e2e-test` and check `project_summary.md`, `tech_stack.md`, `config.yaml`
3. Run interactive init if needed: `scripts/init-project.sh`
4. Cleanup: `rm -rf /tmp/e2e-test`

## CI

### GitHub Actions example

```yaml
name: Validate Template
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run validation
        run: ./validate.sh
      - name: Test initialization
        run: |
          mkdir -p /tmp/test-init
          ./init.sh TestProject /tmp/test-init fullstack
          test -f /tmp/test-init/openspec/context/project_summary.md
```

## Troubleshooting

1. **Validation fails (missing files)** – Check paths and permissions.
2. **Init script fails** – Check target directory permissions and that template files exist.
3. **Skills not working** – Ensure `skills` is under `.cursor/skills/` and SKILL.md format is correct.

## Best Practices

1. Run `./validate.sh` after changes.
2. Test init before committing: `./init.sh TestProject /tmp/test fullstack`.
3. Test all dev modes: fullstack, frontend-only, backend-only, middleware-only.
4. Verify generated files: placeholders replaced, format and required fields correct.
