# <!-- Feature Name --> - API Specification

## Overview
<!-- Brief description of this feature's API -->

---

## API Endpoints

### `GET /api/v1/<!-- resource -->`

**Summary**: <!-- Endpoint description -->

**Request Headers**:
| Header | Required | Description |
|--------|----------|-------------|
| X-Request-ID | Yes | Request tracing ID (UUID v4) |
| Authorization | Yes/No | Bearer token for authentication |

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | integer | No | Page number (default: 1) |
| page_size | integer | No | Items per page (default: 20) |

**Response** (Success - 200):
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Example",
        "created_at": "2024-01-28T10:30:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total_count": 100,
      "total_pages": 5
    }
  }
}
```

**Response** (Error - 400):
```json
{
  "code": 1000,
  "message": "Invalid Parameter",
  "data": null,
  "error_details": {
    "field": "page",
    "reason": "Must be a positive integer",
    "trace_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

### `POST /api/v1/<!-- resource -->`

**Summary**: <!-- Endpoint description -->

**Request Headers**:
| Header | Required | Description |
|--------|----------|-------------|
| Content-Type | Yes | application/json |
| X-Request-ID | Yes | Request tracing ID (UUID v4) |
| Authorization | Yes | Bearer token |

**Request Body**:
```json
{
  "name": "Example Name",
  "description": "Example description"
}
```

**Response** (Success - 201):
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "Example Name",
    "description": "Example description",
    "created_at": "2024-01-28T10:30:00Z",
    "updated_at": "2024-01-28T10:30:00Z"
  }
}
```

**Response** (Error - 400):
```json
{
  "code": 1001,
  "message": "Validation Failed",
  "data": null,
  "error_details": {
    "field": "name",
    "reason": "Name is required",
    "trace_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

### `GET /api/v1/<!-- resource -->/{id}`

**Summary**: <!-- Endpoint description -->

**Path Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| id | integer | Resource ID |

**Response** (Success - 200):
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": 123,
    "name": "Example Name",
    "description": "Example description",
    "created_at": "2024-01-28T10:30:00Z",
    "updated_at": "2024-01-28T10:30:00Z"
  }
}
```

**Response** (Error - 404):
```json
{
  "code": 2000,
  "message": "Resource Not Found",
  "data": null,
  "error_details": {
    "resource": "<!-- resource -->",
    "id": 123,
    "trace_id": "550e8400-e29b-41d4-a716-446655440000"
  }
}
```

---

## Error Codes

Reference: `infrastructure.md` for complete error code system.

| Code | Message | HTTP Status | When to Use |
|------|---------|-------------|-------------|
| 1000 | Invalid Parameter | 400 | Missing or malformed request parameter |
| 1001 | Validation Failed | 400 | Data validation error |
| 2000 | Resource Not Found | 404 | Requested resource doesn't exist |
| 4000 | Database Error | 500 | Database operation failure |
| 5000 | Internal Server Error | 500 | Unexpected system error |

---

## Logging Requirements

| Operation | Log Level | Required Fields |
|-----------|-----------|-----------------|
| Request received | INFO | trace_id, method, path, user_id |
| Request completed | INFO | trace_id, status, duration_ms |
| Slow operation (>1s) | WARN | trace_id, operation, duration_ms |
| Error occurred | ERROR | trace_id, error_code, stack_trace |

---

## Database Schema

### Table: `<!-- table_name -->`

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| id | SERIAL | NO | - | Primary Key |
| name | VARCHAR(255) | NO | - | Resource name |
| description | TEXT | YES | NULL | Resource description |
| created_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Creation time |
| updated_at | TIMESTAMP | NO | CURRENT_TIMESTAMP | Last update time |

**Indexes**:
- `idx_<!-- table_name -->_name` ON (name)
- `idx_<!-- table_name -->_created_at` ON (created_at)

**Constraints**:
- PRIMARY KEY (id)
- UNIQUE (name) <!-- if applicable -->

---

## Validation Checklist

- [ ] All endpoints have JSON request/response examples
- [ ] All responses follow StandardResp structure
- [ ] Database tables define necessary indexes
- [ ] Error codes are documented and follow infrastructure.md standards
- [ ] Logging requirements are specified for critical operations
- [ ] Request headers include X-Request-ID for tracing
- [ ] Pagination endpoints return total_count
- [ ] Error responses include error_details with trace_id
