<template>
  <div class="mobile-shell">
    <mobile-top-bar />
    <div class="mobile-main">
      <app-main />
    </div>
    <mobile-tab-bar @quick="quickOpen = true" />
    <quick-record v-model="quickOpen" />
  </div>
</template>

<script setup>
import { AppMain } from '@/layout/components'
import MobileTopBar from './TopBar.vue'
import MobileTabBar from './TabBar.vue'
import QuickRecord from './QuickRecord.vue'
import useNursingStore from '@/store/modules/nursing'

const nursingStore = useNursingStore()
const quickOpen = ref(false)
let heartbeatTimer = null

onMounted(() => {
  heartbeatTimer = setInterval(() => {
    nursingStore.heartbeat()
  }, 20000)
  nursingStore.heartbeat()
})

onUnmounted(() => {
  if (heartbeatTimer) {
    clearInterval(heartbeatTimer)
  }
})
</script>

<style scoped lang="scss">
.mobile-shell {
  min-height: 100%;
  background: var(--bg);
  padding-bottom: calc(58px + env(safe-area-inset-bottom, 0px));
}

.mobile-main {
  min-height: calc(100vh - 56px - 58px);
}

.mobile-main :deep(.app-main) {
  min-height: calc(100vh - 56px - 58px);
  overflow: visible;
}

.mobile-main :deep(.fixed-header + .app-main),
.mobile-main :deep(.hasTagsView .fixed-header + .app-main) {
  padding-top: 0;
}
</style>
