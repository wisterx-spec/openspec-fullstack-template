# 测试指南

本文档说明如何测试 OpenSpec Fullstack Template 项目。

## 快速测试

### 1. 运行验证脚本

```bash
./validate.sh
```

这会运行 16 项检查，验证：
- ✅ 目录结构完整性
- ✅ 核心配置文件存在
- ✅ 所有模板文件存在
- ✅ 上下文模板文件（包括 infrastructure.template.md）
- ✅ 13 步工作流结构
- ✅ Schema 配置正确性
- ✅ 初始化脚本可执行性

**预期结果**：所有 16 项检查都应该通过 ✅

### 2. 测试初始化脚本

#### 测试完整初始化脚本

```bash
# 创建临时测试目录
mkdir -p /tmp/test-openspec-project
cd /tmp/test-openspec-project

# 运行初始化脚本
/path/to/openspec-fullstack-template/init.sh TestProject . fullstack

# 验证生成的文件
ls -la openspec/context/
# 应该看到：project_summary.md, tech_stack.md

# 验证配置
grep "TestProject" openspec/config.yaml
```

#### 测试友好初始化脚本

```bash
# 在模板目录下
cd openspec-fullstack-template

# 创建测试目录
mkdir -p /tmp/test-init-project
cd /tmp/test-init-project

# 复制必要的目录结构
mkdir -p openspec/context
cp -r /path/to/openspec-fullstack-template/openspec/context/*.template.md openspec/context/

# 运行脚本（交互式）
/path/to/openspec-fullstack-template/scripts/init-project.sh
# 按提示输入项目信息，选择是否生成 infrastructure.md
```

### 3. 测试 Cursor Skills

在 Cursor 中测试以下命令：

```bash
# 1. 项目初始化
/opsx:init-project

# 2. 创建新变更
/opsx:new test-feature

# 3. 检查开发规范
/opsx:check-standards

# 4. 新手引导
/opsx:onboard
```

## 详细测试清单

### 模板文件测试

```bash
# 检查所有模板文件是否存在
for file in proposal.md spec.md design.md tasks.md infrastructure.md; do
  test -f "openspec/schemas/workflow/templates/$file" && echo "✓ $file" || echo "✗ $file missing"
done

# 检查上下文模板文件
for file in project_summary.template.md tech_stack.template.md infrastructure.template.md; do
  test -f "openspec/context/$file" && echo "✓ $file" || echo "✗ $file missing"
done
```

### 配置文件测试

```bash
# 验证 config.yaml 格式
python3 -c "import yaml; yaml.safe_load(open('openspec/config.yaml'))" && echo "✓ Valid YAML"

# 验证 schema.yaml 格式
python3 -c "import yaml; yaml.safe_load(open('openspec/schemas/workflow/schema.yaml'))" && echo "✓ Valid YAML"

# 检查必需字段
grep -q "schema: workflow" openspec/config.yaml && echo "✓ schema field present"
grep -q "^context:" openspec/config.yaml && echo "✓ context field present"
grep -q "^rules:" openspec/config.yaml && echo "✓ rules field present"
```

### 脚本可执行性测试

```bash
# 检查所有脚本是否可执行
for script in init.sh validate.sh scripts/init-project.sh; do
  test -x "$script" && echo "✓ $script is executable" || echo "✗ $script not executable"
done
```

### 工作流结构测试

```bash
# 验证 13 步工作流结构
grep -q "13-Step Contract-First" openspec/schemas/workflow/schema.yaml && echo "✓ 13-step workflow found"
grep -q "Phase 0" openspec/schemas/workflow/templates/tasks.md && echo "✓ Phase 0 found"
grep -q "Phase 8" openspec/schemas/workflow/templates/tasks.md && echo "✓ Phase 8 found"
grep -q "Step 13" openspec/schemas/workflow/templates/tasks.md && echo "✓ Step 13 found"
```

### Skills 目录测试

```bash
# 检查所有必需的 skills
REQUIRED_SKILLS=(
  "openspec-new-change"
  "openspec-continue-change"
  "openspec-ff-change"
  "openspec-apply-change"
  "openspec-check-standards"
  "openspec-verify-change"
  "openspec-archive-change"
  "openspec-onboard"
  "openspec-init-project"
)

for skill in "${REQUIRED_SKILLS[@]}"; do
  test -f "skills/$skill/SKILL.md" && echo "✓ $skill" || echo "✗ $skill missing"
done
```

## 集成测试

### 端到端测试流程

1. **初始化新项目**
   ```bash
   ./init.sh E2ETestProject /tmp/e2e-test fullstack
   ```

2. **验证生成的文件**
   ```bash
   cd /tmp/e2e-test
   test -f openspec/context/project_summary.md && echo "✓ project_summary.md created"
   test -f openspec/context/tech_stack.md && echo "✓ tech_stack.md created"
   grep -q "E2ETestProject" openspec/config.yaml && echo "✓ config.yaml updated"
   ```

3. **测试初始化脚本**
   ```bash
   cd /tmp/e2e-test
   # 如果 infrastructure.md 不存在，运行脚本生成
   /path/to/openspec-fullstack-template/scripts/init-project.sh
   ```

4. **清理测试环境**
   ```bash
   rm -rf /tmp/e2e-test
   ```

## 持续集成

### GitHub Actions 示例

```yaml
name: Validate Template

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run validation
        run: ./validate.sh
      - name: Test initialization
        run: |
          mkdir -p /tmp/test-init
          ./init.sh TestProject /tmp/test-init fullstack
          test -f /tmp/test-init/openspec/context/project_summary.md
```

## 故障排查

### 常见问题

1. **验证失败：缺少文件**
   - 检查文件是否在正确的位置
   - 确认文件权限正确

2. **初始化脚本失败**
   - 检查目标目录权限
   - 确认模板文件存在

3. **Skills 不工作**
   - 确认 skills 目录在 `.cursor/skills/` 下
   - 检查 SKILL.md 文件格式

## 测试最佳实践

1. **每次修改后运行验证**
   ```bash
   ./validate.sh
   ```

2. **提交前测试初始化**
   ```bash
   ./init.sh TestProject /tmp/test fullstack
   ```

3. **测试所有开发模式**
   ```bash
   for mode in fullstack frontend-only backend-only middleware-only; do
     ./init.sh TestProject /tmp/test-$mode $mode
   done
   ```

4. **验证生成的文件内容**
   - 检查占位符是否被正确替换
   - 验证文件格式正确性
   - 确认所有必需字段都存在
