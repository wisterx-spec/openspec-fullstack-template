"""
健康检查路由
"""
from fastapi import APIRouter
from ..core.response import ok

router = APIRouter(tags=["Health"])


@router.get("/health")
async def health_check():
    """健康检查"""
    return ok({"status": "healthy"})
