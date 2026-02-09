#!/bin/bash

# ff-check-no-mock-in-build.sh
#
# 检查生产构建产物中是否包含 Mock 代码残留。
# 在 CI/CD 中或部署前运行，确认构建隔离有效。
#
# 用法：
#   ./scripts/ff-check-no-mock-in-build.sh [build-dir]
#
# 示例：
#   ./scripts/ff-check-no-mock-in-build.sh           # 默认检查 dist/
#   ./scripts/ff-check-no-mock-in-build.sh build/     # 检查 build/ 目录
#   ./scripts/ff-check-no-mock-in-build.sh .next/     # Next.js 构建产物
#
# 检查项：
#   1. Mock 相关关键词（mockData, mock_data, MOCK_MODE, enableMock, .mock.）
#   2. MSW 相关文件（mockServiceWorker）
#   3. devtools 引用
#
# 退出码：
#   0 = 干净，无 Mock 泄漏
#   1 = 发现 Mock 代码残留

BUILD_DIR="${1:-dist}"

echo ""
echo "═══════════════════════════════════════════"
echo "  构建产物 Mock 泄漏检查"
echo "═══════════════════════════════════════════"
echo ""
echo "检查目录: ${BUILD_DIR}/"
echo ""

# 检查目录是否存在
if [ ! -d "$BUILD_DIR" ]; then
  echo "❌ 构建目录不存在: ${BUILD_DIR}/"
  echo "   请先运行构建命令（如 npm run build）"
  exit 1
fi

FOUND_ISSUES=0

# 检查 1：Mock 相关关键词
echo "── 检查 1：Mock 关键词 ──"
MOCK_KEYWORDS="mockData\|mock_data\|MOCK_MODE\|enableMock\|ENABLE_MOCK\|\.mock\.\|useMock\|isMock"
MATCHES=$(grep -rl "$MOCK_KEYWORDS" "$BUILD_DIR" 2>/dev/null)

if [ -n "$MATCHES" ]; then
  echo "❌ 发现 Mock 关键词:"
  echo "$MATCHES" | while read -r file; do
    echo "   - $file"
    grep -n "$MOCK_KEYWORDS" "$file" 2>/dev/null | head -3 | while read -r line; do
      echo "     $line"
    done
  done
  FOUND_ISSUES=1
else
  echo "✅ 无 Mock 关键词"
fi
echo ""

# 检查 2：MSW 相关
echo "── 检查 2：MSW / Service Worker ──"
MSW_KEYWORDS="mockServiceWorker\|setupWorker\|msw\/browser\|msw\/node"
MATCHES=$(grep -rl "$MSW_KEYWORDS" "$BUILD_DIR" 2>/dev/null)

if [ -n "$MATCHES" ]; then
  echo "❌ 发现 MSW 相关代码:"
  echo "$MATCHES" | while read -r file; do
    echo "   - $file"
  done
  FOUND_ISSUES=1
else
  echo "✅ 无 MSW 相关代码"
fi
echo ""

# 检查 3：devtools 引用
echo "── 检查 3：devtools 引用 ──"
DEVTOOLS_KEYWORDS="devtools\|\/mocks\/\|mock-handler\|mockHandler"
MATCHES=$(grep -rl "$DEVTOOLS_KEYWORDS" "$BUILD_DIR" 2>/dev/null)

if [ -n "$MATCHES" ]; then
  echo "❌ 发现 devtools 引用:"
  echo "$MATCHES" | while read -r file; do
    echo "   - $file"
  done
  FOUND_ISSUES=1
else
  echo "✅ 无 devtools 引用"
fi
echo ""

# 检查 4：mockServiceWorker.js 文件
echo "── 检查 4：mockServiceWorker.js 文件 ──"
if [ -f "$BUILD_DIR/mockServiceWorker.js" ]; then
  echo "❌ 发现 mockServiceWorker.js 文件（应排除在构建产物外）"
  FOUND_ISSUES=1
else
  echo "✅ 无 mockServiceWorker.js 文件"
fi
echo ""

# 总结
echo "═══════════════════════════════════════════"
if [ $FOUND_ISSUES -eq 0 ]; then
  echo "✅ 构建产物干净，无 Mock 泄漏"
  echo "═══════════════════════════════════════════"
  exit 0
else
  echo "❌ 发现 Mock 代码残留！请检查构建配置"
  echo ""
  echo "常见原因："
  echo "  1. 入口文件未使用 import.meta.env.DEV 条件判断"
  echo "  2. 业务代码中直接 import 了 devtools/ 下的文件"
  echo "  3. 静态 import 而非动态 import() Mock 模块"
  echo ""
  echo "修复方法见: FRONTEND_FIRST_WORKFLOW_CN.md 第4层防护章节"
  echo "═══════════════════════════════════════════"
  exit 1
fi
