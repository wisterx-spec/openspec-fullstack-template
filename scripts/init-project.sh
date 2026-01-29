#!/bin/bash
# 友好的项目初始化脚本
# 用法: ./scripts/init-project.sh 或直接运行后在 Cursor 中使用 /opsx:init-project

set -e

CONTEXT_DIR="openspec/context"
TEMPLATE_DIR="openspec/context"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      OpenSpec 项目上下文初始化助手                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查模板文件是否存在
if [ ! -f "$TEMPLATE_DIR/project_summary.template.md" ]; then
    echo -e "${YELLOW}⚠️  模板文件不存在，请确保在项目根目录运行此脚本${NC}"
    exit 1
fi

# 检查是否已存在文件
if [ -f "$CONTEXT_DIR/project_summary.md" ]; then
    echo -e "${YELLOW}⚠️  project_summary.md 已存在${NC}"
    read -p "是否覆盖？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "已取消"
        exit 0
    fi
fi

# 收集项目信息
echo -e "${GREEN}📝 请填写项目信息（直接回车使用默认值）${NC}"
echo ""

read -p "项目名称: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-"MyProject"}

read -p "项目描述: " PROJECT_DESC
PROJECT_DESC=${PROJECT_DESC:-"待填写项目描述"}

echo ""
echo -e "${BLUE}技术栈信息：${NC}"
read -p "语言/运行时 (如 Python 3.11, Node.js 20): " LANG_RUNTIME
LANG_RUNTIME=${LANG_RUNTIME:-"待填写"}

read -p "框架 (如 FastAPI, React 18): " FRAMEWORKS
FRAMEWORKS=${FRAMEWORKS:-"待填写"}

read -p "数据库/ORM (如 PostgreSQL + SQLAlchemy): " DB_ORM
DB_ORM=${DB_ORM:-"待填写"}

# 确保目录存在
mkdir -p "$CONTEXT_DIR"

# 生成 project_summary.md
echo -e "${GREEN}📄 正在生成 project_summary.md...${NC}"
sed "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" \
    "$TEMPLATE_DIR/project_summary.template.md" | \
    sed "s/{{ PROJECT_DESCRIPTION }}/$PROJECT_DESC/g" > \
    "$CONTEXT_DIR/project_summary.md"

# 如果 tech_stack.md 不存在，从模板复制
if [ ! -f "$CONTEXT_DIR/tech_stack.md" ]; then
    echo -e "${GREEN}📄 正在生成 tech_stack.md...${NC}"
    cp "$TEMPLATE_DIR/tech_stack.template.md" "$CONTEXT_DIR/tech_stack.md"
fi

# 更新 config.yaml（如果存在）
if [ -f "openspec/config.yaml" ]; then
    echo -e "${GREEN}⚙️  正在更新 config.yaml...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" openspec/config.yaml
    else
        # Linux
        sed -i "s/{{ PROJECT_NAME }}/$PROJECT_NAME/g" openspec/config.yaml
    fi
fi

echo ""
echo -e "${GREEN}✅ 初始化完成！${NC}"
echo ""
echo -e "${BLUE}📋 下一步：${NC}"
echo "1. 编辑 openspec/context/project_summary.md 补充详细信息"
echo "2. 编辑 openspec/context/tech_stack.md 填写技术栈详情"
echo "3. 在 Cursor 中运行: /opsx:new infrastructure (可选，生成基础设施规范)"
echo "4. 开始开发: /opsx:new <功能名>"
echo ""
