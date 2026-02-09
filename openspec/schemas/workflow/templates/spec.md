# <!-- Feature Name --> - API Specification

## Overview
<!-- Brief description of this feature's API -->

---

## Requirements Traceability (Optional but Recommended)

<!-- Map each endpoint to proposal user stories / acceptance criteria. Reduces late rework by ensuring nothing is missed. -->

| Endpoint / Behavior | User Story | Acceptance Criterion |
|--------------------|------------|----------------------|
| `GET /api/v1/...`  | Story 1    | AC-1.1, AC-1.2       |
| `POST /api/v1/...` | Story 2    | AC-2.1               |

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
    "total": 100,
    "page": 1,
    "page_size": 20
  }
}
```

**Response** (Error - 400):
```json
{
  "code": 100001,
  "message": "Missing Required Parameter",
  "data": null,
  "details": {
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
  "code": 100002,
  "message": "Invalid Parameter Format",
  "data": null,
  "details": {
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
  "code": 300001,
  "message": "Resource Not Found",
  "data": null,
  "details": {
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
| 100001 | Missing Required Parameter | 400 | Missing or malformed request parameter |
| 100002 | Invalid Parameter Format | 400 | Data validation error |
| 300001 | Resource Not Found | 404 | Requested resource doesn't exist |
| 500001 | Database Error | 500 | Database operation failure |
| 500003 | Internal Server Error | 500 | Unexpected system error |

> Error codes are 6-digit `CCMMSS` format. See `openspec/conventions/api-convention.md` for full table.

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
- [ ] Error responses include details with trace_id
