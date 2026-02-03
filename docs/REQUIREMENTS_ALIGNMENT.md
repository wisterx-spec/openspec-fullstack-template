# 13-Step Workflow: Requirements Alignment and Reducing Late-Stage Changes

This document assesses whether the **13-step contract-first workflow** can align requirements as much as possible and reduce late-stage changes, and suggests concrete improvements.

---

## Conclusion (Short Answer)

**Yes.** The current design already supports strong alignment and fewer late reworks via contract-first, single source of truth (spec), dispersed testing, and drift checks. Adding **requirements traceability** and **explicit binding of acceptance criteria to tests** pushes this further.

---

## Existing Strengths

| Mechanism | Role |
|-----------|------|
| **Contract-first (Spec first)** | proposal → spec → design → tasks; implementation follows spec, avoiding drift from “code first, docs later”. |
| **Single source of truth (spec.md)** | Mock data, skeleton responses, seed data, contract tests, and drift checks all reference spec; frontend and backend share one contract. |
| **Explicit Non-Goals and boundaries (Proposal)** | Non-Goals and Edge Cases & Risks must be stated; scope is clear. |
| **Step 3 validation gate** | Proposal logic is validated by the user before writing Spec. |
| **Design depends on Spec** | design.md is derived from spec; routes, services, tables, and endpoints stay aligned. |
| **Task dependency chain** | tasks depend on design + spec; paths, class names, table names are made concrete. |
| **Dispersed testing** | Task 4.2 / 5.2 / 5.4 / 5.6 run right after implementation; issues surface early. |
| **Step 12 drift check** | Code vs spec drift is quantified (&lt;1%). |
| **StandardResp + error codes** | Unified response format and error codes (infrastructure.md) keep semantics consistent. |

---

## Potential Gaps

| Gap | Description |
|-----|-------------|
| **No explicit Proposal → Spec traceability** | User stories and acceptance criteria (AC) may not map to endpoints/behaviors in spec; easy to miss or over-spec. |
| **No explicit AC → test binding** | AC live in proposal; tests in design/tasks; without “each AC covered by which test”, coverage can be incomplete or wrong. |
| **Spec completeness is manual** | Validation Checklist exists but is not enforced in the workflow; fields, error codes, pagination can be missed. |
| **Non-functional requirements not first-class** | Performance, rate limiting, security may only appear in Edge Cases or infrastructure; easy to forget. |
| **Contract change and versioning** | When spec changes, compatibility, versioning, and regression scope are not explicitly guided. |

---

## Suggested Improvements (Implemented Where Noted)

1. **Requirements traceability in spec**  
   - Add optional **Requirements Traceability** section in spec template: map each endpoint to User Story / AC (e.g. Story 1 / AC-1.1).  
   - Enables Proposal ↔ Spec review and change impact.

2. **Proposal → spec linkage**  
   - In User Stories / AC: state that each acceptance criterion should have a corresponding API or behavior in spec.md (traceability).  
   - Reduces missing AC in spec.

3. **AC coverage in design**  
   - In Verification Plan: each proposal AC should be covered by at least one of unit test, integration/contract test, or E2E/frontend verification.  
   - Optional table in design template: AC id → coverage type.  
   - Aligns test scope with requirements.

4. **“Check Spec before design” in workflow** (implemented)  
   - In `openspec/schemas/workflow/schema.yaml` spec instruction: complete **Validation Checklist** before moving to design (Step 5); tick each item and confirm in review.  
   - Makes Spec completeness a process step.

5. **Non-functional and contract change** (implemented)  
   - In `openspec/schemas/workflow/templates/proposal.md` Impact: **5.3 Non-Functional Requirements (optional)** — Performance, Rate limiting/Security, Compatibility.  
   - For API versioning, document “contract change and compatibility” in spec or infrastructure.  
   - Gives non-functional and contract evolution a clear place.

---

## Summary

- **Can the 13-step workflow align requirements and reduce late changes?** Yes; contract-first, single source of truth, dispersed testing, and drift check already do most of the work.  
- **What else?** Add **Proposal ↔ Spec traceability**, **AC ↔ test binding**, and **mandatory Spec checklist** in the workflow to reduce gaps further.  
- These improvements are reflected in this repo’s **proposal / spec / design** templates and in **docs/REQUIREMENTS_ALIGNMENT.md** (and _CN for Chinese).
