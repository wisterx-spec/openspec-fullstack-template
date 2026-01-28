# OpenSpec Fullstack Template

13 步契约优先开发工作流模板，适用于全栈项目。

## 快速开始

### 1. 复制到你的项目

```bash
# 复制 openspec 配置
cp -r openspec-fullstack-template/openspec/ your-project/openspec/

# 复制 skills（可选，放到 .cursor/skills/）
cp -r openspec-fullstack-template/skills/ your-project/.cursor/skills/
```

### 2. 初始化项目上下文

```bash
cd your-project/openspec/context/

# 重命名模板文件
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md

# 编辑填写项目信息
```

### 3. 更新配置

编辑 `openspec/config.yaml`，替换 `{{ PROJECT_NAME }}` 为你的项目名。

### 4. 开始使用

```bash
# 查看可用命令
/opsx:onboard    # 新手引导

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

## 目录结构

```
openspec/
├── config.yaml                 # 入口配置
├── schemas/
│   └── workflow.yaml           # 13 步工作流定义
├── templates/
│   ├── proposal.hbs            # Phase 0-1 提案模板
│   ├── contract.hbs            # Phase 1 Spec 模板
│   ├── design.hbs              # Phase 2 设计模板
│   └── tasks.hbs               # Phase 3-8 任务模板
├── context/
│   ├── project_summary.md      # 项目上下文（需填写）
│   └── tech_stack.md           # 技术栈（需填写）
├── specs/                      # 主规格文件（自动生成）
└── changes/                    # 进行中的变更（自动生成）

skills/
├── openspec-new-change/        # 创建新变更
├── openspec-continue-change/   # 继续创建 artifacts
├── openspec-ff-change/         # 快速生成 artifacts
├── openspec-apply-change/      # 实现任务
├── openspec-check-standards/   # 检查开发规范
├── openspec-verify-change/     # 验证实现
├── openspec-archive-change/    # 归档变更
├── openspec-bulk-archive-change/ # 批量归档
├── openspec-explore/           # 探索模式
├── openspec-onboard/           # 新手引导
└── openspec-sync-specs/        # 同步 specs
```

## 13 步工作流

| Phase | Steps | 描述 |
|-------|-------|------|
| Phase 0 | Step 1 | 技术栈分析 |
| Phase 1 | Steps 2-4 | 提案 → 验证 → Spec（契约） |
| Phase 2 | Step 5 | 前后端设计分离 |
| Phase 3 | Steps 6-7 | 前端 Mock 开发 → 验证 |
| Phase 4 | Step 8 | 后端骨架（返回静态 Mock） |
| Phase 5 | Step 9 | E2E 契约测试 |
| Phase 6 | Step 10 | 真实实现（DB + Service） |
| Phase 7 | Steps 11-12 | 真实测试 → Drift Check |
| Phase 8 | Step 13 | 归档 |

## 开发规范（内置）

### 数据处理
- ❌ 禁止前端分页、排序、过滤
- ❌ 禁止伪分页
- ✅ 使用服务端分页

### API 设计
- ✅ 列表 API 必须支持 `page` + `page_size`
- ✅ 必须返回 `total_count`
- ❌ 禁止 `page_size > 100`

### 前端
- ✅ 必须展示 Loading/Empty/Error 状态
- ✅ API 调用通过数据获取库（如 React Query）

### 后端
- ✅ 列表查询默认 `limit = 20`
- ✅ 使用参数化查询
- ✅ 慢查询（>1s）记录日志

## 核心原则

1. **Spec First** - 先写 Spec，再写实现
2. **Mock Before Real** - 先 Mock，后真实
3. **Contract as Truth** - Spec 是唯一真相源
4. **Verify at Every Gate** - 每个 Phase 验证

## License

MIT
