---
name: OpenSpec: Proposal
description: Scaffold a new OpenSpec change and validate strictly.
category: OpenSpec
tags: [openspec, change]
---
<!-- OPENSPEC:START -->
**Guardrails**
- Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
- Keep changes tightly scoped to the requested outcome.
- Refer to `openspec/AGENTS.md` (located inside the `openspec/` directory—run `ls openspec` or `openspec update` if you don't see it) if you need additional OpenSpec conventions or clarifications.
- Identify any vague or ambiguous details and ask the necessary follow-up questions before editing files.
- Do not write any code during the proposal stage. Only create design documents (proposal.md, tasks.md, design.md, and spec deltas). Implementation happens in the apply stage after approval.

**Steps**
1. Review `openspec/project.md`, run `openspec list` and `openspec list --specs`, and inspect related code or docs (e.g., via `rg`/`ls`) to ground the proposal in current behaviour; note any gaps that require clarification.
2. Choose a unique verb-led `change-id` and scaffold `proposal.md`, `tasks.md`, and `design.md` (when needed) under `openspec/changes/<id>/`.
3. Map the change into concrete capabilities or requirements, breaking multi-scope efforts into distinct spec deltas with clear relationships and sequencing.
4. Capture architectural reasoning in `design.md` when the solution spans multiple systems, introduces new patterns, or demands trade-off discussion before committing to specs.
5. Draft spec deltas in `changes/<id>/specs/<capability>/spec.md` (one folder per capability) using `## ADDED|MODIFIED|REMOVED Requirements` with at least one `#### Scenario:` per requirement and cross-reference related capabilities when relevant.
6. Draft `tasks.md` as an ordered list of small, verifiable work items that deliver user-visible progress, include validation (tests, tooling), and highlight dependencies or parallelizable work.
7. Validate with `openspec validate <id> --strict` and resolve every issue before sharing the proposal.

**Reference**
- Use `openspec show <id> --json --deltas-only` or `openspec show <spec> --type spec` to inspect details when validation fails.
- Search existing requirements with `rg -n "Requirement:|Scenario:" openspec/specs` before writing new ones.
- Explore the codebase with `rg <keyword>`, `ls`, or direct file reads so proposals align with current implementation realities.
<!-- OPENSPEC:END -->

# Core Development Protocol (v1.0)

You act as a Senior Full-Stack Architect. When creating proposals, you MUST adhere to the following rules.

## 1. 契约优先 (Contract First)

涉及新接口的功能，必须在 proposal 中明确接口定义：
- URL、Method
- 请求参数（Query/Body）
- 响应结构

格式示例：
```
接口：GET /api/users?page=1&limit=20
响应：{status: "ok", data: {items: User[], total, page, limit, total_pages}}
```

## 2. 统一响应标准 (Unified Response)

所有后端接口必须返回此结构：
```json
{
  "status": "ok",
  "data": { ... },
  "message": null
}
```

错误时：
```json
{
  "status": "error",
  "data": null,
  "message": "用户友好的错误提示"
}
```

## 3. 分页格式

统一使用：
```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "limit": 20,
  "total_pages": 5
}
```

## 4. 职责边界

| 功能 | 责任方 |
|------|--------|
| 搜索、排序、分页 | 后端 |
| 数据计算、统计 | 后端 |
| 日期/金额格式化展示 | 前端 |
| 枚举字典维护 | 后端 |

## 5. HTTP Method

- GET：查询（参数走 Query String）
- POST：创建/复杂查询（参数走 JSON Body）
- PUT：更新
- DELETE：删除

## 6. 枚举

前后端枚举值必须一致，用字符串不用数字。
