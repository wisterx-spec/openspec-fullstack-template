# 13-Step Contract-First Development Workflow

This document describes the OpenSpec Fullstack Template 13-step contract-first development workflow in detail.

## Workflow Overview

| Phase | Steps | Stage | Outputs | Status |
|-------|-------|-------|----------|--------|
| **Phase 0** | Step 1 | Initialization | Tech stack analysis, infrastructure spec | Optional |
| **Phase 1** | Steps 2-4 | Definition | proposal.md, spec.md | Required |
| **Phase 2** | Step 5 | Design split | design.md | Required |
| **Phase 3** | Steps 6-7 | Frontend mock dev | Mock data + frontend code | By mode |
| **Phase 4** | Step 8 | Backend skeleton | Backend API skeleton (returns mock) | By mode |
| **Phase 5** | Step 9 | Contract testing | E2E test cases | By mode |
| **Phase 6** | Step 10 | Real implementation | Full backend implementation | By mode |
| **Phase 7** | Steps 11-12 | Real verification | Test report, drift check | By mode |
| **Phase 8** | Step 13 | Archive | Archive document | Required |

---

## Phase 0: Initialization (Step 1)

### Step 1: Tech Stack Analysis and Infrastructure Setup

**Goal**: Establish project technical foundation and infrastructure patterns.

**Tasks**:
1. **Task 0.1**: Analyze tech stack and map project structure (via context injection; see `context/tech_stack.md`, `context/project_summary.md`).
2. **Task 0.2**: Set up infrastructure components (optional, for new projects only): review `infrastructure.md`, install logging library, configure structured logging (trace_id), define error codes, implement StandardResp wrapper, set up middleware pipeline. Skip if infrastructure already exists.

**Outputs**: `infrastructure.md` (optional).

---

## Phase 1: Definition (Steps 2-4)

### Step 2: Proposal

**Goal**: Establish WHY — why this change is needed.

**Tasks**: **Task 1.1** — Draft proposal with: Background & Goals, Non-Goals (required), User Stories with acceptance criteria, Edge Cases & Risks (required), Impact and BREAKING changes.

**Outputs**: `proposal.md`.

### Step 3: Validation

**Goal**: Validate proposal logic (user verification; confirm scope and understanding).

**Outputs**: Validated proposal.

### Step 4: Spec

**Goal**: Create API specification as **Source of Truth**.

**Tasks**: **Task 1.3** — Define spec with: Overview, API Endpoints (request/response JSON examples, error codes, logging requirements per endpoint), Database Schema (if applicable), Validation Checklist (all endpoints with JSON examples, StandardResp, indexes, error codes, logging). JSON examples are used as mock data in Phase 3.

**Outputs**: `spec.md`.

---

## Phase 2: Design Split (Step 5)

### Step 5: Frontend/Backend Architecture Split

**Goal**: Establish HOW — how to implement the change.

**Tasks**: **Task 2.1** (frontend component design), **Task 2.2** (backend controller interface). First choose development mode: fullstack, frontend-only, backend-only, middleware-only. Required sections: Development mode configuration, Frontend architecture (unless backend-only), Backend architecture (unless frontend-only), Middleware architecture, Verification plan, Development workflow preview (Phases 3–6), Infrastructure integration.

**Outputs**: `design.md`.

---

## Phase 3: Frontend Mock Dev (Steps 6-7)

### Step 6: Mock Data Development

**Goal**: Implement frontend with mock data from spec.

**Tasks**: **Task 3.1** — Create mock data conforming to StandardResp from `spec.md` JSON; implement UI components, API client (X-Request-ID), error handling; handle loading/error/empty states. Constraint: mock must match spec.md JSON.

**Outputs**: Mock data, frontend components, API client.

### Step 7: Frontend Verification

**Goal**: Verify frontend works locally.

**Tasks**: **Task 3.2** — Verify rendering and interaction, loading/error/empty states; ensure mock matches spec.md.

**Skip**: If `dev_mode: backend-only`, skip Phase 3.

---

## Phase 4: Backend Skeleton (Step 8)

### Step 8: Controller Skeleton (Static Mock)

**Goal**: Create backend API skeleton returning static JSON from spec.

**Tasks**: **Task 4.1** — Implement router(s) returning **static JSON** from spec.md; **no database**. Integrate middleware (auth, validation, logging), X-Request-ID, StandardResp, error responses per infrastructure.md. Constraint: no DB connection; static JSON only.

**Outputs**: Backend API skeleton (mock only).

**Skip**: If `dev_mode: frontend-only`, skip Phase 4.

---

## Phase 5: Contract Testing (Step 9)

### Step 9: E2E Tests (Mock Mode)

**Goal**: Write and run contract tests so API conforms to Spec.

**Tasks**: **Task 5.1** — Run E2E tests against skeleton API; verify response format matches spec.md, error responses and codes, trace_id; all responses must follow StandardResp.

**Outputs**: E2E test cases, test report.

**Skip**: If `dev_mode: frontend-only`, skip Phase 5.

---

## Phase 6: Real Implementation (Step 10)

### Step 10: Service Implementation and Database Migration

**Goal**: Implement real business logic and database operations.

**Tasks**: **Task 6.1** — Database models and migrations (tables from spec, seed data from spec JSON). **Task 6.2** — Implement service logic (replace mock with real DB); constraints: structured logging (trace_id, user_id, duration_ms), slow op logging (>1s), error logging with context, error codes from infrastructure.md, StandardResp, error_details and trace_id in errors; request validation and auth where needed. **Task 6.3** — Connect frontend to real backend; remove mock; test with real API and error responses.

**Outputs**: Migrations, service implementation, updated frontend API client.

**Skip**: frontend-only → skip Task 6.1, 6.2; backend-only → skip Task 6.3.

---

## Phase 7: Real Verification (Steps 11-12)

### Step 11: Real Database Tests

**Goal**: Run tests with real database.

**Tasks**: **Task 7.1** — Run full test suite with test DB; verify all scenarios from spec.md.

**Outputs**: Test report.

### Step 12: Code vs Spec Audit (Drift Check)

**Goal**: Ensure implementation does not drift from contract.

**Tasks**: **Task 7.2** — Verify OpenAPI/schema matches spec.md; compare response structures; drift rate must be &lt; 1%.

**Outputs**: Drift check report.

**Skip**: If `dev_mode: frontend-only`, skip Phase 7.

---

## Phase 8: Archive (Step 13)

### Step 13: Archive

**Goal**: Archive completed change.

**Tasks**: **Task 8.1** — Verify all tasks done; run `openspec archive`; move change to archive.

**Outputs**: Archive document.

---

## Progress Summary

| Phase | Steps | Status | Notes |
|-------|-------|--------|-------|
| Phase 0 | Step 1 | Done | Tech stack and infrastructure |
| Phase 1 | Steps 2-4 | Done | Proposal and Spec |
| Phase 2 | Step 5 | Done | Design split |
| Phase 3 | Steps 6-7 | Pending | Frontend mock dev |
| Phase 4 | Step 8 | Pending | Backend skeleton |
| Phase 5 | Step 9 | Pending | Contract testing |
| Phase 6 | Step 10 | Pending | Implementation |
| Phase 7 | Steps 11-12 | Pending | Verification |
| Phase 8 | Step 13 | Pending | Archive |

---

## Development Mode

- **frontend-only**: Skip Phase 4, Phase 6 (Task 6.1, 6.2), Phase 7.
- **backend-only**: Skip Phase 3 (Task 3.1, 3.2), Phase 6 (Task 6.3).
- **fullstack**: All tasks required.
- **middleware-only**: Skip Phase 3; Phase 4 and 6 only middleware-related.

---

## Core Principles

1. **Spec First** — Write Spec before implementation.
2. **Mock Before Real** — Mock first, then real.
3. **Contract as Truth** — Spec is the single source of truth.
4. **Verify at Every Gate** — Validate at each phase.

---

## Key Constraints

- **Phases 3–4**: Use spec.md JSON as mock; Phase 4 returns static JSON, **no database**.
- **Phase 6**: Replace mock with real implementation; structured logging (trace_id, duration_ms); error codes from infrastructure.md.
- **Phase 7**: Drift rate must be &lt; 1%.
- **Infrastructure**: All responses StandardResp; X-Request-ID in requests; error codes and structured logging per infrastructure.md.

---

## References

- `proposal.md` — Proposal
- `spec.md` — API specification (source of truth)
- `design.md` — Design
- `tasks.md` — Task tracking
- `infrastructure.md` — Infrastructure specification
- `context/project_summary.md` — Project context
- `context/tech_stack.md` — Tech stack

For the full Chinese version, see [13_STEP_WORKFLOW_CN.md](13_STEP_WORKFLOW_CN.md).
