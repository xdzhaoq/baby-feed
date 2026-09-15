<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-form v-if="nursingStore.currentBabyId" :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="类型" prop="diaperType">
        <el-select v-model="queryParams.diaperType" placeholder="全部" clearable style="width: 120px">
          <el-option v-for="dict in nc_diaper_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="性状" prop="stoolTexture">
        <el-select v-model="queryParams.stoolTexture" placeholder="全部" clearable style="width: 140px">
          <el-option v-for="dict in nc_stool_texture" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="时间">
        <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" v-if="nursingStore.currentBabyId">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:diaper:add']">记一笔尿布</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-row v-if="nursingStore.currentBabyId" :gutter="16" class="mb8">
      <el-col :span="8">
        <el-card shadow="never">
          <div class="label">今日次数</div>
          <div class="value">{{ todayCount }}</div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="never">
          <div class="label">今日异常性状</div>
          <div class="value" :class="{ danger: todayAbnormal > 0 }">{{ todayAbnormal }}</div>
        </el-card>
      </el-col>
    </el-row>
    <el-card v-if="nursingStore.currentBabyId" shadow="never" class="mb8">
      <template #header>近 7 天小便 / 大便</template>
      <div ref="chartRef" style="height: 240px" />
    </el-card>

    <el-table v-if="nursingStore.currentBabyId" v-loading="loading" :data="recordList" :row-class-name="diaperRowClass">
      <el-table-column label="时间" align="center" prop="recordTime" width="170">
        <template #default="scope"><span>{{ parseTime(scope.row.recordTime) }}</span></template>
      </el-table-column>
      <el-table-column label="类型" align="center" width="100">
        <template #default="scope">
          <dict-tag :options="nc_diaper_type" :value="scope.row.diaperType" />
        </template>
      </el-table-column>
      <el-table-column label="大便性状" align="center" width="130">
        <template #default="scope">
          <span :class="{ 'is-abnormal': isAbnormalStool(scope.row.stoolTexture) }">
            <dict-tag v-if="scope.row.stoolTexture" :options="nc_stool_texture" :value="scope.row.stoolTexture" />
            <span v-else>—</span>
          </span>
        </template>
      </el-table-column>
      <el-table-column label="操作人" width="120">
        <template #default="scope">
          <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
        </template>
      </el-table-column>
      <el-table-column label="备注" prop="notes" min-width="140" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" width="160">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:diaper:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:diaper:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="520px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="时间" prop="recordTime">
          <el-date-picker v-model="form.recordTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="选择时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="类型" prop="diaperType">
          <el-select v-model="form.diaperType" placeholder="请选择" style="width: 100%">
            <el-option v-for="dict in nc_diaper_type" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.diaperType !== 'pee'" label="大便性状" prop="stoolTexture">
          <el-select v-model="form.stoolTexture" placeholder="请选择" style="width: 100%">
            <el-option v-for="dict in nc_stool_texture" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="notes">
          <el-input v-model="form.notes" type="textarea" :rows="2" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingDiaper">
import { listDiaper, getDiaper, addDiaper, updateDiaper, delDiaper, chartDiaper } from "@/api/nursing/diaper";
import { createRecordLock, nowDateTime } from "@/utils/nursingLock";
import { axisDates, bindChart, disposeChart, isAbnormalStool, lineBarOption, nameInitial } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_diaper_type, nc_stool_texture } = proxy.useDict("nc_diaper_type", "nc_stool_texture");
const nursingStore = useNursingStore();
const recordLock = createRecordLock("diaper");

const recordList = ref([]);
const open = ref(false);
const loading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");
const dateRange = ref([]);
const todayCount = ref(0);
const todayAbnormal = ref(0);
const chartRef = ref(null);
let chart = null;

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    babyId: undefined,
    diaperType: undefined,
    stoolTexture: undefined
  },
  rules: {
    recordTime: [{ required: true, message: "时间不能为空", trigger: "change" }],
    diaperType: [{ required: true, message: "请选择类型", trigger: "change" }]
  }
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
  listDiaper(proxy.addDateRange(queryParams.value, dateRange.value)).then(response => {
    recordList.value = response.rows;
    total.value = response.total;
  }).finally(() => {
    loading.value = false;
  });
  renderChart();
}

function renderChart() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  chartDiaper(nursingStore.currentBabyId, 7).then(res => {
    const data = res.data || {};
    todayCount.value = data.todayCount || 0;
    todayAbnormal.value = data.todayAbnormal || 0;
    const rows = data.days || [];
    nextTick(() => {
      chart = bindChart(chartRef.value, chart);
      if (!chart) {
        return;
      }
      chart.setOption(lineBarOption(axisDates(rows), [
        { name: "小便", type: "bar", stack: "d", data: rows.map(item => item.count || 0) },
        { name: "大便", type: "bar", stack: "d", data: rows.map(item => item.extra || 0) }
      ], "次"));
    });
  });
}

function diaperRowClass({ row }) {
  return isAbnormalStool(row.stoolTexture) ? "row-abnormal" : "";
}

function reset() {
  form.value = {
    diaperId: undefined,
    babyId: nursingStore.currentBabyId,
    recordTime: nowDateTime(),
    diaperType: "pee",
    stoolTexture: undefined,
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function cancel() { open.value = false; }
function onDialogClosed() { recordLock.release(); reset(); }
function handleQuery() { queryParams.value.pageNum = 1; getList(); }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery(); }
function handleAdd() { reset(); open.value = true; title.value = "记一笔尿布"; }

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.diaperId).then(() => getDiaper(row.diaperId)).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改尿布记录";
  }).catch(() => { recordLock.release(); });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const req = form.value.diaperId != undefined ? updateDiaper(form.value) : addDiaper(form.value);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.diaperId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

function handleDelete(row) {
  proxy.$modal.confirm("是否确认删除这条尿布记录？").then(() => delDiaper(row.diaperId)).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) cancel();
  handleQuery();
});
onUnmounted(() => { recordLock.release(); chart = disposeChart(chart); });
getList();
</script>

<style scoped>
.label { color: #9a8a7d; font-size: 13px; }
.value { font-size: 26px; font-weight: 600; margin-top: 6px; }
.danger { color: #c4574f; }
:deep(.row-abnormal) { background: #f8e0dc !important; }
.is-abnormal { font-weight: 600; }
</style>
