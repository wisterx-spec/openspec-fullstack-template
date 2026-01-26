# OpenSpec Fullstack Template

AI 辅助全栈开发的工程化模板，解决"前后端接口不一致"、"联调成本高"的问题。

## 快速开始

```bash
# 1. 克隆模板
git clone https://github.com/你的用户名/openspec-fullstack-template.git
cd openspec-fullstack-template

# 2. 复制到你的项目
./init.sh /path/to/your-project --stack fastapi+react
```

## 包含内容

```
├── .claude/commands/openspec/    # OpenSpec 命令（含开发规范）
├── openspec/                     # OpenSpec 基础配置
├── templates/                    # 各技术栈的基础设施代码
│   ├── fastapi/                  # FastAPI 后端模板
│   ├── express/                  # Express 后端模板
│   ├── react/                    # React 前端模板
│   └── vue/                      # Vue 前端模板
├── docs/
│   └── dev-protocol.md           # 完整开发规范文档
└── init.sh                       # 初始化脚本
```

## 核心规范

### 统一响应格式

```json
{
  "status": "ok",
  "data": { ... },
  "message": null
}
```

### 分页格式

```json
{
  "status": "ok",
  "data": {
    "items": [...],
    "total": 100,
    "page": 1,
    "limit": 20,
    "total_pages": 5
  }
}
```

### 职责边界

| 功能 | 责任方 |
|------|--------|
| 搜索、排序、分页 | 后端 |
| 数据计算、统计 | 后端 |
| 日期/金额格式化展示 | 前端 |
| 枚举字典维护 | 后端 |

### 开发流程

| 需求类型 | 流程 |
|----------|------|
| 简单（改文案） | 直接写 |
| 涉及新接口 | 一句话说清接口，再写代码 |
| 复杂功能 | 写 proposal，确认后再写代码 |

## 使用方式

### 方式一：完整初始化（新项目）

```bash
./init.sh /path/to/new-project --stack fastapi+react
```

这会复制：
- `.claude/commands/openspec/` - OpenSpec 命令
- `openspec/` - OpenSpec 配置
- 后端基础设施代码
- 前端基础设施代码
- `CLAUDE.md` - AI 规则

### 方式二：仅复制规范（已有项目）

```bash
# 只复制 OpenSpec 命令和规范
cp -r .claude/commands/openspec /path/to/existing-project/.claude/commands/
cp -r openspec /path/to/existing-project/
```

### 方式三：手动选择

按需复制你需要的部分：

```bash
# 只要后端模板
cp -r templates/fastapi/* /path/to/project/backend/app/

# 只要前端模板
cp -r templates/react/* /path/to/project/frontend/src/
```

## 技术栈支持

### 后端

| 技术栈 | 状态 |
|--------|------|
| FastAPI (Python) | ✅ 完整 |
| Express (Node.js) | 🚧 计划中 |
| Go Gin | 🚧 计划中 |

### 前端

| 技术栈 | 状态 |
|--------|------|
| React + TypeScript | ✅ 完整 |
| Vue 3 + TypeScript | 🚧 计划中 |

## 自定义

### 修改响应格式

编辑 `templates/[stack]/core/response.py` 或 `templates/[stack]/lib/request.ts`

### 修改开发规范

编辑 `.claude/commands/openspec/proposal.md` 中的 `# Core Development Protocol` 部分

### 添加新技术栈

1. 在 `templates/` 下创建新目录
2. 实现基础设施代码
3. 更新 `init.sh` 支持新技术栈

## License

MIT
