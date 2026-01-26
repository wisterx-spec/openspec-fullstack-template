"""
业务异常和错误码定义
"""
from typing import Optional


class ErrorCode:
    """错误码定义"""
    # 通用错误 (400xx)
    INVALID_PARAMS = 40001
    RESOURCE_NOT_FOUND = 40004
    RESOURCE_ALREADY_EXISTS = 40009

    # 认证错误 (401xx)
    UNAUTHORIZED = 40101
    TOKEN_EXPIRED = 40102

    # 权限错误 (403xx)
    FORBIDDEN = 40301

    # 服务器错误 (500xx)
    INTERNAL_ERROR = 50001
    DATABASE_ERROR = 50002


class BusinessException(Exception):
    """业务异常

    用于业务逻辑中的可预期错误，会被全局异常处理器捕获并转为统一响应格式。
    """

    def __init__(
        self,
        message: str,
        code: int = ErrorCode.INTERNAL_ERROR,
        detail: Optional[dict] = None
    ):
        self.message = message
        self.code = code
        self.detail = detail
        super().__init__(message)

    def __str__(self) -> str:
        return f"[{self.code}] {self.message}"


class NotFoundException(BusinessException):
    """资源不存在"""
    def __init__(self, message: str = "资源不存在", detail: Optional[dict] = None):
        super().__init__(message, ErrorCode.RESOURCE_NOT_FOUND, detail)


class ValidationException(BusinessException):
    """参数校验失败"""
    def __init__(self, message: str = "参数校验失败", detail: Optional[dict] = None):
        super().__init__(message, ErrorCode.INVALID_PARAMS, detail)


class UnauthorizedException(BusinessException):
    """未授权"""
    def __init__(self, message: str = "未授权", detail: Optional[dict] = None):
        super().__init__(message, ErrorCode.UNAUTHORIZED, detail)


class ForbiddenException(BusinessException):
    """无权限"""
    def __init__(self, message: str = "无权限", detail: Optional[dict] = None):
        super().__init__(message, ErrorCode.FORBIDDEN, detail)
