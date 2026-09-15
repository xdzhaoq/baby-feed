import { listMineBaby } from '@/api/nursing/baby'
import { memberHeartbeat } from '@/api/nursing/member'
import useUserStore from '@/store/modules/user'

const STORAGE_KEY = 'nursing_current_baby_id'

const useNursingStore = defineStore('nursing', {
  state: () => ({
    babyList: [],
    currentBabyId: undefined
  }),
  getters: {
    currentBaby(state) {
      return state.babyList.find(item => item.babyId === state.currentBabyId) || null
    }
  },
  actions: {
    loadMine() {
      return listMineBaby().then(res => {
        this.babyList = res.data || []
        const saved = Number(localStorage.getItem(STORAGE_KEY) || 0)
        const exists = this.babyList.some(item => item.babyId === saved)
        if (exists) {
          this.currentBabyId = saved
        } else if (this.babyList.length) {
          this.currentBabyId = this.babyList[0].babyId
          localStorage.setItem(STORAGE_KEY, String(this.currentBabyId))
        } else {
          this.currentBabyId = undefined
          localStorage.removeItem(STORAGE_KEY)
        }
        return this.babyList
      })
    },
    switchBaby(babyId) {
      this.currentBabyId = babyId ? Number(babyId) : undefined
      if (this.currentBabyId) {
        localStorage.setItem(STORAGE_KEY, String(this.currentBabyId))
      } else {
        localStorage.removeItem(STORAGE_KEY)
      }
    },
    heartbeat() {
      if (!this.currentBabyId) {
        return Promise.resolve()
      }
      const user = useUserStore()
      if (Number(user.id) === 1) {
        return Promise.resolve()
      }
      return memberHeartbeat(this.currentBabyId).catch(() => {})
    },
    reset() {
      this.babyList = []
      this.currentBabyId = undefined
      localStorage.removeItem(STORAGE_KEY)
    }
  }
})

export default useNursingStore
