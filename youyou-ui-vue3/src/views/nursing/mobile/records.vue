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
  { to: '/daily/feeding', title: '喂养', desc: '奶量、时长、拍嗝' },
  { to: '/daily/sleep', title: '睡眠', desc: '入睡、醒来、小睡' },
  { to: '/daily/diaper', title: '尿布', desc: '尿尿、大便、性状' },
  { to: '/daily/cry', title: '哭闹', desc: '程度、安抚、原因' }
]
</script>
