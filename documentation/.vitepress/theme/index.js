import DefaultTheme from 'vitepress/theme'

function isGeneratedApiPath(to) {
  try {
    const path = new URL(to, 'http://local.invalid').pathname
    return /(?:^|\/)api(?:\/|$)/.test(path) && !path.includes('api-reference')
  } catch {
    return false
  }
}

export default {
  extends: DefaultTheme,
  enhanceApp({ router }) {
    router.onBeforeRouteChange = (to) => {
      if (!isGeneratedApiPath(to)) {
        return
      }
      if (typeof window !== 'undefined') {
        window.location.assign(to)
      }
      return false
    }
  },
}
