"""
CORS 配置
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


def setup_cors(app: FastAPI, origins: list[str] = None):
    """配置 CORS

    Args:
        app: FastAPI 应用实例
        origins: 允许的源列表，默认允许所有
    """
    if origins is None:
        origins = ["*"]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
