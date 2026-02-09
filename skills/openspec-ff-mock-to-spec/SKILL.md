---
name: openspec-ff-mock-to-spec
description: 从冻结的 Mock 数据反推 API Spec。在 Frontend-First 流程 Step 4 使用——读取 Mock 数据文件和前端组件，自动生成 spec.md。这是 Frontend-First 流程的核心步骤。
license: MIT
compatibility: Works with any frontend project using the Frontend-First workflow.
metadata:
  author: openspec
  version: "1.0"
---

从冻结的 Mock 数据和前端组件代码反推 API Spec，生成 spec.md。

**前提条件：** Step 3 UI Freeze 已完成，Mock 数据已冻结。

**Input**: 功能名称（feature name）。如果未提供，尝试从对话上下文推断；如果不明确，提示用户选择。

**Steps**

1. **定位 Mock 数据文件**

   搜索 `devtools/mocks/data/` 目录，找到与功能相关的 Mock 文件：
   - `devtools/mocks/data/<feature>/*.mock.ts`
   - `devtools/mocks/data/<feature>.mock.ts`
   - `devtools/mocks/data/<feature>/*.mock.json`

   如果找到多个文件，列出并让用户确认范围。
   如果找不到，提示用户：Mock 数据是否已创建并冻结？

2. **读取 Mock 数据，提取响应结构**

   从 Mock 数据文件中提取：

   **a. 响应顶层结构**
   ```
   {
     code: number,
     message: string,
     data: { ... }     ← 这是核心
   }
   ```

   **b. data 内部结构**（逐字段）
   对每个字段记录：
   - 字段名（原样保留，大小写敏感）
   - 数据类型（从实际值推断：string / number / boolean / null / array / object）
   - 是否可选（如果任何一条测试数据中该字段为 null → 标记可选）
   - 嵌套结构（如果是 object/array，递归提取）
   - 枚举值（如果多条数据的同一字段值有限集合，如 status: "active" | "inactive"）

   **c. 边界数据**
   - 是否有空数组（`items: []`）的 Mock 响应
   - 是否有 null 值的字段
   - 记录哪些边界情况有 Mock 数据覆盖

3. **读取前端组件，提取请求参数**

   搜索与功能相关的前端组件文件（`src/components/`、`src/pages/`），查找：

   **a. 筛选器（Filter）**
   - 搜索模式：`<Select>`、`<Dropdown>`、`filter`、`onChange` 与数据查询关联的组件
   - 每个筛选器 → 对应一个 API query 参数
   - 记录：参数名、类型、可选值

   **b. 搜索框（Search）**
   - 搜索模式：`<Input>` + `search`、`keyword`、`query`
   - → 对应 `search` 或 `keyword` 参数
   - 记录：搜索哪些字段（如果前端代码有说明）

   **c. 排序（Sort）**
   - 搜索模式：`sortBy`、`sort_by`、`orderBy`、`<Table>` 的 `sorter` 属性
   - → 对应 `sort_by` + `sort_order` 参数
   - 记录：可排序的字段列表

   **d. 分页（Pagination）**
   - 搜索模式：`<Pagination>`、`page`、`pageSize`、`page_size`
   - → 对应 `page` + `page_size` 参数
   - 记录：是否需要 `total` / `total_count`

   **e. 其他交互**
   - 表单提交 → POST/PUT 请求参数
   - 删除按钮 → DELETE 请求
   - 详情页链接 → GET 单条记录的参数（通常是 id）

   如果无法从代码中确定某个参数的名称或类型，**使用 AskUserQuestion 工具询问用户**。

4. **确定 API 设计**

   基于提取的信息，向用户确认：

   使用 **AskUserQuestion 工具** 逐一确认：
   - HTTP 方法和路径（例如：`GET /api/users`）
   - 如果一个功能涉及多个 endpoint（列表 + 详情 + 创建），逐一确认
   - 有疑问的参数名或类型

   **原则：**
   - 响应结构 100% 复制 Mock 数据，不做任何"优化"
   - 请求参数从前端组件反推，名称尽量与前端代码中使用的一致
   - 不要添加"将来可能用到"的字段
   - 响应信封、分页格式、错误码、字段命名风格必须遵守 `openspec/conventions/api-convention.md`

5. **生成 spec.md**

   按以下结构生成：

   ```markdown
   # API Spec: <功能名称>

   > 此 Spec 由 Mock 数据反推生成（Frontend-First Step 4）
   > Mock 数据版本：<冻结日期>
   > 生成日期：<当前日期>

   ## 接口列表

   | 方法 | 路径 | 功能 |
   |------|------|------|
   | GET  | /api/<resource> | <描述> |

   ---

   ## <接口1>: <方法> <路径>

   ### 功能
   <一句话描述>

   ### 请求参数
   | 参数名 | 类型 | 必填 | 说明 | 示例 | 来源 |
   |--------|------|------|------|------|------|
   | page | number | 否 | 页码，默认1 | 1 | 分页组件 |
   | page_size | number | 否 | 每页条数，默认20，最大100 | 20 | 分页组件 |
   | search | string | 否 | 搜索关键词 | "张" | 搜索框 |
   | status | string | 否 | 状态筛选 | "active" | 筛选器 |
   | sort_by | string | 否 | 排序字段 | "created_at" | 表头排序 |
   | sort_order | string | 否 | 排序方向 | "desc" | 表头排序 |

   > "来源"列标注该参数对应前端的哪个组件/交互，方便回溯。

   ### 成功响应 (code: 0)
   ```json
   <直接从 Mock 数据复制>
   ```

   ### 错误响应
   ```json
   {
     "code": 100001,
     "message": "缺少必填参数",
     "data": null
   }
   ```
   > 错误码为 6 位数字，格式 `CCMMSS`，详见 `openspec/conventions/api-convention.md`

   ### 数据字典
   | 字段路径 | 类型 | 必填 | 说明 | 特殊情况 |
   |----------|------|------|------|---------|
   | data.items[].id | number | 是 | 用户ID | - |
   | data.items[].name | string | 是 | 用户名 | - |
   | data.items[].last_login | string|null | 否 | 最后登录时间 | null=从未登录 |
   | data.total | number | 是 | 总记录数 | - |

   ### 业务规则
   1. 筛选、搜索、排序由后端完成（前端只传参数）
   2. 分页默认值：page=1, page_size=20
   3. page_size 最大值：100
   ```

   **对于每个 endpoint 重复上述结构。**

6. **自动一致性检查**

   生成 Spec 后，立即执行 Mock↔Spec 对比：
   - 逐字段检查 Mock 数据中的字段是否都在 Spec 数据字典中
   - 逐字段检查 Spec 数据字典中的字段是否都在 Mock 数据中
   - 检查类型是否一致
   - 输出对比结果

   ```
   ✅ 一致性检查通过：Mock 和 Spec 字段 100% 对齐

   或

   ⚠ 发现 N 处不一致：
   - data.items[].email: Mock 中有，Spec 数据字典中缺失 → 已自动补充
   - data.items[].role: Mock 值 "pending" 不在 Spec 枚举定义中 → 已自动补充
   ```

   如果有不一致，**自动修复 Spec**（因为 Mock 是源头，Spec 要对齐 Mock）。

7. **保存并提示用户 Review**

   将 spec.md 写入 `openspec/specs/<feature>/spec.md`（或 `openspec/changes/<name>/specs/<feature>/spec.md`，取决于是否在 change 上下文中）。

   提示用户：
   ```
   ✅ Spec 已生成

   文件：openspec/specs/<feature>/spec.md
   
   包含：
   - N 个 endpoint
   - M 个请求参数（从前端组件提取）
   - K 个响应字段（从 Mock 数据提取）
   - Mock↔Spec 一致性：100%

   请 Review：
   1. 每个字段的"说明"是否准确？
   2. 业务规则是否完整？
   3. 错误情况是否需要补充？

   确认后，运行 /opsx:ff-freeze-spec（或进入 Step 5 Spec Review）锁定 Spec。
   ```

**Output**

- `spec.md` 文件（完整的 API 契约）
- Mock↔Spec 一致性检查报告
- 请求参数来源追溯表

**与 Spec-First 流程的 Spec 创建的区别**

| 维度 | Spec-First（openspec-continue-change） | Frontend-First（本 Skill） |
|------|---------------------------------------|--------------------------|
| 输入 | proposal.md（需求描述） | Mock 数据 + 前端组件代码 |
| 方法 | 从业务需求正向设计 | 从实际使用场景反向推导 |
| 响应结构 | 开发者设计 | 100% 复制 Mock 数据 |
| 请求参数 | 开发者设计 | 从前端组件交互提取 |
| 验证 | Review 业务完整性 | Mock↔Spec 自动对比 |
| 风险 | 可能遗漏前端需要的字段 | 字段保证与前端一致 |

**Guardrails**

- **Mock 是源头**：Spec 的响应结构必须 100% 复制 Mock 数据，不允许"优化"字段名、改嵌套结构、加未来字段
- **不要猜**：如果无法从 Mock 或组件代码中确定某个信息，问用户
- **来源追溯**：Spec 中每个请求参数都标注"来源"（哪个组件/交互产生了这个参数），方便后续回溯
- **自动对比**：生成后立即校验一致性，不要等到 Step 5 才发现问题
- **一个功能可能有多个 endpoint**：列表、详情、创建、更新、删除——都从同一组 Mock 数据和组件中提取
