---
name: openspec-ff-freeze
description: 冻结 Frontend-First UI 和 Mock 数据。在 Step 3 使用——展示检查清单，要求用户逐项确认，保存 Mock 数据版本快照，生成 ui-freeze.md。冻结后 Mock 数据结构不再变动。
license: MIT
compatibility: Works with any frontend project using the Frontend-First workflow.
metadata:
  author: openspec
  version: "1.0"
---

冻结 UI 和 Mock 数据：展示检查清单 → 用户逐项确认 → 保存 Mock 版本快照 → 生成 ui-freeze.md。

**前提条件：** Step 2（Frontend Design + Mock Data）已完成，前端组件和 Mock 数据文件已存在。

**Input**: 功能名称（feature name）。如果未提供，尝试从 `devtools/mocks/data/` 目录推断；如果有多个功能，使用 AskUserQuestion 让用户选择。

**Steps**

1. **定位 Mock 数据和组件文件**

   搜索与功能相关的文件：
   - Mock 数据：`devtools/mocks/data/<feature>/`
   - 前端组件：`src/components/<Feature>/` 或 `src/pages/<feature>/`

   如果找不到，提示用户确认路径。

2. **读取 Mock 数据，提取当前字段清单**

   从 Mock 数据文件中提取所有字段：
   - 字段名
   - 数据类型
   - 是否有 null 值（可选字段）
   - 枚举值（如果能识别）

   生成字段清单，供后续检查使用。

3. **展示检查清单，逐项确认**

   使用 **AskUserQuestion 工具** 分组确认：

   **第 1 组：显示字段检查**
   ```
   以下字段将被冻结，确认完整吗？
   <列出从 Mock 提取的所有字段>
   - 所有需要展示的字段都在 Mock 中了吗？
   - 每个字段的数据类型确定了吗？
   - 可选字段（可能为 null）标记清楚了吗？
   ```
   选项：[确认] / [需要补充字段，回到 Step 2]

   **第 2 组：交互功能检查**
   ```
   确认以下交互功能：
   - 筛选条件：<从组件代码推断或询问>
   - 搜索字段：<从组件代码推断或询问>
   - 排序字段：<从组件代码推断或询问>
   - 分页：<是/否>
   ```
   选项：[确认] / [需要调整，回到 Step 2]

   **第 3 组：边界情况检查**
   ```
   Mock 数据中是否包含：
   □ 空列表响应（items: []）
   □ null 值字段的数据
   □ 错误响应数据
   ```
   选项：[全部覆盖] / [需要补充]

   **第 4 组：最终确认**
   ```
   最终确认——回答以下三个问题：
   1. 如果现在就上线，这个 UI 可以接受吗？
   2. 接下来一周都不改 UI，能接受吗？
   3. Mock 数据包含了所有需要的字段吗？
   ```
   选项：[全部是，冻结] / [还有犹豫，回到 Step 2]

   **如果任何一组未通过**，提示用户回到 Step 2 继续迭代，本次冻结中止。

4. **保存 Mock 数据版本快照**

   如果 `scripts/ff-freeze-mock-version.js` 存在，调用它来创建快照：
   ```bash
   node scripts/ff-freeze-mock-version.js devtools/mocks/data/<feature>
   ```

   如果脚本不存在，手动执行：
   - 在 Mock 数据文件顶部添加冻结标记注释：
     ```typescript
     /**
      * @frozen 2024-01-28T10:30:00Z
      * @version v1.0
      * @feature <feature-name>
      * UI Freeze 确认后，此文件的数据结构不再变动。
      * 字段名、类型、嵌套结构均已锁定。
      */
     ```

5. **生成 ui-freeze.md**

   在 `openspec/specs/<feature>/` 目录下创建 `ui-freeze.md`：

   ```markdown
   # UI 设计确认文档

   ## 功能：<功能名称>
   ## 冻结日期：<当前日期 YYYY-MM-DD>
   ## Mock 版本：v1.0

   ## 显示字段清单
   <从 Mock 数据自动生成的字段列表，每个字段包含：名称、类型、是否可选、说明>

   | 字段路径 | 类型 | 必填 | 说明 |
   |----------|------|------|------|
   | data.items[].id | number | 是 | <说明> |
   | data.items[].name | string | 是 | <说明> |
   | ... | ... | ... | ... |

   ## 交互功能清单
   - 筛选：<确认的筛选条件>
   - 搜索：<确认的搜索字段>
   - 排序：<确认的排序字段>
   - 分页：<是/否>

   ## 边界情况
   - [x] 空列表展示
   - [x] 加载中状态
   - [x] 错误提示
   - [x] null 值处理

   ## 确认
   ✅ 以上所有项已确认
   ✅ Mock 数据包含所有需要的字段
   ✅ UI 不再变动

   签名：<用户>
   日期：<冻结日期>
   ```

6. **提示用户下一步**

   ```
   ✅ UI 已冻结

   冻结信息：
   - 功能：<feature>
   - 冻结日期：<日期>
   - Mock 版本：v1.0
   - 字段数量：<N> 个
   - 文档：openspec/specs/<feature>/ui-freeze.md

   从此刻起，前端数据需求不再变动。

   下一步：运行 /opsx:ff-mock-to-spec 从 Mock 数据反推 API Spec（Step 4）
   ```

**Output**

- Mock 数据文件添加冻结标记
- `ui-freeze.md`（UI 确认文档，含字段清单和交互功能清单）
- Mock 版本快照（如果脚本可用）

**Guardrails**

- **必须逐项确认**：不允许跳过检查清单，每一组都要用户明确选择
- **有犹豫就不冻结**：最终确认中任何一个"否"都中止冻结
- **冻结后不可改结构**：冻结标记表示字段名、类型、嵌套结构已锁定；只允许修正数据值（如修复 typo），不允许增删字段
- **字段清单自动生成**：从 Mock 数据文件中程序化提取，不要让用户手动列——减少遗漏
