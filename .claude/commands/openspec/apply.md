---
name: OpenSpec: Apply
description: Implement an approved OpenSpec change and keep tasks in sync.
category: OpenSpec
tags: [openspec, apply]
---
<!-- OPENSPEC:START -->
**Guardrails**
- Favor straightforward, minimal implementations first and add complexity only when it is requested or clearly required.
- Keep changes tightly scoped to the requested outcome.
- Refer to `openspec/AGENTS.md` (located inside the `openspec/` directory—run `ls openspec` or `openspec update` if you don't see it) if you need additional OpenSpec conventions or clarifications.

**Steps**
Track these steps as TODOs and complete them one by one.
1. Read `changes/<id>/proposal.md`, `contract.md` (if present), `design.md` (if present), and `tasks.md` to confirm scope and acceptance criteria.
2. Work through tasks sequentially, keeping edits minimal and focused on the requested change.
3. Confirm completion before updating statuses—make sure every item in `tasks.md` is finished.
4. Update the checklist after all work is done so each task is marked `- [x]` and reflects reality.
5. Reference `openspec list` or `openspec show <item>` when additional context is required.

**Reference**
- Use `openspec show <id> --json --deltas-only` if you need additional context from the proposal while implementing.
<!-- OPENSPEC:END -->

# Core Development Protocol (v1.0)

You act as a Senior Full-Stack Developer. When implementing changes, you MUST adhere to the following rules.

## 1. 响应格式

后端所有接口必须返回 StandardResp：
```python
from core.response import ok, error, paginated

# 成功
return ok(data)

# 错误
return error("错误信息")

# 分页
return paginated(items, total, page, limit)
```

## 2. 前端请求

使用统一的 request 封装：
```typescript
import { api } from '@/lib/request';

// GET
const data = await api.get<User[]>('/api/users');

// POST
const result = await api.post<User>('/api/users', { name: 'test' });
```

## 3. 错误处理

后端：
```python
from core.exceptions import BusinessException, NotFoundException

# 业务错误
raise BusinessException("用户不存在")

# 资源不存在
raise NotFoundException("用户不存在")
```

前端：
```typescript
try {
  const data = await api.get('/api/users');
} catch (error) {
  // 错误已被 request.ts 统一处理并打印
  // 这里只需处理特殊逻辑
}
```

## 4. 枚举使用

后端：
```python
from core.enums import TaskStatus

task.status = TaskStatus.COMPLETED
```

前端：
```typescript
import { TaskStatus, TaskStatusLabel } from '@/types/enums';

if (task.status === TaskStatus.COMPLETED) {
  // ...
}

// 显示标签
<span>{TaskStatusLabel[task.status]}</span>
```

## 5. 日期处理

后端返回 ISO 8601 UTC 时间，前端负责格式化：
```typescript
import { formatDate, formatRelativeTime } from '@/utils/date';

formatDate(task.created_at);        // 2024-01-15 10:30:00
formatRelativeTime(task.created_at); // 5分钟前
```

## 6. 检查清单

实现完成后自查：
- [ ] 后端接口是否都用了 StandardResp 包装？
- [ ] 前端是否消灭了所有 `any` 类型？
- [ ] 分页格式是否统一？
- [ ] 枚举值前后端是否一致？
- [ ] 错误是否有统一提示？
