<template>
  <nav class="m-tabbar">
    <router-link class="tab" :class="{ active: isActive('today') }" to="/overview/dashboard">
      <svg-icon icon-class="dashboard" />
      <span>今日</span>
    </router-link>
    <router-link class="tab" :class="{ active: isActive('records') }" to="/m/records">
      <svg-icon icon-class="date" />
      <span>记录</span>
    </router-link>
    <button type="button" class="fab" @click="$emit('quick')">
      <span>记</span>
    </button>
    <router-link class="tab" :class="{ active: isActive('health') }" to="/m/health">
      <svg-icon icon-class="example" />
      <span>健康</span>
    </router-link>
    <router-link class="tab" :class="{ active: isActive('family') }" to="/m/family">
      <svg-icon icon-class="peoples" />
      <span>家庭</span>
    </router-link>
  </nav>
</template>

<script setup>
const route = useRoute()
defineEmits(['quick'])

function isActive(name) {
  const path = route.path
  if (name === 'today') {
    return path === '/overview/dashboard' || path === '/index'
  }
  if (name === 'records') {
    return path.startsWith('/m/records') || path.startsWith('/daily/')
  }
  if (name === 'health') {
    return path.startsWith('/m/health') || path.startsWith('/health/')
  }
  if (name === 'family') {
    return path.startsWith('/m/family') || path.startsWith('/family/')
  }
  return false
}
</script>

<style scoped lang="scss">
.m-tabbar {
  position: fixed;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 30;
  height: calc(58px + env(safe-area-inset-bottom, 0px));
  padding-bottom: env(safe-area-inset-bottom, 0px);
  display: flex;
  align-items: flex-start;
  justify-content: space-around;
  background: #fff9f3;
  border-top: 1px solid var(--line);
  box-shadow: 0 -6px 18px rgba(176, 142, 110, 0.08);
}

.tab {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding-top: 8px;
  color: var(--muted);
  font-size: 11px;
  text-decoration: none;
}

.tab :deep(.svg-icon) {
  font-size: 18px;
}

.tab.active {
  color: var(--pri-deep);
  font-weight: 600;
}

.fab {
  width: 52px;
  height: 52px;
  margin-top: -18px;
  border: 0;
  border-radius: 50%;
  background: var(--pri);
  color: #fff;
  font-size: 18px;
  font-weight: 700;
  box-shadow: 0 8px 18px rgba(201, 111, 82, 0.35);
}
</style>
