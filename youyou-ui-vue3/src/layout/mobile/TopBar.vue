<template>
  <header class="m-topbar">
    <div class="brand">
      <img src="@/assets/logo/logo.png" alt="" class="logo" />
      <span class="name">{{ babyName }}</span>
    </div>
    <div class="right">
      <el-select
        v-if="nursingStore.babyList.length"
        class="baby-switcher"
        :model-value="nursingStore.currentBabyId"
        placeholder="宝宝"
        @change="onSwitchBaby"
      >
        <el-option
          v-for="item in nursingStore.babyList"
          :key="item.babyId"
          :label="item.babyName"
          :value="item.babyId"
        />
      </el-select>
      <el-dropdown trigger="click" @command="handleCommand">
        <span class="avatar-hit">
          <img :src="userStore.avatar" class="avatar" />
        </span>
        <template #dropdown>
          <el-dropdown-menu>
            <router-link to="/user/profile">
              <el-dropdown-item>个人中心</el-dropdown-item>
            </router-link>
            <el-dropdown-item divided command="logout">退出登录</el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </header>
</template>

<script setup>
import { ElMessageBox } from 'element-plus'
import useUserStore from '@/store/modules/user'
import useNursingStore from '@/store/modules/nursing'

const router = useRouter()
const userStore = useUserStore()
const nursingStore = useNursingStore()

const babyName = computed(() => nursingStore.currentBaby?.babyName || '护理工作台')

function onSwitchBaby(babyId) {
  nursingStore.switchBaby(babyId)
}

function handleCommand(command) {
  if (command !== 'logout') {
    return
  }
  ElMessageBox.confirm('确定退出登录吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logOut().then(() => {
      router.replace('/login')
    })
  }).catch(() => {})
}
</script>

<style scoped lang="scss">
.m-topbar {
  position: sticky;
  top: 0;
  z-index: 20;
  height: 56px;
  padding: 0 12px;
  padding-top: env(safe-area-inset-top, 0px);
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: rgba(250, 245, 239, 0.94);
  backdrop-filter: blur(8px);
  border-bottom: 1px solid var(--line);
}

.brand {
  display: flex;
  align-items: center;
  gap: 8px;
  min-width: 0;
}

.logo {
  width: 28px;
  height: 28px;
  border-radius: 8px;
}

.name {
  font-weight: 600;
  color: var(--pri-deep);
  font-size: 15px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 42vw;
}

.right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.baby-switcher {
  width: 108px;
}

.avatar-hit {
  display: flex;
}

.avatar {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}
</style>
