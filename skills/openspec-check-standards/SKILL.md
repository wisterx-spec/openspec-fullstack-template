---
name: openspec-check-standards
description: Check code against project development standards. Use when the user wants to verify code follows conventions like server-side pagination, structured logging, etc.
license: MIT
compatibility: Works with any codebase with openspec/context/project_summary.md
metadata:
  author: openspec
  version: "1.0"
---

Check code against project development standards defined in `openspec/context/project_summary.md`.

**Input**: Optionally specify file paths, directories, or a change name. If omitted, checks recently modified files or files in active change.

**Steps**

1. **Load development standards**

   Read `openspec/context/project_summary.md` and extract the "Development Standards" section.
   
   Key rules to check:
   
   **Data Processing (Frontend)**:
   - No frontend pagination (client-side slicing of full data)
   - No frontend sorting (Array.sort on API data)
   - No frontend filtering/searching (filter on full dataset)
   - No pseudo-pagination (loading all data, showing pages)
   
   **API Design**:
   - List APIs must support `page` + `page_size` parameters
   - List APIs must return `total_count`
   - No `page_size > 100`
   - No SELECT without LIMIT
   
   **Frontend Constraints**:
   - Must show Loading/Empty/Error states
   - API calls must go through React Query hooks
   
   **Backend Constraints**:
   - List queries must have default `limit`
   - Must use parameterized queries
   - Slow queries (>1s) must be logged

2. **Determine scope**

   **If change name provided:**
   - Get files modified in that change from `openspec/changes/<name>/tasks.md`
   - Or check git diff if tasks reference file paths
   
   **If file/directory paths provided:**
   - Use those paths directly
   
   **If nothing provided:**
   - Check recently modified files (git status)
   - Or scan `frontend/src/` and `backend/app/` for common issues

3. **Run checks**

   For each file in scope:

   ### Frontend Checks (*.tsx, *.ts in frontend/)
   
   **Anti-pattern: Frontend Pagination**
   ```
   Search for patterns like:
   - .slice(startIndex, endIndex)  // on API response data
   - data.slice(page * pageSize    // pseudo-pagination
   - useState.*page.*setPage       // local pagination state with no API call
   ```
   
   **Anti-pattern: Frontend Sorting**
   ```
   Search for patterns like:
   - .sort((a, b) =>               // sorting API response
   - [...data].sort(               // copying and sorting
   - useMemo.*sort                 // memoized sort on full data
   ```
   
   **Anti-pattern: Frontend Filtering**
   ```
   Search for patterns like:
   - .filter(item =>               // on API response data
   - data.filter(                  // filtering full dataset
   - useMemo.*filter               // memoized filter on API data
   ```
   
   **Required: Loading States**
   ```
   Check for:
   - isLoading / isPending usage
   - Skeleton / Spinner components
   - Loading fallback UI
   ```
   
   **Required: React Query**
   ```
   Check for:
   - useQuery / useMutation usage
   - No direct fetch() in components
   ```

   ### Backend Checks (*.py in backend/)
   
   **Anti-pattern: Missing LIMIT**
   ```
   Search for patterns like:
   - .all() without .limit()
   - SELECT * FROM without LIMIT
   - query.all() on unbounded queries
   ```
   
   **Anti-pattern: Missing Pagination Params**
   ```
   Check router functions for:
   - List endpoints missing page/page_size params
   - Missing skip/limit in queries
   ```
   
   **Required: Structured Logging**
   ```
   Check service classes for:
   - logger.info/warning/error usage
   - Key fields: task_id, duration, retry_count
   ```

4. **Generate report**

   ```
   ## Standards Check Report
   
   **Scope:** [files checked]
   **Date:** [timestamp]
   
   ### Summary
   | Category | Passed | Failed | Warnings |
   |----------|--------|--------|----------|
   | Frontend Data Processing | X | Y | Z |
   | API Design | X | Y | Z |
   | Backend Constraints | X | Y | Z |
   
   ### Issues Found
   
   #### CRITICAL (Must Fix)
   
   **[File:Line] Frontend Pagination Detected**
   ```tsx
   const paginatedData = data.slice(page * 10, (page + 1) * 10);
   ```
   - Problem: Loading full data then slicing client-side
   - Fix: Add `page` and `page_size` params to API, use server pagination
   
   #### WARNING (Should Fix)
   
   **[File:Line] Missing Loading State**
   - Problem: No loading indicator while fetching
   - Fix: Add `{isLoading && <Spinner />}` or skeleton
   
   #### SUGGESTION (Nice to Fix)
   
   **[File:Line] Consider Structured Logging**
   - Add task_id and duration to log entries
   
   ### Passed Checks
   - ✓ React Query usage
   - ✓ Parameterized queries
   - ✓ Default LIMIT on queries
   ```

5. **Provide actionable next steps**

   Based on findings:
   - If CRITICAL issues: "Fix these before proceeding"
   - If only warnings: "Ready to continue, consider fixing warnings"
   - If all passed: "All standards checks passed!"

**Output**

A structured report showing:
- What was checked
- Issues found (grouped by severity)
- Specific file:line references
- Concrete fix suggestions
- Overall status (PASS/WARN/FAIL)

**Integration with Other Skills**

- Run after `openspec-apply-change` completes tasks
- Run before `openspec-verify-change` for complete validation
- Run before `openspec-archive-change` as final gate

**Guardrails**
- Don't report false positives for legitimate use cases (e.g., local UI state sorting)
- Distinguish between API data manipulation and UI-only data
- If uncertain, mark as SUGGESTION not CRITICAL
- Always provide file:line references for issues
- Focus on patterns, not exhaustive analysis
- Keep the report actionable and concise
