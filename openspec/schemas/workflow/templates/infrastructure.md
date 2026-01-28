# Infrastructure Specification: <!-- Project Name -->

## 1. Logging System

### 1.1 Log Levels
| Level | Usage | Example |
|-------|-------|---------|
| DEBUG | Development debugging | Function entry/exit, variable values |
| INFO | Normal operations | Request received, task completed |
| WARN | Recoverable issues | Retry attempts, deprecated API usage |
| ERROR | Application errors | Failed operations, caught exceptions |
| CRITICAL | System failures | Database down, service unavailable |

### 1.2 Structured Logging Format
```json
{
  "timestamp": "2024-01-28T10:30:00.000Z",
  "level": "INFO",
  "service": "<!-- service_name -->",
  "trace_id": "uuid-v4",
  "message": "User login successful",
  "context": {
    "user_id": 12345,
    "ip": "192.168.1.1",
    "duration_ms": 150
  }
}
```

### 1.3 Required Fields
- **timestamp**: ISO 8601 format
- **level**: Log level (DEBUG/INFO/WARN/ERROR/CRITICAL)
- **service**: Service/module name
- **trace_id**: Request tracing ID (from X-Request-ID header)
- **message**: Human-readable message
- **context**: Additional structured data (optional)

### 1.4 Implementation Guidelines
- **Backend**: Use structured logging library (e.g., winston, pino, structlog)
- **Frontend**: Use console wrapper with structured format
- **Sensitive Data**: Never log passwords, tokens, or PII
- **Performance**: Log slow operations (>1s) with duration metrics

---

## 2. Error Handling System

### 2.1 Error Code Structure
```
[Category][SubCategory][Sequence]
Example: 1001, 2003, 4005
```

| Range | Category | Description |
|-------|----------|-------------|
| 1xxx | Client Errors | Invalid input, validation failures |
| 2xxx | Business Logic Errors | Business rule violations |
| 3xxx | External Service Errors | Third-party API failures |
| 4xxx | System Errors | Database, network, infrastructure |
| 5xxx | Unknown Errors | Unexpected exceptions |

### 2.2 Standard Error Codes
| Code | Message | Description |
|------|---------|-------------|
| 1000 | Invalid Parameter | Missing or malformed request parameter |
| 1001 | Validation Failed | Data validation error |
| 1002 | Unauthorized | Authentication required |
| 1003 | Forbidden | Insufficient permissions |
| 2000 | Resource Not Found | Requested resource doesn't exist |
| 2001 | Resource Already Exists | Duplicate resource creation |
| 2002 | Business Rule Violation | Operation violates business logic |
| 3000 | External Service Unavailable | Third-party service timeout/error |
| 4000 | Database Error | Database connection/query failure |
| 4001 | Network Error | Network connectivity issue |
| 5000 | Internal Server Error | Unexpected system error |

### 2.3 Error Response Format
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

### 2.4 Error Handling Guidelines
- **Catch Specific Exceptions**: Avoid generic `catch (Exception e)`
- **Log Before Throwing**: Always log errors with context
- **User-Friendly Messages**: Don't expose internal details to users
- **Retry Logic**: Implement exponential backoff for transient errors
- **Circuit Breaker**: Prevent cascading failures for external services

---

## 3. Request/Response Format

### 3.1 Standard Response Structure (StandardResp)
```typescript
interface StandardResp<T> {
  code: number;        // 0 for success, error code otherwise
  message: string;     // Human-readable message
  data: T | null;      // Response payload (null on error)
}
```

### 3.2 Success Response Example
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "Example",
    "created_at": "2024-01-28T10:30:00Z"
  }
}
```

### 3.3 Error Response Example
```json
{
  "code": 1000,
  "message": "Invalid Parameter",
  "data": null
}
```

### 3.4 Pagination Response
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total_count": 100,
      "total_pages": 5
    }
  }
}
```

### 3.5 Request Headers (Required)
- **Content-Type**: `application/json`
- **X-Request-ID**: Unique request identifier (UUID v4)
- **Authorization**: `Bearer <token>` (for authenticated endpoints)

---

## 4. Middleware Architecture

### 4.1 Request Processing Pipeline
```
Request → [CORS] → [Request ID] → [Logging] → [Auth] → [Validation] → [Handler] → [Response] → [Error Handler]
```

### 4.2 Middleware Execution Order (Critical)
1. CORS (first)
2. Request ID generation
3. Logging (request start)
4. Authentication
5. Validation
6. Business logic handler
7. Logging (response)
8. Error handler (last)

### 4.3 Standard Middleware Components

#### Authentication Middleware
- Verify JWT token
- Extract user context
- Attach user info to request

#### Validation Middleware
- Validate request schema
- Sanitize input data
- Return 400 on validation failure

#### Logging Middleware
- Log request start (method, path, headers)
- Log response (status, duration)
- Generate trace_id for request tracking

#### Error Handler Middleware
- Catch all unhandled exceptions
- Convert to StandardResp format
- Log error with stack trace
- Return appropriate HTTP status code

---

## 5. Development Mode Support

### 5.1 Mode Selection
```yaml
# Configuration
dev_mode: "fullstack"  # Options: fullstack, frontend-only, backend-only, middleware-only
```

### 5.2 Mode Descriptions

**Frontend-Only Mode**:
- Mock backend using JSON examples from spec.md
- Mock server (e.g., MSW, json-server)
- No backend dependency

**Backend-Only Mode**:
- API testing via Postman/curl
- CORS enabled for any origin
- No frontend dependency

**Middleware-Only Mode**:
- Isolated middleware testing
- Mock handlers for testing

**Fullstack Mode**:
- Complete integration
- E2E testing enabled

---

## 6. Implementation Checklist

- [ ] **Logging System**
  - [ ] Install logging library
  - [ ] Configure log levels and output format
  - [ ] Implement structured logging wrapper
  - [ ] Add trace_id generation

- [ ] **Error Handling**
  - [ ] Define error code constants
  - [ ] Implement custom exception classes
  - [ ] Create error response formatter
  - [ ] Add global error handler

- [ ] **Request/Response**
  - [ ] Define StandardResp type/interface
  - [ ] Create response wrapper utility
  - [ ] Implement pagination helper

- [ ] **Middleware**
  - [ ] Implement authentication middleware
  - [ ] Implement validation middleware
  - [ ] Implement logging middleware
  - [ ] Implement error handler middleware
  - [ ] Configure execution order
