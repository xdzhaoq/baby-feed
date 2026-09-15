<template>
  <el-drawer
    v-model="visible"
    direction="btt"
    size="auto"
    :with-header="false"
    class="quick-drawer"
    append-to-body
  >
    <div class="sheet">
      <div class="grab" />
      <div class="sheet-title">记一笔</div>
      <div v-if="!nursingStore.currentBabyId" class="empty">请先选择宝宝</div>
      <template v-else>
        <div class="types">
          <button
            v-for="item in types"
            :key="item.value"
            type="button"
            class="type-btn"
            :class="{ active: kind === item.value }"
            @click="kind = item.value"
          >
            {{ item.label }}
          </button>
        </div>

        <el-form ref="formRef" :model="form" :rules="rules" label-position="top" class="sheet-form">
          <template v-if="kind === 'feeding'">
            <el-form-item label="时间" prop="feedTime">
              <nursing-date-time v-model="form.feedTime" />
            </el-form-item>
            <el-form-item label="方式" prop="feedMethod">
              <el-select v-model="form.feedMethod" style="width: 100%">
                <el-option v-for="dict in nc_feed_method" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item v-if="form.feedMethod && form.feedMethod !== 'breast'" label="奶量 ml">
              <el-input-number v-model="form.amountMl" :min="0" :step="5" controls-position="right" style="width: 100%" />
            </el-form-item>
            <el-form-item label="时长（分）">
              <el-input-number v-model="form.durationMin" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.notes" type="textarea" :rows="2" />
            </el-form-item>
          </template>

          <template v-else-if="kind === 'sleep'">
            <el-form-item label="入睡" prop="startTime">
              <nursing-date-time v-model="form.startTime" />
            </el-form-item>
            <el-form-item label="醒来（可空）">
              <nursing-date-time v-model="form.endTime" />
            </el-form-item>
            <el-form-item label="类型" prop="sleepType">
              <el-select v-model="form.sleepType" style="width: 100%">
                <el-option v-for="dict in nc_sleep_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.notes" type="textarea" :rows="2" />
            </el-form-item>
          </template>

          <template v-else-if="kind === 'diaper'">
            <el-form-item label="时间" prop="recordTime">
              <nursing-date-time v-model="form.recordTime" />
            </el-form-item>
            <el-form-item label="类型" prop="diaperType">
              <el-select v-model="form.diaperType" style="width: 100%">
                <el-option v-for="dict in nc_diaper_type" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item v-if="form.diaperType !== 'pee'" label="大便性状">
              <el-select v-model="form.stoolTexture" clearable style="width: 100%">
                <el-option v-for="dict in nc_stool_texture" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.notes" type="textarea" :rows="2" />
            </el-form-item>
          </template>

          <template v-else>
            <el-form-item label="开始" prop="cryStart">
              <nursing-date-time v-model="form.cryStart" />
            </el-form-item>
            <el-form-item label="程度" prop="intensity">
              <el-select v-model="form.intensity" style="width: 100%">
                <el-option v-for="dict in nc_cry_intensity" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
            <el-form-item label="可能原因">
              <el-input v-model="form.possibleCause" placeholder="饥饿、胀气、尿布…" />
            </el-form-item>
            <el-form-item label="备注">
              <el-input v-model="form.notes" type="textarea" :rows="2" />
            </el-form-item>
          </template>
        </el-form>

        <el-button type="primary" class="submit" :loading="saving" @click="submit">保存</el-button>
      </template>
    </div>
  </el-drawer>
</template>

<script setup>
import { ElMessage } from 'element-plus'
import NursingDateTime from '@/components/NursingDateTime/index.vue'
import { addFeeding } from '@/api/nursing/feeding'
import { addSleep } from '@/api/nursing/sleep'
import { addDiaper } from '@/api/nursing/diaper'
import { addCry } from '@/api/nursing/cry'
import { nowDateTime } from '@/utils/nursingLock'
import useNursingStore from '@/store/modules/nursing'

const props = defineProps({
  modelValue: { type: Boolean, default: false }
})
const emit = defineEmits(['update:modelValue'])

const { proxy } = getCurrentInstance()
const { nc_feed_method, nc_sleep_type, nc_diaper_type, nc_stool_texture, nc_cry_intensity } = proxy.useDict(
  'nc_feed_method',
  'nc_sleep_type',
  'nc_diaper_type',
  'nc_stool_texture',
  'nc_cry_intensity'
)
const nursingStore = useNursingStore()
const formRef = ref()
const kind = ref('feeding')
const saving = ref(false)
const form = ref(emptyForm())

const types = [
  { value: 'feeding', label: '喂养' },
  { value: 'sleep', label: '睡眠' },
  { value: 'diaper', label: '尿布' },
  { value: 'cry', label: '哭闹' }
]

const visible = computed({
  get: () => props.modelValue,
  set: val => emit('update:modelValue', val)
})

const rules = computed(() => {
  if (kind.value === 'sleep') {
    return {
      startTime: [{ required: true, message: '请选择入睡时间', trigger: 'change' }],
      sleepType: [{ required: true, message: '请选择类型', trigger: 'change' }]
    }
  }
  if (kind.value === 'diaper') {
    return {
      recordTime: [{ required: true, message: '请选择时间', trigger: 'change' }],
      diaperType: [{ required: true, message: '请选择类型', trigger: 'change' }]
    }
  }
  if (kind.value === 'cry') {
    return {
      cryStart: [{ required: true, message: '请选择开始时间', trigger: 'change' }],
      intensity: [{ required: true, message: '请选择程度', trigger: 'change' }]
    }
  }
  return {
    feedTime: [{ required: true, message: '请选择时间', trigger: 'change' }],
    feedMethod: [{ required: true, message: '请选择方式', trigger: 'change' }]
  }
})

watch(() => props.modelValue, open => {
  if (open) {
    kind.value = 'feeding'
    form.value = emptyForm()
  }
})

function emptyForm() {
  const now = nowDateTime()
  return {
    feedTime: now,
    feedMethod: 'breast',
    amountMl: undefined,
    durationMin: undefined,
    startTime: now,
    endTime: undefined,
    sleepType: 'nap',
    recordTime: now,
    diaperType: 'pee',
    stoolTexture: undefined,
    cryStart: now,
    intensity: 'mild',
    possibleCause: undefined,
    notes: undefined
  }
}

function submit() {
  formRef.value?.validate(valid => {
    if (!valid) {
      return
    }
    if (!nursingStore.currentBabyId) {
      ElMessage.warning('请先选择宝宝')
      return
    }
    saving.value = true
    const babyId = nursingStore.currentBabyId
    let req
    if (kind.value === 'sleep') {
      req = addSleep({
        babyId,
        startTime: form.value.startTime,
        endTime: form.value.endTime,
        sleepType: form.value.sleepType,
        notes: form.value.notes
      })
    } else if (kind.value === 'diaper') {
      req = addDiaper({
        babyId,
        recordTime: form.value.recordTime,
        diaperType: form.value.diaperType,
        stoolTexture: form.value.stoolTexture,
        notes: form.value.notes
      })
    } else if (kind.value === 'cry') {
      req = addCry({
        babyId,
        startTime: form.value.cryStart,
        intensity: form.value.intensity,
        possibleCause: form.value.possibleCause,
        notes: form.value.notes
      })
    } else {
      req = addFeeding({
        babyId,
        feedTime: form.value.feedTime,
        feedMethod: form.value.feedMethod,
        amountMl: form.value.amountMl,
        durationMin: form.value.durationMin,
        burped: '0',
        notes: form.value.notes
      })
    }
    req.then(() => {
      ElMessage.success('已记下')
      visible.value = false
      window.dispatchEvent(new CustomEvent('nursing-saved', { detail: { kind: kind.value } }))
    }).finally(() => {
      saving.value = false
    })
  })
}
</script>

<style scoped lang="scss">
.sheet {
  padding: 8px 16px calc(16px + env(safe-area-inset-bottom, 0px));
}

.grab {
  width: 42px;
  height: 4px;
  border-radius: 4px;
  background: var(--line);
  margin: 0 auto 12px;
}

.sheet-title {
  text-align: center;
  font-weight: 700;
  margin-bottom: 12px;
  color: var(--ink);
}

.types {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 8px;
  margin-bottom: 12px;
}

.type-btn {
  height: 36px;
  border-radius: 12px;
  border: 1px solid var(--line);
  background: var(--card-2);
  color: var(--ink-2);
}

.type-btn.active {
  border-color: var(--pri);
  background: var(--pri-soft);
  color: var(--pri-deep);
  font-weight: 600;
}

.submit {
  width: 100%;
  height: 44px;
  border-radius: 12px;
}

.empty {
  text-align: center;
  color: var(--muted);
  padding: 24px 0;
}
</style>
