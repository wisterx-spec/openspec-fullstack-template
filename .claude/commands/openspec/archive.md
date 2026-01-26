---
name: OpenSpec: Archive
description: Archive a completed OpenSpec change after deployment.
category: OpenSpec
tags: [openspec, archive]
---
<!-- OPENSPEC:START -->
**Guardrails**
- Only archive changes that have been fully implemented and deployed.
- Refer to `openspec/AGENTS.md` for archiving conventions.

**Steps**
1. Verify all tasks in `tasks.md` are marked complete (`- [x]`).
2. Run `openspec archive <change-id> --yes` to archive the change.
3. If specs were modified, ensure `openspec/specs/` is updated accordingly.
4. Run `openspec validate --strict` to confirm the archive is valid.

**Reference**
- Use `openspec show <change-id>` to review the change before archiving.
- Use `--skip-specs` flag if the change was tooling-only and didn't modify specs.
<!-- OPENSPEC:END -->
