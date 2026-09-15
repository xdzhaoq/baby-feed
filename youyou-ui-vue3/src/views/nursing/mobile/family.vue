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
  { to: '/family/member', title: '家庭成员', desc: '谁在照看、账号' },
  { to: '/family/collab', title: '协作中心', desc: '交接、留言' },
  { to: '/family/knowledge', title: '应急手册', desc: '急救与就医指引' }
]
</script>
