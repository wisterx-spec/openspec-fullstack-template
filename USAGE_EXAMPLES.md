# OpenSpec Template Usage Examples

This document provides practical usage examples for the OpenSpec Fullstack Template, demonstrating how to use the new infrastructure and development mode features.

## Table of Contents

1. [Complete New Project Flow](#complete-new-project-flow)
2. [Frontend-Only Development Example](#frontend-only-development-example)
3. [Backend-Only Development Example](#backend-only-development-example)
4. [Middleware Development Example](#middleware-development-example)
5. [Infrastructure Initialization Example](#infrastructure-initialization-example)

---

## Complete New Project Flow

### Scenario: Creating a User Management System

#### Step 1: Project Initialization

```bash
# 1. Copy template to project
cp -r openspec-fullstack-template/openspec/ my-project/openspec/
cp -r openspec-fullstack-template/skills/ my-project/.cursor/skills/

# 2. Enter project directory
cd my-project

# 3. Configure project information
cd openspec/context/
mv project_summary.template.md project_summary.md
mv tech_stack.template.md tech_stack.md

# 4. Edit project information
# Edit project_summary.md and tech_stack.md
```

#### Step 2: Configure Development Mode

Edit `openspec/config.yaml`:

```yaml
project:
  name: "User Management System"
  language: "en"

# Select development mode
dev_mode: fullstack  # Complete frontend + backend development

global_context:
  - "context/project_summary.md"
  - "context/tech_stack.md"
  - "context/infrastructure.md"  # Will be generated in next step
```

#### Step 3: Generate Infrastructure Spec

In Cursor, execute:

```bash
/opsx:new infrastructure
```

This generates `openspec/context/infrastructure.md`, containing:
- Logging system specification
- Error code definitions (1000-5000)
- StandardResp response format
- Middleware architecture
- Development mode configuration

#### Step 4: Create User Management Feature

```bash
/opsx:new user-management
```

The system will guide you through:
1. **Proposal**: Define user management requirements and user stories
2. **Spec**: Define API endpoints and database schema
3. **Design**: Frontend and backend architecture design
4. **Tasks**: Specific implementation tasks

#### Step 5: View Generated Spec

`openspec/changes/user-management/spec.md` example:

```markdown
# User Management - API Specification

## API Endpoints

### `POST /api/users`

**Request**:
```json
{
  "username": "john_doe",
  "email": "john@example.com",
  "password": "secure_password"
}
```

**Response** (Success):
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

**Response** (Error):
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

**Error Codes**:
| Code | Message | When to Use |
|------|---------|-------------|
| 1000 | Invalid Parameter | Missing or malformed request parameter |
| 1001 | Validation Failed | Email already exists |
| 2000 | Resource Not Found | User not found |
```

#### Step 6: Implement Feature

```bash
/opsx:apply user-management
```

The system implements according to `tasks.md`:
- Phase 3: Frontend mock development
- Phase 4: Backend skeleton (returns static mock)
- Phase 5: E2E contract testing
- Phase 6: Real implementation (database + business logic)
- Phase 7: Real testing + Drift Check

#### Step 7: Verify Implementation

```bash
/opsx:verify user-management
```

Verification includes:
- API response format matches Spec
- Error codes are correct
- Logs include trace_id
- Pagination format is correct

---

## Frontend-Only Development Example

### Scenario: Frontend team develops UI first, backend not ready yet

#### Step 1: Configure Frontend-Only Mode

Edit `openspec/config.yaml`:

```yaml
dev_mode: frontend-only  # Frontend-only development mode
```

#### Step 2: Create Feature

```bash
/opsx:new product-list
```

#### Step 3: View Generated Design

`openspec/changes/product-list/design.md` will contain:

```markdown
## 0. Development Mode Configuration

### Mode: frontend-only

**Frontend-Only Mode**:
- Mock backend using JSON examples from `spec.md`
- Mock server configuration (e.g., MSW, json-server)
- No backend implementation required in this phase
- Focus: UI components, state management, user interactions

## 1. Frontend Architecture

### 1.3 Mocking Strategy

**Mock Server Setup**:
- Tool: MSW (Mock Service Worker)
- Mock data source: JSON examples from `spec.md`
- Mock server port: 3001
- How to simulate error responses: Use MSW handlers with error codes from infrastructure.md
```

#### Step 4: View Generated Tasks

`openspec/changes/product-list/tasks.md` will contain:

```markdown
## Phase 3: Frontend Mock Dev (Steps 6-7)
- [ ] **Task 3.1**: [Step 6] Implement Frontend with Mock Data
  - Action: Create Mock Data conforming to `StandardResp` format.
  - Action: Implement UI Components (ProductList, ProductCard, ProductFilter).
  - Action: Setup mock server (MSW) using JSON from `spec.md`
  - Action: Configure mock server port and routes
  - Action: Implement API client with request interceptors (add X-Request-ID)
  - Action: Implement error handling for StandardResp format

## Phase 4: Backend Skeleton (Step 8)
- [x] **Task 4.1**: [Step 8] Backend Skeleton
  - Status: Skipped (frontend-only mode)
```

#### Step 5: Implement Frontend

```bash
/opsx:apply product-list
```

Implementation includes:
- Create mock server using MSW
- Implement UI components
- Use JSON from `spec.md` as mock data
- Test UI interactions and data rendering

#### Step 6: Switch Mode When Backend Ready

When backend API is ready, modify `config.yaml`:

```yaml
dev_mode: fullstack  # Switch to fullstack mode
```

Then connect to real backend:
```bash
/opsx:apply product-list  # Continue implementation, connect to real API
```

---

## Backend-Only Development Example

### Scenario: Backend team focuses on API development, frontend handled by another team

#### Step 1: Configure Backend-Only Mode

Edit `openspec/config.yaml`:

```yaml
dev_mode: backend-only  # Backend-only development mode
```

#### Step 2: Create Feature

```bash
/opsx:new order-management
```

#### Step 3: View Generated Design

`openspec/changes/order-management/design.md` will contain:

```markdown
## 0. Development Mode Configuration

### Mode: backend-only

**Backend-Only Mode**:
- API implementation without frontend
- Testing via Postman/curl/automated tests
- CORS configuration for future frontend integration
- Focus: API endpoints, business logic, database operations

## 1. Frontend Architecture

**Frontend Architecture**: Not applicable for backend-only mode.

## 2. Backend Architecture

### 2.1 Router Location
- File: `backend/app/routers/orders.py`
- Endpoints: POST /api/orders, GET /api/orders, GET /api/orders/{id}

### 2.4 Middleware Integration
- Authentication: Required for all endpoints
- Validation: Request schema validation using Pydantic
- Logging: Log all requests with trace_id
- Error handling: Use error codes from infrastructure.md
```

#### Step 4: View Generated Tasks

```markdown
## Phase 3: Frontend Mock Dev (Steps 6-7)
- [x] **Task 3.1**: [Step 6-7] Frontend Mock Dev
  - Status: Skipped (backend-only mode)

## Phase 4: Backend Skeleton (Step 8)
- [ ] **Task 4.1**: [Step 8] Implement Controller Skeleton
  - Target: Create/Update Routers (backend/app/routers/orders.py).
  - Constraint: Return **Static JSON** from Contract. **NO DB CONNECTION**.
  - Action: Implement middleware integration (auth, validation, logging)
  - Action: Add X-Request-ID header handling
  - Action: Return StandardResp format with mock data from `spec.md`

## Phase 5: Contract Testing (Step 9)
- [ ] **Task 5.1**: [Step 9] Run API Tests
  - Action: Test endpoints with Postman/curl/automated tests
  - Action: Verify response format matches `spec.md`
  - Action: Test error responses and error codes
```

#### Step 5: Implement Backend

```bash
/opsx:apply order-management
```

Implementation includes:
- Create API routes
- Implement business logic
- Configure database models and migrations
- Add middleware (authentication, validation, logging)
- Test API with Postman

#### Step 6: API Test Example

Test with Postman:

```bash
# Create order
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

# Expected response
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

## Middleware Development Example

### Scenario: Establish project infrastructure layer (authentication, logging, error handling)

#### Step 1: Configure Middleware-Only Mode

Edit `openspec/config.yaml`:

```yaml
dev_mode: middleware-only  # Middleware-only development mode
```

#### Step 2: Create Middleware Feature

```bash
/opsx:new authentication-middleware
```

#### Step 3: View Generated Design

```markdown
## 0. Development Mode Configuration

### Mode: middleware-only

**Middleware-Only Mode**:
- Isolated middleware development and testing
- Mock handlers for testing middleware behavior
- Focus: Authentication, validation, logging, error handling

## 3. Middleware Architecture

### 3.1 Middleware Components
- **Authentication Middleware**: Verify JWT token, extract user context
- **Logging Middleware**: Log request/response with trace_id
- **Error Handler Middleware**: Catch exceptions, return StandardResp format

### 3.2 Execution Order
1. CORS
2. Request ID generation
3. Logging (request start)
4. Authentication
5. Validation
6. Business logic handler
7. Logging (response)
8. Error handler

### 3.3 Testing Strategy
- Test middleware in isolation with mock handlers
- Verify request/response transformation
- Test error handling and logging
```

#### Step 4: Implement Middleware

```python
# backend/app/middleware/auth.py
from fastapi import Request, HTTPException
from jose import jwt, JWTError
import logging

logger = logging.getLogger(__name__)

async def auth_middleware(request: Request, call_next):
    trace_id = request.headers.get("X-Request-ID", "unknown")

    # Skip auth for public endpoints
    if request.url.path in ["/health", "/docs"]:
        return await call_next(request)

    # Verify JWT token
    token = request.headers.get("Authorization", "").replace("Bearer ", "")
    if not token:
        logger.error(f"[{trace_id}] Missing authorization token")
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
        logger.info(f"[{trace_id}] User authenticated: {request.state.user_id}")
    except JWTError as e:
        logger.error(f"[{trace_id}] Invalid token: {str(e)}")
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

#### Step 5: Test Middleware

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

## Infrastructure Initialization Example

### Scenario: New project initialization, establishing infrastructure standards

#### Step 1: Generate Infrastructure Spec

```bash
/opsx:new infrastructure
```

#### Step 2: View Generated infrastructure.md

The file contains:

1. **Logging System**
   - Log levels (DEBUG/INFO/WARN/ERROR/CRITICAL)
   - Structured log format (JSON)
   - Required fields (timestamp, level, trace_id, message, context)

2. **Error Handling System**
   - Error code structure (1xxx-5xxx)
   - Standard error code list
   - Error response format

3. **Request/Response Format**
   - StandardResp interface definition
   - Success response example
   - Error response example
   - Pagination response format

4. **Middleware Architecture**
   - Standard middleware components
   - Execution order
   - Implementation guidelines

5. **Development Mode Support**
   - 4 development modes explained
   - Configuration examples for each mode

#### Step 3: Implement Infrastructure

Based on `infrastructure.md`, implement:

**Logging System**:
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

**Error Code Definitions**:
```python
# backend/app/constants/error_codes.py
class ErrorCode:
    # 1xxx: Client Errors
    INVALID_PARAMETER = 1000
    VALIDATION_FAILED = 1001
    UNAUTHORIZED = 1002
    FORBIDDEN = 1003

    # 2xxx: Business Logic Errors
    RESOURCE_NOT_FOUND = 2000
    RESOURCE_ALREADY_EXISTS = 2001
    BUSINESS_RULE_VIOLATION = 2002

    # 3xxx: External Service Errors
    EXTERNAL_SERVICE_UNAVAILABLE = 3000

    # 4xxx: System Errors
    DATABASE_ERROR = 4000
    NETWORK_ERROR = 4001

    # 5xxx: Unknown Errors
    INTERNAL_SERVER_ERROR = 5000

ERROR_MESSAGES = {
    ErrorCode.INVALID_PARAMETER: "Invalid Parameter",
    ErrorCode.VALIDATION_FAILED: "Validation Failed",
    ErrorCode.UNAUTHORIZED: "Unauthorized",
    # ... other error codes
}
```

**StandardResp Implementation**:
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

#### Step 4: Verify Infrastructure

```bash
# Run tests
pytest tests/test_infrastructure.py

# Check log format
tail -f logs/app.log | jq .

# Verify error response
curl -X POST http://localhost:8000/api/test-error \
  -H "X-Request-ID: test-123"
```

---

## Summary

These examples demonstrate how to use the OpenSpec Template's new features:

1. **Infrastructure Standards**: Establish unified logging, error handling, and response format standards for projects
2. **Development Modes**: Support frontend, backend, and middleware independent development, improving team parallelism
3. **Contract First**: Ensure frontend-backend interface consistency, reduce integration costs
4. **Auto Verification**: Automatic verification at each phase ensures implementation matches contract

For more information, see:
- [README.md](README.md) - Complete usage guide
- [OPTIMIZATION_SUMMARY.md](OPTIMIZATION_SUMMARY.md) - Optimization details
