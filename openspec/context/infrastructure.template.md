# Infrastructure Specification: {{ PROJECT_NAME }}

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
  "service": "{{ SERVICE_NAME }}",
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

### 3.1 Standard Response Format (StandardResp)
```json
{
  "code": 0,
  "message": "success",
  "data": {
    // Response data
  }
}
```

### 3.2 Success Response Examples

**Single Resource**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "John Doe",
    "email": "john@example.com"
  }
}
```

**List with Pagination**:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {"id": 1, "name": "Item 1"},
      {"id": 2, "name": "Item 2"}
    ],
    "total": 100,
    "page": 1,
    "page_size": 20,
    "total_pages": 5
  }
}
```

### 3.3 Required Request Headers
- **X-Request-ID**: UUID v4 for request tracing (required for all API calls)

### 3.4 Response Code Convention
- **code: 0**: Success
- **code: 1xxx-5xxx**: Error codes (see Error Handling System)

---

## 4. Middleware Architecture

### 4.1 Middleware Components
- **CORS Middleware**: Handle cross-origin requests
- **Request ID Middleware**: Generate/forward X-Request-ID header
- **Logging Middleware**: Log request/response with trace_id
- **Authentication Middleware**: Verify JWT token, extract user context
- **Validation Middleware**: Validate request parameters/body
- **Error Handler Middleware**: Catch exceptions, return StandardResp format

### 4.2 Execution Order
1. CORS
2. Request ID generation (if missing)
3. Logging (request start)
4. Authentication (if required)
5. Validation
6. Business logic handler
7. Logging (response)
8. Error handler (catch exceptions)

### 4.3 Middleware Implementation Guidelines
- **Idempotent**: Middleware should not modify request/response unnecessarily
- **Fast**: Keep middleware lightweight, avoid heavy operations
- **Configurable**: Allow enabling/disabling per route
- **Testable**: Test middleware in isolation

---

## 5. Development Mode Support

### 5.1 Fullstack Mode
- Complete frontend + backend + middleware development
- Real database connections
- Full API implementation
- E2E testing

### 5.2 Frontend-Only Mode
- Frontend development with mock backend
- Mock API responses from spec.md JSON examples
- No real database connections
- Focus on UI/UX development

### 5.3 Backend-Only Mode
- Backend API development
- Real database connections
- Test with Postman/curl
- No frontend code generation

### 5.4 Middleware-Only Mode
- Infrastructure and middleware development
- Focus on auth, logging, error handling
- Mock handlers for testing
- Isolated middleware testing

---

## 6. Console Output Format

### 6.1 Development Console
- Use structured logging format (see Logging System)
- Color-coded output for different log levels
- Include trace_id in all log messages

### 6.2 Production Console
- JSON format only (no colors)
- All logs must include trace_id
- Sensitive data must be masked

---

## 7. Testing Standards

### 7.1 Unit Tests
- Test individual functions/methods
- Mock external dependencies
- Use test fixtures for data

### 7.2 Integration Tests
- Test API endpoints
- Use test database
- Verify StandardResp format

### 7.3 E2E Tests
- Test complete user flows
- Use real database (test environment)
- Verify contract compliance

---

## 8. Security Guidelines

### 8.1 Authentication
- Use JWT tokens for API authentication
- Token expiration: 24 hours (configurable)
- Refresh token mechanism

### 8.2 Authorization
- Role-based access control (RBAC)
- Resource-level permissions
- Audit logging for sensitive operations

### 8.3 Data Protection
- Never log sensitive data (passwords, tokens, PII)
- Use HTTPS for all API calls
- Validate and sanitize all inputs

---

## Notes

- This infrastructure specification should be referenced in all feature specs
- Error codes should be consistent across all APIs
- Logging format should be consistent across all services
- Middleware order should be strictly followed
