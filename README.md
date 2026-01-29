# OpenSpec Fullstack Template

[🇨🇳 中文文档](README_CN.md) | [📖 使用示例](USAGE_EXAMPLES_CN.md) | [📋 优化总结](OPTIMIZATION_SUMMARY_CN.md)

> 13-Step Contract-First Development Workflow template for fullstack projects. Solves frontend-backend API inconsistency and high integration costs through Spec First, Mock Before Real principles.

## ✨ Features

- 🎯 **Contract First**: Write Spec before implementation, ensuring frontend-backend consistency
- 🚀 **Mock First**: Frontend develops with mock data while backend implements later, enabling parallel development
- ✅ **Auto Verification**: Automatic validation at each phase ensures implementation matches contract
- 📋 **Built-in Standards**: Built-in development standard checks to avoid common issues
- 🔄 **Complete Workflow**: 13-step process from proposal to archive
- 🏗️ **Infrastructure Templates**: Built-in logging, error handling, and unified response format specifications
- 🔀 **Independent Dev Modes**: Support for frontend, backend, and middleware independent development
- 📝 **Error Code System**: Standardized error code definitions (1xxx-5xxx)
- 🔍 **Structured Logging**: Structured logging system with trace_id support

## 🚀 Quick Start

### 1. Clone Template

```bash
git clone https://github.com/anthropics/openspec-fullstack-template.git
cd openspec-fullstack-template
```

### 2. Copy to Your Project

```bash
# Copy OpenSpec configuration
cp -r openspec-fullstack-template/openspec/ your-project/openspec/

# Copy Cursor Skills (optional, place in .cursor/skills/)
cp -r openspec-fullstack-template/skills/ your-project/.cursor/skills/
```

### 3. Initialize Project Context

**方式一：使用交互式脚本（推荐）**

```bash
cd your-project
./scripts/init-project.sh
```

脚本会引导你填写项目信息，自动生成 `project_summary.md` 和 `tech_stack.md`。

**方式二：使用 Cursor Skill（最友好）**

在 Cursor 中直接运行：
```
/opsx:init-project
```

AI 会交互式引导你填写信息，自动生成所有必要的文件。

**方式三：手动初始化**

```bash
cd your-project/openspec/context/

# Rename template files
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md

# Edit and fill in project information
```

### 4. Update Configuration

如果使用方式一或方式二，`config.yaml` 会自动更新。否则，手动编辑 `openspec/config.yaml`，替换 `{{ PROJECT_NAME }}` 为你的项目名。

**Optional: Configure Development Mode**

```yaml
# Development mode selection (affects design and task generation)
dev_mode: fullstack  # Options: fullstack, frontend-only, backend-only, middleware-only
```

- **fullstack** (default): Complete frontend + backend + middleware development
- **frontend-only**: Frontend only, using mock backend
- **backend-only**: Backend API development only
- **middleware-only**: Middleware/infrastructure development only

### 5. Optional: Generate Infrastructure Spec

**方式一：在项目初始化时生成（推荐）**

使用 `/opsx:init-project` 或 `./scripts/init-project.sh` 时，会询问是否生成 `infrastructure.md`。

**方式二：单独生成**

```bash
# In Cursor
/opsx:new infrastructure

# This generates infrastructure.md containing:
# - Logging system specification
# - Error handling and error code definitions
# - Request/response format standards
# - Middleware architecture patterns
# - Development mode configuration
```

**方式三：从模板手动创建**

```bash
cd openspec/context/
cp infrastructure.template.md infrastructure.md
# 然后编辑 infrastructure.md，替换 {{ PROJECT_NAME }} 等占位符
```

### 6. Start Using

Use these commands in Cursor:

```bash
# Onboarding guide
/opsx:onboard

# Create new change
/opsx:new <name>       # Step-by-step artifact creation
/opsx:ff <name>        # Fast-forward generate all artifacts

# Implementation and verification
/opsx:apply <name>     # Implement tasks
/opsx:check-standards  # Check development standards
/opsx:verify <name>    # Verify implementation

# Archive
/opsx:archive <name>   # Archive completed change
```

## 📁 Directory Structure

```
openspec-fullstack-template/
├── openspec/                      # OpenSpec configuration
│   ├── config.yaml               # Entry configuration (supports dev_mode)
│   ├── schemas/
│   │   └── workflow/              # 13-step workflow schema
│   │       ├── schema.yaml       # Workflow definition
│   │       └── templates/        # Artifact templates
│   │           ├── infrastructure.md
│   │           ├── proposal.md
│   │           ├── spec.md
│   │           ├── design.md
│   │           └── tasks.md
│   └── context/                  # Project context
│       ├── project_summary.template.md
│       └── tech_stack.template.md
│
├── skills/                        # Cursor Skills
│   ├── openspec-new-change/      # Create new change
│   ├── openspec-continue-change/ # Continue creating artifacts
│   ├── openspec-ff-change/       # Fast-forward artifacts
│   ├── openspec-apply-change/    # Implement tasks
│   ├── openspec-check-standards/ # Check development standards
│   ├── openspec-verify-change/   # Verify implementation
│   ├── openspec-archive-change/  # Archive change
│   ├── openspec-bulk-archive-change/ # Bulk archive
│   ├── openspec-explore/         # Explore mode
│   ├── openspec-onboard/         # Onboarding guide
│   └── openspec-sync-specs/      # Sync specs
│
├── scripts/
│   └── init-project.sh          # Friendly project initialization script
├── init.sh                       # Full initialization script (optional)
├── validate.sh                   # Validation script (15 checks)
└── README.md                     # This document
```

## 🔄 13-Step Workflow

| Phase | Steps | Description | Output |
|-------|-------|-------------|--------|
| **Phase 0** | Step 1 | Tech Stack Analysis | Tech stack document |
| **Phase 1** | Steps 2-4 | Proposal → Validate → Spec (Contract) | `proposal.md`, `spec.md` |
| **Phase 2** | Step 5 | Frontend/Backend Design Split | `design.md` |
| **Phase 3** | Steps 6-7 | Frontend Mock Development → Verify | Mock data + Frontend code |
| **Phase 4** | Step 8 | Backend Skeleton (returns static mock) | Backend API skeleton |
| **Phase 5** | Step 9 | E2E Contract Testing | Test cases |
| **Phase 6** | Step 10 | Real Implementation (DB + Service) | Complete backend |
| **Phase 7** | Steps 11-12 | Real Testing → Drift Check | Test report |
| **Phase 8** | Step 13 | Archive | Archive document |

### Workflow Description

1. **Phase 0-1**: Define requirements, generate contract (Spec)
2. **Phase 2**: Frontend/backend design split, clarify responsibilities
3. **Phase 3-4**: Frontend develops with mock, backend provides mock API
4. **Phase 5**: Write contract tests, ensure API matches Spec
5. **Phase 6**: Implement real backend logic
6. **Phase 7**: Run tests, check for implementation drift from contract
7. **Phase 8**: Archive completed change

## 📋 Development Standards (Built-in)

### Data Processing

- ❌ **No frontend pagination, sorting, filtering**
- ❌ **No pseudo-pagination** (frontend pagination with full backend data)
- ✅ **Use server-side pagination**

### API Design

- ✅ List APIs must support `page` + `page_size`
- ✅ Must return `total_count`
- ❌ No `page_size > 100`
- ✅ Use unified response format (StandardResp)

### Frontend Standards

- ✅ Must display Loading/Empty/Error states
- ✅ API calls through data fetching library (e.g., React Query)
- ✅ Date/currency formatting done on frontend

### Backend Standards

- ✅ List queries default `limit = 20`
- ✅ Use parameterized queries (prevent SQL injection)
- ✅ Log slow queries (>1s)
- ✅ Search, sort, pagination done on backend

## 🏗️ Infrastructure Standards

### Error Code System

| Range | Category | Description |
|-------|----------|-------------|
| 1xxx | Client Errors | Invalid input, validation failures |
| 2xxx | Business Logic Errors | Business rule violations |
| 3xxx | External Service Errors | Third-party API failures |
| 4xxx | System Errors | Database, network, infrastructure |
| 5xxx | Unknown Errors | Unexpected exceptions |

**Common Error Codes**:
- `1000`: Invalid Parameter
- `1001`: Validation Failed
- `1002`: Unauthorized
- `2000`: Resource Not Found
- `4000`: Database Error
- `5000`: Internal Server Error

### Unified Response Format (StandardResp)

```typescript
interface StandardResp<T> {
  code: number;        // 0 = success, other = error code
  message: string;     // Human-readable message
  data: T | null;      // Response data (null on error)
}
```

**Success Response Example**:
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

**Error Response Example**:
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

### Structured Logging

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

**Log Levels**:
- **DEBUG**: Development debugging
- **INFO**: Normal operations
- **WARN**: Recoverable issues
- **ERROR**: Application errors
- **CRITICAL**: System failures

### Middleware Architecture

**Standard Middleware Execution Order**:
1. CORS (first)
2. Request ID generation
3. Logging (request start)
4. Authentication
5. Validation
6. Business logic handler
7. Logging (response)
8. Error handler (last)

### Development Mode Support

| Mode | Description | Use Case |
|------|-------------|----------|
| **fullstack** | Complete frontend + backend + middleware | End-to-end feature development |
| **frontend-only** | Frontend only + mock backend | Independent frontend development |
| **backend-only** | Backend API only | Independent backend development |
| **middleware-only** | Middleware/infrastructure only | Infrastructure development |

## 🎯 Core Principles

1. **Spec First** - Write Spec before implementation
2. **Mock Before Real** - Mock first, then real
3. **Contract as Truth** - Spec is the single source of truth
4. **Verify at Every Gate** - Validate at each Phase

## 🔧 Customization

### Configure Development Mode

Edit `openspec/config.yaml`:

```yaml
# Development mode selection
dev_mode: fullstack  # Options: fullstack, frontend-only, backend-only, middleware-only
```

**Use Cases**:
- **fullstack**: Team collaboration, synchronized frontend-backend development
- **frontend-only**: Frontend-first, rapid UI iteration with mock data
- **backend-only**: Backend-first, focus on API and business logic
- **middleware-only**: Infrastructure development like auth, logging, error handling

### Customize Workflow

Edit `openspec/schemas/workflow/schema.yaml` to customize workflow steps.
Edit `openspec/schemas/workflow/templates/*.md` to customize artifact templates.

### Workflow Schema Notes

The workflow schema uses 13-Step Contract-First process, different from the default spec-driven schema:

| Feature | spec-driven | workflow |
|---------|-------------|----------|
| Spec Structure | `specs/` directory (multi-file) | Single `spec.md` |
| Validation Command | `openspec validate` | Check via apply |
| Proposal Format | `## Why` / `## What Changes` | `## Background & Goals` / `## Non-Goals` |

**Important**: `openspec validate` is designed for spec-driven schema. For workflow schema, use `openspec instructions apply --json` to check task completion status.

**Note**:
- Keep the core 13-step workflow structure unchanged
- `infrastructure` artifact is optional (`optional: true`)
- Custom rules and dependencies can be added

### Add Project Context

Add more context files in `openspec/context/` and configure in `config.yaml`:

```yaml
global_context:
  - "context/project_summary.md"
  - "context/tech_stack.md"
  - "context/infrastructure.md"  # Infrastructure spec
  - "context/custom_context.md"  # Custom context
```

## 🧪 Testing

Run the validation script to verify the template is properly configured:

```bash
./validate.sh
```

This runs 16 validation checks including:
- Directory structure
- Template files completeness
- Configuration correctness
- 13-step workflow structure

See [TESTING.md](TESTING.md) for detailed testing guide.

## 📚 Resources

- [13-Step Workflow Details](13_STEP_WORKFLOW.md) - 详细的13步工作流说明
- [OpenSpec Documentation](https://github.com/anthropics/openspec)
- [Cursor Skills Documentation](https://cursor.sh/docs)
- [Testing Guide](TESTING.md)

## 🤝 Contributing

Issues and Pull Requests are welcome!

Before submitting:
1. Run `./validate.sh` to ensure all checks pass
2. Test initialization with `./init.sh TestProject /tmp/test fullstack`
3. Update documentation if needed

## 📄 License

MIT
