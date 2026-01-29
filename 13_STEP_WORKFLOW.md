# 13 步契约优先开发工作流详细说明

本文档详细说明 OpenSpec Fullstack Template 的 13 步契约优先开发工作流。

## 📋 工作流概览

| Phase | Steps | 阶段名称 | 产出物 | 状态 |
|-------|-------|---------|--------|------|
| **Phase 0** | Step 1 | 初始化 | 技术栈分析、基础设施规范 | 可选 |
| **Phase 1** | Steps 2-4 | 定义阶段 | proposal.md, spec.md | 必需 |
| **Phase 2** | Step 5 | 设计分离 | design.md | 必需 |
| **Phase 3** | Steps 6-7 | 前端 Mock 开发 | Mock 数据 + 前端代码 | 按模式 |
| **Phase 4** | Step 8 | 后端骨架 | 后端 API 骨架（返回 Mock） | 按模式 |
| **Phase 5** | Step 9 | 契约测试 | E2E 测试用例 | 按模式 |
| **Phase 6** | Step 10 | 真实实现 | 完整后端实现 | 按模式 |
| **Phase 7** | Steps 11-12 | 真实验证 | 测试报告、Drift 检查 | 按模式 |
| **Phase 8** | Step 13 | 归档 | 归档文档 | 必需 |

---

## Phase 0: 初始化（Step 1）

### Step 1: 技术栈分析与基础设施设置

**目标**：建立项目技术基础和基础设施规范

**任务**：

1. **Task 0.1**: 分析技术栈并映射项目结构
   - ✅ 通过上下文注入自动完成
   - 参考：`context/tech_stack.md`, `context/project_summary.md`

2. **Task 0.2**: 设置基础设施组件（可选，仅新项目需要）
   - 审查 `infrastructure.md` 获取基础模式
   - 安装日志库（如 winston, pino, structlog）
   - 配置结构化日志（支持 trace_id）
   - 定义错误码常量（参考 infrastructure.md）
   - 实现 StandardResp 包装工具
   - 设置中间件管道（auth, validation, logging, error handler）
   - **注意**：如果项目已有基础设施，跳过此任务

**产出物**：
- `infrastructure.md`（可选）- 基础设施规范文档

**何时执行**：
- 新项目初始化时
- 重大基础设施重构时

---

## Phase 1: 定义阶段（Steps 2-4）

### Step 2: 提案（Proposal）

**目标**：明确 WHY - 为什么需要这个变更

**任务**：

- **Task 1.1**: 起草提案文档

**必需章节**：

1. **背景与目标（Background & Goals）**
   - 要解决什么问题？为什么现在做？
   - 业务价值和预期成果

2. **非目标（Non-Goals）** ⚠️ 必须明确定义
   - 本次变更不会涉及的内容
   - 范围边界

3. **用户故事（User Stories）**
   - 格式：作为 [用户类型]，我想要 [操作]，以便 [收益]
   - 包含验收标准

4. **边界情况与风险（Edge Cases & Risks）** ⚠️ 必须明确定义
   - 潜在失败场景
   - 风险缓解策略

5. **影响（Impact）**
   - 受影响的代码、API、依赖或系统
   - 破坏性变更（标记为 **BREAKING**）

**产出物**：
- `proposal.md` - 提案文档（1-2 页，聚焦"为什么"而非"如何"）

---

### Step 3: 验证（Validation）

**目标**：验证提案逻辑的正确性

**任务**：

- **Task 1.2**: 验证提案逻辑
  - ✅ 用户验证完成
  - 确认需求理解正确
  - 确认范围合理

**产出物**：
- 验证通过的提案

---

### Step 4: 规格说明（Spec）

**目标**：创建 API 规格说明，作为**唯一真相源（Source of Truth）**

**任务**：

- **Task 1.3**: 定义规格说明

**必需章节**：

1. **概览（Overview）**
   - 功能 API 的简要描述

2. **API 端点（API Endpoints）** - 每个端点包含：
   ```
   ### `METHOD /path`
   **摘要**: 端点描述
   
   **请求**:
   ```json
   { /* 请求体示例 */ }
   ```
   
   **响应**（成功）:
   ```json
   {
     "code": 0,
     "message": "success",
     "data": { /* 响应数据 - 必须遵循 StandardResp */ }
   }
   ```
   
   **响应**（错误）:
   ```json
   {
     "code": 1000,
     "message": "Invalid Parameter",
     "data": null,
     "error_details": { "field": "xxx", "reason": "xxx", "trace_id": "uuid" }
   }
   ```
   
   **错误码**: 参考 infrastructure.md
   **日志要求**: 此端点需要记录什么
   ```

3. **数据库 Schema**（如适用）：
   - 表定义（列、类型、可空性）
   - 索引和约束
   - 从 JSON 响应生成种子数据示例

4. **验证清单**：
   - [ ] 所有端点都有 JSON 请求/响应示例
   - [ ] 所有响应遵循 StandardResp 结构
   - [ ] 数据库表定义了必要的索引
   - [ ] 错误码遵循 infrastructure.md 标准
   - [ ] 指定了日志要求

**重要**：JSON 示例将在 Phase 3 中用作 Mock 数据。

**产出物**：
- `spec.md` - API 规格说明文档（包含完整的 JSON 示例）

---

## Phase 2: 设计分离（Step 5）

### Step 5: 前后端架构分离

**目标**：明确 HOW - 如何实现变更

**任务**：

- **Task 2.1**: 前端组件设计
- **Task 2.2**: 后端控制器接口设计

**首先确定开发模式**：
- **fullstack**: 完整前端 + 后端 + 中间件（默认）
- **frontend-only**: 前端开发，使用 Mock 后端
- **backend-only**: 后端 API 开发，无前端
- **middleware-only**: 中间件/基础设施开发

**必需章节**：

1. **开发模式配置**
   - 选择的模式及理由
   - 模式特定考虑事项

2. **前端架构**（除非 backend-only）：
   - 组件树和描述
   - 状态管理方法
   - Mock 策略（使用 spec.md 中的 JSON）
   - API 集成（客户端、拦截器、错误处理）
   - 路由（如适用）

3. **后端架构**（除非 frontend-only）：
   - 路由位置和端点
   - 业务逻辑（Service 类、方法）
   - DB 操作（表、查询、事务）
   - 中间件集成（auth, validation, logging）
   - 外部依赖

4. **中间件架构**：
   - 中间件组件
   - 执行顺序
   - 参考 infrastructure.md 获取模式

5. **验证计划**：
   - 单元测试范围
   - 集成测试范围
   - 契约验证方法

6. **开发工作流**（Phase 3-6 预览）：
   - Phase 3: 前端 Mock 开发步骤
   - Phase 4: 后端骨架步骤
   - Phase 5: 契约测试步骤
   - Phase 6: 实现步骤

7. **基础设施集成**：
   - 日志要求
   - 错误处理方法
   - 请求/响应格式合规性

**产出物**：
- `design.md` - 设计文档

---

## Phase 3: 前端 Mock 开发（Steps 6-7）

### Step 6: Mock 数据开发

**目标**：使用 Mock 数据实现前端功能

**任务**：

- **Task 3.1**: 使用 Mock 数据实现前端
  - 创建符合 `StandardResp` 格式的 Mock 数据（来自 `spec.md` JSON 示例）
  - 实现 UI 组件：[列出具体组件路径]
  - 实现 API 客户端（添加 X-Request-ID 请求拦截器）
  - 实现 StandardResp 格式的错误处理
  - 处理 loading/error/empty 状态

**约束**：
- Mock 数据必须完全匹配 `spec.md` 中的 JSON 示例
- 必须遵循 StandardResp 格式
- 必须包含 X-Request-ID 头

**产出物**：
- Mock 数据文件
- 前端组件代码
- API 客户端代码

---

### Step 7: 前端验证

**目标**：验证前端功能正常工作

**任务**：

- **Task 3.2**: 验证前端功能
  - 验证数据渲染和交互逻辑（本地）
  - 测试 loading 状态
  - 使用 Mock 错误响应测试错误状态
  - 测试空状态
  - 验证 Mock 数据与 `spec.md` 示例匹配

**产出物**：
- 验证通过的前端功能

**跳过条件**：
- 如果 `dev_mode: backend-only`，跳过 Phase 3

---

## Phase 4: 后端骨架（Step 8）

### Step 8: 控制器骨架（返回静态 Mock）

**目标**：创建后端 API 骨架，返回静态 Mock 数据

**任务**：

- **Task 4.1**: 实现控制器骨架
  - 目标：创建/更新路由文件：[具体路由文件路径]
  - **约束**：返回 `spec.md` 中的**静态 JSON**。**不连接数据库**。
  - 实现中间件集成（auth, validation, logging）
  - 添加 X-Request-ID 头处理
  - 返回 StandardResp 格式的 Mock 数据
  - 实现错误响应（使用 `infrastructure.md` 中的错误码）

**关键约束**：
- ⚠️ **禁止数据库连接**
- ⚠️ **必须返回静态 JSON**（来自 spec.md）
- ✅ 必须遵循 StandardResp 格式
- ✅ 必须集成中间件

**产出物**：
- 后端 API 骨架代码（返回 Mock 数据）

**跳过条件**：
- 如果 `dev_mode: frontend-only`，跳过 Phase 4

---

## Phase 5: 契约测试（Step 9）

### Step 9: E2E 测试（Mock 模式）

**目标**：编写并运行契约测试，确保 API 符合 Spec

**任务**：

- **Task 5.1**: 运行 E2E 测试（Mock 模式）
  - 编写测试以验证骨架 API
  - 验证响应格式匹配 `spec.md`
  - 测试错误响应和错误码
  - 验证响应中的 trace_id
  - **约束**：所有响应必须遵循 StandardResp 结构

**产出物**：
- E2E 测试用例
- 测试报告

**跳过条件**：
- 如果 `dev_mode: frontend-only`，跳过 Phase 5

---

## Phase 6: 真实实现（Step 10）

### Step 10: 服务实现与数据库迁移

**目标**：实现真实的业务逻辑和数据库操作

**任务**：

#### Task 6.1: 数据库模型与迁移

- 创建表迁移：[具体表名列表]
- 更新 ORM 模型
- **从 `spec.md` JSON 示例生成种子数据**（用于 dev/test 数据库）
- 验证索引按 `spec.md` 中的指定创建

#### Task 6.2: 实现服务逻辑

- 在以下位置实现业务逻辑：[具体服务类路径]
- 用真实 DB 查询替换 Mock 返回
- **约束**：
  - ✅ **必须包含结构化日志**（关键字段：trace_id, user_id, duration_ms）
  - ✅ 记录慢操作（>1s）的持续时间指标
  - ✅ 记录所有错误及完整上下文（堆栈跟踪、请求参数）
  - ✅ 使用 `infrastructure.md` 中的错误码
  - ✅ 所有响应返回 StandardResp 格式
  - ✅ 错误响应中包含 error_details 和 trace_id
- 使用中间件实现请求验证
- 在需要的地方添加身份验证检查

#### Task 6.3: 连接前端到真实后端

- 更新 API 客户端使用真实后端 URL
- 移除 Mock 服务器/数据
- 使用真实 API 测试前端
- 使用真实错误响应验证错误处理

**产出物**：
- 数据库迁移文件
- 服务类实现
- 更新的前端 API 客户端

**跳过条件**：
- 如果 `dev_mode: frontend-only`，跳过 Task 6.1 和 6.2
- 如果 `dev_mode: backend-only`，跳过 Task 6.3

---

## Phase 7: 真实验证（Steps 11-12）

### Step 11: 真实数据库测试

**目标**：使用真实数据库运行测试

**任务**：

- **Task 7.1**: 运行测试（真实 DB）
  - 使用测试数据库执行测试
  - 命令：`[项目特定的测试命令]`
  - 验证 `spec.md` 中的所有场景

**产出物**：
- 测试报告

---

### Step 12: 代码与 Spec 审计（Drift Check）

**目标**：检查实现是否偏离契约

**任务**：

- **Task 7.2**: 审计代码与 Spec（自动化 Drift 检查）
  - 验证 OpenAPI schema 匹配 `spec.md` 定义
  - 将响应结构与 Spec 示例进行比较
  - **约束**：Drift 率必须 < 1%（字段名、类型、必需状态）

**产出物**：
- Drift 检查报告

**跳过条件**：
- 如果 `dev_mode: frontend-only`，跳过 Phase 7

---

## Phase 8: 归档（Step 13）

### Step 13: 归档

**目标**：归档已完成的变更

**任务**：

- **Task 8.1**: 准备归档
  - 验证所有任务已完成
  - 运行 `openspec archive`
  - 将变更移动到归档目录

**产出物**：
- 归档文档

---

## 📊 进度跟踪

### 进度摘要表

| Phase | Steps | 状态 | 备注 |
|-------|-------|------|------|
| Phase 0 | Step 1 | ✅ Done | 技术栈与基础设施 |
| Phase 1 | Steps 2-4 | ✅ Done | 提案与 Spec |
| Phase 2 | Step 5 | ✅ Done | 设计分离 |
| Phase 3 | Steps 6-7 | ⏳ Pending | 前端 Mock 开发 |
| Phase 4 | Step 8 | ⏳ Pending | 后端骨架 |
| Phase 5 | Step 9 | ⏳ Pending | 契约测试 |
| Phase 6 | Step 10 | ⏳ Pending | 实现 |
| Phase 7 | Steps 11-12 | ⏳ Pending | 验证 |
| Phase 8 | Step 13 | ⏳ Pending | 归档 |

---

## 🔀 开发模式调整

### 模式特定任务状态

**如果 frontend-only**：
- Phase 4 (Task 4.1): 跳过
- Phase 6 (Task 6.1, 6.2): 跳过
- Phase 7: 跳过

**如果 backend-only**：
- Phase 3 (Task 3.1, 3.2): 跳过
- Phase 6 (Task 6.3): 跳过

**如果 fullstack**：
- 所有任务都需要

**如果 middleware-only**：
- Phase 3: 跳过
- Phase 4: 仅中间件相关部分
- Phase 6: 仅中间件实现

---

## 🎯 核心原则

1. **Spec First** - 先写 Spec，再写实现
2. **Mock Before Real** - 先 Mock，后真实
3. **Contract as Truth** - Spec 是唯一真相源
4. **Verify at Every Gate** - 每个 Phase 验证

---

## 📝 关键约束

### Phase 3-4（Mock 阶段）
- ✅ 使用 `spec.md` JSON 示例作为 Mock 数据
- ✅ Phase 4 返回静态 JSON，**不连接数据库**

### Phase 6（实现阶段）
- ✅ 用真实实现替换 Mock
- ✅ 必须包含结构化日志（trace_id, duration_ms）
- ✅ 使用 `infrastructure.md` 中的错误码

### Phase 7（验证阶段）
- ✅ Drift 率必须 < 1%

### 基础设施合规性
- ✅ 所有响应遵循 StandardResp 格式
- ✅ 请求中包含 X-Request-ID
- ✅ 使用 `infrastructure.md` 中的错误码
- ✅ 实现结构化日志（trace_id）

---

## 📚 参考文档

- `proposal.md` - 提案文档
- `spec.md` - API 规格说明（唯一真相源）
- `design.md` - 设计文档
- `tasks.md` - 任务跟踪文档
- `infrastructure.md` - 基础设施规范
- `context/project_summary.md` - 项目上下文
- `context/tech_stack.md` - 技术栈信息
