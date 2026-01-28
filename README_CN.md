# OpenSpec Fullstack Template

> 13 步契约优先开发工作流模板，适用于全栈项目。通过 Spec First、Mock Before Real 的原则，解决前后端接口不一致、联调成本高的问题。

## ✨ 特性

- 🎯 **契约优先**：先写 Spec，再写实现，确保前后端一致
- 🚀 **Mock 先行**：前端先基于 Mock 开发，后端后实现，并行开发
- ✅ **自动验证**：每个阶段自动验证，确保实现符合契约
- 📋 **内置规范**：内置开发规范检查，避免常见问题
- 🔄 **完整工作流**：从提案到归档的 13 步完整流程
- 🏗️ **基础架构模板**：内置日志、错误处理、统一响应格式等基础设施规范
- 🔀 **独立开发模式**：支持前端、后端、中间件独立开发
- 📝 **错误码系统**：标准化的错误码定义（1xxx-5xxx）
- 🔍 **结构化日志**：支持 trace_id 的结构化日志系统

## 🚀 快速开始

### 1. 克隆模板

```bash
git clone https://github.com/anthropics/openspec-fullstack-template.git
cd openspec-fullstack-template
```

### 2. 复制到你的项目

```bash
# 复制 OpenSpec 配置
cp -r openspec-fullstack-template/openspec/ your-project/openspec/

# 复制 Cursor Skills（可选，放到 .cursor/skills/）
cp -r openspec-fullstack-template/skills/ your-project/.cursor/skills/
```

### 3. 初始化项目上下文

```bash
cd your-project/openspec/context/

# 重命名模板文件
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md

# 编辑填写项目信息
```

### 4. 更新配置

编辑 `openspec/config.yaml`，替换 `{{ PROJECT_NAME }}` 为你的项目名。

**可选：配置开发模式**

```yaml
# 开发模式选择（影响设计和任务生成）
dev_mode: fullstack  # 可选: fullstack, frontend-only, backend-only, middleware-only
```

- **fullstack**（默认）：完整的前后端 + 中间件开发
- **frontend-only**：仅前端开发，使用 Mock 后端
- **backend-only**：仅后端 API 开发
- **middleware-only**：仅中间件/基础设施开发

### 5. 可选：生成基础架构规范

对于新项目，可以先生成基础架构规范：

```bash
# 在 Cursor 中使用
/opsx:new infrastructure

# 这将生成 infrastructure.md，包含：
# - 日志系统规范
# - 错误处理和错误码定义
# - 请求/响应格式标准
# - 中间件架构模式
# - 控制台输出格式
```

### 6. 开始使用

在 Cursor 中使用以下命令：

```bash
# 新手引导
/opsx:onboard

# 创建新变更
/opsx:new <name>       # 逐步创建 artifacts
/opsx:ff <name>        # 快速生成所有 artifacts

# 实现和验证
/opsx:apply <name>     # 实现任务
/opsx:check-standards  # 检查开发规范
/opsx:verify <name>    # 验证实现

# 归档
/opsx:archive <name>   # 归档完成的变更
```

## 📁 目录结构

```
openspec-fullstack-template/
├── openspec/                      # OpenSpec 配置
│   ├── config.yaml               # 入口配置（支持 dev_mode）
│   ├── schemas/
│   │   └── workflow/              # 13 步工作流 schema
│   │       ├── schema.yaml       # workflow 定义
│   │       └── templates/        # artifact 模板
│   │           ├── infrastructure.md
│   │           ├── proposal.md
│   │           ├── spec.md
│   │           ├── design.md
│   │           └── tasks.md
│   └── context/                  # 项目上下文
│       ├── project_summary.template.md
│       └── tech_stack.template.md
│
├── skills/                        # Cursor Skills
│   ├── openspec-new-change/      # 创建新变更
│   ├── openspec-continue-change/ # 继续创建 artifacts
│   ├── openspec-ff-change/       # 快速生成 artifacts
│   ├── openspec-apply-change/    # 实现任务
│   ├── openspec-check-standards/ # 检查开发规范
│   ├── openspec-verify-change/   # 验证实现
│   ├── openspec-archive-change/  # 归档变更
│   ├── openspec-bulk-archive-change/ # 批量归档
│   ├── openspec-explore/         # 探索模式
│   ├── openspec-onboard/         # 新手引导
│   └── openspec-sync-specs/      # 同步 specs
│
├── init.sh                       # 初始化脚本（可选）
├── validate.sh                   # 验证脚本（15 项检查）
└── README.md                     # 英文文档
```

## 🔄 13 步工作流

| 阶段 | 步骤 | 描述 | 产出物 |
|------|------|------|--------|
| **Phase 0** | Step 1 | 技术栈分析 | 技术栈文档 |
| **Phase 1** | Steps 2-4 | 提案 → 验证 → Spec（契约） | `proposal.md`, `spec.md` |
| **Phase 2** | Step 5 | 前后端设计分离 | `design.md` |
| **Phase 3** | Steps 6-7 | 前端 Mock 开发 → 验证 | Mock 数据 + 前端代码 |
| **Phase 4** | Step 8 | 后端骨架（返回静态 Mock） | 后端 API 骨架 |
| **Phase 5** | Step 9 | E2E 契约测试 | 测试用例 |
| **Phase 6** | Step 10 | 真实实现（DB + Service） | 完整后端实现 |
| **Phase 7** | Steps 11-12 | 真实测试 → Drift Check | 测试报告 |
| **Phase 8** | Step 13 | 归档 | 归档文档 |

### 工作流说明

1. **Phase 0-1**：明确需求，生成契约（Spec）
2. **Phase 2**：前后端设计分离，明确职责边界
3. **Phase 3-4**：前端基于 Mock 开发，后端提供 Mock API
4. **Phase 5**：编写契约测试，确保 API 符合 Spec
5. **Phase 6**：实现真实后端逻辑
6. **Phase 7**：运行测试，检查实现是否偏离契约
7. **Phase 8**：归档完成的变更

## 📋 开发规范（内置）

### 数据处理

- ❌ **禁止前端分页、排序、过滤**
- ❌ **禁止伪分页**（前端分页后端全量数据）
- ✅ **使用服务端分页**

### API 设计

- ✅ 列表 API 必须支持 `page` + `page_size`
- ✅ 必须返回 `total_count`
- ❌ 禁止 `page_size > 100`
- ✅ 使用统一的响应格式（StandardResp）

### 前端规范

- ✅ 必须展示 Loading/Empty/Error 状态
- ✅ API 调用通过数据获取库（如 React Query）
- ✅ 日期/金额格式化在前端完成

### 后端规范

- ✅ 列表查询默认 `limit = 20`
- ✅ 使用参数化查询（防止 SQL 注入）
- ✅ 慢查询（>1s）记录日志
- ✅ 搜索、排序、分页在后端完成

## 🏗️ 基础架构规范

### 错误码系统

| 范围 | 类别 | 说明 |
|------|------|------|
| 1xxx | 客户端错误 | 无效输入、验证失败 |
| 2xxx | 业务逻辑错误 | 业务规则违反 |
| 3xxx | 外部服务错误 | 第三方 API 失败 |
| 4xxx | 系统错误 | 数据库、网络、基础设施 |
| 5xxx | 未知错误 | 意外异常 |

**常用错误码**：
- `1000`: Invalid Parameter（无效参数）
- `1001`: Validation Failed（验证失败）
- `1002`: Unauthorized（未授权）
- `2000`: Resource Not Found（资源不存在）
- `4000`: Database Error（数据库错误）
- `5000`: Internal Server Error（内部服务器错误）

### 统一响应格式（StandardResp）

```typescript
interface StandardResp<T> {
  code: number;        // 0 表示成功，其他为错误码
  message: string;     // 人类可读的消息
  data: T | null;      // 响应数据（错误时为 null）
}
```

**成功响应示例**：
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "Example"
  }
}
```

**错误响应示例**：
```json
{
  "code": 1000,
  "message": "Invalid Parameter",
  "data": null,
  "error_details": {
    "field": "email",
    "reason": "Invalid email format",
    "trace_id": "uuid-v4"
  }
}
```

### 结构化日志

```json
{
  "timestamp": "2024-01-28T10:30:00.000Z",
  "level": "INFO",
  "service": "user-service",
  "trace_id": "uuid-v4",
  "message": "User login successful",
  "context": {
    "user_id": 12345,
    "duration_ms": 150
  }
}
```

**日志级别**：
- **DEBUG**: 开发调试
- **INFO**: 正常操作
- **WARN**: 可恢复问题
- **ERROR**: 应用错误
- **CRITICAL**: 系统故障

### 中间件架构

**标准中间件执行顺序**：
1. CORS（首先）
2. Request ID 生成
3. 日志（请求开始）
4. 认证
5. 验证
6. 业务逻辑处理器
7. 日志（响应）
8. 错误处理器（最后）

### 开发模式支持

| 模式 | 说明 | 适用场景 |
|------|------|----------|
| **fullstack** | 完整前后端 + 中间件 | 端到端功能开发 |
| **frontend-only** | 仅前端 + Mock 后端 | 前端独立开发 |
| **backend-only** | 仅后端 API | 后端独立开发 |
| **middleware-only** | 仅中间件/基础设施 | 基础设施开发 |

## 🎯 核心原则

1. **Spec First** - 先写 Spec，再写实现
2. **Mock Before Real** - 先 Mock，后真实
3. **Contract as Truth** - Spec 是唯一真相源
4. **Verify at Every Gate** - 每个 Phase 验证

## 🔧 自定义配置

### 配置开发模式

编辑 `openspec/config.yaml`：

```yaml
# 开发模式选择
dev_mode: fullstack  # 可选: fullstack, frontend-only, backend-only, middleware-only
```

**使用场景**：
- **fullstack**：团队协作，前后端同步开发
- **frontend-only**：前端先行，使用 Mock 数据快速迭代 UI
- **backend-only**：后端先行，专注 API 和业务逻辑
- **middleware-only**：基础设施开发，如认证、日志、错误处理

### 自定义工作流

编辑 `openspec/schemas/workflow/schema.yaml` 自定义工作流步骤。
编辑 `openspec/schemas/workflow/templates/*.md` 自定义 artifact 模板。

### workflow schema 注意事项

workflow schema 使用 13-Step Contract-First 流程，与默认的 spec-driven schema 有以下区别：

| 功能 | spec-driven | workflow |
|------|-------------|----------|
| Spec 结构 | `specs/` 目录（多文件） | 单一 `spec.md` |
| 验证命令 | `openspec validate` | 通过 apply 检查 |
| Proposal 格式 | `## Why` / `## What Changes` | `## Background & Goals` / `## Non-Goals` |

**重要**：`openspec validate` 命令是为 spec-driven 设计的，workflow schema 请使用 `openspec instructions apply --json` 检查任务完成状态。

**注意**：
- 核心的 13 步工作流结构应保持不变
- `infrastructure` artifact 是可选的（`optional: true`）
- 可以添加自定义的 rules 和 dependencies

### 添加项目上下文

在 `openspec/context/` 目录下添加更多上下文文件，并在 `config.yaml` 中配置：

```yaml
global_context:
  - "context/project_summary.md"
  - "context/tech_stack.md"
  - "context/infrastructure.md"  # 基础架构规范
  - "context/custom_context.md"  # 自定义上下文
```

## 📚 相关资源

- [OpenSpec 文档](https://github.com/anthropics/openspec)
- [Cursor Skills 文档](https://cursor.sh/docs)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

MIT
