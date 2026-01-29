---
name: openspec-apply-change
description: Implement tasks from an OpenSpec change. Use when the user wants to start implementing, continue implementation, or work through tasks.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: openspec
  version: "1.0"
  generatedBy: "1.0.2"
---

Implement tasks from an OpenSpec change.

**Input**: Optionally specify a change name. If omitted, check if it can be inferred from conversation context. If vague or ambiguous you MUST prompt for available changes.

**Steps**

1. **Select the change**

   If a name is provided, use it. Otherwise:
   - Infer from conversation context if the user mentioned a change
   - Auto-select if only one active change exists
   - If ambiguous, run `openspec list --json` to get available changes and use the **AskUserQuestion tool** to let the user select

   Always announce: "Using change: <name>" and how to override (e.g., `/opsx:apply <other>`).

2. **Check status to understand the schema**
   ```bash
   openspec status --change "<name>" --json
   ```
   Parse the JSON to understand:
   - `schemaName`: The workflow being used (e.g., "spec-driven")
   - Which artifact contains the tasks (typically "tasks" for spec-driven, check status for others)

3. **Get apply instructions**

   ```bash
   openspec instructions apply --change "<name>" --json
   ```

   This returns:
   - Context file paths (varies by schema - could be proposal/specs/design/tasks or spec/tests/implementation/docs)
   - Progress (total, complete, remaining)
   - Task list with status
   - Dynamic instruction based on current state

   **Handle states:**
   - If `state: "blocked"` (missing artifacts): show message, suggest using openspec-continue-change
   - If `state: "all_done"`: congratulate, suggest archive
   - Otherwise: proceed to implementation

4. **Read context files**

   Read the files listed in `contextFiles` from the apply instructions output.
   The files depend on the schema being used:
   - **spec-driven**: proposal, specs, design, tasks
   - Other schemas: follow the contextFiles from CLI output

5. **Show current progress**

   Display:
   - Schema being used
   - Progress: "N/M tasks complete"
   - Remaining tasks overview
   - Dynamic instruction from CLI

6. **Implement tasks (loop until done or blocked)**

   For each pending task:
   - Show which task is being worked on
   - **Identify task type**:
     - **Code implementation task**: Make the code changes required
     - **Test/Verification task**: Run the test command or verification step
     - **Manual task**: Guide user through manual steps
   - Keep changes minimal and focused
   - Mark task complete in the tasks file: `- [ ]` → `- [x]`
   - Continue to next task

   **Special handling for test/verification tasks**:
   - **Task 5.1 (E2E Tests)**: Run the test command specified in the task
     - If command is `<!-- project-specific test command -->`, ask user for the actual command
     - Execute tests and verify they pass
     - If tests fail, report failures and pause for user guidance
   - **Task 7.1 (Real DB Tests)**: Run tests with real database
     - Execute the test command
     - Verify all scenarios from spec.md are covered
   - **Task 7.2 (Drift Check)**: Perform automated drift check
     - Verify OpenAPI schema matches spec.md
     - Compare response structures
     - Calculate drift rate (must be < 1%)
     - Report any drift issues
   - **Task 3.2, 7.1**: These are verification tasks - actually run the verification steps

   **Pause if:**
   - Task is unclear → ask for clarification
   - Implementation reveals a design issue → suggest updating artifacts
   - Error or blocker encountered → report and wait for guidance
   - Test failures → report and wait for user to fix
   - User interrupts

7. **On completion or pause, show status**

   Display:
   - Tasks completed this session
   - Overall progress: "N/M tasks complete"
   - If all done: suggest archive
   - If paused: explain why and wait for guidance

**Output During Implementation**

```
## Implementing: <change-name> (schema: <schema-name>)

Working on task 3/7: <task description>
[...implementation happening...]
✓ Task complete

Working on task 4/7: <task description>
[...implementation happening...]
✓ Task complete
```

**Output On Completion**

```
## Implementation Complete

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 7/7 tasks complete ✓

### Completed This Session
- [x] Task 1
- [x] Task 2
...

All tasks complete! Ready to archive this change.
```

**Output On Pause (Issue Encountered)**

```
## Implementation Paused

**Change:** <change-name>
**Schema:** <schema-name>
**Progress:** 4/7 tasks complete

### Issue Encountered
<description of the issue>

**Options:**
1. <option 1>
2. <option 2>
3. Other approach

What would you like to do?
```

## Guardrails
- Keep going through tasks until done or blocked
- Always read context files before starting (from the apply instructions output)
- If task is ambiguous, pause and ask before implementing
- If implementation reveals issues, pause and suggest artifact updates
- Keep code changes minimal and scoped to each task
- Update task checkbox immediately after completing each task
- **For test/verification tasks**: Actually run the tests/checks, don't just mark as done
- **For tasks with placeholders** (like `<!-- project-specific test command -->`): Ask user for actual values
- Pause on errors, blockers, or unclear requirements - don't guess
- Pause on test failures - report and wait for user to fix
- Use contextFiles from CLI output, don't assume specific file names

## Task Type Detection

Recognize task types from task descriptions:

- **Code implementation**: Contains "Implement", "Create", "Update", "Add"
- **Test task**: Contains "Run Tests", "Test", "Verify", "E2E", "Contract Testing"
- **Verification task**: Contains "Verify", "Check", "Audit", "Drift Check"
- **Manual task**: Contains "Run", "Execute" with command placeholders

For test/verification tasks:
1. Extract the test command if specified
2. If command is a placeholder, ask user for actual command
3. Run the command
4. Verify results
5. Mark complete only if tests pass or verification succeeds

**Fluid Workflow Integration**

This skill supports the "actions on a change" model:

- **Can be invoked anytime**: Before all artifacts are done (if tasks exist), after partial implementation, interleaved with other actions
- **Allows artifact updates**: If implementation reveals design issues, suggest updating artifacts - not phase-locked, work fluidly
