# OpenSpec Fullstack Template

> 13 步契约优先开发工作流模板，适用于全栈项目。通过 Spec First、Mock Before Real 的原则，解决前后端接口不一致、联调成本高的问题。

## ✨ 特性

- 🎯 **契约优先**：先写 Spec，再写实现，确保前后端一致
- 🚀 **Mock 先行**：前端先基于 Mock 开发，后端后实现，并行开发
- ✅ **自动验证**：每个阶段自动验证，确保实现符合契约
- 📋 **内置规范**：内置开发规范检查，避免常见问题
- 🔄 **完整工作流**：从提案到归档的 13 步完整流程

## 🚀 快速开始

### 1. 克隆模板

```bash
git clone https://github.com/wisterx-spec/openspec-fullstack-template.git
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

### 5. 开始使用

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
│   ├── config.yaml               # 入口配置
│   ├── schemas/
│   │   └── workflow.yaml         # 13 步工作流定义
│   ├── templates/                # Handlebars 模板
│   │   ├── proposal.hbs          # Phase 0-1 提案模板
│   │   ├── contract.hbs         # Phase 1 Spec 模板
│   │   ├── design.hbs           # Phase 2 设计模板
│   │   └── tasks.hbs            # Phase 3-8 任务模板
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
└── README.md                     # 本文档
```

## 🔄 13 步工作流

| Phase | Steps | 描述 | 产出物 |
|-------|-------|------|--------|
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
- ✅ 使用统一的响应格式

### 前端规范

- ✅ 必须展示 Loading/Empty/Error 状态
- ✅ API 调用通过数据获取库（如 React Query）
- ✅ 日期/金额格式化在前端完成

### 后端规范

- ✅ 列表查询默认 `limit = 20`
- ✅ 使用参数化查询（防止 SQL 注入）
- ✅ 慢查询（>1s）记录日志
- ✅ 搜索、排序、分页在后端完成

## 🎯 核心原则

1. **Spec First** - 先写 Spec，再写实现
2. **Mock Before Real** - 先 Mock，后真实
3. **Contract as Truth** - Spec 是唯一真相源
4. **Verify at Every Gate** - 每个 Phase 验证

## 🔧 自定义配置

### 修改工作流

编辑 `openspec/schemas/workflow.yaml` 自定义工作流步骤。

### 修改模板

编辑 `openspec/templates/` 下的 Handlebars 模板文件。

### 添加项目上下文

在 `openspec/context/` 目录下添加更多上下文文件，并在 `config.yaml` 中配置。

## 📚 相关资源

- [OpenSpec 文档](https://github.com/wisterx-spec/openspec)
- [Cursor Skills 文档](https://cursor.sh/docs)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 License

MIT
