# UI UX Pro Max (内置版)

基于 [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) 的简化内置版本，为 OpenSpec 工作流提供设计系统生成能力。

## 功能

- **30 种 UI 样式** - 从 Minimalism 到 Cyberpunk
- **20 种配色方案** - 针对不同行业的专业配色
- **15 种字体配对** - 精选的标题/正文字体组合
- **20 条行业推理规则** - 根据项目类型智能推荐设计系统

## 使用方法

### 生成设计系统

```bash
# 基础用法
python3 scripts/search.py "saas dashboard" --design-system -p "MyApp"

# 保存到文件
python3 scripts/search.py "beauty spa" --design-system --persist -p "SerenitySpaMaster"

# Markdown 格式输出
python3 scripts/search.py "fintech banking" --design-system -f markdown -p "FinanceApp"
```

### 领域搜索

```bash
# 搜索 UI 样式
python3 scripts/search.py "glassmorphism" --domain style

# 搜索配色
python3 scripts/search.py "healthcare" --domain colors

# 搜索字体
python3 scripts/search.py "elegant" --domain typography

# 搜索推理规则
python3 scripts/search.py "ecommerce" --domain reasoning
```

## 数据文件

| 文件 | 描述 |
|------|------|
| `data/styles.csv` | UI 样式定义 |
| `data/colors.csv` | 配色方案 |
| `data/typography.csv` | 字体配对 |
| `data/reasoning.csv` | 行业推理规则 |

## 输出示例

```
+----------------------------------------------------------------------------------------+
|  TARGET: MyApp - RECOMMENDED DESIGN SYSTEM                                             |
+----------------------------------------------------------------------------------------+
|                                                                                        |
|  PATTERN: Feature-Rich Showcase                                                        |
|     Product Type: SaaS                                                                 |
|                                                                                        |
|  STYLE: Minimalism & Swiss Style                                                       |
|     Keywords: clean, whitespace, grid, simple, functional                              |
|     Performance: Excellent | Accessibility: WCAG AAA                                   |
|                                                                                        |
|  COLORS:                                                                               |
|     Primary:    #4F46E5                                                                |
|     Secondary:  #818CF8                                                                |
|     CTA:        #10B981                                                                |
|                                                                                        |
|  TYPOGRAPHY: Inter / Inter                                                             |
|     Mood: Clean; modern; versatile                                                     |
|                                                                                        |
+----------------------------------------------------------------------------------------+
```

## 在 OpenSpec 工作流中的集成

此工具在 Phase 2 (设计阶段) 自动调用，生成 `design-system/MASTER.md` 文件，供 `design.md` 引用。

## 许可证

MIT License - 基于 ui-ux-pro-max-skill
