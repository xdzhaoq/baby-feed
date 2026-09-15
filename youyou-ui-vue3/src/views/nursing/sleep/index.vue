<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-form v-if="nursingStore.currentBabyId" :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="类型" prop="sleepType">
        <el-select v-model="queryParams.sleepType" placeholder="全部" clearable style="width: 140px">
          <el-option v-for="dict in nc_sleep_type" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="入睡日期">
        <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button-group>
          <el-button :type="rangeKind === 'today' ? 'primary' : ''" @click="applyRange('today')">今日</el-button>
          <el-button :type="rangeKind === 'week' ? 'primary' : ''" @click="applyRange('week')">近7天</el-button>
        </el-button-group>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" v-if="nursingStore.currentBabyId">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:sleep:add']">记一笔睡眠</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-card v-if="nursingStore.currentBabyId" shadow="never" class="mb8">
      <template #header>每日睡眠时长（小时）</template>
      <div ref="chartRef" style="height: 240px" />
    </el-card>

    <el-table v-if="nursingStore.currentBabyId" v-loading="loading" :data="recordList">
      <el-table-column label="入睡" align="center" prop="startTime" width="170">
        <template #default="scope"><span>{{ parseTime(scope.row.startTime) }}</span></template>
      </el-table-column>
      <el-table-column label="醒来" align="center" prop="endTime" width="170">
        <template #default="scope"><span>{{ scope.row.endTime ? parseTime(scope.row.endTime) : '进行中' }}</span></template>
      </el-table-column>
      <el-table-column label="类型" align="center" width="110">
        <template #default="scope">
          <dict-tag :options="nc_sleep_type" :value="scope.row.sleepType" />
        </template>
      </el-table-column>
      <el-table-column label="时长" align="center" width="110">
        <template #default="scope">{{ scope.row.endTime ? formatMinutes(scope.row.durationMin) : '进行中' }}</template>
      </el-table-column>
      <el-table-column label="操作人" width="120">
        <template #default="scope">
          <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
        </template>
      </el-table-column>
      <el-table-column label="备注" prop="notes" min-width="140" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" width="160">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:sleep:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:sleep:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="560px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="入睡时间" prop="startTime">
          <el-date-picker v-model="form.startTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="选择时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="醒来时间" prop="endTime">
          <el-date-picker v-model="form.endTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="未醒可留空" style="width: 100%" />
        </el-form-item>
        <el-form-item label="类型" prop="sleepType">
          <el-select v-model="form.sleepType" placeholder="请选择" style="width: 100%">
            <el-option v-for="dict in nc_sleep_type" :key="dict.value" :label="dict.label" :value="dict.value" />
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

<script setup name="NursingSleep">
import { listSleep, getSleep, addSleep, updateSleep, delSleep, chartSleep } from "@/api/nursing/sleep";
import { createRecordLock, formatMinutes, nowDateTime, dateRangeOf } from "@/utils/nursingLock";
import { axisDates, bindChart, disposeChart, lineBarOption, nameInitial } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_sleep_type } = proxy.useDict("nc_sleep_type");
const nursingStore = useNursingStore();
const recordLock = createRecordLock("sleep");

const recordList = ref([]);
const open = ref(false);
const loading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");
const dateRange = ref([]);
const rangeKind = ref("week");
const chartRef = ref(null);
let chart = null;

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    babyId: undefined,
    sleepType: undefined
  },
  rules: {
    startTime: [{ required: true, message: "入睡时间不能为空", trigger: "change" }],
    sleepType: [{ required: true, message: "请选择睡眠类型", trigger: "change" }]
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
  listSleep(proxy.addDateRange(queryParams.value, dateRange.value)).then(response => {
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
  chartSleep(nursingStore.currentBabyId, 7).then(res => {
    const rows = res.data || [];
    nextTick(() => {
      chart = bindChart(chartRef.value, chart);
      if (!chart) {
        return;
      }
      chart.setOption(lineBarOption(axisDates(rows), [
        { name: "小时", type: "line", smooth: true, areaStyle: { opacity: 0.15 }, data: rows.map(item => item.amount || 0) }
      ], "小时"));
    });
  });
}

function applyRange(kind) {
  rangeKind.value = kind;
  dateRange.value = dateRangeOf(kind);
  handleQuery();
}

function reset() {
  form.value = {
    sleepId: undefined,
    babyId: nursingStore.currentBabyId,
    startTime: nowDateTime(),
    endTime: undefined,
    sleepType: "nap",
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function cancel() { open.value = false; }
function onDialogClosed() { recordLock.release(); reset(); }
function handleQuery() { queryParams.value.pageNum = 1; getList(); }
function resetQuery() { dateRange.value = []; rangeKind.value = "all"; proxy.resetForm("queryRef"); handleQuery(); }
function handleAdd() { reset(); open.value = true; title.value = "记一笔睡眠"; }

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.sleepId).then(() => getSleep(row.sleepId)).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改睡眠记录";
  }).catch(() => { recordLock.release(); });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const req = form.value.sleepId != undefined ? updateSleep(form.value) : addSleep(form.value);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.sleepId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

function handleDelete(row) {
  proxy.$modal.confirm("是否确认删除这条睡眠记录？").then(() => delSleep(row.sleepId)).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) cancel();
  handleQuery();
});
onUnmounted(() => { recordLock.release(); chart = disposeChart(chart); });
applyRange("week");
</script>
