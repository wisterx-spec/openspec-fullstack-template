# Project Context: {{ PROJECT_NAME }}

## Domain
{{ PROJECT_NAME }} - {{ PROJECT_DESCRIPTION }}

**核心业务场景**：
- <!-- 业务场景 1 -->
- <!-- 业务场景 2 -->
- <!-- 业务场景 3 -->

## Tech Stack
- **Language/Runtime**: <!-- e.g., Python 3.11, Node.js -->
- **Frameworks**: <!-- e.g., FastAPI, React 18 -->
- **Database/ORM**: <!-- e.g., PostgreSQL + SQLAlchemy -->
- **Testing**: <!-- e.g., Pytest, Playwright -->
- **Infrastructure**: <!-- e.g., Docker, Kubernetes -->

## Project Structure
- **Backend Entry**: <!-- e.g., backend/app/main.py -->
- **Frontend Entry**: <!-- e.g., frontend/src/main.tsx -->
- **API Routers**: <!-- e.g., backend/app/routers/ -->
- **Business Classes**: <!-- e.g., backend/app/business/ -->
- **Tests**: <!-- e.g., backend/tests/, frontend/e2e/ -->

## Architecture Patterns
- <!-- 架构模式 1: 描述 -->
- <!-- 架构模式 2: 描述 -->
- <!-- 架构模式 3: 描述 -->

## Conventions
- **Naming**: 
  - Python: `snake_case`
  - TypeScript: `camelCase`
  - React Components: `PascalCase`
- **API Response**: `StandardResp {"code": int, "message": str, "data": Any}`
- **Docs/Comments**: <!-- 语言偏好 -->
- **Commit Style**: Conventional Commits (`type: description`)

## Constraints (Critical)
1. <!-- 关键约束 1 -->
2. <!-- 关键约束 2 -->
3. <!-- 关键约束 3 -->

## Development Standards (严格执行)

### 数据处理规范 (禁止前端处理大数据)
| 禁止项 | 原因 | 正确做法 |
|--------|------|----------|
| 前端分页 | 需加载全量数据，内存爆炸 | 使用后端分页 |
| 前端排序 | 大数据集排序冻结 UI | 后端 ORDER BY |
| 前端过滤/搜索 | 无法利用数据库索引 | 后端 WHERE 条件 |
| 伪分页 | 本质是全量加载 | 真正的服务端分页 |

### API 设计约束
- 列表 API **必须**支持 `page` + `page_size` 参数
- 列表 API **必须**返回 `total_count` 字段
- 单次查询 **禁止** `page_size > 100`（防内存溢出）
- **禁止**无 LIMIT 的 SELECT 查询

### 前端约束
- 表格/列表组件 **必须**使用服务端分页模式
- **必须**展示 Loading 状态（骨架屏或 Spinner）
- **必须**处理空状态和错误状态
- API 调用 **必须**通过数据获取库（如 React Query）

### 后端约束
- 列表查询 **必须**有默认 `limit`（建议值: 20）
- **必须**使用参数化查询（防 SQL 注入）
- 慢查询（>1s）**必须**记录日志

### 数据存储约定
- <!-- 如有特殊存储约定，在此定义 -->

## External Dependencies
- <!-- 外部依赖 1: 描述 -->
- <!-- 外部依赖 2: 描述 -->

## 13-Step Workflow (SOP)
所有开发任务必须遵循严格的 13 步契约优先流程：

- **Phase 0: Initialization**
  - Step 1: Tech Stack Analysis
- **Phase 1: Definition**
  - Step 2: Proposal (User Stories)
  - Step 3: Validation
  - Step 4: Spec + JSON Examples (The Source of Truth)
- **Phase 2: Design Split**
  - Step 5: FE/BE Architecture Split
- **Phase 3: Frontend Mock Dev**
  - Step 6: Mock Data Dev
  - Step 7: Frontend Verification
- **Phase 4: Backend Skeleton**
  - Step 8: Controller Skeleton (Static Mock Return)
- **Phase 5: Contract Testing**
  - Step 9: E2E Testing against Skeleton
- **Phase 6: Implementation**
  - Step 10: Service Implementation & DB Migrations
- **Phase 7: Real Verification**
  - Step 11: Real DB Testing
  - Step 12: Drift Check
- **Phase 8: Archive**
  - Step 13: Archiving
