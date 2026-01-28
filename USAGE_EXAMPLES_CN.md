# OpenSpec 模板使用示例

本文档提供了 OpenSpec Fullstack Template 的实际使用示例，展示如何使用新增的基础架构和开发模式功能。

## 目录

1. [新项目完整流程](#新项目完整流程)
2. [前端独立开发示例](#前端独立开发示例)
3. [后端独立开发示例](#后端独立开发示例)
4. [中间件开发示例](#中间件开发示例)
5. [基础架构初始化示例](#基础架构初始化示例)

---

## 新项目完整流程

### 场景：创建一个用户管理系统

#### 步骤 1：项目初始化

```bash
# 1. 复制模板到项目
cp -r openspec-fullstack-template/openspec/ my-project/openspec/
cp -r openspec-fullstack-template/skills/ my-project/.cursor/skills/

# 2. 进入项目目录
cd my-project

# 3. 配置项目信息
cd openspec/context/
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md

# 4. 编辑项目信息
# 编辑 project_summary.md 和 tech_stack.md
```

#### 步骤 2：配置开发模式

编辑 `openspec/config.yaml`:

```yaml
project:
  name: "用户管理系统"
  language: "zh-CN"

# 选择开发模式
dev_mode: fullstack  # 完整前后端开发

global_context:
  - "context/project_summary.md"
  - "context/tech_stack.md"
  - "context/infrastructure.md"  # 将在下一步生成
```

#### 步骤 3：生成基础架构规范

在 Cursor 中执行：

```bash
/opsx:new infrastructure
```

这将生成 `openspec/context/infrastructure.md`，包含：
- 日志系统规范
- 错误码定义（1000-5000）
- StandardResp 响应格式
- 中间件架构
- 开发模式配置

#### 步骤 4：创建用户管理功能

```bash
/opsx:new user-management
```

系统会引导你完成：
1. **Proposal（提案）**：定义用户管理的需求和用户故事
2. **Spec（契约）**：定义 API 端点和数据库 schema
3. **Design（设计）**：前后端架构设计
4. **Tasks（任务）**：具体实现任务

#### 步骤 5：查看生成的 Spec

`openspec/changes/user-management/spec.md` 示例：

```markdown
# 用户管理 - API 规格

## API 端点

### `POST /api/users`

**请求**:
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password"
}
```

**响应** (成功):
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "username": "john_doe",
    "email": "john@example.com",
    "created_at": "2024-01-28T10:30:00Z"
  }
}
```

**响应** (错误):
```json
{
  "code": 1001,
  "message": "Validation Failed",
  "data": null,
  "error_details": {
    "field": "email",
    "reason": "Email already exists",
    "trace_id": "abc-123-def"
  }
}
```

**错误码**:
| 码 | 消息 | 使用场景 |
|------|---------|-------------|
| 1000 | Invalid Parameter | 缺少或格式错误的请求参数 |
| 1001 | Validation Failed | 邮箱已存在 |
| 2000 | Resource Not Found | 用户不存在 |
```

#### 步骤 6：实现功能

```bash
/opsx:apply user-management
```

系统会根据 `tasks.md` 逐步实现：
- Phase 3: 前端 Mock 开发
- Phase 4: 后端骨架（返回静态 Mock）
- Phase 5: E2E 契约测试
- Phase 6: 真实实现（数据库 + 业务逻辑）
- Phase 7: 真实测试 + Drift Check

#### 步骤 7：验证实现

```bash
/opsx:verify user-management
```

验证：
- API 响应格式是否匹配 Spec
- 错误码是否正确
- 日志是否包含 trace_id
- 分页格式是否正确

---

## 前端独立开发示例

### 场景：前端团队先行开发 UI，后端尚未就绪

#### 步骤 1：配置前端独立模式

编辑 `openspec/config.yaml`:

```yaml
dev_mode: frontend-only  # 前端独立开发模式
```

#### 步骤 2：创建功能

```bash
/opsx:new product-list
```

#### 步骤 3：查看生成的 Design

`openspec/changes/product-list/design.md` 会包含：

```markdown
## 0. 开发模式配置

### 模式: frontend-only

**前端独立模式**:
- 使用 `spec.md` 中的 JSON 示例模拟后端
- Mock 服务器配置（如 MSW, json-server）
- 此阶段无需后端实现
- 重点: UI 组件、状态管理、用户交互

## 1. 前端架构

### 1.3 Mock 策略

**Mock 服务器设置**:
- 工具: MSW (Mock Service Worker)
- Mock 数据源: `spec.md` 中的 JSON 示例
- Mock 服务器端口: 3001
- 如何模拟错误响应: 使用 MSW handlers 配合 infrastructure.md 中的错误码
```

#### 步骤 4：查看生成的 Tasks

`openspec/changes/product-list/tasks.md` 会包含：

```markdown
## Phase 3: 前端 Mock 开发 (Steps 6-7)
- [ ] **Task 3.1**: [Step 6] 使用 Mock 数据实现前端
  - 操作: 创建符合 `StandardResp` 格式的 Mock 数据
  - 操作: 实现 UI 组件 (ProductList, ProductCard, ProductFilter)
  - 操作: 使用 `spec.md` 中的 JSON 设置 mock 服务器 (MSW)
  - 操作: 配置 mock 服务器端口和路由
  - 操作: 实现带有请求拦截器的 API 客户端（添加 X-Request-ID）
  - 操作: 实现 StandardResp 格式的错误处理

## Phase 4: 后端骨架 (Step 8)
- [x] **Task 4.1**: [Step 8] 后端骨架
  - 状态: 跳过（frontend-only 模式）
```

#### 步骤 5：实现前端

```bash
/opsx:apply product-list
```

实现内容：
- 使用 MSW 创建 Mock 服务器
- 实现 UI 组件
- 使用 `spec.md` 中的 JSON 作为 Mock 数据
- 测试 UI 交互和数据渲染

#### 步骤 6：后端就绪后切换模式

当后端 API 就绪后，修改 `config.yaml`:

```yaml
dev_mode: fullstack  # 切换到全栈模式
```

然后连接真实后端：
```bash
/opsx:apply product-list  # 继续实现，连接真实 API
```

---

## 后端独立开发示例

### 场景：后端团队专注 API 开发，前端由其他团队负责

#### 步骤 1：配置后端独立模式

编辑 `openspec/config.yaml`:

```yaml
dev_mode: backend-only  # 后端独立开发模式
```

#### 步骤 2：创建功能

```bash
/opsx:new order-management
```

#### 步骤 3：查看生成的 Design

`openspec/changes/order-management/design.md` 会包含：

```markdown
## 0. 开发模式配置

### 模式: backend-only

**后端独立模式**:
- 无前端的 API 实现
- 通过 Postman/curl/自动化测试进行测试
- 为未来前端集成配置 CORS
- 重点: API 端点、业务逻辑、数据库操作

## 1. 前端架构

**前端架构**: 不适用于 backend-only 模式。

## 2. 后端架构

### 2.1 路由位置
- 文件: `backend/app/routers/orders.py`
- 端点: POST /api/orders, GET /api/orders, GET /api/orders/{id}

### 2.4 中间件集成
- 认证: 所有端点都需要
- 验证: 使用 Pydantic 进行请求 schema 验证
- 日志: 记录所有带 trace_id 的请求
- 错误处理: 使用 infrastructure.md 中的错误码
```

#### 步骤 4：查看生成的 Tasks

```markdown
## Phase 3: 前端 Mock 开发 (Steps 6-7)
- [x] **Task 3.1**: [Step 6-7] 前端 Mock 开发
  - 状态: 跳过（backend-only 模式）

## Phase 4: 后端骨架 (Step 8)
- [ ] **Task 4.1**: [Step 8] 实现控制器骨架
  - 目标: 创建/更新路由 (backend/app/routers/orders.py)
  - 约束: 返回契约中的**静态 JSON**。**不连接数据库**。
  - 操作: 实现中间件集成（认证、验证、日志）
  - 操作: 添加 X-Request-ID header 处理
  - 操作: 使用 `spec.md` 中的 mock 数据返回 StandardResp 格式

## Phase 5: 契约测试 (Step 9)
- [ ] **Task 5.1**: [Step 9] 运行 API 测试
  - 操作: 使用 Postman/curl/自动化测试测试端点
  - 操作: 验证响应格式匹配 `spec.md`
  - 操作: 测试错误响应和错误码
```

#### 步骤 5：实现后端

```bash
/opsx:apply order-management
```

实现内容：
- 创建 API 路由
- 实现业务逻辑
- 配置数据库模型和迁移
- 添加中间件（认证、验证、日志）
- 使用 Postman 测试 API

#### 步骤 6：API 测试示例

使用 Postman 测试：

```bash
# 创建订单
POST http://localhost:8000/api/orders
Headers:
  Content-Type: application/json
  X-Request-ID: abc-123-def
Body:
{
  "user_id": 123,
  "items": [
    {"product_id": 1, "quantity": 2}
  ]
}

# 预期响应
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 456,
    "user_id": 123,
    "total_amount": 99.99,
    "status": "pending",
    "created_at": "2024-01-28T10:30:00Z"
  }
}
```

---

## 中间件开发示例

### 场景：建立项目的基础设施层（认证、日志、错误处理）

#### 步骤 1：配置中间件独立模式

编辑 `openspec/config.yaml`:

```yaml
dev_mode: middleware-only  # 中间件独立开发模式
```

#### 步骤 2：创建中间件功能

```bash
/opsx:new authentication-middleware
```

#### 步骤 3：查看生成的 Design

```markdown
## 0. 开发模式配置

### 模式: middleware-only

**中间件独立模式**:
- 隔离的中间件开发和测试
- 使用 Mock handlers 测试中间件行为
- 重点: 认证、验证、日志、错误处理

## 3. 中间件架构

### 3.1 中间件组件
- **认证中间件**: 验证 JWT token，提取用户上下文
- **日志中间件**: 记录带 trace_id 的请求/响应
- **错误处理中间件**: 捕获异常，返回 StandardResp 格式

### 3.2 执行顺序
1. CORS
2. Request ID 生成
3. 日志（请求开始）
4. 认证
5. 验证
6. 业务逻辑处理器
7. 日志（响应）
8. 错误处理器

### 3.3 测试策略
- 使用 mock handlers 隔离测试中间件
- 验证请求/响应转换
- 测试错误处理和日志
```

#### 步骤 4：实现中间件

```python
# backend/app/middleware/auth.py
from fastapi import Request, HTTPException
from jose import jwt, JWTError
import logging

logger = logging.getLogger(__name__)

async def auth_middleware(request: Request, call_next):
    trace_id = request.headers.get("X-Request-ID", "unknown")

    # 跳过公开端点的认证
    if request.url.path in ["/health", "/docs"]:
        return await call_next(request)

    # 验证 JWT token
    token = request.headers.get("Authorization", "").replace("Bearer ", "")
    if not token:
        logger.error(f"[{trace_id}] 缺少授权 token")
        raise HTTPException(
            status_code=401,
            detail={
                "code": 1002,
                "message": "Unauthorized",
                "data": None,
                "error_details": {
                    "reason": "Missing authorization token",
                    "trace_id": trace_id
                }
            }
        )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=["HS256"])
        request.state.user_id = payload.get("user_id")
        logger.info(f"[{trace_id}] 用户已认证: {request.state.user_id}")
    except JWTError as e:
        logger.error(f"[{trace_id}] 无效 token: {str(e)}")
        raise HTTPException(
            status_code=401,
            detail={
                "code": 1002,
                "message": "Unauthorized",
                "data": None,
                "error_details": {
                    "reason": "Invalid token",
                    "trace_id": trace_id
                }
            }
        )

    response = await call_next(request)
    return response
```

#### 步骤 5：测试中间件

```python
# tests/test_auth_middleware.py
import pytest
from fastapi.testclient import TestClient

def test_auth_middleware_missing_token(client: TestClient):
    response = client.get("/api/users")
    assert response.status_code == 401
    assert response.json()["code"] == 1002
    assert "trace_id" in response.json()["error_details"]

def test_auth_middleware_valid_token(client: TestClient):
    token = generate_test_token(user_id=123)
    response = client.get(
        "/api/users",
        headers={"Authorization": f"Bearer {token}"}
    )
    assert response.status_code == 200
```

---

## 基础架构初始化示例

### 场景：新项目初始化，建立基础设施标准

#### 步骤 1：生成基础架构规范

```bash
/opsx:new infrastructure
```

#### 步骤 2：查看生成的 infrastructure.md

文件包含：

1. **日志系统**
   - 日志级别（DEBUG/INFO/WARN/ERROR/CRITICAL）
   - 结构化日志格式（JSON）
   - 必需字段（timestamp, level, trace_id, message, context）

2. **错误处理系统**
   - 错误码结构（1xxx-5xxx）
   - 标准错误码列表
   - 错误响应格式

3. **请求/响应格式**
   - StandardResp 接口定义
   - 成功响应示例
   - 错误响应示例
   - 分页响应格式

4. **中间件架构**
   - 标准中间件组件
   - 执行顺序
   - 实现指南

5. **开发模式支持**
   - 4 种开发模式说明
   - 每种模式的配置示例

#### 步骤 3：实现基础架构

根据 `infrastructure.md` 实现：

**日志系统**:
```python
# backend/app/utils/logger.py
import logging
import json
from datetime import datetime

class StructuredLogger:
    def __init__(self, service_name: str):
        self.service_name = service_name
        self.logger = logging.getLogger(service_name)

    def log(self, level: str, message: str, trace_id: str, context: dict = None):
        log_entry = {
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "level": level,
            "service": self.service_name,
            "trace_id": trace_id,
            "message": message,
            "context": context or {}
        }

        if level == "ERROR" or level == "CRITICAL":
            self.logger.error(json.dumps(log_entry))
        elif level == "WARN":
            self.logger.warning(json.dumps(log_entry))
        else:
            self.logger.info(json.dumps(log_entry))
```

**错误码定义**:
```python
# backend/app/constants/error_codes.py
class ErrorCode:
    # 1xxx: 客户端错误
    INVALID_PARAMETER = 1000
    VALIDATION_FAILED = 1001
    UNAUTHORIZED = 1002
    FORBIDDEN = 1003

    # 2xxx: 业务逻辑错误
    RESOURCE_NOT_FOUND = 2000
    RESOURCE_ALREADY_EXISTS = 2001
    BUSINESS_RULE_VIOLATION = 2002

    # 3xxx: 外部服务错误
    EXTERNAL_SERVICE_UNAVAILABLE = 3000

    # 4xxx: 系统错误
    DATABASE_ERROR = 4000
    NETWORK_ERROR = 4001

    # 5xxx: 未知错误
    INTERNAL_SERVER_ERROR = 5000

ERROR_MESSAGES = {
    ErrorCode.INVALID_PARAMETER: "Invalid Parameter",
    ErrorCode.VALIDATION_FAILED: "Validation Failed",
    ErrorCode.UNAUTHORIZED: "Unauthorized",
    # ... 其他错误码
}
```

**StandardResp 实现**:
```python
# backend/app/models/response.py
from typing import TypeVar, Generic, Optional
from pydantic import BaseModel

T = TypeVar('T')

class StandardResp(BaseModel, Generic[T]):
    code: int
    message: str
    data: Optional[T] = None
    error_details: Optional[dict] = None

def success_response(data: T) -> StandardResp[T]:
    return StandardResp(code=0, message="success", data=data)

def error_response(code: int, message: str, trace_id: str, details: dict = None) -> StandardResp:
    return StandardResp(
        code=code,
        message=message,
        data=None,
        error_details={
            "trace_id": trace_id,
            **(details or {})
        }
    )
```

#### 步骤 4：验证基础架构

```bash
# 运行测试
pytest tests/test_infrastructure.py

# 检查日志格式
tail -f logs/app.log | jq .

# 验证错误响应
curl -X POST http://localhost:8000/api/test-error \
  -H "X-Request-ID: test-123"
```

---

## 总结

这些示例展示了如何使用 OpenSpec Template 的新功能：

1. **基础架构规范**：为项目建立统一的日志、错误处理、响应格式标准
2. **开发模式**：支持前端、后端、中间件独立开发，提高团队并行效率
3. **契约优先**：确保前后端接口一致，减少联调成本
4. **自动验证**：每个阶段自动验证，确保实现符合契约

更多信息请参考：
- [README.md](README.md) - 英文完整使用指南
- [README_CN.md](README_CN.md) - 中文完整使用指南
- [OPTIMIZATION_SUMMARY.md](OPTIMIZATION_SUMMARY.md) - 英文优化详情
- [OPTIMIZATION_SUMMARY_CN.md](OPTIMIZATION_SUMMARY_CN.md) - 中文优化详情
