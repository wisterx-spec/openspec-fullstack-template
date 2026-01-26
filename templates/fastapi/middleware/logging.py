"""
请求日志中间件
"""
import time
import uuid
import logging
from contextvars import ContextVar
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

logger = logging.getLogger(__name__)

# 请求上下文中的 trace_id
trace_id_var: ContextVar[str] = ContextVar("trace_id", default="")


def get_trace_id() -> str:
    """获取当前请求的 trace_id"""
    return trace_id_var.get()


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """请求日志中间件

    记录每个请求的：
    - trace_id
    - 请求方法和路径
    - 响应状态码
    - 耗时
    """

    async def dispatch(self, request: Request, call_next):
        # 生成 trace_id
        trace_id = request.headers.get("X-Trace-ID") or str(uuid.uuid4())[:8]
        trace_id_var.set(trace_id)

        # 记录请求开始
        start_time = time.time()
        method = request.method
        path = request.url.path
        query = str(request.query_params) if request.query_params else ""

        logger.info(f"[{trace_id}] --> {method} {path} {query}")

        # 执行请求
        response = await call_next(request)

        # 记录请求结束
        duration = time.time() - start_time
        status_code = response.status_code

        log_level = logging.INFO if status_code < 400 else logging.WARNING
        logger.log(
            log_level,
            f"[{trace_id}] <-- {method} {path} {status_code} ({duration:.3f}s)"
        )

        # 在响应头中返回 trace_id
        response.headers["X-Trace-ID"] = trace_id

        return response
