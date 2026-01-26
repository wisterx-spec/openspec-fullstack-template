"""
统一响应格式
"""
from typing import Optional, Any, TypeVar, Generic
from pydantic import BaseModel, Field

T = TypeVar('T')


class StandardResp(BaseModel, Generic[T]):
    """标准响应格式"""
    status: str = Field(default="ok", description="状态: ok/error")
    data: Optional[T] = Field(None, description="响应数据")
    message: Optional[str] = Field(None, description="消息")


class PaginatedData(BaseModel, Generic[T]):
    """分页数据"""
    items: list[T] = Field(default_factory=list, description="数据列表")
    total: int = Field(description="总数")
    page: int = Field(description="当前页")
    limit: int = Field(description="每页数量")
    total_pages: int = Field(description="总页数")


def ok(data: Any = None, message: str = None) -> dict:
    """成功响应"""
    return {
        "status": "ok",
        "data": data,
        "message": message
    }


def error(message: str, data: Any = None) -> dict:
    """错误响应"""
    return {
        "status": "error",
        "data": data,
        "message": message
    }


def paginated(items: list, total: int, page: int, limit: int) -> dict:
    """分页响应"""
    total_pages = (total + limit - 1) // limit if limit > 0 else 0
    return ok({
        "items": items,
        "total": total,
        "page": page,
        "limit": limit,
        "total_pages": total_pages
    })
