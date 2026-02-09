#!/usr/bin/env node

/**
 * ff-contract-test-runner.js
 *
 * 运行契约测试：对真实 API 发送请求，验证响应结构是否与 Spec 定义一致。
 * 输出每个 endpoint 的结构一致性报告。
 *
 * 用法：
 *   node scripts/ff-contract-test-runner.js <spec-file> [--base-url <url>]
 *
 * 示例：
 *   node scripts/ff-contract-test-runner.js openspec/specs/users/spec.md --base-url http://localhost:3000
 *
 * 依赖：Node.js 18+（原生 fetch）
 *
 * 注意：这是模板脚本。Spec 文件解析假定使用 Frontend-First spec.md 格式。
 * 请根据实际项目的 API 认证方式修改 headers 配置。
 */

const fs = require('fs')
const path = require('path')

// ── 参数解析 ──────────────────────────────────────────────

const args = process.argv.slice(2)
let specFilePath = null
let baseUrl = 'http://localhost:3000'

for (let i = 0; i < args.length; i++) {
  if (args[i] === '--base-url' && args[i + 1]) {
    baseUrl = args[i + 1]
    i++
  } else if (!specFilePath) {
    specFilePath = args[i]
  }
}

if (!specFilePath) {
  console.error('用法: node scripts/ff-contract-test-runner.js <spec-file> [--base-url <url>]')
  console.error('')
  console.error('示例:')
  console.error('  node scripts/ff-contract-test-runner.js openspec/specs/users/spec.md --base-url http://localhost:3000')
  process.exit(1)
}

specFilePath = path.resolve(specFilePath)

// ── Spec 解析 ─────────────────────────────────────────────

/**
 * 从 Spec 文件中提取 endpoint 列表和预期的响应结构
 */
function parseSpec(content) {
  const endpoints = []
  const lines = content.split('\n')
  let currentEndpoint = null

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()

    // 匹配 endpoint 标题：## GET /api/users 或 ### `GET /api/users`
    const endpointMatch = line.match(/^#{2,3}\s+`?(GET|POST|PUT|PATCH|DELETE)\s+(\/[^`\s]+)`?/i)
    if (endpointMatch) {
      if (currentEndpoint) endpoints.push(currentEndpoint)
      currentEndpoint = {
        method: endpointMatch[1].toUpperCase(),
        path: endpointMatch[2],
        expectedFields: [],
        successExample: null,
      }
      continue
    }

    // 提取 JSON 响应示例
    if (currentEndpoint && line === '```json') {
      let json = ''
      i++
      while (i < lines.length && lines[i].trim() !== '```') {
        json += lines[i] + '\n'
        i++
      }
      try {
        const parsed = JSON.parse(json)
        if (parsed.code === 0 && !currentEndpoint.successExample) {
          currentEndpoint.successExample = parsed
        }
      } catch {
        // 忽略非法 JSON
      }
    }
  }
  if (currentEndpoint) endpoints.push(currentEndpoint)

  return endpoints
}

// ── 结构验证 ──────────────────────────────────────────────

/**
 * 验证响应结构是否符合 StandardResp 信封
 */
function validateEnvelope(response) {
  const issues = []

  if (!('code' in response)) issues.push('缺少 code 字段')
  if (!('message' in response)) issues.push('缺少 message 字段')
  if (!('data' in response)) issues.push('缺少 data 字段')

  if ('code' in response && typeof response.code !== 'number') {
    issues.push(`code 应为 number，实际为 ${typeof response.code}`)
  }
  if ('message' in response && typeof response.message !== 'string') {
    issues.push(`message 应为 string，实际为 ${typeof response.message}`)
  }

  return issues
}

/**
 * 递归比较两个对象的结构（字段名和类型）
 */
function compareStructure(expected, actual, prefix = '') {
  const issues = []

  if (expected === null || actual === null) return issues
  if (typeof expected !== 'object' || typeof actual !== 'object') return issues

  // 如果是数组，比较第一个元素
  if (Array.isArray(expected) && Array.isArray(actual)) {
    if (expected.length > 0 && actual.length > 0) {
      return compareStructure(expected[0], actual[0], `${prefix}[]`)
    }
    return issues
  }

  // 检查预期字段在实际响应中是否存在
  for (const key of Object.keys(expected)) {
    const fieldPath = prefix ? `${prefix}.${key}` : key

    if (!(key in actual)) {
      issues.push(`缺少字段: ${fieldPath}`)
      continue
    }

    const expectedType = expected[key] === null ? 'null' : typeof expected[key]
    const actualType = actual[key] === null ? 'null' : typeof actual[key]

    // null 兼容：预期非 null 但实际 null 是可接受的（可选字段）
    if (actualType === 'null' && expectedType !== 'null') {
      // 可选字段，跳过
      continue
    }

    if (expectedType !== actualType && expectedType !== 'null') {
      issues.push(`类型不匹配: ${fieldPath} — 预期 ${expectedType}，实际 ${actualType}`)
      continue
    }

    // 递归比较嵌套对象/数组
    if (typeof expected[key] === 'object' && expected[key] !== null) {
      issues.push(...compareStructure(expected[key], actual[key], fieldPath))
    }
  }

  // 检查实际响应中多出的字段（警告，不是错误）
  for (const key of Object.keys(actual)) {
    if (!(key in expected)) {
      const fieldPath = prefix ? `${prefix}.${key}` : key
      issues.push(`额外字段（非错误）: ${fieldPath}`)
    }
  }

  return issues
}

// ── 主逻辑 ────────────────────────────────────────────────

async function main() {
  if (!fs.existsSync(specFilePath)) {
    console.error(`❌ Spec 文件不存在: ${specFilePath}`)
    process.exit(1)
  }

  const specContent = fs.readFileSync(specFilePath, 'utf-8')
  const endpoints = parseSpec(specContent)

  if (endpoints.length === 0) {
    console.error('⚠ 未从 Spec 文件中解析到任何 endpoint')
    console.error('  请确认 Spec 使用 "## GET /api/xxx" 或 "### `GET /api/xxx`" 格式')
    process.exit(1)
  }

  console.log('')
  console.log('═══════════════════════════════════════════')
  console.log('  契约测试报告')
  console.log('═══════════════════════════════════════════')
  console.log('')
  console.log(`Spec 文件: ${args[0]}`)
  console.log(`Base URL:  ${baseUrl}`)
  console.log(`Endpoint:  ${endpoints.length} 个`)
  console.log('')

  let passed = 0
  let failed = 0
  let skipped = 0

  for (const endpoint of endpoints) {
    const url = `${baseUrl}${endpoint.path}`
    console.log(`── ${endpoint.method} ${endpoint.path} ──`)

    // 只测试 GET 请求（POST/PUT/DELETE 需要请求体，模板无法自动生成）
    if (endpoint.method !== 'GET') {
      console.log(`   ⏭ 跳过（${endpoint.method} 请求需要手动配置请求体）`)
      console.log('')
      skipped++
      continue
    }

    try {
      const response = await fetch(url, {
        method: endpoint.method,
        headers: {
          'Content-Type': 'application/json',
          'X-Request-ID': `contract-test-${Date.now()}`,
          // 如果需要认证，在这里添加：
          // 'Authorization': `Bearer ${process.env.TEST_TOKEN || 'test-token'}`,
        },
      })

      const body = await response.json()

      // 检查 1：响应信封
      const envelopeIssues = validateEnvelope(body)
      if (envelopeIssues.length > 0) {
        console.log('   ❌ 响应信封不符合 StandardResp:')
        for (const issue of envelopeIssues) {
          console.log(`      - ${issue}`)
        }
        failed++
        console.log('')
        continue
      }
      console.log('   ✅ 响应信封正确（code + message + data）')

      // 检查 2：与 Spec 示例对比结构
      if (endpoint.successExample && body.code === 0) {
        const structureIssues = compareStructure(endpoint.successExample, body)
        const errors = structureIssues.filter(i => !i.startsWith('额外字段'))
        const warnings = structureIssues.filter(i => i.startsWith('额外字段'))

        if (errors.length === 0) {
          console.log('   ✅ 响应结构与 Spec 一致')
          if (warnings.length > 0) {
            for (const w of warnings) {
              console.log(`   ⚠ ${w}`)
            }
          }
          passed++
        } else {
          console.log('   ❌ 响应结构与 Spec 不一致:')
          for (const issue of errors) {
            console.log(`      - ${issue}`)
          }
          failed++
        }
      } else if (body.code !== 0) {
        console.log(`   ⚠ API 返回错误: code=${body.code}, message=${body.message}`)
        console.log('      无法验证成功响应结构')
        skipped++
      } else {
        console.log('   ⚠ Spec 中未找到成功响应示例，跳过结构对比')
        skipped++
      }
    } catch (error) {
      console.log(`   ❌ 请求失败: ${error.message}`)
      console.log('      请确认后端服务正在运行')
      failed++
    }

    console.log('')
  }

  // 总结
  console.log('═══════════════════════════════════════════')
  console.log(`  通过: ${passed}  失败: ${failed}  跳过: ${skipped}  总计: ${endpoints.length}`)
  console.log('═══════════════════════════════════════════')

  process.exit(failed > 0 ? 1 : 0)
}

main()
