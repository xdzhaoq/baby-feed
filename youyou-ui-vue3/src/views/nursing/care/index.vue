<template>
  <div class="app-container">
    <nursing-baby-guide />

    <template v-if="nursingStore.currentBabyId">
      <el-form :inline="true" class="mb8">
        <el-form-item label="日期">
          <el-date-picker v-model="careDate" type="date" value-format="YYYY-MM-DD" @change="loadList" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:care:add']">自定义事项</el-button>
        </el-form-item>
      </el-form>

      <el-card shadow="never" v-loading="loading">
        <el-empty v-if="!itemList.length" description="暂无护理事项" />
        <div v-for="item in itemList" :key="item.itemId" class="care-row">
          <el-checkbox
            :model-value="item.completed === '1'"
            :disabled="!checkPermi(['nursing:care:edit'])"
            @change="val => onToggle(item, val)"
          >
            <span :class="{ done: item.completed === '1' }">{{ item.itemName }}</span>
          </el-checkbox>
          <el-tag v-if="isBuiltin(item)" size="small" type="info">内置</el-tag>
          <span v-if="item.completed === '1'" class="meta">
            {{ parseTime(item.completeTime) }} · {{ item.operatorName }}
          </span>
          <el-button
            class="care-del"
            link
            type="danger"
            icon="Delete"
            @click="handleDelete(item)"
            v-hasPermi="['nursing:care:remove', 'nursing:care:edit']"
          >删除</el-button>
        </div>
      </el-card>
    </template>

    <el-dialog title="新增自定义事项" v-model="open" width="420px" append-to-body>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="80px">
        <el-form-item label="名称" prop="itemName">
          <el-input v-model="form.itemName" placeholder="如：户外晒太阳" maxlength="50" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="open = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingCare">
import { listCareToday, addCareItem, toggleCare, delCareItem } from "@/api/nursing/care";
import { nowDate } from "@/utils/nursingLock";
import { checkPermi } from "@/utils/permission";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const nursingStore = useNursingStore();
const itemList = ref([]);
const loading = ref(false);
const open = ref(false);
const careDate = ref(nowDate());
const form = ref({ itemName: "" });
const rules = { itemName: [{ required: true, message: "事项名称不能为空", trigger: "blur" }] };

function loadList() {
  if (!nursingStore.currentBabyId) {
    itemList.value = [];
    return;
  }
  loading.value = true;
  listCareToday({ babyId: nursingStore.currentBabyId, careDate: careDate.value }).then(res => {
    itemList.value = res.data || [];
  }).finally(() => { loading.value = false; });
}

function onToggle(item, checked) {
  toggleCare({
    babyId: nursingStore.currentBabyId,
    itemId: item.itemId,
    careDate: careDate.value,
    completed: checked ? "1" : "0"
  }).then(() => {
    loadList();
  }).catch(() => {});
}

function handleAdd() {
  form.value = { itemName: "" };
  open.value = true;
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    addCareItem({ babyId: nursingStore.currentBabyId, itemName: form.value.itemName }).then(() => {
      proxy.$modal.msgSuccess("已添加");
      open.value = false;
      loadList();
    });
  });
}

function isBuiltin(item) {
  return item.babyId == null || String(item.isBuiltin || "").trim() === "1";
}

function handleDelete(item) {
  const tip = isBuiltin(item)
    ? '确认从本宝宝清单中移除「' + item.itemName + '」？系统模板仍保留，不影响其他宝宝。'
    : '确认删除自定义事项「' + item.itemName + '」？';
  proxy.$modal.confirm(tip).then(() => {
    return delCareItem(item.itemId, nursingStore.currentBabyId);
  }).then(() => {
    proxy.$modal.msgSuccess("已删除");
    loadList();
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => loadList());
loadList();
</script>

<style scoped>
.care-row { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
.care-row:last-child { border-bottom: none; }
.done { text-decoration: line-through; color: #909399; }
.meta { color: #909399; font-size: 12px; }
.care-del { margin-left: auto; }
</style>
