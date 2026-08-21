import { existsSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { spawn } from 'node:child_process'

const toolDirectory = dirname(fileURLToPath(import.meta.url))
const repositoryRoot = resolve(toolDirectory, '..')
const indexPath = join(
  repositoryRoot,
  'documentation',
  'public',
  'api',
  'index.html',
)

if (existsSync(indexPath)) {
  console.log(`Using existing ${indexPath}`)
  process.exit(0)
}

console.log('Generated API reference is missing; running dart doc...')
const child = spawn(process.execPath, [join(toolDirectory, 'generate_documentation_api.mjs')], {
  cwd: repositoryRoot,
  stdio: 'inherit',
})

child.on('exit', (code, signal) => {
  process.exit(signal ? 1 : code ?? 1)
})
