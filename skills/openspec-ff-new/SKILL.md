---
name: openspec-ff-new
description: 创建 Frontend-First 新功能。引导用户描述需求，生成 proposal.md，创建符合 api-convention 的 Mock 数据模板和前端组件模板。这是 Frontend-First 流程 Step 1 + Step 2 的启动步骤。
license: MIT
compatibility: Works with any frontend project using the Frontend-First workflow.
metadata:
  author: openspec
  version: "1.0"
---

创建 Frontend-First 新功能：引导用户描述需求 → 生成 proposal.md → 创建 Mock 数据模板 + 前端组件模板。

**前提条件：** 项目已完成 Frontend-First 初始化（Step 0），`devtools/mocks/` 目录存在。

**Input**: 功能名称（feature name）。如果未提供，使用 AskUserQuestion 询问。

**Steps**

1. **收集需求信息**

   使用 **AskUserQuestion 工具** 逐步引导用户：

   **a. 功能名称**
   - 如果未提供，询问："这个功能叫什么？（英文，用于目录名，如 user-management）"
   - 验证命名规范：kebab-case，纯小写字母和连字符

   **b. 背景和目标**
   - "这个功能要解决什么问题？（一两句话）"
   - "用户能做什么？（列出 2-3 个核心用例）"

   **c. 非目标**
   - "这个版本不做什么？（明确排除的功能）"

   **d. 开发模式确认**
   - 读取 `openspec/config.yaml` 中的 `dev_mode`
   - 如果是 `fullstack` 或 `frontend-only`，继续完整流程
   - 如果是 `backend-only`，提示用户此功能走 Spec-First 流程，建议使用 `/opsx:new` 代替

2. **生成 proposal.md**

   在 `openspec/specs/<feature>/` 目录下创建 `proposal.md`：

   ```markdown
   # Proposal: <功能名称>

   ## 背景
   <用户提供的背景>

   ## 目标
   - <目标1>
   - <目标2>
   - <目标3>

   ## 非目标
   - <排除项1>
   - <排除项2>

   ## 关键用例
   1. <用例1>
   2. <用例2>
   ```

3. **创建 Mock 数据模板**

   在 `devtools/mocks/data/<feature>/` 目录下创建 Mock 文件。

   **读取 `openspec/conventions/api-convention.md` 中的响应信封规范**，确保模板符合约束。

   ```typescript
   // devtools/mocks/data/<feature>/<feature>.mock.ts

   // Mock 数据 — 遵守 api-convention.md 约束
   // 响应信封：{ code, message, data }
   // 字段命名：snake_case
   // 日期格式：ISO 8601 "2024-01-28T10:30:00Z"
   // 错误码：6位数字 CCMMSS

   // 成功响应 — 正常数据
   export const mock<Feature>ListSuccess = {
     code: 0,
     message: 'success',
     data: {
       items: [
         // TODO: 根据 UI 需要填充字段
         { id: 1 },
       ],
       total: 1,
       page: 1,
       page_size: 20,
     },
   }

   // 成功响应 — 空列表
   export const mock<Feature>ListEmpty = {
     code: 0,
     message: 'success',
     data: {
       items: [],
       total: 0,
       page: 1,
       page_size: 20,
     },
   }

   // 错误响应 — 参数错误
   export const mock<Feature>Error = {
     code: 100001,
     message: '缺少必填参数',
     data: null,
   }
   ```

4. **创建 MSW Handler 模板**

   ```typescript
   // devtools/mocks/data/<feature>/handlers.ts
   import { http, HttpResponse } from 'msw'
   import { mock<Feature>ListSuccess } from './<feature>.mock'

   export const <feature>Handlers = [
     http.get('/api/<feature>', () => {
       return HttpResponse.json(mock<Feature>ListSuccess)
     }),
   ]
   ```

   同时更新 `devtools/mocks/handlers.ts` 汇总文件，import 新功能的 handlers。

5. **创建前端组件模板**（如果项目有前端框架）

   检测项目使用的框架（React/Vue），生成对应的组件骨架：

   ```typescript
   // src/components/<Feature>/<Feature>List.tsx (React 示例)
   import { useEffect, useState } from 'react'

   export function <Feature>List() {
     const [data, setData] = useState(null)
     const [loading, setLoading] = useState(true)
     const [error, setError] = useState(null)

     useEffect(() => {
       fetch('/api/<feature>')
         .then(res => res.json())
         .then(json => {
           if (json.code !== 0) throw new Error(json.message)
           setData(json.data)
         })
         .catch(err => setError(err.message))
         .finally(() => setLoading(false))
     }, [])

     if (loading) return <div>加载中...</div>
     if (error) return <div>错误: {error}</div>
     if (!data?.items.length) return <div>暂无数据</div>

     return (
       <div>
         {/* TODO: 根据 UI 设计填充展示内容 */}
         {data.items.map(item => (
           <div key={item.id}>{JSON.stringify(item)}</div>
         ))}
       </div>
     )
   }
   ```

6. **提示用户下一步**

   ```
   ✅ Frontend-First 功能「<feature>」已创建

   已生成：
   - openspec/specs/<feature>/proposal.md（需求文档）
   - devtools/mocks/data/<feature>/<feature>.mock.ts（Mock 数据模板）
   - devtools/mocks/data/<feature>/handlers.ts（MSW Handler）
   - src/components/<Feature>/<Feature>List.tsx（前端组件骨架）

   下一步：
   1. 在浏览器中运行项目，开始设计 UI（Step 2）
   2. 根据 UI 需要，补充 Mock 数据中的字段
   3. 满意后运行 /opsx:ff-freeze 冻结 UI（Step 3）
   ```

**Output**

- `proposal.md`（需求文档）
- Mock 数据模板（符合 api-convention.md 约束）
- MSW Handler 模板
- 前端组件骨架

**Guardrails**

- Mock 数据**必须**使用 `{ code: 0, message: "success", data: { ... } }` 信封格式
- 分页**必须**使用扁平结构 `{ items, total, page, page_size }`
- 字段名**必须**使用 snake_case
- 错误响应**必须**使用 6 位错误码
- 不要在模板中添加"将来可能用到"的字段——让用户在 Step 2 迭代中按需添加
