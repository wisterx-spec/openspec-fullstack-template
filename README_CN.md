# OpenSpec Fullstack Template

> 全栈项目结构化开发工作流模板。提供两种模式：**13 步 Spec-First**（契约驱动）和 **7 步 Frontend-First**（UI 驱动），解决前后端接口不一致、联调成本高的问题。

---

## 在开始之前——这个模板适合你吗？

### 这个模板是什么

这是一个**工作流模板**，不是框架或库。它提供：
- 一组 **Markdown 文档模板**（proposal、spec、design、tasks、archive）
- **Cursor IDE Skills**（AI 驱动的命令，如 `/opsx:new`、`/opsx:apply`）
- **Cursor Subagents**（自动化验证：Mock↔Spec 一致性、构建泄漏检查）
- **工作流约定**（API 规范、错误码、响应格式）

它**不包含**任何运行时代码、UI 组件或后端框架。技术栈由你自己决定。

### 运行环境依赖

| 依赖 | 是否必需 | 用途 |
|------|---------|------|
| **[Cursor IDE](https://cursor.sh)** | **必需** | Skills 和 Subagents 仅在 Cursor 中运行 |
| **[OpenSpec CLI](https://github.com/anthropics/openspec)** | **必需** | 读取 `config.yaml`，生成 artifact 指令，跟踪工作流状态 |
| **Git** | **必需** | 版本控制，Git Hooks 用于 Mock 隔离检查 |
| **Node.js ≥ 18** | 推荐 | Frontend-First 模式使用 MSW（Mock Service Worker）时需要 |
| **Python 3.9+** | 可选 | 仅 `ui-ux-pro-max` 设计系统生成器需要 |
| **你的技术栈** | 自备 | React/Vue/Svelte、Express/FastAPI/Go、任意数据库——本模板与技术栈无关 |

**关键点**：没有 Cursor IDE + OpenSpec CLI，Skills / Subagents / 自动化检查将无法运行。文档模板仍可手动使用，但会失去 AI 辅助工作流的能力。

### 适合的项目类型

| 场景 | 适配度 | 原因 |
|------|--------|------|
| 新全栈项目（个人或小团队） | **最佳** | 两种工作流模式全面受益，干净起步 |
| 已有项目添加新功能 | **良好** | 渐进式使用——新功能走流程，旧代码不动 |
| 前端为重的 SaaS / 管理后台 | **良好** | Frontend-First 模式最适合：UI → Mock → Spec → Backend |
| 多团队共享 API 契约 | **良好** | Spec-First 模式提供清晰的契约交接 |
| API 交互复杂的项目 | **良好** | 契约测试防止"改了 A，B 崩了"的连锁故障 |
| 需要设计系统一致性的项目 | **良好** | 内置 `ui-ux-pro-max` 生成设计 tokens |

### 不适合的项目类型

| 场景 | 适配度 | 原因 |
|------|--------|------|
| 快速原型 / 黑客松 / 一次性代码 | **差** | 流程开销 > 收益；直接写代码更快 |
| 纯静态站点（完全没有 API） | **差** | 不需要后端契约；用静态站点生成器即可 |
| 移动端应用（React Native / Flutter） | **有限** | Frontend-First 模式假设浏览器端 MSW；移动端需要适配 |
| 几十个服务间 API 的微服务架构 | **有限** | 本模板设计用于前端↔后端契约，不是服务间通信网格 |
| 团队不使用 Cursor IDE | **有限** | Skills 和 Subagents 无法工作；只能手动走流程 |
| 纯 CI/CD 环境（无人参与） | **差** | 工作流依赖开发者在检查点（UI Freeze、Spec Review）的人工确认 |
| 已有成熟 API 文档的项目（Swagger/OpenAPI） | **边际** | 本模板使用自有 Spec 格式；除非迁移，否则是重复工作 |

### 两种模式怎么选

```
你的项目有前端吗？
├─ 有 → 个人或小团队？
│       ├─ 是 → Frontend-First（7 步） ← 推荐默认
│       └─ 否 → Spec-First（13 步），适合跨团队契约
└─ 没有 → Spec-First（13 步）— backend-only 模式
```

---

## 两种工作流模式

本模板支持两种互补的开发工作流，通过 `openspec/config.yaml` 中的 `dev_mode` 配置：

### 模式一：13 步 Spec-First（契约驱动）

**核心思路**：先写 API 契约（Spec），再根据契约实现前端和后端。

**适用场景**：纯后端项目、多团队交接、API 优先设计。

| 阶段 | 步骤 | 描述 | 产出物 |
|------|------|------|--------|
| Phase 0 | Step 1 | 技术栈分析 | 技术栈文档 |
| Phase 1 | Steps 2-4 | 提案 → 验证 → Spec（契约） | `proposal.md`, `spec.md` |
| Phase 2 | Step 5 | 前后端设计分离 | `design.md` |
| Phase 3 | Steps 6-7 | 前端 Mock 开发 → 验证 | Mock 数据 + 前端代码 |
| Phase 4 | Step 8 | 后端骨架（返回静态 Mock） | 后端 API 骨架 |
| Phase 5 | Step 9 | E2E 契约测试 | 测试用例 |
| Phase 6 | Step 10 | 真实实现（DB + Service） | 完整后端实现 |
| Phase 7 | Steps 11-12 | 真实测试 → Drift Check | 测试报告 |
| Phase 8 | Step 13 | 归档 | 归档文档 |

详见 [13 步工作流详细说明](13_STEP_WORKFLOW_CN.md)。

### 模式二：7 步 Frontend-First（UI 驱动）

**核心思路**：先用 Mock 数据构建 UI，再从前端实际需求反推 API 契约。

**适用场景**：全栈个人开发、UI 密集型项目、快速迭代。

```
Step 1: Proposal          → 要做什么功能？
Step 2: Frontend + Mock   → 用假数据构建 UI，随意迭代
Step 3: UI Freeze         → 🔒 检查点：锁定 UI 和 Mock 数据
Step 4: API Spec          → 从冻结的 Mock 数据反推 API 契约
Step 5: Spec Review       → 🔒 检查点：验证 Mock ↔ Spec 100% 一致
Step 6: Backend           → 严格按 Spec 实现
Step 7: Integration       → 前端切换真实 API，归档
```

详见 [Frontend-First 工作流详细说明](FRONTEND_FIRST_WORKFLOW_CN.md)。

### 模式对比

| 维度 | 13 步 Spec-First | 7 步 Frontend-First |
|------|------------------|---------------------|
| Spec 来源 | 从需求文档正向设计 | 从 Mock 数据反推 |
| 适用场景 | 无前端 / API 优先 / 多团队协作 | 有前端 / 个人开发 / UI 驱动 |
| 迭代速度 | 中等（Spec 变更需要 review） | Phase 1 快速（自由迭代），锁定后受控 |
| 风险特征 | 中（Spec 基于假设） | 低（Spec 基于真实 UI 需求） |
| 共存方式 | 两种模式共享 Proposal 和 Spec 格式，产出物兼容 |

---

## 快速开始

### 1. 克隆模板

```bash
git clone https://github.com/anthropics/openspec-fullstack-template.git
cd openspec-fullstack-template
```

### 2. 复制到你的项目

```bash
# 复制 OpenSpec 配置
cp -r openspec-fullstack-template/openspec/ your-project/openspec/

# 复制 Cursor Skills（放到 .cursor/skills/）
cp -r openspec-fullstack-template/skills/ your-project/.cursor/skills/
```

### 3. 初始化项目上下文

**方式 A：交互式脚本（推荐）**

```bash
cd your-project
./scripts/init-project.sh
```

**方式 B：Cursor Skill**

```
/opsx:init-project
```

**方式 C：手动**

```bash
cd your-project/openspec/context/
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md
# 编辑填写项目信息
```

### 4. 配置开发模式

编辑 `openspec/config.yaml`：

```yaml
# 选择工作流模式
dev_mode: fullstack          # 可选: fullstack, frontend-only, backend-only, middleware-only

# Frontend-First 模式：
# dev_mode: frontend-first-solo
```

| 模式 | 工作流 | 适用场景 |
|------|--------|----------|
| `fullstack` | 13 步 | 完整前后端 + 中间件 |
| `frontend-only` | 7 步（部分） | 仅前端，Mock 后端 |
| `backend-only` | 13 步（部分） | 仅后端 API |
| `frontend-first-solo` | 7 步 | 个人全栈，UI 驱动 |

### 5. 开始使用

```bash
# 新手引导
/opsx:onboard

# 创建新变更（Spec-First）
/opsx:new <name>              # 逐步创建 artifacts
/opsx:ff <name>               # 快速生成所有 artifacts

# 创建新功能（Frontend-First）
/opsx:ff-new <name>           # 创建 proposal + Mock 模板 + 组件骨架
/opsx:ff-freeze <name>        # UI 冻结检查点
/opsx:ff-mock-to-spec <name>  # 从 Mock 数据反推 Spec
/opsx:ff-done <name>          # 集成 + 归档

# 实现和验证
/opsx:apply <name>            # 实现任务
/opsx:check-standards         # 检查开发规范
/opsx:verify <name>           # 验证实现

# 归档
/opsx:archive <name>          # 归档完成的变更
```

---

## 目录结构

```
openspec-fullstack-template/
├── openspec/                          # 核心配置
│   ├── config.yaml                   # 入口配置（dev_mode、rules、context）
│   ├── conventions/
│   │   └── api-convention.md         # API 响应格式、错误码、字段命名规范
│   ├── schemas/
│   │   └── workflow/
│   │       ├── schema.yaml           # 13 步工作流定义
│   │       └── templates/            # Artifact 模板（proposal、spec、design、tasks）
│   ├── context/                      # 项目上下文文件
│   │   ├── project_summary.template.md
│   │   └── tech_stack.template.md
│   └── ui-ux-pro-max/               # 设计系统生成器（可选，需要 Python）
│       ├── scripts/search.py
│       └── data/                     # 配色/字体/风格数据集
│
├── skills/                            # Cursor Skills（AI 命令）
│   ├── openspec-new-change/          # /opsx:new — 创建新变更
│   ├── openspec-ff-change/           # /opsx:ff — 快速生成 artifacts
│   ├── openspec-ff-new/              # /opsx:ff-new — Frontend-First：新功能
│   ├── openspec-ff-freeze/           # /opsx:ff-freeze — Frontend-First：UI 冻结
│   ├── openspec-ff-mock-to-spec/     # /opsx:ff-mock-to-spec — 从 Mock 反推 Spec
│   ├── openspec-apply-change/        # /opsx:apply — 实现任务
│   ├── openspec-check-standards/     # /opsx:check-standards — 检查规范
│   ├── openspec-verify-change/       # /opsx:verify — 验证实现
│   ├── openspec-archive-change/      # /opsx:archive — 归档变更
│   ├── openspec-design-system/       # 设计系统生成
│   └── ...                           # 其他 skills（onboard、explore、sync）
│
├── scripts/
│   └── init-project.sh               # 交互式项目初始化
├── validate.sh                        # 模板验证（17 项检查）
├── 13_STEP_WORKFLOW.md                # Spec-First 工作流详细说明
├── FRONTEND_FIRST_WORKFLOW.md         # Frontend-First 工作流详细说明
└── README.md                          # 英文文档
```

---

## 内置规范

### API 接口规范（`openspec/conventions/api-convention.md`）

这是项目中所有 API 格式规则的唯一定义：

| 约束 | 规则 |
|------|------|
| 响应信封 | `{ code, message, data }` — 成功 `code: 0`，失败 `code: 6位错误码` |
| 分页格式 | 扁平结构：`{ items, total, page, page_size }` — 不使用嵌套 `pagination` 对象 |
| 错误码 | 6 位数字 `CCMMSS`（分类 + 模块 + 序号） |
| 字段命名 | JSON 字段 `snake_case`，URL 路径 `kebab-case` |
| 日期格式 | ISO 8601：`"2024-01-28T10:30:00Z"` |
| 空值处理 | 声明的字段必须返回（无值时返回 `null`，不省略） |

### 开发规范

**数据处理**：服务端分页、排序、过滤（前端禁止）；`page_size` 最大 100，默认 20。

**前端**：必须展示 Loading/Empty/Error 状态；日期/金额格式化在前端完成。

**后端**：参数化查询；慢查询（>1s）记录日志；结构化日志包含 `trace_id`。

---

## 自动化验证（Cursor Subagents）

这些 Subagents 在 Cursor 中运行，只读不写：

| Subagent | 检查内容 | 使用时机 |
|----------|---------|---------|
| `ff-verifier` | 三方一致性：Mock ↔ Spec ↔ Backend | Step 7（集成）完成后 |
| `ff-contract-tester` | 运行并分析契约测试 | Step 6（后端）完成后 |
| `ff-spec-checker` | 字段级 Mock ↔ Spec 对比 | Step 5（Spec Review）完成后 |
| `ff-build-checker` | 生产构建中无 Mock 代码泄漏 | 部署前 |
| `ff-migrator` | 扫描已有项目的 Mock 数据分布 | 已有项目初始化时 |

多个检查器可并行运行，加快反馈速度。

---

## 相关资源

- [13 步工作流详细说明](13_STEP_WORKFLOW_CN.md) / [English](13_STEP_WORKFLOW.md)
- [Frontend-First 工作流详细说明](FRONTEND_FIRST_WORKFLOW_CN.md) / [English](FRONTEND_FIRST_WORKFLOW.md)
- [需求对齐与减少后期修改](docs/REQUIREMENTS_ALIGNMENT_CN.md) / [English](docs/REQUIREMENTS_ALIGNMENT.md)
- [测试指南](TESTING_CN.md) / [English](TESTING.md)
- [OpenSpec 文档](https://github.com/anthropics/openspec)
- [Cursor Skills 文档](https://cursor.sh/docs)

## 贡献

欢迎提交 Issue 和 Pull Request！

提交前请：
1. 运行 `./validate.sh` 确保所有检查通过
2. 用 `./init.sh TestProject /tmp/test fullstack` 测试初始化
3. 按需更新文档

## License

MIT
