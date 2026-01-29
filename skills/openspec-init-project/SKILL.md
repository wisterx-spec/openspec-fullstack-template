# OpenSpec: Initialize Project Context

## When to use

Use this skill when the user wants to:
- Initialize or create `project_summary.md` for a new project
- Set up project context files (`project_summary.md`, `tech_stack.md`)
- Configure OpenSpec for the first time in a project

## What this skill does

1. **Checks existing files**: Detects if `project_summary.md` or `tech_stack.md` already exist
2. **Interactive setup**: Guides the user through filling in project information
3. **Auto-generates files**: Creates `project_summary.md` and `tech_stack.md` from templates
4. **Updates config**: Automatically updates `openspec/config.yaml` with project name

## Workflow

### Step 1: Check Current State

```bash
# Check if context files exist
ls -la openspec/context/project_summary.md openspec/context/tech_stack.md 2>/dev/null || echo "Files not found"
```

### Step 2: Read Template Files

Read `openspec/context/project_summary.template.md` and `openspec/context/tech_stack.template.md` to understand the structure.

### Step 3: Interactive Information Gathering

Ask the user for the following information (in a friendly, conversational way):

1. **Project Name**: What's your project name?
2. **Project Description**: Briefly describe what your project does
3. **Core Business Scenarios**: What are the main business scenarios? (3-5 items)
4. **Tech Stack**:
   - Language/Runtime (e.g., Python 3.11, Node.js 20)
   - Frameworks (e.g., FastAPI, React 18)
   - Database/ORM (e.g., PostgreSQL + SQLAlchemy)
   - Testing tools (e.g., Pytest, Playwright)
   - Infrastructure (e.g., Docker, Kubernetes)
5. **Project Structure**:
   - Backend entry point
   - Frontend entry point
   - API routers location
   - Business classes location
   - Tests location
6. **Architecture Patterns**: What architecture patterns are used? (optional)
7. **Key Constraints**: Any critical constraints? (optional)

### Step 4: Generate Files

1. Read the template files
2. Replace placeholders with user-provided information
3. Create `openspec/context/project_summary.md`
4. Create `openspec/context/tech_stack.md` (can use simpler format if user provides tech stack info)
5. Update `openspec/config.yaml` to replace `{{ PROJECT_NAME }}` with actual project name

### Step 5: Verify and Confirm

Show the user what was created and ask if they want to edit anything.

## Implementation Notes

- **Be conversational**: Don't overwhelm the user with all questions at once. Ask naturally, one or two at a time.
- **Provide defaults**: If user doesn't provide some information, use sensible defaults or mark as "TODO: fill in"
- **Validate paths**: If user provides file paths, check if they exist and suggest corrections if needed
- **Preserve existing**: If files already exist, ask if user wants to overwrite or update specific sections
- **Use Chinese**: Respond in Chinese (Simplified) as per user preference

## Example Interaction

**User**: `/opsx:init-project`

**AI**: 
"好的！我来帮你初始化项目上下文。让我先检查一下当前状态..."

[检查文件]

"看起来还没有创建项目上下文文件。让我问你几个问题来设置：

1. **项目名称**是什么？（例如：用户管理系统）"

[用户回答后]

"很好！接下来：

2. **项目描述**：请简单描述一下这个项目是做什么的？"

[继续交互式询问，逐步收集信息]

[生成文件后]

"✅ 已成功创建项目上下文文件！

- `openspec/context/project_summary.md` - 已生成
- `openspec/context/tech_stack.md` - 已生成  
- `openspec/config.yaml` - 已更新项目名称

你可以随时编辑这些文件来补充更多细节。需要我帮你打开文件查看吗？"

## File Structure

The generated `project_summary.md` should include:
- Project domain and description
- Core business scenarios
- Tech stack overview
- Project structure (file paths)
- Architecture patterns
- Naming conventions
- API response format
- Development standards (from template)
- 13-step workflow reference

The `tech_stack.md` should include:
- Detailed tech stack information
- Version numbers
- Key dependencies

## Error Handling

- If template files don't exist: Guide user to copy from template repository
- If openspec directory doesn't exist: Create it first
- If user cancels: Save partial progress and allow resume later
- If files exist: Ask for confirmation before overwriting
