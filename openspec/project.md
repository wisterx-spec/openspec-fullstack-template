# OpenSpec Project Configuration

## Project Info

- **Name**: [项目名称]
- **Stack**: FastAPI + React + TypeScript
- **Database**: SQLite / PostgreSQL

## Conventions

### API Design

- 所有接口返回 `{status: "ok/error", data, message}` 格式
- 分页使用 `{items, total, page, limit, total_pages}` 格式
- 枚举用字符串不用数字

### Code Style

- Python: 使用 ruff 格式化
- TypeScript: 使用 prettier 格式化
- 变量命名: snake_case (Python), camelCase (TypeScript)

### File Structure

```
backend/
├── app/
│   ├── core/           # 核心模块（response, exceptions, enums）
│   ├── middleware/     # 中间件
│   ├── routers/        # 路由
│   ├── schemas/        # Pydantic 模型
│   ├── services/       # 业务逻辑
│   └── main.py

frontend/
├── src/
│   ├── components/     # 组件
│   ├── lib/            # 工具库（request.ts）
│   ├── pages/          # 页面
│   ├── types/          # 类型定义
│   └── utils/          # 工具函数
```

## Specs Overview

[初始化后根据项目添加]
