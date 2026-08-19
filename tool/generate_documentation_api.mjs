import { existsSync } from 'node:fs'
import { mkdir } from 'node:fs/promises'
import { dirname, join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'
import { spawn } from 'node:child_process'

const toolDirectory = dirname(fileURLToPath(import.meta.url))
const repositoryRoot = resolve(toolDirectory, '..')
const packageDirectory = join(repositoryRoot, 'flutter_inappwebview_forge')
const outputDirectory = join(
  repositoryRoot,
  'documentation',
  'public',
  'api',
)

const configuredDart = process.env.DART_BIN
const fvmDart = join(repositoryRoot, '.fvm', 'flutter_sdk', 'bin', 'dart')
const fvmDartWindows = `${fvmDart}.bat`
const flutterRoot = process.env.FLUTTER_ROOT
const flutterDart = flutterRoot
  ? join(flutterRoot, 'bin', 'cache', 'dart-sdk', 'bin', 'dart')
  : null
const flutterDartWindows = flutterDart ? `${flutterDart}.bat` : null
const dartCommand =
  configuredDart ||
  (existsSync(fvmDart)
    ? fvmDart
    : existsSync(fvmDartWindows)
      ? fvmDartWindows
      : flutterDart && existsSync(flutterDart)
        ? flutterDart
        : flutterDartWindows && existsSync(flutterDartWindows)
          ? flutterDartWindows
          : 'dart')

await mkdir(outputDirectory, { recursive: true })

const child = spawn(
  dartCommand,
  ['doc', `--output=${outputDirectory}`, packageDirectory],
  {
    cwd: repositoryRoot,
    stdio: 'inherit',
    shell: process.platform === 'win32' && dartCommand.endsWith('.bat'),
  },
)

child.on('error', (error) => {
  console.error(`Unable to run ${dartCommand}: ${error.message}`)
  process.exitCode = 1
})

child.on('close', (code, signal) => {
  if (signal) {
    console.error(`dart doc exited with signal ${signal}`)
    process.exitCode = 1
  } else if (code === 0 && !existsSync(join(outputDirectory, 'index.html'))) {
    console.error(
      `dart doc completed but did not create ${join(outputDirectory, 'index.html')}`,
    )
    process.exitCode = 1
  } else {
    process.exitCode = code ?? 1
  }
})
