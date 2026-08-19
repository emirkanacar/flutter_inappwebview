import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'flutter_inappwebview_forge',
  description: 'Flutter WebView documentation',
  lang: 'en-US',
  cleanUrls: true,
  lastUpdated: true,
  srcExclude: ['README.md'],
  themeConfig: {
    siteTitle: 'flutter_inappwebview_forge',
    nav: [
      { text: 'Guide', link: '/getting-started' },
      { text: 'API reference', link: '/api/' },
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
          { text: 'API reference', link: '/api-reference' },
          { text: 'Changelog', link: '/changelog' },
          {
            text: 'Migration and upstream',
            link: '/migration-from-upstream',
          },
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
