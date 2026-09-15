<template>
  <div class="app-container" />
</template>

<script setup>
import { onBeforeUnmount } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
let timer = 0
let tries = 0

function hasDashboard() {
  return router.getRoutes().some(r => r.path === '/overview/dashboard')
}

function jump() {
  if (hasDashboard()) {
    router.replace('/overview/dashboard')
    return
  }
  tries += 1
  if (tries > 40) {
    return
  }
  timer = window.setTimeout(jump, 50)
}

jump()
onBeforeUnmount(() => window.clearTimeout(timer))
</script>
