<template>
  <input
    v-if="useNative"
    class="native-datetime"
    type="datetime-local"
    :value="nativeValue"
    :disabled="disabled"
    @change="onNativeChange"
  />
  <el-date-picker
    v-else
    :model-value="modelValue"
    type="datetime"
    value-format="YYYY-MM-DD HH:mm:ss"
    :placeholder="placeholder"
    :disabled="disabled"
    :clearable="clearable"
    style="width: 100%"
    popper-class="nursing-datetime-popper"
    @update:model-value="emit('update:modelValue', $event)"
  />
</template>

<script setup>
import { isNativeApp } from '@/utils/apiBase'

const props = defineProps({
  modelValue: { type: String, default: undefined },
  placeholder: { type: String, default: '选择时间' },
  disabled: { type: Boolean, default: false },
  clearable: { type: Boolean, default: true }
})
const emit = defineEmits(['update:modelValue'])

const useNative = computed(() => isNativeApp() || (typeof window !== 'undefined' && window.innerWidth < 960))

const nativeValue = computed(() => toNative(props.modelValue))

function toNative(value) {
  if (!value) {
    return ''
  }
  return String(value).replace(' ', 'T').slice(0, 16)
}

function onNativeChange(event) {
  const raw = event.target.value
  if (!raw) {
    emit('update:modelValue', props.clearable ? undefined : props.modelValue)
    return
  }
  emit('update:modelValue', raw.replace('T', ' ') + ':00')
}
</script>

<style scoped>
.native-datetime {
  width: 100%;
  height: 40px;
  padding: 0 12px;
  border: 1px solid var(--line);
  border-radius: 12px;
  background: #fbf8f5;
  color: var(--ink);
  font-size: 16px;
  line-height: 40px;
  box-sizing: border-box;
}
.native-datetime:disabled {
  opacity: 0.6;
}
</style>
