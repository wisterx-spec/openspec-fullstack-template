"""
全局异常处理器
"""
import logging
import traceback
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import ValidationError

from .exceptions import BusinessException
from .response import error

logger = logging.getLogger(__name__)


def register_exception_handlers(app: FastAPI):
    """注册全局异常处理器"""

    @app.exception_handler(BusinessException)
    async def business_exception_handler(request: Request, exc: BusinessException):
        """业务异常处理"""
        logger.warning(f"Business exception: {exc}")
        return JSONResponse(
            status_code=200,  # HTTP 200，业务码在 body 里
            content=error(exc.message)
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(request: Request, exc: RequestValidationError):
        """请求参数校验异常"""
        errors = []
        for err in exc.errors():
            field = ".".join(str(loc) for loc in err["loc"][1:])  # 跳过 body/query
            errors.append(f"{field}: {err['msg']}")
        message = "; ".join(errors) if errors else "参数校验失败"
        logger.warning(f"Validation error: {message}")
        return JSONResponse(
            status_code=200,
            content=error(message)
        )

    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        """全局异常处理"""
        logger.error(f"Unhandled exception: {exc}\n{traceback.format_exc()}")

        # 开发环境返回详细错误
        import os
        if os.getenv("DEBUG", "false").lower() == "true":
            return JSONResponse(
                status_code=500,
                content=error(f"服务器错误: {str(exc)}")
            )

        # 生产环境返回友好提示
        return JSONResponse(
            status_code=500,
            content=error("服务器内部错误，请稍后重试")
        )
