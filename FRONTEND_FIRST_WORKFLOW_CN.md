# Frontend-First Solo 开发工作流详细文档

## 目录
1. [核心理念](#核心理念)
2. [工作流概览](#工作流概览)
   - 完整7步流程
   - 不同开发模式的流程差异（fullstack / frontend-only / backend-only）
   - 模式选择决策树 & 模式切换
3. [详细步骤说明](#详细步骤说明)（Step 1-7，每个功能重复执行）
4. [质量保障机制](#质量保障机制)
5. [配置指南](#配置指南)
   - API 接口规范（`openspec/conventions/api-convention.md`）
   - 项目初始化：新项目 vs 已有项目（Step 0，每个项目执行一次）
   - OpenSpec 配置 / Cursor Skills / 工具脚本 / Git Hooks
6. [常见问题处理](#常见问题处理)（含 Mock 数据降级防治）
7. [附录](#附录)（文档模板 / 检查清单 / 时间估算）

---

## 核心理念

### 你遇到的核心问题

**问题场景：**
- 后端API写完后，前端对接时发现缺少字段或功能
- 回头修改后端API
- 修改过程中牵一发而动全身：改了A接口，调用A的B、C、D功能全部出问题
- 项目复杂度增加后，这种问题呈指数级增长

**根本原因：**
- 需求理解不充分就开始写后端
- API设计基于"想象"而非"真实使用场景"
- 没有机制防止随意修改已有API

### 解决方案核心思路

**Frontend-First + Mock-Driven 原则：**

1. **先做前端UI，用Mock数据** - 在真实的界面中发现所有需求
2. **UI确定后锁定** - 设立明确的"不再改动"检查点
3. **从真实需求反推API** - 基于前端实际需要设计后端
4. **严格契约执行** - 后端实现后不允许随意修改API结构
5. **自动化防护** - 用工具确保各环节一致性

**效果对比：**

| 维度 | 传统流程（后端先行） | Frontend-First流程 |
|------|---------------------|-------------------|
| 返工次数 | 3-5次（反复修改API） | 0-1次 |
| 总开发时间 | 6小时+ | 4小时 |
| 心理压力 | 很高（改到崩溃） | 低（有条不紊） |
| 代码质量 | 到处是补丁 | 一次性做对 |
| 改了a，b崩了 | 经常发生 | 几乎不会 |

### 与 OpenSpec 13 步流程的关系

本文档的 7 步流程**不是替代** openspec-fullstack-template 原有的 13 步流程，而是一种**模式变体**：

| 维度 | 13 步流程（Spec-First） | 7 步流程（Frontend-First） |
|------|------------------------|--------------------------|
| 核心思路 | 先写契约，再实现前后端 | 先做前端 UI，从 UI 反推契约 |
| 适用场景 | 无前端 / API 优先 / 多团队协作 | 有前端 / Solo 开发 / UI 驱动 |
| Spec 来源 | 从需求文档正向设计 | 从 Mock 数据反推 |
| 对应关系 | Proposal → Design → Spec → Tasks → Implement | Proposal → Frontend+Mock → Freeze → Spec → Backend → Integrate |

**共存方式：**
- `config.yaml` 中 `dev_mode` 决定使用哪种模式
- `backend-only` 项目 → 走 13 步流程（Spec-First）
- `fullstack` / `frontend-only` 项目 → 走 7 步流程（Frontend-First）
- 两种模式共享 Proposal 和 Spec 的文档格式，产出物兼容

---

## 工作流概览

**两个层级：**
- **Step 0（项目初始化）**：每个项目执行**一次**，搭建脚手架和 Mock 基础设施。详见"配置指南"章节。
- **Step 1-7（功能开发）**：每个功能**重复执行**一遍，是日常开发的核心循环。

```
项目生命周期：
  Step 0: 初始化（一次性）
    ↓
  Feature A: Step 1→2→3→4→5→6→7
    ↓
  Feature B: Step 1→2→3→4→5→6→7
    ↓
  Feature C: ...
```

### 完整7步流程

```
Phase 0: 需求理解
└─ Step 1: Proposal

Phase 1: 前端设计（可反复迭代）
├─ Step 2: Frontend Design + Mock Data
└─ Step 3: UI Review & Freeze

Phase 2: API契约锁定
├─ Step 4: API Spec（从Mock反推）
└─ Step 5: Spec Review

Phase 3: 后端实现
└─ Step 6: Backend Implementation

Phase 4: 集成
└─ Step 7: Integration & Archive
```

### 流程可视化

```
Step 1: Proposal (2分钟)
   ↓
   我要做什么功能？
   
Step 2: Frontend + Mock (1-2小时，可反复)
   ↓
   画UI → 写组件 → 用假数据 → 浏览器看效果
   ↓
   发现缺字段？加到Mock → 继续调整
   ↓
   不满意？继续改 → 满意了进入下一步
   
Step 3: UI Freeze (10分钟)
   ↓
   [关键检查点] 确定不改了吗？
   ↓
   如果还要改 → 回Step 2
   ↓
   如果确定 → 锁定Mock数据版本
   
Step 4: API Spec (20分钟)
   ↓
   根据Mock数据反推API设计
   ↓
   每个字段都是前端真正需要的
   
Step 5: Spec Review (5分钟)
   ↓
   对比Mock和Spec，确保100%一致
   ↓
   [关键检查点] 从这里开始API结构冻结
   
Step 6: Backend (2小时)
   ↓
   严格按Spec实现
   ↓
   写测试防止改坏
   ↓
   如果发现Spec有问题 → 回Step 4改Spec，不能直接改代码
   
Step 7: Integration (10分钟)
   ↓
   前端切换真实API
   ↓
   因为结构一致，无缝对接
   ↓
   完成 ✅
```

### 不同开发模式的流程差异

根据项目类型，流程会有所裁剪。核心原则不变：**有前端就先做前端，没前端就直接写契约**。

#### 模式总览

| 模式 | 适用场景 | 执行步骤 | 跳过步骤 |
|------|---------|----------|---------|
| fullstack | 前后端在同一项目 | 1→2→3→4→5→6→7 | 无 |
| frontend-only | 纯前端 / 前端先行 | 1→2→3（→4→5） | 6→7 |
| backend-only | 纯后端 / API服务 | 1→4→5→6 | 2→3→7 |

---

#### fullstack（全栈模式）

**场景：** 前后端在同一个仓库，或你一个人同时负责前后端。

**流程：** 完整7步，无裁剪。

```
Step 1: Proposal
   ↓
Step 2: Frontend + Mock  ← 在浏览器中反复迭代
   ↓
Step 3: UI Freeze        ← 🔒 检查点：确认UI不再改动
   ↓
Step 4: API Spec         ← 从Mock数据反推API设计
   ↓
Step 5: Spec Review      ← 🔒 检查点：Mock与Spec 100%一致
   ↓
Step 6: Backend          ← 严格按Spec实现
   ↓
Step 7: Integration      ← 前端切换真实API，归档
```

**要点：**
- 这是本文档描述的默认流程
- Step 7 的切换应该是"无感"的——如果结构一致，只需改数据源

---

#### frontend-only（纯前端模式）

纯前端模式分两种情况：

##### 情况A：独立前端项目（无后端依赖）

**场景：** 纯静态站点、展示型页面、独立的前端组件库、无需API的工具类应用。

**流程：** Steps 1→2→3→完成

```
Step 1: Proposal
   ↓
Step 2: Frontend + Mock  ← 如果有数据展示，用静态Mock
   ↓
Step 3: UI Review & Done ← 确认UI，直接交付/上线
   ↓
   完成 ✅
```

**要点：**
- 不需要 Spec（没有后端需要对齐）
- 不需要 Backend 和 Integration
- Mock数据直接作为最终数据源（静态数据）或由第三方API提供
- 这里的 Step 3 不叫"Freeze"而叫"Review & Done"——因为没有后续步骤依赖锁定，"冻结"没有意义，只是最终确认

##### 情况B：前端先行，后端在另一个项目

**场景：** 前后端分仓库，你先做前端，后续自己或别人来做后端。

**流程：** Steps 1→2→3→4→5→完成（交付Spec给后端项目）

```
Step 1: Proposal
   ↓
Step 2: Frontend + Mock  ← 用Mock数据跑通所有功能
   ↓
Step 3: UI Freeze        ← 🔒 锁定UI和Mock数据
   ↓
Step 4: API Spec         ← 从Mock反推，生成API契约
   ↓
Step 5: Spec Review      ← 🔒 确认Spec完整准确
   ↓
   完成 ✅ → 将 spec.md 交给后端项目
```

**要点：**
- Spec 是前端项目的最终产出物之一
- 后端项目拿到 Spec 后，走 backend-only 模式的 Step 6
- 集成测试（Step 7）在后端项目完成后进行，由前端项目发起
- Mock数据保留，直到后端API上线后才切换

**前端项目的产出物：**
```
/feature-xxx/
  ├── proposal.md        ← 需求
  ├── mock-data/         ← 冻结的Mock数据
  ├── ui-freeze.md       ← UI确认文档
  ├── spec.md            ← API契约（交付给后端）
  └── src/components/    ← 前端组件代码
```

---

#### backend-only（纯后端模式）

**场景：** 纯API服务、微服务、数据处理服务、没有前端界面。

**流程：** Steps 1→4→5→6→完成

```
Step 1: Proposal
   ↓
Step 4: API Spec         ← 直接设计API契约（传统Spec-First）
   ↓
Step 5: Spec Review      ← 🔒 确认Spec完整准确
   ↓
Step 6: Backend          ← 严格按Spec实现 + 契约测试
   ↓
   完成 ✅
```

**要点：**
- **跳过 Step 2（Frontend + Mock）和 Step 3（UI Freeze）**——没有UI，无需可视化确认
- **跳过 Step 7（Integration）**——没有前端需要对接
- 这本质上就是传统的 **Spec-First（契约优先）** 模式
- Step 4 的 Spec 不再是"从Mock反推"，而是直接根据需求设计

**与 fullstack 模式 Step 4 的区别：**

| 维度 | fullstack 的 Step 4 | backend-only 的 Step 4 |
|------|---------------------|----------------------|
| 输入 | 冻结的Mock数据 + UI组件 | Proposal中的需求描述 |
| 方法 | 反推（从前端实际需要推导） | 正向设计（从业务需求推导） |
| 验证 | 与Mock数据逐字段对比 | Review业务逻辑完整性 |
| 风险 | 低（基于真实使用场景） | 中（基于想象，可能遗漏） |

**降低 backend-only 风险的措施：**
- Proposal 阶段多列具体的请求/响应示例
- 如果是给已有前端提供API，先收集前端的数据需求
- Spec Review 阶段用 Postman/curl 实际测试 Mock Server

**backend-only 的产出物：**
```
/feature-xxx/
  ├── proposal.md        ← 需求
  ├── spec.md            ← API契约
  ├── src/               ← 后端实现代码
  └── tests/contract/    ← 契约测试
```

---

#### 模式选择决策树

```
你的项目有前端吗？
├─ 有 → 前后端在同一个项目/仓库吗？
│       ├─ 是 → fullstack模式（完整7步）
│       └─ 否 → 前端项目走 frontend-only 模式B
│               后端项目走 backend-only 模式
│               最后回前端项目做 Step 7 Integration
└─ 没有 → backend-only模式（跳过UI相关步骤）
```

#### 模式切换场景

**场景1：backend-only 项目后来要加前端**
- 已有 Spec → 前端基于 Spec 创建Mock → 走 Step 2→3 确认UI
- 不需要重做 Step 4-5（Spec已存在）
- 直接进入 Step 7 Integration

**场景2：frontend-only 项目后来要加后端**
- 如果之前做了 Step 4-5（情况B）→ 后端直接走 Step 6
- 如果之前只做到 Step 3（情况A）→ 补做 Step 4-5，再走 Step 6

**场景3：开发到一半发现模式判断错误**
- 例如：以为是 backend-only，后来发现需要前端
- 不要硬撑，停下来重新走 frontend-only 模式
- 已完成的 Spec 可以保留，但要与前端Mock对齐后更新

---

## 详细步骤说明

### Step 1: Proposal - 需求理解（2分钟）

**目标：**
快速记录功能需求，不需要详细设计

**输出物：**
proposal.md 文件

**内容结构：**
- 背景：为什么要做这个功能
- 目标：用户能做什么
- 关键用例：2-3个核心场景

**时间控制：**
不超过5分钟，不要写长篇大论

**检查标准：**
- 能用一句话说清楚这个功能吗？
- 列出了3个以内的核心用例吗？
- 没有涉及技术实现细节吗？

**常见错误：**
- ❌ 写成详细的产品需求文档（太重）
- ❌ 包含了技术方案（这一步不需要）
- ❌ 列了10几个功能点（太多，拆分）

**示例结构：**
```
背景：需要管理用户账号

目标：
- 查看所有用户
- 筛选和搜索用户
- 查看用户详情

非目标：
- 编辑用户（下个版本）
- 批量操作（下个版本）
```

---

### Step 2: Frontend Design + Mock Data - 前端设计（1-2小时）

**目标：**
用真实的界面和交互，发现所有需求细节

**可以采用的方式（任选）：**

**方式A：直接写前端代码（推荐）**
- 创建React/Vue组件
- 写Mock数据文件
- 在浏览器中实际运行
- 优点：最真实，最快发现问题

**方式B：原型设计**
- 用Figma/Sketch画界面
- 标注所有数据字段
- 优点：适合UI复杂的场景

**方式C：手绘 + 文字说明**
- 画草图
- 列出所有展示的数据
- 优点：最快，适合简单功能

**视觉基础：**
如果在 Step 0.2.5 中生成了设计基础（`design-system/tokens.css`），在写组件时直接引用 CSS Variables：
```css
/* 用 design tokens，不要硬编码颜色值 */
.button-primary { background: var(--color-primary); }  /* ✅ */
.button-primary { background: #4F46E5; }               /* ❌ 硬编码 */
```
这样所有组件的视觉风格天然统一，后续调整只需改 `tokens.css` 一处。

**核心要求：**
无论用哪种方式，必须明确：
- 界面上展示哪些字段
- 每个字段的数据类型
- 交互功能（筛选、搜索、排序）
- 边界情况（空数据、加载中、错误）

**Mock数据要求：**

Mock 数据**必须遵守** `openspec/conventions/api-convention.md` 的约束（响应信封、分页格式、6位错误码、snake_case 字段名、ISO 8601 日期）。具体检查清单见该文件第 9 节。

Mock数据必须包含：
- 完整的响应结构（`{ code: 0, message: "success", data: { ... } }`）
- 至少2-3条测试数据
- 所有前端要展示的字段
- 边界情况数据（null值、空数组等）
- 至少一条错误响应（`{ code: 6位错误码, message: "...", data: null }`）

**反复迭代的过程：**

这个阶段可以随意修改，直到满意：

```
第1轮：
画UI → 写Mock → 浏览器看
发现：少了"角色"字段 → 加到Mock → 前端加列

第2轮：
继续看 → 发现需要"最后登录时间"
→ 加到Mock → 前端加列 → 调整格式化

第3轮：
测试筛选功能 → 发现需要"状态"筛选
→ Mock加status字段 → 加筛选器组件

第4轮：
全部功能测试 → 发现"从未登录"的用户显示有问题
→ Mock中加一条last_login为null的数据 → 调整显示逻辑

满意了 → 进入Step 3
```

**关键原则：**
- 这个阶段想改就改，没有任何限制
- 多加测试数据，覆盖各种情况
- 在真实的浏览器/设备中测试
- 模拟用户实际操作流程

**时间分配建议：**
- 简单功能（单个列表）：30分钟-1小时
- 中等功能（列表+详情+表单）：1-2小时
- 复杂功能（多个关联页面）：2-4小时

---

### Step 3: UI Review & Freeze - UI冻结检查（10分钟）

**目标：**
明确确认UI不再改动，这是整个流程最关键的检查点

**为什么重要：**
- 这是"可以随意改"和"不能随意改"的分界线
- 过了这个点，前端需要的数据结构就锁定了
- 后续的Spec和后端都基于这个锁定的需求

**检查清单：**

**显示字段检查：**
- 所有需要展示的字段都在Mock数据中吗？
- 每个字段的数据类型确定了吗？
- 可选字段（可能为null）标记清楚了吗？

**交互功能检查：**
- 筛选功能需要哪些筛选条件？
- 搜索功能搜索哪些字段？
- 排序功能支持哪些字段排序？
- 分页需要显示总数吗？

**边界情况检查：**
- 空列表怎么展示？（Mock中有空数组测试数据吗）
- 加载中状态设计了吗？
- 错误情况怎么提示？
- null值怎么显示？（例如"从未登录"）

**用户体验检查：**
- 在不同屏幕尺寸测试过吗？
- 数据量大时（100+条）性能如何？
- 操作流程顺畅吗？

**最终确认问题：**

问自己3个问题：
1. 如果现在就上线，这个UI可以吗？
2. 接下来一周都不能改UI，能接受吗？
3. Mock数据包含了所有需要的字段吗？

**如果有任何犹豫 → 回到Step 2继续调整**

**通过检查后：**
- 保存Mock数据的当前版本（可以加个时间戳备份）
- 在文档中明确标注"UI已冻结，日期：XXXX-XX-XX"
- 告诉自己：从现在开始，前端数据需求不再变动

**输出物：**
- 冻结版本的Mock数据文件
- UI确认文档（记录所有字段和功能）

---

### Step 4: API Spec - API设计（20分钟）

**目标：**
根据前端真实需求，设计后端API契约

**核心原则：**
这一步是"反推"，不是"设计"
- 不是想象后端应该返回什么
- 而是看前端需要什么，就设计什么
- Spec 的响应格式、错误码、分页结构等必须遵守 `openspec/conventions/api-convention.md`

**Spec必须包含的内容：**

**1. 接口基本信息**
- HTTP方法（GET/POST/PUT/DELETE）
- 路径（例如：/api/users）
- 功能描述（一句话）

**2. 请求参数**
- 参数名
- 数据类型
- 是否必填
- 说明和示例
- 参数来源（从前端的筛选、搜索、分页功能提取）

**3. 响应格式**
- 成功响应结构（直接用Mock数据的结构）
- 错误响应结构（统一格式）
- 所有字段的数据字典

**4. 数据字典**
每个字段必须说明：
- 字段名
- 数据类型（string/number/boolean/null）
- 是否必填
- 说明（这个字段的含义）
- 特殊情况（例如：null表示从未登录）

**5. 业务规则**
- 筛选、搜索、排序在哪里完成（必须是后端）
- 分页默认值
- 数据范围限制（例如：page_size最大100）
- 特殊逻辑说明

**6. 错误情况**
- 参数错误怎么返回
- 权限错误怎么返回
- 系统错误怎么返回

**从Mock数据提取Spec的过程：**

**第1步：确定请求参数**
看前端组件，找出所有的：
- 筛选器 → 对应请求参数
- 搜索框 → 对应search参数
- 排序按钮 → 对应sort_by、sort_order参数
- 分页组件 → 对应page、page_size参数

**第2步：确定响应结构**
直接复制Mock数据的结构：
- 保持完全一致的字段名
- 保持完全一致的数据类型
- 保持完全一致的嵌套结构

**第3步：补充说明**
为每个字段添加：
- 中文说明（这个字段是干什么的）
- 取值范围（枚举类型要列出所有可能值）
- 特殊情况（什么时候为null）

**注意事项：**

**严格一致性：**
- Spec中的字段必须和Mock数据完全一致
- 字段名一个字母都不能差
- 数据类型必须匹配
- 嵌套结构必须相同

**不要"优化"响应结构：**
- 不要想"这个字段后端换个名字更好"（不行！）
- 不要想"这里用对象比数组更合理"（不行！）
- 不要想"加个字段方便以后扩展"（不需要！）
- 一切以前端Mock为准
- **这条规则的作用域是"当前版本的Spec"**——当前版本只定义前端实际需要的字段

**将来修改 Spec 时的约束（不是现在要做的事）：**
- 只能加可选字段，不能删除/改名/改类型已有字段
- 如果必须做破坏性变更，走变更流程（回到 Step 2 重新确认）
- 这不是让你现在就"规划未来字段"，而是限制将来改动的方式

---

### Step 5: Spec Review - Spec检查（5分钟）

**目标：**
确保Spec和Mock数据100%一致，这是防止后续问题的关键

**检查方法：**

**方法A：手动对比（必做）**

打开两个文件对比：
- 左边：Mock数据文件
- 右边：Spec文档中的响应示例

逐字段检查：
- Mock中的每个字段，Spec都有定义吗？
- Spec中的每个字段，Mock都有吗？
- 数据类型一致吗？（string vs number）
- 嵌套结构一致吗？

**方法B：自动化脚本（推荐）**

写一个简单的对比脚本：
- 读取Mock数据
- 解析Spec文档中的响应示例
- 比较两者的字段列表
- 输出差异报告

**方法C：TypeScript类型检查（最佳）**

如果使用TypeScript：
- 从Spec生成类型定义
- 让Mock数据使用这个类型
- TypeScript编译器会自动检查一致性

**常见不一致问题：**

**问题1：字段缺失**
- Mock中有字段X，但Spec忘记写了
- 解决：补充到Spec

**问题2：字段多余**
- Spec中有字段Y，但Mock中没有
- 检查：前端真的需要这个字段吗？
- 不需要 → 从Spec删除
- 需要 → 回Step 2，加到Mock

**问题3：类型不匹配**
- Mock中是字符串，Spec定义成数字
- 决策：前端需要什么类型？
- 统一成前端需要的类型

**问题4：枚举值不全**
- Mock中有status="pending"，但Spec只列了active/inactive
- 补充：把pending加到Spec的枚举定义中

**边界情况检查：**

**空数据：**
- Spec定义了空列表的返回格式吗？
- 和Mock中的空数据一致吗？

**null值：**
- 哪些字段可以为null？
- Spec中标注清楚了吗？
- Mock中有null值的测试数据吗？

**错误响应：**
- Spec定义了错误格式吗？
- 和项目的统一错误格式一致吗？

**最终确认：**

在Spec文档中添加一个章节：

```
## Spec确认记录

- Mock数据版本：v1.0（2024-01-28冻结）
- Spec版本：v1.0
- 对比检查：已完成
- 字段一致性：100%
- 确认人：[你的名字]
- 确认日期：2024-01-28

从此刻起，API结构锁定，不再随意修改。
```

**通过标准：**
- Mock和Spec字段完全一致
- 所有字段都有清晰说明
- 边界情况都有定义
- 业务规则写清楚了

**如果检查不通过：**
- 小问题 → 直接改Spec
- 大问题（结构性差异）→ 回Step 4重写
- 发现前端需求变了 → 回Step 2（但应该尽量避免）

---

### Step 6: Backend Implementation - 后端实现（2小时）

**目标：**
严格按照Spec实现后端API，不允许偏离

**核心原则：**

**原则1：Spec是唯一的真理**
- 打开Spec文档，逐行实现
- 不要凭记忆写
- 不要"我觉得这样更好"

**原则2：发现问题改Spec，不改代码**
- 如果实现时发现Spec设计有问题
- 停下来，回去改Spec
- 改完Spec后，更新前端Mock
- 然后再继续实现后端
- 不允许"先这样写，回头再说"

**原则3：测试是防护网**
- 每个API都写契约测试
- 测试的作用：防止以后改坏
- 不是测业务逻辑，是测API结构

**实现步骤：**

**第1步：数据库设计**
- 根据 Spec 中的字段，设计表结构
- 注意：表字段名可以和 API 字段名不同（后端做映射转换）
- 创建 migration 文件并执行

**第2步：创建API handler骨架**
- 定义路由
- 解析请求参数
- 返回空响应（结构正确即可）

**第3步：参数校验**
- 按Spec定义校验每个参数
- 类型检查
- 范围检查（例如：page_size不能超过100）
- 必填项检查
- 校验失败返回错误（格式严格按Spec）

**第4步：业务逻辑实现**
- 数据库查询
- 数据处理
- 筛选、搜索、排序、分页
- 按Spec的业务规则实现

**第5步：构造响应**
- 严格按照Spec的响应格式
- 字段名不能变
- 数据类型不能变
- 结构不能变
- 就算你觉得不合理也不能改

**第6步：错误处理**
- 所有异常都要捕获
- 返回统一的错误格式
- 错误码按项目标准
- 错误信息要有用（不是"出错了"）

**契约测试的写法：**

**测试目标：**
验证API响应结构和Spec一致，不是测业务逻辑

**必须测试的内容：**
- 响应顶层结构（code、message、data）
- data的结构（items、total、page等）
- items中每个对象的字段
- 字段的数据类型
- 枚举字段的可能值

**边界情况测试：**
- 参数错误时的响应
- 空结果时的响应
- 权限错误时的响应

**测试失败时的处理：**
- 如果测试失败 → 代码和Spec有差异
- 检查：是代码写错了，还是Spec定义错了
- 代码错 → 改代码
- Spec错 → 改Spec，同步更新前端Mock

**防止改坏的机制：**

**为什么需要防护：**
这就是你遇到的"改了a，b崩了"的场景
- 一个月后，你要加新功能
- 改动了这个API的返回格式
- 其他地方调用这个API的代码全崩了

**防护措施1：契约测试**
- 每次提交代码前自动运行测试
- 如果你改了API结构，测试会失败
- 提示你：不能随意改，要评估影响

**防护措施2：字段只增不减**
- 可以添加新的可选字段
- 不能删除现有字段
- 不能改变字段类型
- 不能改变字段名

**实现过程中的常见问题：**

**问题1：发现Spec缺少某个业务规则**
例如：Spec没说重复邮箱怎么处理
- 停下来
- 在Spec中补充这个规则
- 决定返回什么错误码
- 然后继续实现

**问题2：数据库结构和Spec不匹配**
例如：数据库中角色字段是role_id，Spec要求返回role名称
- 这是正常的，需要做转换
- 查询时join关联表
- 或者查询后在代码中转换
- 保证返回格式符合Spec

**问题3：性能问题**
例如：Spec要求返回每个用户的帖子数，查询很慢
- 优化：可以加索引、缓存
- 不可以：改变返回字段
- 如果实在无法优化 → 回去改Spec（和前端商量）

**问题4：第三方API格式不同**
例如：调用支付API返回的格式和Spec定义的不一样
- 在后端做转换
- 适配成Spec定义的格式
- 前端不需要知道这些细节

**完成标准：**
- 所有endpoint都实现了
- 契约测试全部通过
- 手动测试（用Postman）也通过
- 响应格式和Spec完全一致
- 业务规则都实现了

---

### Step 7: Integration & Archive - 集成与归档（10分钟）

**目标：**
前端切换到真实API，验证整个流程，归档文档

**前端切换步骤：**

**第1步：修改数据源**
- 之前：使用Mock数据
- 现在：调用真实API
- 理想情况：只需要改一行代码

**第2步：环境配置**
- 配置API base URL
- 如果需要认证，配置token
- 确保能访问到后端服务

**第3步：功能测试**
按照Step 2中测试过的所有功能，再测试一遍：
- 列表展示
- 筛选功能
- 搜索功能
- 排序功能
- 分页功能
- 边界情况（空数据、错误）

**预期结果：**
- 因为数据结构一致，应该和Mock数据时的效果完全一样
- 不应该有任何"咦，怎么显示不出来"的情况
- 不应该需要修改前端代码

**如果出现问题：**

**问题类型A：数据显示异常**
- 检查：后端返回的数据格式对吗？
- 用浏览器DevTools查看Network请求
- 对比：返回数据 vs Spec定义
- 如果不一致 → 后端Bug，改后端

**问题类型B：功能不工作**
- 例如：筛选不生效
- 检查：前端发送的参数对吗？
- 检查：后端有处理这个参数吗？
- 如果后端没处理 → 后端Bug
- 如果前端参数错 → 前端Bug

**问题类型C：性能问题**
- 加载很慢
- 检查：后端查询慢还是网络慢
- 后端慢 → 优化查询（加索引、缓存）
- 网络慢 → 考虑数据压缩、分批加载

**完成验收标准：**

- 所有功能正常工作
- 性能可接受（页面加载<2秒）
- 错误情况有友好提示
- 没有console报错
- 移动端/桌面端都测试过

**归档文档内容：**

**必须记录的信息：**

**功能总结：**
- 实现了哪些功能
- 每个功能的简要说明
- 有没有遗留问题

**技术实现：**
- API地址列表
- 前端使用的主要组件
- 后端使用的主要技术
- 数据库改动（如果有）

**测试情况：**
- 测试覆盖率
- 已知问题（如果有）
- 性能指标

**经验总结：**
- 这次做得好的地方
- 遇到的问题和解决方案
- 下次可以改进的地方

**维护信息：**
- 相关文件路径
- 依赖的其他模块
- 如果要修改，需要注意什么

**归档的作用：**

**作用1：知识沉淀**
- 几个月后回来看代码
- 快速回忆当时的设计思路
- 不需要重新理解代码

**作用2：问题追溯**
- 出现Bug时
- 看归档了解这个功能是怎么实现的
- 快速定位问题

**作用3：新功能参考**
- 做类似功能时
- 可以参考之前的实现方式
- 保持代码风格一致

**归档文件的存放：**

建议结构：
```
/docs/archives/
  /user-management/
    - proposal.md（原始需求）
    - spec.md（API契约）
    - mock-data.ts（Mock数据）
    - archive.md（归档总结）
    - screenshots/（功能截图）
```

---

## 质量保障机制

### 四道防线总览

```
防线1: UI Freeze（Step 3）     → 锁定需求，防止后续反复改 UI
防线2: Spec Review（Step 5）   → 锁定契约，防止 Mock 和 Spec 不一致
防线3: 契约测试（Step 6）      → 锁定实现，防止后端偏离 Spec
防线4: 字段只增不减（维护期）  → 锁定演进方式，防止改坏已有调用者
```

每道防线的详细检查清单见附录。防线 1-3 的执行细节分别在 Step 3、Step 5、Step 6 中说明，这里不再重复。

**防线4 补充说明（Solo 开发者适用的做法）：**

API 上线后如果需要修改：
- **可以做**：添加新的可选字段、添加新的 endpoint
- **不能做**：删除字段、改字段名、改字段类型、改嵌套结构
- **如果必须做破坏性变更**：回到 Step 2 重新走流程，当作新功能处理

> 注：URL 版本控制（v1/v2）、Header 版本控制等是团队/公共 API 的方案，Solo 项目通常不需要。遵守"字段只增不减"原则即可。

---

### 三方一致性原则

```
Mock数据 ←→ API Spec ←→ 后端实现
   ↑           ↑           ↑
   └───────────┴───────────┘
      字段名、类型、结构必须100%一致
```

| 维度 | 规则 | 违规示例 |
|------|------|---------|
| 字段名 | 三方完全一致 | Mock 叫 `name`，后端返回 `username` |
| 数据类型 | 三方完全一致 | Mock 是数字 `1`，后端返回字符串 `"1"` |
| 结构 | 三方完全一致 | Mock 是数组，后端改成对象 |
| 可选性 | Mock 有 null → Spec 标可选 → 后端支持 null | Spec 标必填但后端返回 null |

检查方法：Step 5 手动对比 + 自动化脚本（见"工具脚本"章节）。

---

### 契约测试 vs 单元测试

| | 单元测试 | 契约测试 |
|--|---------|---------|
| 测什么 | 函数计算对不对 | API 返回格式对不对 |
| 示例 | `sum(1,2) === 3` | `response.data.items` 是数组且每项有 `id` 字段 |
| 防什么 | 业务逻辑 Bug | 改了字段名/类型/结构导致前端崩溃 |
| 执行时机 | 开发中随时 | 每次提交前 + CI |

契约测试的详细写法和测试失败处理流程见 Step 6。

---

## 配置指南

### API 接口规范（唯一约束源）

**文件位置：** `openspec/conventions/api-convention.md`

本文件是项目中**所有 API 响应格式、错误码、字段命名、分页结构的唯一定义**。Mock 数据、Spec 文档、后端实现都必须遵守。

**核心约束速查：**

| 约束 | 规则 |
|------|------|
| 响应信封 | `{ code, message, data }` — 成功 `code: 0`，失败 `code: 6位错误码` |
| 分页格式 | 扁平结构：`{ items, total, page, page_size }` — 不使用嵌套 `pagination` 对象 |
| 错误码 | 6 位数字 `CCMMSS`（分类2位 + 模块2位 + 序号2位） |
| 字段命名 | JSON 字段 `snake_case`，URL 路径 `kebab-case` |
| 日期格式 | ISO 8601，`"2024-01-28T10:30:00Z"` |
| 空值 | 声明的字段必须返回（无值时返回 `null`，不省略） |

**在工作流中的使用：**
- **Step 2**（Mock 数据）：写 Mock 时对照第 9 节"Mock 数据合规检查清单"
- **Step 4**（Spec 生成）：Spec 的响应格式、错误码必须引用此文件
- **Step 6**（后端实现）：后端返回的格式必须与此文件一致

详细定义（含完整错误码表、预定义错误码、变更规则）请阅读原文件。

---

### 项目初始化：新项目 vs 已有项目

初始化是整个工作流的 Step 0——在写第一个 Proposal 之前，项目必须具备运行这套流程的基础设施。新项目和已有项目的初始化动作差异很大。

#### 初始化动作对照表

| 动作 | 新项目 | 已有项目 |
|------|--------|---------|
| 工程脚手架 | 从零搭建（Vite/Next/Nuxt等） | 已有，跳过 |
| OpenSpec 目录结构 | 创建完整结构 | 在现有项目中新增目录 |
| config.yaml | 从模板生成 | 根据现有项目情况填写 |
| dev_mode 选择 | 直接选定 | 根据项目现状判断 |
| Mock 基础设施 | 从零搭建（安装MSW等） | 评估是否已有Mock方案，决定替换还是适配 |
| Mock/业务隔离 | 一开始就物理分离 | 需要重构已有的Mock代码 |
| 构建隔离 | 入口写法正确即可（无需额外配置） | 确认入口写法 + CI 加检查脚本 |
| Git Hooks | 直接安装 | 与已有的hooks合并 |
| 已有API处理 | 不涉及 | 需要决定：补Spec？补Mock？还是不管？ |
| 已有前端组件 | 不涉及 | 需要决定：纳入管理？还是只管新功能？ |
| 团队/协作约定 | 直接定规矩 | 需要沟通、渐进推行 |

---

#### 新项目初始化

**耗时预估：30-60分钟（一次性）**

**Step 0.1：工程脚手架**

脚手架的目标是：用最少的决策，得到一个**能跑、能构建、能区分环境**的空项目。下面按决策顺序排列。

**决策1：选技术栈**

只需要确定3件事，其他的都可以后面再加：

```
必须决定的：
  ① 框架      → React / Vue / Svelte / 其他
  ② 语言      → TypeScript（强烈推荐） / JavaScript
  ③ 构建工具   → Vite（推荐） / Next.js / Nuxt

可以以后再加的（不要在脚手架阶段纠结）：
  - 样式方案（Tailwind / CSS Modules / styled-components）
  - 状态管理（Zustand / Pinia / Redux）
  - UI组件库（Ant Design / Element Plus / shadcn）
  - 路由（react-router / vue-router）
```

**为什么推荐 Vite + TypeScript：**
- Vite：开发启动快、构建配置简单、环境变量原生支持（`import.meta.env`）
- TypeScript：Mock数据和API响应可以共享类型定义，Spec一致性天然有编译器帮你检查

**决策2：选脚手架命令**

根据开发模式选择对应的脚手架：

**fullstack 或 frontend-only 模式：**

```bash
# ---- React + TypeScript ----
npm create vite@latest my-project -- --template react-ts

# ---- Vue + TypeScript ----
npm create vite@latest my-project -- --template vue-ts

# ---- React + Next.js（需要SSR时）----
npx create-next-app@latest my-project --typescript --app

# ---- Vue + Nuxt（需要SSR时）----
npx nuxi@latest init my-project
```

**backend-only 模式（无前端）：**

```bash
# ---- Node.js + TypeScript ----
mkdir my-project && cd my-project
npm init -y
npm install typescript tsx @types/node --save-dev
npx tsc --init

# ---- Python + FastAPI ----
mkdir my-project && cd my-project
python -m venv venv
source venv/bin/activate
pip install fastapi uvicorn

# ---- Go ----
mkdir my-project && cd my-project
go mod init my-project
```

**决策3：执行脚手架 + 初始验证**

以 `Vite + React + TypeScript` 为例（最常用组合）：

```bash
# 1. 创建项目
npm create vite@latest my-project -- --template react-ts

# 2. 进入项目
cd my-project

# 3. 安装依赖
npm install

# 4. 验证开发服务器能启动
npm run dev
# → 浏览器打开 http://localhost:5173，看到Vite默认页面 → ✅

# 5. 验证生产构建能成功
npm run build
# → 输出 dist/ 目录，无报错 → ✅

# 6. 验证环境变量机制
echo "VITE_APP_TITLE=MyApp" > .env
# → 代码中通过 import.meta.env.VITE_APP_TITLE 读取 → ✅
```

**到这一步为止的目录结构：**

```
my-project/
├── node_modules/
├── public/
│   └── vite.svg
├── src/
│   ├── App.tsx             ← 默认组件（后续会替换）
│   ├── main.tsx            ← 应用入口（后续配置Mock启动）
│   ├── App.css
│   ├── index.css
│   └── vite-env.d.ts
├── .gitignore
├── index.html
├── package.json
├── tsconfig.json
├── tsconfig.app.json
├── tsconfig.node.json
└── vite.config.ts
```

这是框架给你的初始结构，**干净但不完整**——还缺少 OpenSpec 目录、Mock 基础设施、API 层等。接下来的 Step 0.2-0.9 会补齐这些。

**脚手架阶段的常见错误：**

```
❌ 一开始就装一堆库（UI库、状态管理、路由……）
   → 先跑通Mock流程，再按需添加

❌ 一开始就配 ESLint + Prettier + Husky + lint-staged 全套
   → 先在 Step 0.7 统一处理，避免配置冲突

❌ 纠结目录结构规范（src/features/ vs src/modules/ vs src/pages/）
   → 先用框架默认结构，功能多了再重构，Frontend-First的核心是Mock隔离，不是目录美学

❌ 选用 monorepo（turborepo/nx）
   → 除非你确定需要，否则先用单仓库。monorepo 的构建配置复杂度会让初始化耗时翻倍
```

**fullstack 模式的特殊情况：前后端在同一仓库**

如果前后端代码要放在一起：

```bash
# 方式A：前端为主，后端是子目录
npm create vite@latest my-project -- --template react-ts
cd my-project
mkdir -p server/src        # 后端代码放这里

# 方式B：顶层目录管理，前后端平级
mkdir my-project && cd my-project
npm init -y                                           # 顶层 package.json（workspace管理）
npm create vite@latest frontend -- --template react-ts # 前端
mkdir -p backend/src                                   # 后端
```

两种方式都可以，选择取决于前后端谁更"重"。如果是一个有复杂前端的项目（管理后台、SaaS），推荐方式A；如果前后端体量相当，推荐方式B。

**方式A 最终目录结构预览：**
```
my-project/
├── openspec/              ← OpenSpec（管理前后端共享的契约）
├── devtools/              ← Mock（前端开发工具）
├── server/                ← 后端代码
│   └── src/
├── src/                   ← 前端代码
├── docs/
├── package.json
└── vite.config.ts
```

**方式B 最终目录结构预览：**
```
my-project/
├── openspec/              ← OpenSpec（管理前后端共享的契约）
├── frontend/              ← 前端项目（独立 package.json）
│   ├── devtools/
│   ├── src/
│   └── package.json
├── backend/               ← 后端项目（独立 package.json）
│   ├── src/
│   └── package.json
├── docs/
└── package.json           ← 顶层（workspace配置）
```

**Step 0.2：创建 OpenSpec 目录结构**

```
my-project/
├── openspec/                      ← OpenSpec 核心目录
│   ├── config.yaml                ← 项目配置
│   └── specs/                     ← 存放各功能的Spec
│       └── .gitkeep
├── design-system/                 ← 设计基础（配色/字体/tokens，可选）
│   ├── tokens.css                 ← CSS Variables（框架无关）
│   ├── tailwind.preset.ts         ← Tailwind 预设（如果用 Tailwind）
│   └── MASTER.md                  ← 设计系统完整说明文档
├── devtools/                      ← 开发工具（与src物理隔离）
│   └── mocks/
│       ├── handlers.ts            ← Mock请求处理器（汇总）
│       ├── browser.ts             ← MSW浏览器端启动配置
│       └── data/                  ← Mock数据文件
│           └── .gitkeep
├── docs/
│   └── archives/                  ← 功能归档文档
│       └── .gitkeep
└── src/
    ├── api/                       ← API调用层（纯业务，禁止引用devtools）
    └── ...
```

```bash
# 一键创建目录
mkdir -p openspec/specs design-system devtools/mocks/data docs/archives src/api
```

**Step 0.2.5：生成设计基础（可选，有前端时推荐）**

如果项目有前端（fullstack 或 frontend-only），在写第一个组件之前确立配色、字体、间距等视觉基础。这样 Step 2 写组件时直接引用 design tokens，避免"随手选颜色"导致的视觉不统一。

**方式A：使用 ui-ux-pro-max 自动生成（推荐）**

```bash
# 根据产品类型生成设计系统
python3 openspec/ui-ux-pro-max/scripts/search.py "<产品类型关键词>" \
  --design-system --persist -p "<项目名>" -f markdown

# 示例
python3 openspec/ui-ux-pro-max/scripts/search.py "saas dashboard" \
  --design-system --persist -p "MyApp" -f markdown
```

生成 `design-system/MASTER.md` 后，手动提取关键值到代码可用的格式：

```css
/* design-system/tokens.css — 框架无关的 CSS Variables */
:root {
  /* 从 MASTER.md 中提取 */
  --color-primary: #4F46E5;
  --color-secondary: #818CF8;
  --color-cta: #10B981;
  --color-background: #FFFFFF;
  --color-text: #1F2937;

  --font-heading: 'Inter', sans-serif;
  --font-body: 'Inter', sans-serif;

  --transition-default: 200ms ease;
  --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

```typescript
// design-system/tailwind.preset.ts — 如果项目用 Tailwind
export default {
  theme: {
    extend: {
      colors: {
        primary: 'var(--color-primary)',
        secondary: 'var(--color-secondary)',
        cta: 'var(--color-cta)',
      },
      fontFamily: {
        heading: ['Inter', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
      },
    },
  },
}
```

在应用入口引入：
```typescript
// src/main.ts 或 src/index.css
import '../design-system/tokens.css'
```

**方式B：手动定义**

如果已有设计规范或不想用自动生成，直接手写 `design-system/tokens.css` 即可。关键是在写组件前确立统一的变量，而不是写组件时临时选值。

**方式C：跳过**

如果是纯后端项目、原型验证、或不关心视觉一致性，跳过此步。

**Step 0.3：安装 Mock 基础设施**

```bash
# 安装 MSW（Mock Service Worker）
npm install msw --save-dev

# 初始化 MSW（生成 public/mockServiceWorker.js）
npx msw init public/ --save
```

创建 Mock 启动文件：

```typescript
// devtools/mocks/browser.ts
import { setupWorker } from 'msw/browser'
import { handlers } from './handlers'

export const worker = setupWorker(...handlers)
```

```typescript
// devtools/mocks/handlers.ts
// 所有Mock处理器汇总，初始为空
export const handlers = []
```

**Step 0.4：配置应用入口**

```typescript
// src/main.ts
async function bootstrap() {
  if (import.meta.env.DEV && import.meta.env.VITE_ENABLE_MOCK === 'true') {
    const { worker } = await import('../devtools/mocks/browser')
    await worker.start({ onUnhandledRequest: 'warn' })
    // 'warn'：未被 Mock 的请求正常放行，同时在控制台打印警告
    // 这样你能清楚看到哪些请求走了 Mock、哪些走了真实后端
    console.warn('[MOCK] Mock Service Worker 已启动')
  }

  // 正常启动应用...
}

bootstrap()
```

**Step 0.5：配置环境变量**

```bash
# .env.development（开发环境，Mock开启）
VITE_ENABLE_MOCK=true
VITE_API_BASE_URL=http://localhost:3000/api

# .env.production（生产环境，Mock关闭）
VITE_ENABLE_MOCK=false
VITE_API_BASE_URL=https://api.example.com
```

**Step 0.6：确认构建隔离**

如果入口文件按 Step 0.4 的写法（`import.meta.env.DEV` + 动态 `import()`），Vite 生产构建会自动消除 Mock 代码分支，**不需要额外配置**。

验证方法：
```bash
# 构建后检查产物，确认无 Mock 残留
npm run build
grep -r "mockServiceWorker\|devtools\|\.mock\." dist/ && echo "❌ 有泄漏" || echo "✅ 干净"
```

**Step 0.7：安装 Git Hooks**

```bash
# 使用 husky 管理 hooks
npm install husky --save-dev
npx husky init

# 添加 pre-commit hook
echo '#!/bin/sh
# 检查生产代码中是否引用了 devtools
if grep -r "from.*devtools\|import.*devtools" src/ 2>/dev/null; then
  echo "❌ src/ 目录中不允许引用 devtools/"
  exit 1
fi
echo "✅ Mock隔离检查通过"
' > .husky/pre-commit
```

**Step 0.8：创建 OpenSpec config.yaml**

见下方"修改OpenSpec配置"章节。

**Step 0.9：验证**

```bash
# 启动开发服务器，确认Mock模式工作正常
npm run dev
# 浏览器中应该看到 "[MOCK] Mock Service Worker 已启动" 控制台日志

# 构建生产包，确认无Mock污染
npm run build
# 检查构建产物
grep -r "mockServiceWorker\|devtools" dist/ && echo "❌ 有泄漏" || echo "✅ 干净"
```

**新项目初始化 Checklist：**

```
□ 工程脚手架创建完成
□ openspec/ 目录结构创建
□ devtools/mocks/ 目录结构创建
□ MSW 安装并初始化
□ 应用入口配置Mock启动逻辑
□ 环境变量文件创建（.env.development / .env.production）
□ 确认构建隔离（入口写法正确即可，无需额外构建配置）
□ Git Hooks 安装
□ config.yaml 创建
□ 验证：开发模式Mock正常工作
□ 验证：生产构建无Mock污染
```

---

#### 已有项目初始化

**耗时预估：1-3小时（取决于项目复杂度）**

已有项目的初始化比新项目复杂得多，因为需要**在不破坏现有功能的前提下**引入新的工作流基础设施。

**Step 0.1：项目现状评估（必做，不要跳过）**

在动手之前，先回答这些问题：

```
项目基本信息：
□ 使用的前端框架是什么？（React/Vue/Angular/其他）
□ 构建工具是什么？（Vite/Webpack/其他）
□ 是否有TypeScript？
□ 包管理器？（npm/pnpm/yarn）

Mock 现状：
□ 项目中有Mock数据吗？
□ Mock数据在哪里？（散落在各组件中 / 集中管理 / 没有）
□ Mock数据是怎么使用的？（直接import / 环境判断 / axios拦截 / MSW / 其他）
□ 有没有"API失败降级到Mock"的代码？

API 现状：
□ 有多少个API endpoint？
□ 有API文档/Spec吗？
□ API调用是集中管理的还是散落在组件中？
□ 有没有统一的请求/响应格式？

构建和部署：
□ 有CI/CD吗？
□ 有已有的Git Hooks吗？
□ 有代码规范检查吗？（ESLint/Prettier）
```

**Step 0.2：根据评估结果选择策略**

```
策略A：渐进式引入（推荐）
  适用：大型项目、多人协作、不能停下来重构
  方法：只对新功能使用Frontend-First流程，老功能不动
  耗时：30分钟设置基础设施，后续逐步迁移

策略B：全量切换
  适用：小型项目、一个人维护、可以停几天重构
  方法：一次性梳理所有API，补Spec，重组Mock
  耗时：视API数量而定，10个API约3-4小时
```

**Step 0.3：创建 OpenSpec 目录（与现有结构共存）**

```
existing-project/
├── openspec/                      ← 新增
│   ├── config.yaml
│   └── specs/
├── devtools/                      ← 新增
│   └── mocks/
│       ├── handlers.ts
│       ├── browser.ts
│       └── data/
├── src/                           ← 已有
│   ├── api/                       ← 已有（可能需要重构）
│   ├── components/                ← 已有
│   ├── mocks/                     ← ⚠️ 已有的Mock目录（待迁移）
│   └── ...
└── ...
```

**Step 0.4：处理已有的Mock方案（最复杂的一步）**

根据现有Mock方案的不同情况：

**情况A：没有Mock方案**

最简单——按新项目的 Step 0.3-0.5 操作即可。

**情况B：Mock数据散落在组件中**

```typescript
// 典型的散落模式 — 组件内直接写假数据
// src/components/UserList.tsx
const mockUsers = [
  { id: 1, name: 'Alice' },
  { id: 2, name: 'Bob' }
]

function UserList() {
  const [users, setUsers] = useState(mockUsers) // ← 直接用Mock
  // ...
}
```

**迁移方法：**
1. 搜索所有组件中的Mock数据（搜索 `mock`、`fake`、`dummy`、`test` 等关键词）
2. 将Mock数据提取到 `devtools/mocks/data/` 中
3. 将组件改为调用真实API（或通过MSW拦截）
4. **渐进式迁移**——不需要一次改完，优先改正在开发的功能

**情况C：有集中的Mock方案（如 axios-mock-adapter、json-server）**

```
已有方案                   迁移到
─────────────────────────────────────
axios-mock-adapter    →   MSW handlers
json-server           →   MSW handlers + data文件
手写的mock middleware →   MSW handlers
src/mocks/ 目录       →   devtools/mocks/
```

**迁移步骤：**
1. 安装 MSW
2. 将现有Mock规则逐个翻译为 MSW handler
3. 切换到 MSW，验证功能不变
4. 删除旧的Mock方案
5. 同样可以渐进式迁移

**情况D：已有"降级到Mock"的代码（必须处理）**

```typescript
// ❌ 搜索并消除所有这种模式
try {
  return await api.getUsers()
} catch {
  return mockData  // ← 这种代码必须删除
}
```

**处理方法：**
1. 全局搜索：`catch` 块中引用 `mock` / `fallback` / `default` 数据的代码
2. 改为正确的错误处理（抛错或返回空值）
3. 这一步优先级最高，因为它是数据可靠性的隐患

**Step 0.5：处理已有API（决定管理范围）**

**关键决策：已有的API需要补Spec吗？**

```
决策树：

已有的API还会改动吗？
├─ 会（活跃开发中）
│   ├─ 下次改动时补Spec（渐进式，推荐）
│   └─ 现在就补Spec（全量，耗时但彻底）
└─ 不会（稳定功能）
    └─ 不补Spec，维持现状
```

**渐进式（推荐）：**
- 新功能：严格走 Frontend-First 全流程
- 已有功能改动时：补 Spec → 按流程修改
- 已有功能不改动：不管它

**全量式：**
- 列出所有 API endpoint
- 为每个 endpoint 写 Spec（可以从Swagger/Postman导出）
- 为每个 endpoint 补 Mock 数据
- 写契约测试
- 这是一次性投入，适合API数量不多（<20个）的项目

**Step 0.6：配置构建和Hooks（与已有配置合并）**

**构建配置——确认 Mock 隔离：**

如果入口文件使用了 `import.meta.env.DEV` + 动态 `import()`（见新项目 Step 0.4），Vite 生产构建会自动消除 Mock 代码分支，不需要额外构建配置。只需在 CI 中加一步检查：

```bash
# 构建后检查产物，确认无 Mock 残留
npm run build
grep -r "mockServiceWorker\|devtools\|\.mock\." dist/ && echo "❌ 有泄漏" || echo "✅ 干净"
```

**Git Hooks——与已有hooks合并：**

```bash
# 如果已经用了 husky
# 在 .husky/pre-commit 中追加检查（不要覆盖已有内容）

# 追加 Mock 隔离检查
echo '
# === Frontend-First Mock隔离检查 ===
if grep -r "from.*devtools\|import.*devtools" src/ 2>/dev/null; then
  echo "❌ src/ 目录中不允许引用 devtools/"
  exit 1
fi
echo "✅ Mock隔离检查通过"
' >> .husky/pre-commit
```

```bash
# 如果没有用 husky，用其他 hooks 管理工具
# 先确认 .git/hooks/ 中有没有已有的 pre-commit
ls -la .git/hooks/pre-commit

# 如果有，在末尾追加
# 如果没有，新建
```

**Step 0.7：配置 ESLint 规则（防止 src 引用 devtools）**

注意：内置的 `no-restricted-imports` 只能拦截静态 `import` 语句，无法拦截动态 `import()` 表达式。需要使用 `eslint-plugin-import` 的 `import/no-restricted-paths` 规则。

```bash
# 安装插件
npm install eslint-plugin-import --save-dev
```

```javascript
// .eslintrc.js — 追加规则
module.exports = {
  plugins: ['import'],
  // ... 已有规则 ...
  rules: {
    // 禁止 src/ 下的文件引用 devtools/（静态和动态 import 都会被拦截）
    'import/no-restricted-paths': ['error', {
      zones: [{
        target: './src',           // 在 src/ 下的文件中
        from: './devtools',        // 禁止引用 devtools/
        message: '业务代码禁止引用 devtools 目录（Mock隔离规则）'
      }]
    }]
  },
  // 排除入口文件（唯一允许条件引用 devtools 的地方）
  overrides: [{
    files: ['src/main.ts', 'src/main.tsx'],
    rules: {
      'import/no-restricted-paths': 'off'
    }
  }]
}
```

**Step 0.8：验证（比新项目多一步——回归测试）**

```
□ 现有功能全部正常（回归测试）
□ Mock模式在开发环境正常工作
□ 生产构建无Mock污染
□ 已有的CI/CD pipeline未被破坏
□ 已有的Git Hooks仍然正常执行
□ ESLint规则生效（在src中import devtools会报错）
```

---

#### 新项目 vs 已有项目：初始化耗时对比

```
                    新项目         已有项目（渐进式）    已有项目（全量）
─────────────────────────────────────────────────────────────────
目录结构             5min           5min               5min
Mock基础设施         10min          10min              10min
迁移已有Mock         -              30min-2h           30min-2h
补已有API的Spec      -              -                  2-8h
构建/Hooks配置       10min          20min（需合并）     20min
验证                 5min           30min（需回归）     30min
─────────────────────────────────────────────────────────────────
总计                 30min          1-3h               3-11h
```

---

#### 已有项目初始化 Checklist

```
评估阶段：
□ 项目现状评估完成
□ 选定策略（渐进式 / 全量）
□ 识别已有Mock方案
□ 识别已有"降级到Mock"代码

基础设施：
□ openspec/ 目录创建
□ devtools/mocks/ 目录创建
□ MSW 安装并初始化
□ 应用入口配置Mock启动逻辑
□ 环境变量配置

迁移（渐进式可后续逐步完成）：
□ 已有Mock数据迁移到 devtools/mocks/data/
□ 已有"降级到Mock"代码消除
□ src/ 中的Mock import清理

防护：
□ 确认构建隔离（入口写法正确即可，CI 加检查脚本）
□ Git Hooks追加Mock隔离检查（不覆盖已有hooks）
□ ESLint import/no-restricted-paths 规则追加
□ config.yaml 创建

验证：
□ 现有功能回归测试通过
□ 开发模式Mock正常工作
□ 生产构建无Mock污染
□ CI/CD pipeline正常
```

---

### 修改OpenSpec配置

**config.yaml位置：**
```
your-project/
└─ openspec/
   └─ config.yaml
```

**添加Frontend-First配置：**

在config.yaml中添加：

```yaml
# 开发模式
dev_mode: frontend-first-solo

# Frontend-First Solo模式配置
frontend_first_solo:
  # 强制UI冻结检查
  enforce_ui_freeze: true
  
  # 启用契约测试
  contract_testing: true
  
  # Mock和Spec自动对比
  auto_compare_mock_spec: true
  
  # Mock数据路径（必须在 devtools/ 下，禁止放在 src/ 中）
  mock_data_path: "devtools/mocks/data"
  
  # Spec路径
  spec_path: "openspec/specs"

# 工作流阶段定义
workflow:
  phases:
    - name: proposal
      required: true
      
    - name: frontend_mock
      required: true
      artifacts:
        - mock_data
        - frontend_components
      
    - name: ui_freeze
      required: true
      checkpoint: true  # 这是一个检查点
      
    - name: spec
      required: true
      dependencies:
        - ui_freeze  # 必须先通过ui_freeze
      
    - name: spec_review
      required: true
      checkpoint: true
      
    - name: backend
      required: true
      dependencies:
        - spec_review
      artifacts:
        - api_implementation
        - contract_tests
      
    - name: integration
      required: true
      artifacts:
        - integration_tests
        - archive_doc
```

**配置说明：**

**enforce_ui_freeze：**
- 开启后，必须明确确认UI冻结才能进入下一步
- 防止跳过检查点

**contract_testing：**
- 开启后，backend阶段必须包含契约测试
- 测试不通过不允许进入integration

**auto_compare_mock_spec：**
- 开启后，spec_review阶段自动运行对比脚本
- 发现不一致自动报错

**checkpoint：**
- 标记为checkpoint的阶段必须人工确认
- 不能自动跳过

---

### 创建自定义Cursor Skills

**Skill文件结构：**

```
your-project/
└─ .cursor/
   └─ skills/
      ├─ opsx-ff-new/
      │  └─ SKILL.md
      ├─ opsx-ff-freeze/
      │  └─ SKILL.md
      ├─ opsx-ff-spec/
      │  └─ SKILL.md
      └─ opsx-ff-done/
         └─ SKILL.md
```

**Skill 1: opsx-ff-new（创建新功能）**

功能：
- 引导用户描述需求
- 生成proposal.md
- 创建Mock数据模板
- 创建前端组件模板

输出：
- proposal.md
- devtools/mocks/data/[feature].mock.ts（模板）
- src/components/[Feature].tsx（模板）

提示用户：
"Mock数据和组件模板已创建，开始设计UI吧。满意后运行 /opsx:ff-freeze"

---

**Skill 2: opsx-ff-freeze（冻结UI）**

功能：
- 展示检查清单
- 要求用户确认所有项
- 保存Mock数据版本
- 生成UI确认文档

检查清单：
- 所有显示字段都在Mock中了吗？
- 所有交互功能都测试了吗？
- 边界情况都考虑了吗？
- 确定不需要修改了吗？

确认后：
- 在Mock文件中添加版本标记
- 生成ui-freeze.md文档
- 解锁下一步：/opsx:ff-mock-to-spec

---

**Skill 3: opsx-ff-spec（Mock 反推 Spec）**

对应 Skill 文件：`skills/openspec-ff-mock-to-spec/SKILL.md`

这是 Frontend-First 流程与 Spec-First 流程最大的差异点——Spec 不是从需求文档正向设计的，而是从冻结的 Mock 数据和前端组件代码反向推导的。

功能：
- 读取冻结的 Mock 数据 → 提取响应结构（字段名、类型、嵌套、可选性、枚举值）
- 分析前端组件代码 → 提取请求参数（筛选器→filter、搜索框→search、排序→sort_by、分页→page）
- 自动生成 spec.md，响应结构 100% 复制 Mock 数据
- 每个请求参数标注"来源"（哪个组件/交互产生了这个参数）
- 生成后立即运行 Mock↔Spec 自动一致性校验

交互：
- 确认 HTTP 方法和路径
- 无法从代码推断的参数，询问用户
- 生成后让用户 review 字段说明和业务规则

---

**Skill 4: opsx-ff-done（完成集成）**

功能：
- 检查契约测试是否通过
- 生成切换指南
- 生成归档文档

检查：
- 契约测试运行了吗？
- 通过了吗？
- 功能测试做了吗？

生成：
- integration-guide.md（告诉用户怎么切换到真实API）
- archive.md（归档文档）

---

### 自动化子代理（Cursor Subagents）

除了上面的 Skills（用户触发、顺序执行），还配置了一组**子代理**用于自动化验证和检查。子代理的特点是上下文隔离、可并行执行、只读不写。

**文件位置：** `.cursor/agents/`

#### 子代理一览

| 子代理 | 职责 | 触发时机 | 可并行 |
|--------|------|---------|--------|
| `ff-verifier` | 三方一致性综合验证（Mock↔Spec↔Backend） | Step 7 完成后 | 独立运行 |
| `ff-contract-tester` | 运行并分析契约测试 | Step 6 完成后 | ✅ 与下面两个并行 |
| `ff-spec-checker` | Mock↔Spec 字段级对比 | Step 5 或 Step 6 完成后 | ✅ |
| `ff-build-checker` | 构建产物 Mock 泄漏检查 | Step 6 完成后 / 部署前 | ✅ |
| `ff-migrator` | 已有项目 Mock 迁移扫描 | 已有项目 Step 0.4 | 独立运行 |

#### Skills vs Subagents 的分工

```
用户交互、顺序执行、单步操作 → Skill（ff-new / ff-freeze / ff-spec / ff-done）
独立验证、并行检查、大量搜索 → Subagent（ff-verifier / ff-*-checker / ff-migrator）
```

**所有子代理都是 `readonly: true`**——只报告问题，不修改任何文件。

#### 典型使用方式

**方式1：Step 7 后综合验证**
```
> /ff-verifier 验证 user-management 功能的三方一致性
```

**方式2：Step 6 后并行检查（Agent 自动编排）**
```
> 后端实现完成，运行 ff-contract-tester、ff-spec-checker、ff-build-checker 并行验证
```
Agent 会同时启动三个子代理，各自在独立上下文中执行，最后汇总结果。

**方式3：已有项目初始化评估**
```
> /ff-migrator 扫描当前项目的 Mock 现状
```

---

### 工具脚本

**脚本1：compare-mock-spec.js**

功能：
- 对比Mock数据和Spec定义
- 输出差异报告

输出示例：
```
✅ Mock数据和Spec结构一致

字段检查：
✅ id: 类型匹配（number）
✅ name: 类型匹配（string）
⚠️  role: Mock有值"pending"但Spec未定义
❌ email: Spec定义了但Mock中没有

建议：
1. 在Spec的role枚举中加上"pending"
2. 在Mock中加上email字段
```

运行时机：
- Step 5（Spec Review）手动运行
- Git提交前自动运行

---

**脚本2：contract-test-runner.js**

功能：
- 运行所有契约测试
- 生成测试报告

输出示例：
```
契约测试报告
=============

/api/users:
  ✅ 响应结构正确
  ✅ 所有必填字段存在
  ✅ 字段类型正确
  ❌ 字段role的值"manager"不在允许范围内

/api/posts:
  ✅ 所有测试通过

总计：
  通过：8/10
  失败：2/10
```

运行时机：
- Step 6（Backend Implementation）每次改代码后
- CI/CD pipeline中
- 部署前

---

**脚本3：freeze-mock-version.js**

功能：
- 保存当前Mock数据版本
- 添加时间戳和标记

执行内容：
- 复制Mock文件到版本目录
- 在原文件中添加版本注释
- 生成版本对比工具

使用场景：
- Step 3（UI Freeze）时运行
- 以后可以回溯查看历史版本

---

### Git Hook配置

**pre-commit hook**

作用：
- 提交前自动检查
- 防止提交不一致的代码

检查内容：
- 运行契约测试
- 对比Mock和Spec
- 检查代码规范

安装方式：

创建文件：.git/hooks/pre-commit

内容：
```bash
#!/bin/bash

echo "运行提交前检查..."

# 检查1：契约测试
echo "1. 运行契约测试..."
npm run test:contract
if [ $? -ne 0 ]; then
  echo "❌ 契约测试失败"
  exit 1
fi

# 检查2：Mock-Spec一致性
echo "2. 检查Mock-Spec一致性..."
node scripts/compare-mock-spec.js
if [ $? -ne 0 ]; then
  echo "❌ Mock和Spec不一致"
  exit 1
fi

echo "✅ 所有检查通过"
```

赋予执行权限：
```bash
chmod +x .git/hooks/pre-commit
```

---

## 常见问题处理

### 问题1：Step 3 UI冻结后又想改怎么办？

**情况A：小改动（加个字段）**

处理流程：
1. 评估影响：只是加字段，不影响现有逻辑
2. 修改Mock数据：加上新字段
3. 更新Spec：加上新字段（标注为可选）
4. 不需要重走整个流程
5. 更新版本号：ui-freeze v1.1

**情况B：大改动（改交互逻辑）**

处理流程：
1. 评估：是否已经开始写后端了？
2. 如果还没写后端：
   - 回到Step 2
   - 重新设计
   - 重新冻结
3. 如果已经写了后端：
   - 评估成本：重写vs将就
   - 如果重写：废弃当前分支，重新开始
   - 如果将就：在Spec中加notes说明为什么不理想

**避免方法：**
- Step 3多花些时间
- 找人review
- 第二天再确认
- 不要急着进入下一步

---

### 问题2：后端实现时发现Spec设计不合理

**示例场景：**
Spec要求返回用户的所有帖子列表
实现时发现：一个用户可能有10000条帖子
全部返回太慢

**处理流程：**

**Step 1：停止编码**
- 不要硬着头皮实现
- 不要"先这样，以后再改"

**Step 2：评估影响**
- 这个问题影响API设计吗？
- 需要改Spec吗？
- 前端需要改吗？

**Step 3：制定方案**

方案A：改Spec
- 把"返回所有帖子"改成"返回最近10条"
- 或者加分页参数
- 更新Spec文档
- 通知前端（虽然是你自己）
- 更新Mock数据

方案B：优化实现
- Spec不变
- 后端做优化（缓存、索引）
- 保证返回格式不变

**Step 4：记录决策**
- 在Spec中添加notes
- 说明为什么这样设计
- 记录考虑过的其他方案

**避免方法：**
- Step 4写Spec时多想想可行性
- 考虑性能、数据量
- 不要只想理想情况

---

### 问题3：前端切换真实API后发现问题

**问题类型A：字段值格式不对**

示例：
- Mock中日期是"2024-01-28"
- 后端返回"2024-01-28T10:30:00.000Z"
- 前端formatDate函数报错

处理：
- 这是实现问题，不是设计问题
- 检查Spec：定义的是什么格式？
- 如果Spec是"ISO8601" → 后端对的，前端改
- 如果Spec是"YYYY-MM-DD" → 后端错的，后端改

---

**问题类型B：性能问题**

示例：
- Mock数据秒开
- 真实API要10秒

处理：
- 分析原因：查询慢？网络慢？数据量大？
- 优化方案：
  - 加索引
  - 添加缓存
  - 数据分页
  - 异步加载
- 如果优化后还慢：
  - 考虑改设计
  - 例如：改成懒加载、虚拟滚动

---

**问题类型C：业务逻辑错误**

示例：
- 筛选功能不工作
- 测试发现后端没实现筛选

处理：
- 检查Spec：有定义筛选参数吗？
- 有定义 → 后端漏实现了，补上
- 没定义 → Spec遗漏了，补充Spec

---

### 问题4：团队协作时如何使用这个流程

**场景：**
虽然你是一个人做前后端，但可能有其他人review你的代码

**协作方式：**

**方式1：分阶段Review**

- Step 3：找人review UI设计
  - 给对方看Mock数据驱动的原型
  - 收集反馈
  - 修改后再冻结

- Step 5：找人review API设计
  - 给对方看Spec文档
  - 讨论是否合理
  - 确认后再实现

- Step 7：找人review代码
  - 走正常的Code Review流程
  - 重点看契约测试是否完善

**方式2：结对编程**

- Step 2：和同事一起设计UI
- 两个人讨论得更充分
- 减少遗漏

- Step 6：和同事一起写后端
- 一个人写代码，一个人写测试
- 质量更高

**方式3：异步协作**

- 把每个Step的输出物共享出来
- 用文档/评论的方式收集反馈
- 适合远程协作

---

### 问题5：这个流程适合什么类型的功能？

**非常适合：**

**新功能开发：**
- 需求不明确
- 前后端都要从零开始
- 需要反复调整UI
- 例如：用户管理、订单系统、报表功能

**API设计重要的功能：**
- 前端依赖复杂
- 多个地方会调用
- 需要长期维护
- 例如：认证系统、支付接口

**不太适合：**

**Bug修复：**
- 只改一两行代码
- 不涉及API改动
- 走完整流程太重

**紧急修复：**
- 线上故障
- 需要快速上线
- 来不及走流程

**实验性功能：**
- 不确定要不要做
- 先快速验证
- 确定了再规范化

**建议：**

根据功能重要性和复杂度选择：

**复杂度高 + 重要性高：**
- 走完整流程
- 保证质量

**复杂度高 + 重要性低：**
- 走简化流程
- 只要Proposal + Spec + 实现

**复杂度低 + 重要性高：**
- 走简化流程
- 重点做测试

**复杂度低 + 重要性低：**
- 直接实现
- 简单记录

---

### 问题6：Mock数据降级——切换环境时误用Mock数据

**你遇到的问题：**

开发时在Mock和真实API之间切换，某些情况下系统"降级"回Mock数据，但你没有察觉。典型表现：
- 页面看起来正常，但数据是假的
- 某个API挂了，页面没报错，因为悄悄用了Mock
- 上线后发现某个模块一直在读Mock数据
- 联调时以为接口通了，其实前端还在用Mock

**根本原因分析：**

```
原因1：静默降级（最危险）
   API请求失败 → catch里返回Mock数据 → 页面正常显示 → 你以为没问题

原因2：环境变量未生效
   以为切到了production → 实际环境变量还是development → Mock模式未关闭

原因3：遗忘切换
   调试时手动开启Mock → 提交代码时忘记关闭 → Mock代码进入生产包

原因4：条件逻辑漏洞
   if (!useMock) 写成 if (useMock) → 逻辑反了 → 生产环境用Mock

原因5：构建产物污染
   Mock文件被打包进生产构建 → 即使不主动调用，也占体积，且有被误引用的风险
```

**防治方案（5层防护）：**

---

**第1层：架构隔离——Mock代码与业务代码物理分离**

**核心思路：** Mock不是业务代码的一部分，而是独立的"开发工具"。

**目录结构：**
```
src/
├── api/                  ← 业务代码，只包含真实API调用
│   └── users.ts          ← export function getUsers() { return fetch(...) }
├── components/           ← UI组件
└── ...

devtools/                 ← 开发工具目录，完全独立
└── mocks/
    ├── handlers.ts       ← Mock请求处理器
    ├── data/
    │   └── users.mock.ts ← Mock数据
    └── browser.ts        ← MSW浏览器配置
```

**关键规则：**
- `src/` 目录内**绝不**import `devtools/` 目录的任何内容
- Mock的启动入口在应用入口文件中，通过环境变量控制
- 生产构建时，`devtools/` 整个目录不参与打包

**入口文件写法（唯一的条件分支点）：**
```typescript
// main.ts — 应用入口
async function bootstrap() {
  // 唯一的Mock启动点，仅此一处
  if (import.meta.env.DEV && import.meta.env.VITE_ENABLE_MOCK === 'true') {
    const { worker } = await import('../devtools/mocks/browser')
    await worker.start({ onUnhandledRequest: 'warn' })
    console.warn('[MOCK] Mock Service Worker 已启动')
  }

  // 正常启动应用
  createApp(App).mount('#app')
}

bootstrap()
```

**为什么这样做有效：**
- `import()` 动态导入 → 生产构建时因为条件永远为false，tree-shaking会移除整个import
- Mock代码在物理目录上隔离 → 业务代码不可能意外引用
- 只有一个启动入口 → 不存在"某个模块自己偷偷启用Mock"的可能
- `onUnhandledRequest: 'warn'` → 未被 Mock 的请求正常放行并打印警告，开发时一眼看出哪些是 Mock、哪些是真实请求

---

**第2层：禁止静默降级——API失败必须报错，绝不兜底**

**这是最重要的一层。** 你遇到的"降级使用Mock"问题，90%源于这个反模式：

**错误写法（静默降级）：**
```typescript
// ❌ 绝对禁止：API失败时返回Mock数据
async function getUsers() {
  try {
    return await fetch('/api/users').then(r => r.json())
  } catch (error) {
    // 这就是"降级"的根源——看起来贴心，实际上是定时炸弹
    console.warn('API失败，使用Mock数据')
    return mockUsersData  // ← 你永远不知道线上用的是真数据还是假数据
  }
}
```

**正确写法（失败即报错）：**
```typescript
// ✅ 正确：API失败就是失败，让用户/开发者看到
async function getUsers() {
  const response = await fetch('/api/users')
  if (!response.ok) {
    throw new ApiError(`获取用户列表失败: ${response.status}`, response)
  }
  return response.json()
}
```

**绝对原则：**
```
生产代码中不允许出现以下任何模式：
  - catch 块中返回 Mock/默认/兜底数据
  - 请求失败时从本地文件读取数据
  - "降级策略"中包含Mock数据
  - 任何 fallback 到静态数据的逻辑
```

**如果你需要容错（比如非关键数据）：**
```typescript
// 容错可以，但要用空状态，不要用假数据
async function getUserAvatar(userId: string) {
  try {
    return await fetchAvatar(userId)
  } catch {
    return null  // ← 返回空值，UI显示默认头像
    // 而不是返回一个假的头像URL
  }
}
```

---

**第3层：运行时感知——让Mock状态可见**

**问题：** 开发时你可能不知道当前到底在用Mock还是真实API。

**方案A：页面水印/横幅**
```typescript
// 在应用入口或布局组件中
if (import.meta.env.DEV && import.meta.env.VITE_ENABLE_MOCK === 'true') {
  // 页面顶部显示醒目的红色横幅
  const banner = document.createElement('div')
  banner.textContent = '⚠ MOCK MODE — 当前使用模拟数据'
  banner.style.cssText = `
    position: fixed; top: 0; left: 0; right: 0; z-index: 99999;
    background: #ef4444; color: white; text-align: center;
    padding: 4px; font-size: 12px; font-weight: bold;
  `
  document.body.prepend(banner)
}
```

**方案B：控制台标记每一个Mock请求**

使用 MSW（Mock Service Worker）时，默认就会在控制台打印被拦截的请求。确保不要关闭这个日志：
```typescript
// devtools/mocks/browser.ts
worker.start({
  onUnhandledRequest: 'warn',  // 未被Mock的请求会有警告
  // 不要设置 quiet: true
})
```

**方案C：在响应中注入标记**
```typescript
// Mock handler 中给每个响应加标记
export const handlers = [
  http.get('/api/users', () => {
    return HttpResponse.json({
      code: 0,
      message: 'success',
      data: mockUsersData,
      _mock: true,           // ← Mock标记
      _mockTimestamp: Date.now()
    })
  })
]
```

前端可以在开发模式下检查这个标记：
```typescript
// API层的开发检查
if (import.meta.env.DEV && response.data._mock) {
  console.warn(`[MOCK] ${url} 返回的是Mock数据`)
}
```

---

**第4层：构建时阻断——Mock代码不进入生产包**

**原理说明：**
如果入口文件使用了 `import.meta.env.DEV` 条件 + 动态 `import()`，Vite 生产构建时会自动将 `import.meta.env.DEV` 替换为 `false`，然后 tree-shaking 会移除整个 `if` 分支及其动态 import。**不需要额外的 `rollupOptions.external` 配置**（`external` 的语义是"运行时从外部加载"，用在这里反而会导致运行时报错 Module not found）。

所以只要入口文件写法正确（见第1层），生产构建天然不包含 Mock 代码。以下是**额外的安全网**：

**方案A：CI检查——生产包中不能包含Mock关键词（推荐）**
```bash
#!/bin/bash
# scripts/check-no-mock-in-build.sh
# 在CI/CD中运行

echo "检查生产构建是否包含Mock代码..."

# 在构建产物中搜索Mock相关关键词
if grep -r "mockData\|mock_data\|MOCK_MODE\|enableMock\|\.mock\." dist/ 2>/dev/null; then
  echo "❌ 生产构建中发现Mock代码残留！"
  exit 1
fi

echo "✅ 生产构建无Mock代码污染"
```

---

**第5层：测试验证——自动化确认数据来源**

**集成测试中验证不是Mock数据：**
```typescript
// tests/integration/no-mock-leak.test.ts
describe('生产模式无Mock泄漏', () => {
  beforeAll(() => {
    // 确保Mock未启动
    process.env.VITE_ENABLE_MOCK = 'false'
  })

  it('API失败时不应返回Mock数据', async () => {
    // 模拟API不可达
    server.use(
      http.get('/api/users', () => {
        return new HttpResponse(null, { status: 503 })
      })
    )
    
    // 调用应该抛错，而不是返回Mock数据
    await expect(getUsers()).rejects.toThrow()
  })

  it('响应中不应包含_mock标记', async () => {
    const response = await getUsers()
    expect(response).not.toHaveProperty('_mock')
  })
})
```

---

**5层防护总结：**

```
第1层 架构隔离  → Mock代码不可能被业务代码import
第2层 禁止降级  → API失败就报错，不兜底假数据
第3层 运行时感知 → 用Mock时有醒目视觉提示
第4层 构建阻断  → Mock代码不进入生产包
第5层 测试验证  → 自动化确认无Mock泄漏
```

**一句话原则：**

> Mock是开发工具，不是容错机制。API挂了就让它挂，用户看到错误提示比看到假数据好一万倍。

---

### 问题7：同时开发多个功能，Mock 如何共存

**场景：**
Feature A 在 Step 6（后端实现），Feature B 在 Step 2（前端设计），两个功能都有 Mock handler。

**MSW handlers 的组织方式：**

```
devtools/mocks/
├── handlers.ts              ← 汇总入口，import 所有功能的 handler
├── browser.ts
└── data/
    ├── feature-a/
    │   ├── users.mock.ts    ← Feature A 的 Mock 数据
    │   └── handlers.ts      ← Feature A 的 MSW handlers
    └── feature-b/
        ├── orders.mock.ts   ← Feature B 的 Mock 数据
        └── handlers.ts      ← Feature B 的 MSW handlers
```

```typescript
// devtools/mocks/handlers.ts — 汇总所有功能的 handlers
import { featureAHandlers } from './data/feature-a/handlers'
import { featureBHandlers } from './data/feature-b/handlers'

export const handlers = [
  ...featureAHandlers,
  ...featureBHandlers,
]
```

**并行开发时的状态管理：**

```
Feature A（Step 6，后端已实现）：
  → 把 Feature A 的 handlers 从汇总中移除（或注释）
  → 前端切换为调用真实 API
  → Mock 数据保留但不激活

Feature B（Step 2，前端设计中）：
  → Feature B 的 handlers 正常生效
  → MSW 拦截 Feature B 的请求，返回 Mock 数据
  → Feature A 的请求直接穿透到真实后端
```

**关键：MSW 的 `onUnhandledRequest: 'warn'` 配置**

```typescript
worker.start({
  onUnhandledRequest: 'warn'  // 未被 Mock 的请求正常放行 + 控制台警告
})
```

这意味着：有 handler 的请求走 Mock，没有 handler 的请求走真实 API（并在控制台打印警告）。两者自然共存，无需手动切换。

**注意事项：**
- 不同功能的 Mock handler 不要监听同一个 URL（例如都拦截 `/api/users`）
- 如果两个功能确实共享同一个 API，以更新的功能的 handler 为准（后注册的覆盖先注册的）
- Feature A 完成集成（Step 7）后，删除对应的 Mock handler 文件，保持 `devtools/mocks/` 目录干净

---

### 问题8：认证/权限相关的 Mock 怎么处理

**场景：**
90% 的 API 需要登录态（JWT Token）。前端开发阶段后端还没实现，怎么 Mock 认证流程？

**方案：Mock 一个永不过期的假 Token**

```typescript
// devtools/mocks/data/auth/handlers.ts
import { http, HttpResponse } from 'msw'

// Mock 登录接口
const loginHandler = http.post('/api/auth/login', () => {
  return HttpResponse.json({
    code: 0,
    message: 'success',
    data: {
      token: 'mock-jwt-token-never-expires',
      user: {
        id: 1,
        name: '测试用户',
        role: 'admin'         // 可以切换为 'user' 测试不同权限
      }
    }
  })
})

// Mock Token 校验（所有需要认证的接口都会先校验 Token）
// MSW 不需要显式 Mock 校验——因为 Mock handler 根本不检查 Authorization header
// 只要请求路径匹配，直接返回 Mock 数据

export const authHandlers = [loginHandler]
```

**不同角色的 Mock 数据切换：**

```typescript
// devtools/mocks/data/auth/roles.ts
export type MockRole = 'admin' | 'user' | 'guest'

// 在 devtools 的配置中切换角色（不是环境变量，是开发时手动切换）
export let currentMockRole: MockRole = 'admin'

export function setMockRole(role: MockRole) {
  currentMockRole = role
}
```

```typescript
// 在其他 handler 中根据角色返回不同数据
import { currentMockRole } from './auth/roles'

http.get('/api/admin/dashboard', () => {
  if (currentMockRole !== 'admin') {
    return HttpResponse.json({
      code: 200003,
      message: '权限不足',
      data: null
    }, { status: 403 })
  }
  return HttpResponse.json({
    code: 0,
    message: 'success',
    data: { /* admin dashboard data */ }
  })
})
```

**前端代码中的认证逻辑不需要改：**

```typescript
// src/api/client.ts — 业务代码，不需要知道是 Mock 还是真实
const response = await fetch('/api/users', {
  headers: {
    'Authorization': `Bearer ${getToken()}`  // Mock 模式下这个 header 会被忽略
  }
})
```

MSW 拦截请求时不检查 header，所以前端的认证代码可以按正常逻辑写，Mock 和真实 API 切换时无需改动。

---

### 问题9：数据库设计放在哪一步

**问题：** Step 5（Spec Review）到 Step 6（Backend Implementation）之间，缺少数据库表设计环节。

**回答：数据库设计是 Step 6 的第一个子步骤，不是独立的 Step。**

原因：
- 数据库表结构是**实现细节**，不是契约的一部分
- 表结构和 API 响应结构**经常不一致**（这是正常的，后端负责转换）
- 不需要把表设计暴露给"契约"层面

**Step 6 的实际执行顺序应为：**

```
Step 6: Backend Implementation
  ├─ 6.1 数据库设计
  │   ├─ 根据 Spec 中的字段，设计表结构
  │   ├─ 注意：表字段名可以和 API 字段名不同（后端做映射）
  │   ├─ 创建 migration 文件
  │   └─ 执行 migration
  ├─ 6.2 API handler 骨架
  ├─ 6.3 参数校验
  ├─ 6.4 业务逻辑（查询 + 数据转换）
  ├─ 6.5 响应构造（确保与 Spec 一致）
  └─ 6.6 契约测试
```

**表结构 vs API 结构的常见差异：**

| API 字段（Spec 定义） | 数据库字段 | 转换方式 |
|----------------------|-----------|---------|
| `roleName: "管理员"` | `role_id: 1` | JOIN role 表 |
| `fullName: "张三"` | `first_name + last_name` | 代码拼接 |
| `statusText: "已激活"` | `status: 1` | 枚举映射 |
| `createdAt: "2024-01-28"` | `created_at: timestamp` | 格式化 |

**关键原则：API 结构由前端需求（Spec）决定，表结构由数据存储需求决定，后端负责两者之间的转换。**

---

## 附录

### 文档模板

**proposal.md模板**

```markdown
# Proposal: [功能名称]

## 背景
[为什么要做这个功能？解决什么问题？]

## 目标
- [目标1]
- [目标2]
- [目标3]

## 非目标
- [不做什么]
- [留到下个版本的]

## 关键用例
1. [用例1描述]
2. [用例2描述]
```

---

**ui-freeze.md模板**

```markdown
# UI设计确认文档

## 功能：[功能名称]
## 冻结日期：[YYYY-MM-DD]
## Mock版本：v1.0

## 显示字段清单
- [ ] 字段1：[说明]
- [ ] 字段2：[说明]
- ...

## 交互功能清单
- [ ] 筛选：[支持哪些筛选条件]
- [ ] 搜索：[搜索哪些字段]
- [ ] 排序：[支持哪些字段排序]
- [ ] 分页：[是否需要]

## 边界情况
- [ ] 空数据展示
- [ ] 加载中状态
- [ ] 错误提示
- [ ] null值处理

## 确认
✅ 以上所有项已确认
✅ Mock数据包含所有需要的字段
✅ UI不再变动

签名：[你的名字]
日期：[YYYY-MM-DD]
```

---

**spec.md模板**

```markdown
# API Spec: [功能名称]

## 接口信息
- 方法：[GET/POST/PUT/DELETE]
- 路径：[/api/xxx]
- 功能：[一句话描述]

## 请求参数
| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| xxx    | string | 是 | xxx | xxx |

## 响应格式

### 成功响应 (code: 0)
```json
{
  "code": 0,
  "message": "success",
  "data": {
    ...
  }
}
```

### 错误响应
```json
{
  "code": 100001,
  "message": "缺少必填参数",
  "data": null
}
```

> 错误码为 6 位数字，格式 `CCMMSS`（分类+模块+序号），详见 `openspec/conventions/api-convention.md`

## 数据字典
| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| xxx    | string | 是 | xxx |

## 业务规则
1. [规则1]
2. [规则2]

## 注意事项
- [注意事项1]
- [注意事项2]
```

---

**archive.md模板**

```markdown
# Archive: [功能名称]

## 完成时间
[YYYY-MM-DD]

## 功能总结
[简要描述实现了什么]

## 技术实现

### 前端
- 主要组件：[列出组件]
- 使用的库：[列出依赖]

### 后端
- API列表：[列出所有API]
- 技术栈：[框架、数据库等]

### 数据库
- 新增表：[如果有]
- 修改表：[如果有]

## 测试情况
- 单元测试覆盖率：[X%]
- 契约测试：[通过/失败]
- 手动测试：[完成情况]

## 已知问题
- [问题1及workaround]
- [问题2及计划]

## 经验总结

### 做得好的
- [好的地方1]
- [好的地方2]

### 可改进的
- [下次可以改进的地方]

## 维护信息
- 相关文件：[列出关键文件路径]
- 依赖模块：[列出依赖]
- 注意事项：[维护时要注意什么]
```

---

### 检查清单汇总

**Step 3: UI Freeze检查清单**

```
显示字段：
□ 所有需要展示的字段都在Mock中
□ 每个字段的数据类型已确定
□ 可选字段（null值）已标记

交互功能：
□ 筛选条件已明确
□ 搜索字段已明确
□ 排序字段已明确
□ 分页设计已明确

边界情况：
□ 空列表展示设计
□ 加载中状态设计
□ 错误提示设计
□ null值显示设计

用户体验：
□ 不同屏幕尺寸测试
□ 大数据量测试
□ 操作流程测试

最终确认：
□ 如果现在上线，这个UI可以接受
□ 接下来一周不改UI，可以接受
□ Mock数据完整且正确
```

---

**Step 5: Spec Review检查清单**

```
字段一致性：
□ Mock和Spec字段名100%一致
□ 数据类型完全匹配
□ 嵌套结构一致
□ 可选/必填标注正确

完整性：
□ 所有字段都有说明
□ 枚举值列全了
□ 业务规则写清楚了
□ 错误情况有定义

边界情况：
□ 空数据定义了
□ null值规则明确
□ 错误格式统一

演进约束（不是现在要规划，而是确认规则已记录）：
□ 明确标注"字段只增不减"原则
□ 若将来需要破坏性变更，需回到 Step 2 重走流程
```

---

**Step 6: Backend完成检查清单**

```
实现完整性：
□ 所有endpoint都实现了
□ 所有参数都处理了
□ 所有业务规则都实现了

契约测试：
□ 响应结构测试
□ 字段类型测试
□ 必填字段测试
□ 枚举值测试
□ 边界情况测试
□ 所有测试通过

代码质量：
□ 参数校验完整
□ 错误处理正确
□ 日志记录完整
□ 代码review通过

性能：
□ 查询性能可接受
□ 并发测试通过
□ 资源占用正常
```

---

**Step 7: Integration检查清单**

```
切换准备：
□ API地址配置正确
□ 认证配置完成
□ 环境变量设置

功能测试：
□ 列表展示正常
□ 筛选功能正常
□ 搜索功能正常
□ 排序功能正常
□ 分页功能正常
□ 边界情况正常

性能测试：
□ 页面加载时间<2秒
□ 操作响应时间<1秒
□ 无明显卡顿

用户体验：
□ 错误提示友好
□ 加载状态清晰
□ 无console错误
□ 移动端测试通过

文档：
□ Archive文档完成
□ 维护文档更新
□ API文档更新
```

---

### 时间估算参考

**小功能（单个列表页）：**
- Step 1: Proposal - 2分钟
- Step 2: Frontend + Mock - 30分钟
- Step 3: UI Freeze - 5分钟
- Step 4: Spec - 10分钟
- Step 5: Spec Review - 3分钟
- Step 6: Backend - 1小时
- Step 7: Integration - 5分钟
- **总计：约2小时**

**中等功能（CRUD全套）：**
- Step 1: Proposal - 5分钟
- Step 2: Frontend + Mock - 2小时
- Step 3: UI Freeze - 10分钟
- Step 4: Spec - 30分钟
- Step 5: Spec Review - 10分钟
- Step 6: Backend - 3小时
- Step 7: Integration - 15分钟
- **总计：约6小时**

**大功能（复杂业务流程）：**
- Step 1: Proposal - 10分钟
- Step 2: Frontend + Mock - 4小时
- Step 3: UI Freeze - 20分钟
- Step 4: Spec - 1小时
- Step 5: Spec Review - 20分钟
- Step 6: Backend - 6小时
- Step 7: Integration - 30分钟
- **总计：约12小时**

---

## 总结

这个Frontend-First Solo工作流的核心价值在于：

1. **前端先行** - 用真实UI发现真实需求
2. **Mock驱动** - 在可以随意修改的阶段充分试错
3. **明确检查点** - UI Freeze和Spec Review防止随意改动
4. **契约保护** - 自动化测试防止"改了a，b崩了"
5. **一次做对** - 前期多花时间，后期一次性完成

通过这7个步骤，你可以避免传统开发中的返工问题，提高开发效率和代码质量。