#!/usr/bin/env node

/**
 * ff-freeze-mock-version.js
 *
 * 保存 Mock 数据的版本快照：复制到版本目录，在原文件中添加冻结标记。
 *
 * 用法：
 *   node scripts/ff-freeze-mock-version.js <mock-data-dir> [--version <v1.0>]
 *
 * 示例：
 *   node scripts/ff-freeze-mock-version.js devtools/mocks/data/users
 *   node scripts/ff-freeze-mock-version.js devtools/mocks/data/users --version v2.0
 *
 * 执行内容：
 *   1. 创建 <mock-data-dir>/.versions/<timestamp>/ 快照目录
 *   2. 复制所有 .ts / .json 文件到快照目录
 *   3. 在原文件顶部添加 @frozen 标记注释（如果尚未有）
 *   4. 生成 VERSION.md 记录冻结信息
 *
 * 依赖：Node.js 原生（fs + path），无额外 npm 包。
 */

const fs = require('fs')
const path = require('path')

// ── 参数解析 ──────────────────────────────────────────────

const args = process.argv.slice(2)
let mockDir = null
let version = 'v1.0'

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--version' && args[i + 1]) {
    version = args[i + 1]
    i++
  } else if (!mockDir) {
    mockDir = args[i]
  }
}

if (!mockDir) {
  console.error('用法: node scripts/ff-freeze-mock-version.js <mock-data-dir> [--version <v1.0>]')
  console.error('')
  console.error('示例:')
  console.error('  node scripts/ff-freeze-mock-version.js devtools/mocks/data/users')
  process.exit(1)
}

mockDir = path.resolve(mockDir)

// ── 主逻辑 ────────────────────────────────────────────────

function main() {
  // 检查目录存在
  if (!fs.existsSync(mockDir) || !fs.statSync(mockDir).isDirectory()) {
    console.error(`❌ Mock 数据目录不存在: ${mockDir}`)
    process.exit(1)
  }

  const now = new Date()
  const timestamp = now.toISOString().replace(/[:.]/g, '-').slice(0, 19)
  const isoTimestamp = now.toISOString().replace(/\.\d{3}Z$/, 'Z')
  const featureName = path.basename(mockDir)

  // 1. 创建快照目录
  const versionDir = path.join(mockDir, '.versions', timestamp)
  fs.mkdirSync(versionDir, { recursive: true })

  // 2. 复制 Mock 文件到快照
  const mockFiles = fs.readdirSync(mockDir).filter(f => {
    const ext = path.extname(f)
    return ['.ts', '.tsx', '.js', '.json'].includes(ext)
  })

  if (mockFiles.length === 0) {
    console.error(`⚠ 目录中没有找到 Mock 文件: ${mockDir}`)
    console.error('  支持的文件类型: .ts, .tsx, .js, .json')
    process.exit(1)
  }

  let filesCopied = 0
  for (const file of mockFiles) {
    const src = path.join(mockDir, file)
    const dest = path.join(versionDir, file)
    fs.copyFileSync(src, dest)
    filesCopied++
  }

  // 3. 在原文件顶部添加冻结标记
  const frozenComment = `/**
 * @frozen ${isoTimestamp}
 * @version ${version}
 * @feature ${featureName}
 * UI Freeze 确认后，此文件的数据结构不再变动。
 * 字段名、类型、嵌套结构均已锁定。
 */`

  let filesMarked = 0
  for (const file of mockFiles) {
    const filePath = path.join(mockDir, file)
    const content = fs.readFileSync(filePath, 'utf-8')

    // 如果已有 @frozen 标记，更新时间戳
    if (content.includes('@frozen')) {
      const updated = content.replace(
        /@frozen\s+[\dT:Z.-]+/,
        `@frozen ${isoTimestamp}`
      ).replace(
        /@version\s+v[\d.]+/,
        `@version ${version}`
      )
      fs.writeFileSync(filePath, updated, 'utf-8')
      filesMarked++
    } else {
      // 没有标记，在顶部添加
      fs.writeFileSync(filePath, frozenComment + '\n\n' + content, 'utf-8')
      filesMarked++
    }
  }

  // 4. 生成 VERSION.md
  const versionMd = `# Mock 版本记录

## ${featureName}

| 属性 | 值 |
|------|-----|
| 版本 | ${version} |
| 冻结时间 | ${isoTimestamp} |
| 快照目录 | .versions/${timestamp}/ |
| 文件数量 | ${filesCopied} |

### 冻结的文件
${mockFiles.map(f => `- ${f}`).join('\n')}

### 冻结规则
- 字段名不可变
- 字段类型不可变
- 嵌套结构不可变
- 可以修正数据值（如 typo），但不能增删字段
- 如需修改结构，需回到 Step 2 重新设计
`

  fs.writeFileSync(path.join(mockDir, 'VERSION.md'), versionMd, 'utf-8')

  // 输出报告
  console.log('')
  console.log('═══════════════════════════════════════════')
  console.log('  Mock 版本冻结报告')
  console.log('═══════════════════════════════════════════')
  console.log('')
  console.log(`功能:     ${featureName}`)
  console.log(`版本:     ${version}`)
  console.log(`冻结时间: ${isoTimestamp}`)
  console.log('')
  console.log(`文件复制: ${filesCopied} 个 → .versions/${timestamp}/`)
  console.log(`冻结标记: ${filesMarked} 个文件已添加 @frozen`)
  console.log(`版本记录: VERSION.md 已生成`)
  console.log('')
  console.log('✅ Mock 数据已冻结')
  console.log('')
}

main()
