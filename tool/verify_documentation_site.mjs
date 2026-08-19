import { existsSync } from 'node:fs'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const toolDirectory = dirname(fileURLToPath(import.meta.url))
const repositoryRoot = resolve(toolDirectory, '..')
const outputDirectory = join(repositoryRoot, 'documentation', '.vitepress', 'dist')

const requiredFiles = [
  'index.html',
  '404.html',
  'api/index.html',
  'api/static-assets/docs.dart.js',
]

const missingFiles = requiredFiles.filter(
  (relativePath) => !existsSync(join(outputDirectory, relativePath)),
)

if (missingFiles.length > 0) {
  console.error(
    `Documentation build is missing required files:\n- ${missingFiles.join('\n- ')}`,
  )
  process.exitCode = 1
} else {
  console.log(
    `Documentation site verified: ${outputDirectory}`,
  )
}
