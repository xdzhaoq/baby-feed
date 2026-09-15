<template>
  <div class="navbar">
    <hamburger id="hamburger-container" :is-active="appStore.sidebar.opened" class="hamburger-container" @toggleClick="toggleSideBar" />
    <breadcrumb id="breadcrumb-container" class="breadcrumb-container" v-if="!settingsStore.topNav" />
    <top-nav id="topmenu-container" class="topmenu-container" v-if="settingsStore.topNav" />

    <div class="right-menu">
      <router-link v-if="nursingStore.currentBabyId" to="/daily/feeding" class="quick-add">+ 记一笔</router-link>
      <el-select
        v-if="nursingStore.babyList.length"
        class="baby-switcher"
        :model-value="nursingStore.currentBabyId"
        placeholder="当前宝宝"
        @change="onSwitchBaby"
      >
        <el-option
          v-for="item in nursingStore.babyList"
          :key="item.babyId"
          :label="item.babyName"
          :value="item.babyId"
        />
      </el-select>
      <router-link v-else-if="canCreateBaby" to="/overview/baby" class="baby-empty">还没有宝宝，去建档案</router-link>
      <span v-else class="baby-empty">还没有可照看的宝宝</span>
      <template v-if="appStore.device !== 'mobile'">
        <header-search id="header-search" class="right-menu-item" />
        <screenfull id="screenfull" class="right-menu-item hover-effect" />
      </template>
      <div class="avatar-container">
        <el-dropdown @command="handleCommand" class="right-menu-item hover-effect" trigger="click">
          <div class="avatar-wrapper">
            <img :src="userStore.avatar" class="user-avatar" />
            <el-icon><caret-bottom /></el-icon>
          </div>
          <template #dropdown>
            <el-dropdown-menu>
              <router-link to="/user/profile">
                <el-dropdown-item>个人中心</el-dropdown-item>
              </router-link>
              <el-dropdown-item command="setLayout" v-if="settingsStore.showSettings">
                <span>布局设置</span>
              </el-dropdown-item>
              <el-dropdown-item divided command="logout">
                <span>退出登录</span>
              </el-dropdown-item>
            </el-dropdown-menu>
          </template>
        </el-dropdown>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ElMessageBox } from 'element-plus'
import Breadcrumb from '@/components/Breadcrumb'
import TopNav from '@/components/TopNav'
import Hamburger from '@/components/Hamburger'
import Screenfull from '@/components/Screenfull'
import HeaderSearch from '@/components/HeaderSearch'
import { onMounted, onUnmounted } from 'vue'
import useAppStore from '@/store/modules/app'
import useUserStore from '@/store/modules/user'
import useSettingsStore from '@/store/modules/settings'
import useNursingStore from '@/store/modules/nursing'
import { checkPermi } from '@/utils/permission'

const appStore = useAppStore()
const userStore = useUserStore()
const settingsStore = useSettingsStore()
const nursingStore = useNursingStore()
const canCreateBaby = computed(() => checkPermi(['nursing:baby:add']))

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

function onSwitchBaby(babyId) {
  nursingStore.switchBaby(babyId)
}

function toggleSideBar() {
  appStore.toggleSideBar()
}

function handleCommand(command) {
  switch (command) {
    case "setLayout":
      setLayout();
      break;
    case "logout":
      logout();
      break;
    default:
      break;
  }
}

function logout() {
  ElMessageBox.confirm('确定注销并退出系统吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    userStore.logOut().then(() => {
      location.href = '/index';
    })
  }).catch(() => { });
}

const emits = defineEmits(['setLayout'])
function setLayout() {
  emits('setLayout');
}
</script>

<style lang='scss' scoped>
.navbar {
  height: 50px;
  overflow: hidden;
  position: relative;
  background: rgba(250, 245, 239, 0.92);
  backdrop-filter: blur(8px);
  box-shadow: none;
  border-bottom: 1px solid #efe3d6;

  .hamburger-container {
    line-height: 46px;
    height: 100%;
    float: left;
    cursor: pointer;
    transition: background 0.3s;
    -webkit-tap-highlight-color: transparent;

    &:hover {
      background: rgba(0, 0, 0, 0.025);
    }
  }

  .breadcrumb-container {
    float: left;
  }

  .topmenu-container {
    position: absolute;
    left: 50px;
  }

  .errLog-container {
    display: inline-block;
    vertical-align: top;
  }

  .quick-add {
    align-self: center;
    margin-right: 10px;
    padding: 6px 14px;
    border-radius: 999px;
    background: #de8f74;
    color: #fff;
    font-size: 13px;
    line-height: 1.2;
    text-decoration: none;
  }
  .baby-switcher {
    width: 168px;
    margin: 9px 12px 0 0;
  }
  .baby-empty {
    align-self: center;
    margin-right: 12px;
    color: #c96f52;
    font-size: 13px;
    text-decoration: none;
  }

  .right-menu {
    float: right;
    height: 100%;
    line-height: 50px;
    display: flex;

    &:focus {
      outline: none;
    }

    .right-menu-item {
      display: inline-block;
      padding: 0 8px;
      height: 100%;
      font-size: 18px;
      color: #5a5e66;
      vertical-align: text-bottom;

      &.hover-effect {
        cursor: pointer;
        transition: background 0.3s;

        &:hover {
          background: rgba(0, 0, 0, 0.025);
        }
      }
    }

    .avatar-container {
      margin-right: 40px;

      .avatar-wrapper {
        margin-top: 5px;
        position: relative;

        .user-avatar {
          cursor: pointer;
          width: 40px;
          height: 40px;
          border-radius: 10px;
        }

        i {
          cursor: pointer;
          position: absolute;
          right: -20px;
          top: 25px;
          font-size: 12px;
        }
      }
    }
  }
}
</style>
