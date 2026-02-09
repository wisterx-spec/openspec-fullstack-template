#!/usr/bin/env node

/**
 * ff-compare-mock-spec.js
 *
 * 对比 Mock 数据和 Spec 定义的字段级一致性。
 * 输出差异报告：字段名、类型、可选性、枚举值。
 *
 * 用法：
 *   node scripts/ff-compare-mock-spec.js <mock-file> <spec-file>
 *
 * 示例：
 *   node scripts/ff-compare-mock-spec.js devtools/mocks/data/users/users.mock.ts openspec/specs/users/spec.md
 *
 * 依赖：Node.js 原生（fs + path），无额外 npm 包。
 *
 * 注意：这是模板脚本。Mock 文件解析假定导出的是 JSON 兼容对象。
 * 如果 Mock 文件使用 TypeScript 或 ESM，需要先用 tsx/ts-node 编译，
 * 或者将 Mock 数据同时导出为 .json 文件。
 */

const fs = require('fs')
const path = require('path')

// ── 参数解析 ──────────────────────────────────────────────

const args = process.argv.slice(2)

if (args.length < 2) {
  console.error('用法: node scripts/ff-compare-mock-spec.js <mock-file> <spec-file>')
  console.error('')
  console.error('示例:')
  console.error('  node scripts/ff-compare-mock-spec.js devtools/mocks/data/users/users.mock.json openspec/specs/users/spec.md')
  process.exit(1)
}

const mockFilePath = path.resolve(args[0])
const specFilePath = path.resolve(args[1])

// ── 工具函数 ──────────────────────────────────────────────

/**
 * 提取对象的字段结构（递归）
 * 返回 Map<字段路径, { type, nullable, values }>
 */
function extractFields(obj, prefix = '') {
  const fields = new Map()

  if (obj === null || obj === undefined) return fields
  if (typeof obj !== 'object') return fields

  for (const [key, value] of Object.entries(obj)) {
    const fieldPath = prefix ? `${prefix}.${key}` : key

    if (Array.isArray(value)) {
      fields.set(fieldPath, { type: 'array', nullable: false, values: null })
      // 递归第一个元素
      if (value.length > 0 && typeof value[0] === 'object' && value[0] !== null) {
        const itemFields = extractFields(value[0], `${fieldPath}[]`)
        for (const [k, v] of itemFields) {
          fields.set(k, v)
        }
        // 检查其他元素中的 null 值
        for (let i = 1; i < value.length; i++) {
          if (typeof value[i] === 'object' && value[i] !== null) {
            for (const itemKey of Object.keys(value[i])) {
              const itemPath = `${fieldPath}[].${itemKey}`
              if (fields.has(itemPath) && value[i][itemKey] === null) {
                fields.get(itemPath).nullable = true
              }
            }
          }
        }
      }
    } else if (typeof value === 'object' && value !== null) {
      fields.set(fieldPath, { type: 'object', nullable: false, values: null })
      const nested = extractFields(value, fieldPath)
      for (const [k, v] of nested) {
        fields.set(k, v)
      }
    } else {
      fields.set(fieldPath, {
        type: value === null ? 'null' : typeof value,
        nullable: value === null,
        values: null,
      })
    }
  }

  return fields
}

/**
 * 从 Spec markdown 文件中提取数据字典表格
 * 解析 | 字段路径 | 类型 | 必填 | 说明 | 格式的表格
 */
function extractSpecFields(specContent) {
  const fields = new Map()
  const lines = specContent.split('\n')
  let inDataDict = false

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()

    // 识别数据字典表格的开始
    if (line.match(/^#+\s*(数据字典|Data Dictionary)/i)) {
      inDataDict = true
      continue
    }

    // 遇到下一个标题时结束
    if (inDataDict && line.match(/^#+\s/) && !line.match(/数据字典|Data Dictionary/i)) {
      inDataDict = false
      continue
    }

    if (!inDataDict) continue

    // 解析表格行（跳过分隔行）
    if (line.startsWith('|') && !line.match(/^\|[\s-|]+$/)) {
      const cells = line.split('|').map(c => c.trim()).filter(Boolean)
      if (cells.length >= 3 && cells[0] !== '字段路径' && cells[0] !== '字段名' && cells[0] !== 'Field') {
        const fieldPath = cells[0]
        const type = cells[1].toLowerCase()
        const required = cells[2]
        fields.set(fieldPath, {
          type,
          nullable: required === '否' || required === 'No' || required === '可选',
          values: null,
        })
      }
    }
  }

  return fields
}

// ── 主逻辑 ────────────────────────────────────────────────

function main() {
  // 检查文件存在
  if (!fs.existsSync(mockFilePath)) {
    console.error(`❌ Mock 文件不存在: ${mockFilePath}`)
    process.exit(1)
  }
  if (!fs.existsSync(specFilePath)) {
    console.error(`❌ Spec 文件不存在: ${specFilePath}`)
    process.exit(1)
  }

  // 读取文件
  let mockData
  const ext = path.extname(mockFilePath)
  if (ext === '.json') {
    try {
      mockData = JSON.parse(fs.readFileSync(mockFilePath, 'utf-8'))
    } catch (e) {
      console.error(`❌ 解析 Mock JSON 失败: ${e.message}`)
      process.exit(1)
    }
  } else {
    console.error(`⚠ Mock 文件不是 JSON 格式（${ext}）。`)
    console.error('  请将 Mock 数据导出为 .json 文件，或使用 tsx 编译后再运行。')
    console.error('  示例: npx tsx -e "import d from \'./mock.ts\'; console.log(JSON.stringify(d))" > mock.json')
    process.exit(1)
  }

  const specContent = fs.readFileSync(specFilePath, 'utf-8')

  // 提取字段
  const mockFields = extractFields(mockData)
  const specFields = extractSpecFields(specContent)

  // 对比
  const results = {
    match: [],
    mockOnly: [],
    specOnly: [],
    typeMismatch: [],
    nullableMismatch: [],
  }

  // 检查 Mock 中的字段
  for (const [fieldPath, mockField] of mockFields) {
    if (specFields.has(fieldPath)) {
      const specField = specFields.get(fieldPath)
      // 类型检查（简单匹配）
      const mockType = mockField.type
      const specType = specField.type
      if (mockType !== 'null' && !specType.includes(mockType) && specType !== mockType) {
        results.typeMismatch.push({ fieldPath, mockType, specType })
      } else {
        results.match.push(fieldPath)
      }
      // 可选性检查
      if (mockField.nullable && !specField.nullable) {
        results.nullableMismatch.push({ fieldPath, mock: 'nullable', spec: 'required' })
      }
    } else {
      results.mockOnly.push(fieldPath)
    }
  }

  // 检查 Spec 中有但 Mock 中没有的字段
  for (const fieldPath of specFields.keys()) {
    if (!mockFields.has(fieldPath)) {
      results.specOnly.push(fieldPath)
    }
  }

  // 输出报告
  console.log('')
  console.log('═══════════════════════════════════════════')
  console.log('  Mock ↔ Spec 一致性检查报告')
  console.log('═══════════════════════════════════════════')
  console.log('')
  console.log(`Mock 文件: ${args[0]}`)
  console.log(`Spec 文件: ${args[1]}`)
  console.log('')

  if (results.match.length > 0) {
    console.log(`✅ 一致字段: ${results.match.length} 个`)
    for (const f of results.match) {
      console.log(`   ✅ ${f}`)
    }
    console.log('')
  }

  let hasIssues = false

  if (results.mockOnly.length > 0) {
    hasIssues = true
    console.log(`⚠ Mock 中有但 Spec 中缺失: ${results.mockOnly.length} 个`)
    for (const f of results.mockOnly) {
      console.log(`   ⚠ ${f} → 需要补充到 Spec 数据字典`)
    }
    console.log('')
  }

  if (results.specOnly.length > 0) {
    hasIssues = true
    console.log(`⚠ Spec 中有但 Mock 中缺失: ${results.specOnly.length} 个`)
    for (const f of results.specOnly) {
      console.log(`   ⚠ ${f} → 需要补充到 Mock 数据或从 Spec 删除`)
    }
    console.log('')
  }

  if (results.typeMismatch.length > 0) {
    hasIssues = true
    console.log(`❌ 类型不匹配: ${results.typeMismatch.length} 个`)
    for (const f of results.typeMismatch) {
      console.log(`   ❌ ${f.fieldPath}: Mock=${f.mockType}, Spec=${f.specType}`)
    }
    console.log('')
  }

  if (results.nullableMismatch.length > 0) {
    hasIssues = true
    console.log(`⚠ 可选性不匹配: ${results.nullableMismatch.length} 个`)
    for (const f of results.nullableMismatch) {
      console.log(`   ⚠ ${f.fieldPath}: Mock 中为 null 但 Spec 标记为必填`)
    }
    console.log('')
  }

  console.log('───────────────────────────────────────────')
  if (!hasIssues) {
    console.log('✅ Mock 和 Spec 字段 100% 一致')
    process.exit(0)
  } else {
    const total = results.mockOnly.length + results.specOnly.length + results.typeMismatch.length + results.nullableMismatch.length
    console.log(`❌ 发现 ${total} 处不一致，请修复后重新检查`)
    process.exit(1)
  }
}

main()
