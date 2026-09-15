<template>
  <div class="app-container mobile-hub">
    <nursing-baby-guide />
    <div class="hub-grid">
      <router-link v-for="item in items" :key="item.to" class="hub-card" :to="item.to">
        <strong>{{ item.title }}</strong>
        <span>{{ item.desc }}</span>
      </router-link>
    </div>
  </div>
</template>

<script setup>
const items = [
  { to: '/health/care', title: '护理清单', desc: '脐带、维D、洗澡' },
  { to: '/health/checkup', title: '健康与疫苗', desc: '自检、接种时间表' },
  { to: '/health/growth', title: '生长记录', desc: '体重、身长、头围' },
  { to: '/health/album', title: '宝宝相册', desc: '照片和视频' }
]
</script>
