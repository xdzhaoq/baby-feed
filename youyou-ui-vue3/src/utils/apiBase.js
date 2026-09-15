const API_BASE_KEY = 'nursing_api_base'

function packedServer() {
  return String(import.meta.env.VITE_APP_SERVER || '').trim().replace(/\/$/, '')
}

export function isNativeApp() {
  return !!(typeof window !== 'undefined' && window.Capacitor && window.Capacitor.isNativePlatform && window.Capacitor.isNativePlatform())
}

export function needsServerUrl() {
  return isNativeApp() || import.meta.env.VITE_APP_ENV === 'app'
}

/** 打包时已写入 VITE_APP_SERVER 则登录页不再让用户填地址 */
export function showServerInput() {
  return needsServerUrl() && !packedServer()
}

export function getApiBase() {
  if (needsServerUrl()) {
    return packedServer() || (localStorage.getItem(API_BASE_KEY) || '').trim().replace(/\/$/, '')
  }
  return import.meta.env.VITE_APP_BASE_API || '/dev-api'
}

export function setApiBase(url) {
  const value = String(url || '').trim().replace(/\/$/, '')
  if (value) {
    localStorage.setItem(API_BASE_KEY, value)
  } else {
    localStorage.removeItem(API_BASE_KEY)
  }
}

export function getSavedApiBase() {
  return packedServer() || (localStorage.getItem(API_BASE_KEY) || '').trim().replace(/\/$/, '')
}
