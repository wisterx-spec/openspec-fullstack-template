#!/bin/bash

# OpenSpec Fullstack Template 初始化脚本
# 用法: ./init.sh /path/to/project --stack fastapi+react

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
STACK=""

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --stack)
            STACK="$2"
            shift 2
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

if [ -z "$TARGET_DIR" ]; then
    echo "用法: ./init.sh /path/to/project --stack fastapi+react"
    echo ""
    echo "支持的技术栈:"
    echo "  --stack fastapi+react    FastAPI 后端 + React 前端"
    echo "  --stack fastapi          仅 FastAPI 后端"
    echo "  --stack react            仅 React 前端"
    exit 1
fi

# 创建目标目录
mkdir -p "$TARGET_DIR"

echo "初始化项目: $TARGET_DIR"
echo "技术栈: ${STACK:-未指定}"
echo ""

# 1. 复制 OpenSpec 配置
echo "复制 OpenSpec 配置..."
mkdir -p "$TARGET_DIR/.claude/commands"
cp -r "$SCRIPT_DIR/.claude/commands/openspec" "$TARGET_DIR/.claude/commands/"
cp -r "$SCRIPT_DIR/openspec" "$TARGET_DIR/"

# 2. 根据技术栈复制模板
case $STACK in
    fastapi+react)
        echo "复制 FastAPI 后端模板..."
        mkdir -p "$TARGET_DIR/backend/app"
        cp -r "$SCRIPT_DIR/templates/fastapi/"* "$TARGET_DIR/backend/app/"

        echo "复制 React 前端模板..."
        mkdir -p "$TARGET_DIR/frontend/src"
        cp -r "$SCRIPT_DIR/templates/react/"* "$TARGET_DIR/frontend/src/"
        ;;
    fastapi)
        echo "复制 FastAPI 后端模板..."
        mkdir -p "$TARGET_DIR/backend/app"
        cp -r "$SCRIPT_DIR/templates/fastapi/"* "$TARGET_DIR/backend/app/"
        ;;
    react)
        echo "复制 React 前端模板..."
        mkdir -p "$TARGET_DIR/frontend/src"
        cp -r "$SCRIPT_DIR/templates/react/"* "$TARGET_DIR/frontend/src/"
        ;;
    "")
        echo "未指定技术栈，仅复制 OpenSpec 配置"
        ;;
    *)
        echo "不支持的技术栈: $STACK"
        exit 1
        ;;
esac

# 3. 复制 CLAUDE.md
echo "生成 CLAUDE.md..."
cp "$SCRIPT_DIR/CLAUDE.template.md" "$TARGET_DIR/CLAUDE.md"

# 4. 复制 .gitignore
if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    echo "复制 .gitignore..."
    cp "$SCRIPT_DIR/.gitignore.template" "$TARGET_DIR/.gitignore"
fi

# 5. 复制 .env.template
echo "复制 .env.template..."
cp "$SCRIPT_DIR/.env.template" "$TARGET_DIR/.env.template"

echo ""
echo "初始化完成！"
echo ""
echo "下一步:"
echo "  1. cd $TARGET_DIR"
echo "  2. cp .env.template .env  # 配置环境变量"
echo "  3. 根据需要修改 CLAUDE.md 中的项目规范"
