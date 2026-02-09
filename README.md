# OpenSpec Fullstack Template

[中文文档](README_CN.md) | [Usage Examples (CN)](USAGE_EXAMPLES_CN.md) | [Optimization Summary (CN)](OPTIMIZATION_SUMMARY_CN.md)

> A structured development workflow template for fullstack projects. Provides two modes: **13-Step Spec-First** (contract-driven) and **7-Step Frontend-First** (UI-driven), solving frontend-backend API inconsistency and high integration costs.

---

## Before You Start — Is This Template Right for You?

### What This Template Is

This is a **workflow template**, not a framework or library. It provides:
- A set of **Markdown document templates** (proposal, spec, design, tasks, archive)
- **Cursor IDE Skills** (AI-powered commands like `/opsx:new`, `/opsx:apply`)
- **Cursor Subagents** (automated verification: mock↔spec consistency, build leak checks)
- **Workflow conventions** (API standards, error codes, response format)

It does **not** ship any runtime code, UI components, or backend framework. You bring your own tech stack.

### Runtime Environment Requirements

| Dependency | Required | Purpose |
|------------|----------|---------|
| **[Cursor IDE](https://cursor.sh)** | **Yes** | Skills and Subagents only work inside Cursor |
| **[OpenSpec CLI](https://github.com/anthropics/openspec)** | **Yes** | Reads `config.yaml`, generates artifact instructions, tracks workflow state |
| **Git** | **Yes** | Version control, Git Hooks for mock isolation checks |
| **Node.js ≥ 18** | Recommended | Required if using MSW (Mock Service Worker) for Frontend-First mode |
| **Python 3.9+** | Optional | Only for `ui-ux-pro-max` design system generator |
| **Your tech stack** | Self-provided | React/Vue/Svelte, Express/FastAPI/Go, any DB — this template is stack-agnostic |

**Key point**: Without Cursor IDE + OpenSpec CLI, the Skills / Subagents / automated checks will not function. The document templates can still be used manually, but you lose the AI-assisted workflow.

### What Projects Are a Good Fit

| Scenario | Fit | Why |
|----------|-----|-----|
| New fullstack project (solo or small team) | **Best** | Full benefit from both workflow modes, clean start |
| Existing project adding new features | **Good** | Use incrementally — new features follow the workflow, old code untouched |
| Frontend-heavy SaaS / admin dashboards | **Good** | Frontend-First mode shines here: UI → Mock → Spec → Backend |
| Multi-team project sharing API contracts | **Good** | Spec-First mode provides clear contract handoff |
| Projects with complex API interactions | **Good** | Contract testing prevents "changed A, broke B" cascading failures |
| Projects needing design system consistency | **Good** | Built-in `ui-ux-pro-max` generates design tokens |

### What Projects Are NOT a Good Fit

| Scenario | Fit | Why |
|----------|-----|-----|
| Quick prototype / hackathon / throwaway code | **Poor** | Workflow overhead > benefit; just code directly |
| Pure static site (no API at all) | **Poor** | No backend contract needed; use a static site generator instead |
| Mobile app (React Native / Flutter) | **Limited** | Frontend-First mode assumes browser-based MSW; mobile needs adaptation |
| Microservices with dozens of inter-service APIs | **Limited** | Designed for frontend↔backend contracts, not service-to-service mesh |
| Team that doesn't use Cursor IDE | **Limited** | Skills and Subagents won't work; manual workflow only |
| CI/CD-only environments (no human in loop) | **Poor** | Workflow relies on developer review at checkpoints (UI Freeze, Spec Review) |
| Projects with existing mature API documentation (Swagger/OpenAPI) | **Marginal** | This template uses its own Spec format; duplicating effort unless migrating |

### When to Use Which Mode

```
Your project has a frontend?
├─ Yes → Solo or small team?
│        ├─ Yes → Frontend-First (7-Step)  ← recommended default
│        └─ No  → Spec-First (13-Step) for cross-team contracts
└─ No  → Spec-First (13-Step) — backend-only mode
```

---

## Two Workflow Modes

This template supports two complementary development workflows, configured via `dev_mode` in `openspec/config.yaml`:

### Mode 1: 13-Step Spec-First (Contract-Driven)

**Core idea**: Write the API contract (Spec) first, then implement frontend and backend against it.

**Best for**: Backend-only projects, multi-team handoffs, API-first design.

| Phase | Steps | Description | Output |
|-------|-------|-------------|--------|
| Phase 0 | Step 1 | Tech Stack Analysis | Tech stack document |
| Phase 1 | Steps 2-4 | Proposal → Validate → Spec | `proposal.md`, `spec.md` |
| Phase 2 | Step 5 | Frontend/Backend Design Split | `design.md` |
| Phase 3 | Steps 6-7 | Frontend Mock Development → Verify | Mock data + Frontend code |
| Phase 4 | Step 8 | Backend Skeleton (returns static mock) | Backend API skeleton |
| Phase 5 | Step 9 | E2E Contract Testing | Test cases |
| Phase 6 | Step 10 | Real Implementation (DB + Service) | Complete backend |
| Phase 7 | Steps 11-12 | Real Testing → Drift Check | Test report |
| Phase 8 | Step 13 | Archive | Archive document |

See [13-Step Workflow Details](13_STEP_WORKFLOW.md) for the complete guide.

### Mode 2: 7-Step Frontend-First (UI-Driven)

**Core idea**: Build the UI first with mock data, then derive the API contract from what the frontend actually needs.

**Best for**: Fullstack solo development, UI-heavy projects, rapid iteration.

```
Step 1: Proposal          → What feature to build?
Step 2: Frontend + Mock   → Build UI with fake data, iterate freely
Step 3: UI Freeze         → 🔒 Checkpoint: lock down UI and mock data
Step 4: API Spec          → Derive API contract from frozen mock data
Step 5: Spec Review       → 🔒 Checkpoint: verify Mock ↔ Spec 100% match
Step 6: Backend           → Implement strictly per Spec
Step 7: Integration       → Switch frontend to real API, archive
```

See [Frontend-First Workflow Details](FRONTEND_FIRST_WORKFLOW.md) for the complete guide.

### Mode Comparison

| Dimension | 13-Step Spec-First | 7-Step Frontend-First |
|-----------|-------------------|----------------------|
| Spec source | Designed from requirements | Derived from mock data |
| Best for | No frontend / API-first / multi-team | Has frontend / solo dev / UI-driven |
| Iteration speed | Moderate (spec changes require review) | Fast in Phase 1 (free iteration), locked after |
| Risk profile | Medium (spec based on assumptions) | Low (spec based on real UI needs) |
| Coexistence | Both modes share Proposal and Spec formats; outputs are compatible |

---

## Quick Start

### 1. Clone Template

```bash
git clone https://github.com/anthropics/openspec-fullstack-template.git
cd openspec-fullstack-template
```

### 2. Copy to Your Project

```bash
# Copy OpenSpec configuration
cp -r openspec-fullstack-template/openspec/ your-project/openspec/

# Copy Cursor Skills (place in .cursor/skills/)
cp -r openspec-fullstack-template/skills/ your-project/.cursor/skills/
```

### 3. Initialize Project Context

**Option A: Interactive script (recommended)**

```bash
cd your-project
./scripts/init-project.sh
```

**Option B: Cursor Skill**

```
/opsx:init-project
```

**Option C: Manual**

```bash
cd your-project/openspec/context/
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md
# Edit and fill in project information
```

### 4. Configure Development Mode

Edit `openspec/config.yaml`:

```yaml
# Choose your workflow mode
dev_mode: fullstack          # Options: fullstack, frontend-only, backend-only, middleware-only

# For Frontend-First mode, also add:
# dev_mode: frontend-first-solo
```

| Mode | Workflow | Use Case |
|------|----------|----------|
| `fullstack` | 13-Step | Complete frontend + backend + middleware |
| `frontend-only` | 7-Step (partial) | Frontend only, mock backend |
| `backend-only` | 13-Step (partial) | Backend API only |
| `frontend-first-solo` | 7-Step | Solo fullstack, UI-driven |

### 5. Start Using

```bash
# Onboarding guide
/opsx:onboard

# Create new change (Spec-First)
/opsx:new <name>              # Step-by-step artifact creation
/opsx:ff <name>               # Fast-forward generate all artifacts

# Create new feature (Frontend-First)
/opsx:ff-new <name>           # Create proposal + mock template + component scaffold
/opsx:ff-freeze <name>        # UI freeze checkpoint
/opsx:ff-mock-to-spec <name>  # Derive Spec from mock data
/opsx:ff-done <name>          # Integration + archive

# Implementation and verification
/opsx:apply <name>            # Implement tasks
/opsx:check-standards         # Check development standards
/opsx:verify <name>           # Verify implementation

# Archive
/opsx:archive <name>          # Archive completed change
```

---

## Directory Structure

```
openspec-fullstack-template/
├── openspec/                          # Core configuration
│   ├── config.yaml                   # Entry config (dev_mode, rules, context)
│   ├── conventions/
│   │   └── api-convention.md         # API response format, error codes, field naming
│   ├── schemas/
│   │   └── workflow/
│   │       ├── schema.yaml           # 13-step workflow definition
│   │       └── templates/            # Artifact templates (proposal, spec, design, tasks)
│   ├── context/                      # Project-specific context files
│   │   ├── project_summary.template.md
│   │   └── tech_stack.template.md
│   └── ui-ux-pro-max/               # Design system generator (optional, needs Python)
│       ├── scripts/search.py
│       └── data/                     # Color/typography/style datasets
│
├── skills/                            # Cursor Skills (AI commands)
│   ├── openspec-new-change/          # /opsx:new — create new change
│   ├── openspec-ff-change/           # /opsx:ff — fast-forward artifacts
│   ├── openspec-ff-new/              # /opsx:ff-new — Frontend-First: new feature
│   ├── openspec-ff-freeze/           # /opsx:ff-freeze — Frontend-First: UI freeze
│   ├── openspec-ff-mock-to-spec/     # /opsx:ff-mock-to-spec — derive Spec from mock
│   ├── openspec-apply-change/        # /opsx:apply — implement tasks
│   ├── openspec-check-standards/     # /opsx:check-standards — lint conventions
│   ├── openspec-verify-change/       # /opsx:verify — verify implementation
│   ├── openspec-archive-change/      # /opsx:archive — archive change
│   ├── openspec-design-system/       # Design system generation
│   └── ...                           # Other skills (onboard, explore, sync)
│
├── scripts/
│   └── init-project.sh               # Interactive project initialization
├── validate.sh                        # Template validation (17 checks)
├── 13_STEP_WORKFLOW.md                # Spec-First workflow details
├── FRONTEND_FIRST_WORKFLOW.md         # Frontend-First workflow details
└── README.md                          # This document
```

---

## Built-in Standards

### API Convention (`openspec/conventions/api-convention.md`)

This is the single source of truth for all API format rules:

| Rule | Standard |
|------|----------|
| Response envelope | `{ code, message, data }` — success: `code: 0`, error: `code: 6-digit` |
| Pagination | Flat: `{ items, total, page, page_size }` — no nested `pagination` object |
| Error codes | 6-digit `CCMMSS` (category + module + serial) |
| Field naming | JSON fields: `snake_case`, URL paths: `kebab-case` |
| Dates | ISO 8601: `"2024-01-28T10:30:00Z"` |
| Null handling | Declared fields must be returned (use `null`, never omit) |

### Development Standards

**Data Processing**:
- Server-side pagination, sorting, filtering (never on frontend)
- `page_size` max 100, default 20

**Frontend**: Must display Loading/Empty/Error states; date/currency formatting on frontend.

**Backend**: Parameterized queries; slow query logging (>1s); structured logs with `trace_id`.

---

## Automated Verification (Cursor Subagents)

These subagents run in Cursor and perform read-only checks:

| Subagent | What It Checks | When to Use |
|----------|---------------|-------------|
| `ff-verifier` | Three-way consistency: Mock ↔ Spec ↔ Backend | After Step 7 (Integration) |
| `ff-contract-tester` | Run and analyze contract tests | After Step 6 (Backend) |
| `ff-spec-checker` | Field-level Mock ↔ Spec comparison | After Step 5 (Spec Review) |
| `ff-build-checker` | No mock code leaked into production build | Before deployment |
| `ff-migrator` | Scan existing project for mock data distribution | During existing project init |

Multiple checkers can run in parallel for faster feedback.

---

## Resources

- [13-Step Workflow Details](13_STEP_WORKFLOW.md) / [中文版](13_STEP_WORKFLOW_CN.md)
- [Frontend-First Workflow Details](FRONTEND_FIRST_WORKFLOW.md) / [中文版](FRONTEND_FIRST_WORKFLOW_CN.md)
- [Requirements Alignment](docs/REQUIREMENTS_ALIGNMENT.md) / [中文版](docs/REQUIREMENTS_ALIGNMENT_CN.md)
- [Testing Guide](TESTING.md) / [中文版](TESTING_CN.md)
- [OpenSpec Documentation](https://github.com/anthropics/openspec)
- [Cursor Skills Documentation](https://cursor.sh/docs)

## Contributing

Issues and Pull Requests are welcome!

Before submitting:
1. Run `./validate.sh` to ensure all checks pass
2. Test initialization with `./init.sh TestProject /tmp/test fullstack`
3. Update documentation if needed

## License

MIT
