# CLAUDE.md

## Project Overview

[项目简介，初始化后修改]

## Quick Start Commands

```bash
# 后端启动
cd backend
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python run.py

# 前端启动
cd frontend
npm install
npm run dev
```

## 前后端协作规则

### 响应格式

后端所有接口必须返回 StandardResp：
- 成功：`{"status": "ok", "data": {...}}`
- 失败：`{"status": "error", "message": "错误信息"}`

### 分页格式

统一使用：
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
| 表单校验 | 双方（前端体验，后端安全） |

### 接口设计

- GET：查询（参数走 Query String）
- POST：创建/复杂查询（参数走 JSON Body）
- PUT：更新
- DELETE：删除

### 枚举

前后端枚举值必须一致，用字符串不用数字。

### 时间处理

- API 传输：ISO 8601 UTC（`2024-01-15T10:30:00Z`）
- 前端展示：本地时区

## 开发流程

### 按需求复杂度分级

| 类型 | 示例 | 流程 |
|------|------|------|
| 简单 | 改文案、修样式 | 直接写 |
| 涉及新接口 | 加个列表页 | 一句话说清接口，再写代码 |
| 复杂功能 | 多接口、多表关联 | 写 proposal，确认后再写代码 |

### 接口定义格式

```
新增接口：GET /cookies?status=active&page=1
返回：{status, data: {items: Cookie[], total, page, limit}}
```

## Language Constraints

- 所有文档、注释、方案说明使用简体中文
- 代码片段、变量名、命令可保留英文
