<template>
  <div class="app-container">
    <nursing-baby-guide />

    <template v-if="nursingStore.currentBabyId">
      <el-card shadow="never" class="mb8">
        <template #header>体重曲线（kg）</template>
        <div ref="chartRef" style="height: 280px" />
      </el-card>

      <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
        <el-form-item label="测量日期">
          <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
          <el-button icon="Refresh" @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
      <el-row :gutter="10" class="mb8">
        <el-col :span="1.5">
          <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:growth:add']">记一笔生长</el-button>
        </el-col>
        <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
      </el-row>
      <el-table v-loading="loading" :data="recordList">
        <el-table-column label="测量日期" align="center" width="120">
          <template #default="scope">{{ parseTime(scope.row.measureDate, '{y}-{m}-{d}') }}</template>
        </el-table-column>
        <el-table-column label="体重kg" align="center" prop="weightKg" width="100" />
        <el-table-column label="身长cm" align="center" prop="heightCm" width="100" />
        <el-table-column label="头围cm" align="center" prop="headCm" width="100" />
        <el-table-column label="操作人" prop="operatorName" width="100" />
        <el-table-column label="备注" prop="notes" min-width="140" :show-overflow-tooltip="true" />
        <el-table-column label="操作" align="center" width="160">
          <template #default="scope">
            <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:growth:edit']">修改</el-button>
            <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:growth:remove']">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
    </template>

    <el-dialog :title="title" v-model="open" width="520px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="测量日期" prop="measureDate">
          <el-date-picker v-model="form.measureDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" />
        </el-form-item>
        <el-form-item label="体重 kg" prop="weightKg">
          <el-input-number v-model="form.weightKg" :min="0" :precision="3" :step="0.05" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="身长 cm" prop="heightCm">
          <el-input-number v-model="form.heightCm" :min="0" :precision="1" :step="0.5" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="头围 cm" prop="headCm">
          <el-input-number v-model="form.headCm" :min="0" :precision="1" :step="0.5" controls-position="right" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="notes">
          <el-input v-model="form.notes" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="open = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingGrowth">
import * as echarts from "echarts";
import { listGrowth, chartGrowth, getGrowth, addGrowth, updateGrowth, delGrowth } from "@/api/nursing/growth";
import { createRecordLock, nowDate } from "@/utils/nursingLock";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const nursingStore = useNursingStore();
const recordLock = createRecordLock("growth");
const chartRef = ref(null);
let chart;

const recordList = ref([]);
const open = ref(false);
const loading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");
const dateRange = ref([]);

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, babyId: undefined },
  rules: { measureDate: [{ required: true, message: "请选择测量日期", trigger: "change" }] }
});
const { queryParams, form, rules } = toRefs(data);

function getList() {
  if (!nursingStore.currentBabyId) {
    recordList.value = [];
    total.value = 0;
    return;
  }
  queryParams.value.babyId = nursingStore.currentBabyId;
  loading.value = true;
  listGrowth(proxy.addDateRange(queryParams.value, dateRange.value)).then(res => {
    recordList.value = res.rows;
    total.value = res.total;
  }).finally(() => { loading.value = false; });
  renderChart();
}

function renderChart() {
  if (!nursingStore.currentBabyId || !chartRef.value) return;
  chartGrowth(nursingStore.currentBabyId).then(res => {
    const rows = (res.data || []).slice().reverse();
    if (!chart) {
      chart = echarts.init(chartRef.value);
    }
    chart.setOption({
      tooltip: { trigger: "axis" },
      grid: { left: 40, right: 20, top: 20, bottom: 30 },
      xAxis: { type: "category", data: rows.map(r => proxy.parseTime(r.measureDate, "{y}-{m}-{d}")) },
      yAxis: { type: "value", name: "kg", min: "dataMin" },
      series: [{ name: "体重", type: "line", smooth: true, data: rows.map(r => r.weightKg) }]
    });
  });
}

function birthDefaults() {
  const baby = nursingStore.currentBaby || {};
  return {
    weightKg: baby.birthWeightKg,
    heightCm: baby.birthHeightCm,
    headCm: baby.birthHeadCm
  };
}

function reset() {
  const born = birthDefaults();
  form.value = {
    growthId: undefined,
    babyId: nursingStore.currentBabyId,
    measureDate: nowDate(),
    weightKg: born.weightKg,
    heightCm: born.heightCm,
    headCm: born.headCm,
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function onDialogClosed() { recordLock.release(); reset(); }
function handleQuery() { queryParams.value.pageNum = 1; getList(); }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery(); }
function handleAdd() { reset(); open.value = true; title.value = "记一笔生长"; }

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.growthId).then(() => getGrowth(row.growthId)).then(res => {
    form.value = res.data;
    open.value = true;
    title.value = "修改生长记录";
  }).catch(() => { recordLock.release(); });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const req = form.value.growthId != undefined ? updateGrowth(form.value) : addGrowth(form.value);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.growthId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

function handleDelete(row) {
  proxy.$modal.confirm("是否确认删除这条生长记录？").then(() => delGrowth(row.growthId)).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) open.value = false;
  handleQuery();
});
onUnmounted(() => {
  recordLock.release();
  if (chart) {
    chart.dispose();
    chart = null;
  }
});
nextTick(() => getList());
</script>
