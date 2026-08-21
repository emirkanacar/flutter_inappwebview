import { defineConfig } from 'vitepress'

function docsBase() {
  const raw = process.env.DOCS_BASE || '/'
  if (raw === '/') {
    return '/'
  }
  return raw.endsWith('/') ? raw : `${raw}/`
}

function rewriteApiDirectoryIndex() {
  return {
    name: 'rewrite-api-directory-index',
    configureServer(server) {
      server.middlewares.use((req, _res, next) => {
        const url = req.url?.split('?')[0]
        if (url === '/api' || url === '/api/') {
          req.url = '/api/index.html'
        }
        next()
      })
    },
  }
}

export default defineConfig({
  title: 'flutter_inappwebview_forge',
  description: 'Flutter WebView documentation',
  lang: 'en-US',
  base: docsBase(),
  cleanUrls: true,
  lastUpdated: true,
  srcExclude: ['README.md'],
  ignoreDeadLinks: [/^\/api/],
  vite: {
    plugins: [rewriteApiDirectoryIndex()],
  },
  themeConfig: {
    siteTitle: 'flutter_inappwebview_forge',
    nav: [
      { text: 'Guide', link: '/getting-started' },
      { text: 'API reference', link: '/api/index.html', target: '_self' },
      {
        text: 'Repository',
        link: 'https://github.com/emirkanacar/flutter_inappwebview',
      },
    ],
    sidebar: [
      {
        text: 'Overview',
        items: [
          { text: 'Documentation home', link: '/' },
          { text: 'Getting started', link: '/getting-started' },
          { text: 'Inline WebView', link: '/in-app-webview' },
          { text: 'Deprecated APIs', link: '/deprecated-api' },
        ],
      },
      {
        text: 'Build with WebView',
        items: [
          { text: 'Preload and reuse', link: '/preload-and-reuse' },
          { text: 'Examples and recipes', link: '/examples' },
          { text: 'Feature guide', link: '/features' },
          {
            text: 'Lifecycle and performance',
            link: '/lifecycle-and-performance',
          },
          { text: 'Platform guide', link: '/platforms' },
        ],
      },
      {
        text: 'Reference',
        items: [
          { text: 'API reference', link: '/api/index.html', target: '_self' },
          { text: 'Changelog', link: '/changelog' },
          {
            text: 'Migration and upstream',
            link: '/migration-from-upstream',
          },
          { text: 'Deprecated APIs', link: '/deprecated-api' },
          { text: 'Troubleshooting', link: '/troubleshooting' },
        ],
      },
      {
        text: 'Project',
        items: [{ text: 'Contributing', link: '/contributing' }],
      },
    ],
    search: {
      provider: 'local',
    },
    socialLinks: [
      {
        icon: 'github',
        link: 'https://github.com/emirkanacar/flutter_inappwebview',
      },
    ],
    editLink: {
      pattern:
        'https://github.com/emirkanacar/flutter_inappwebview/edit/master/documentation/:path',
      text: 'Edit this page on GitHub',
    },
    footer: {
      message: 'Built from the flutter_inappwebview_forge source tree.',
      copyright: 'Copyright © Emirkan Acar and contributors',
    },
  },
})
