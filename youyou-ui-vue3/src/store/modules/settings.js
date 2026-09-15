import defaultSettings from '@/settings'
import { useDynamicTitle } from '@/utils/dynamicTitle'

const { sideTheme, showSettings, topNav, tagsView, fixedHeader, sidebarLogo, dynamicTitle } = defaultSettings

const storageSetting = JSON.parse(localStorage.getItem('layout-setting')) || ''
const useWarmTheme = !storageSetting || storageSetting.theme === '#409EFF' || storageSetting.sideTheme === 'theme-dark'
if (useWarmTheme) {
  localStorage.setItem('layout-setting', JSON.stringify({
    ...(storageSetting || {}),
    theme: '#DE8F74',
    sideTheme: 'theme-light'
  }))
}

const useSettingsStore = defineStore(
  'settings',
  {
    state: () => ({
      title: '',
      theme: useWarmTheme ? '#DE8F74' : (storageSetting.theme || '#DE8F74'),
      sideTheme: useWarmTheme ? 'theme-light' : (storageSetting.sideTheme || sideTheme),
      showSettings: showSettings,
      topNav: storageSetting.topNav === undefined ? topNav : storageSetting.topNav,
      tagsView: storageSetting.tagsView === undefined ? tagsView : storageSetting.tagsView,
      fixedHeader: storageSetting.fixedHeader === undefined ? fixedHeader : storageSetting.fixedHeader,
      sidebarLogo: storageSetting.sidebarLogo === undefined ? sidebarLogo : storageSetting.sidebarLogo,
      dynamicTitle: storageSetting.dynamicTitle === undefined ? dynamicTitle : storageSetting.dynamicTitle
    }),
    actions: {
      // 修改布局设置
      changeSetting(data) {
        const { key, value } = data
        if (this.hasOwnProperty(key)) {
          this[key] = value
        }
      },
      // 设置网页标题
      setTitle(title) {
        this.title = title
        useDynamicTitle();
      }
    }
  })

export default useSettingsStore
