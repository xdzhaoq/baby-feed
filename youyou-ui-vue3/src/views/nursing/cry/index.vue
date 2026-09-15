<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-form v-if="nursingStore.currentBabyId" :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="程度" prop="intensity">
        <el-select v-model="queryParams.intensity" placeholder="全部" clearable style="width: 120px">
          <el-option v-for="dict in nc_cry_intensity" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item label="开始日期">
        <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" v-if="nursingStore.currentBabyId">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:cry:add']">记一笔哭闹</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-row v-if="nursingStore.currentBabyId" :gutter="16" class="mb8">
      <el-col :xs="24" :md="14">
        <el-card shadow="never">
          <template #header>近 14 天哭闹高峰时段</template>
          <div ref="hourChartRef" style="height: 240px" />
        </el-card>
      </el-col>
      <el-col :xs="24" :md="10">
        <el-card shadow="never">
          <template #header>安抚方式成功率</template>
          <div ref="sootheChartRef" style="height: 240px" />
        </el-card>
      </el-col>
    </el-row>

    <el-table v-if="nursingStore.currentBabyId" v-loading="loading" :data="recordList">
      <el-table-column label="开始" align="center" prop="startTime" width="170">
        <template #default="scope"><span>{{ parseTime(scope.row.startTime) }}</span></template>
      </el-table-column>
      <el-table-column label="结束" align="center" prop="endTime" width="170">
        <template #default="scope"><span>{{ scope.row.endTime ? parseTime(scope.row.endTime) : '进行中' }}</span></template>
      </el-table-column>
      <el-table-column label="程度" align="center" width="100">
        <template #default="scope">
          <dict-tag :options="nc_cry_intensity" :value="scope.row.intensity" />
        </template>
      </el-table-column>
      <el-table-column label="可能原因" prop="possibleCause" min-width="120" :show-overflow-tooltip="true" />
      <el-table-column label="安抚效果" align="center" width="110">
        <template #default="scope">
          <dict-tag v-if="scope.row.sootheEffect" :options="nc_soothe_effect" :value="scope.row.sootheEffect" />
        </template>
      </el-table-column>
      <el-table-column label="操作人" width="120">
        <template #default="scope">
          <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" width="160">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:cry:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:cry:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="620px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="开始时间" prop="startTime">
          <el-date-picker v-model="form.startTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="选择时间" style="width: 100%" />
        </el-form-item>
        <el-form-item label="结束时间" prop="endTime">
          <el-date-picker v-model="form.endTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="未结束可留空" style="width: 100%" />
        </el-form-item>
        <el-form-item label="程度" prop="intensity">
          <el-select v-model="form.intensity" placeholder="请选择" style="width: 100%">
            <el-option v-for="dict in nc_cry_intensity" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="可能原因" prop="possibleCause">
          <el-input v-model="form.possibleCause" placeholder="如：饥饿、胀气、尿布" />
        </el-form-item>
        <el-form-item label="安抚方式" prop="sootheMethodList">
          <el-checkbox-group v-model="form.sootheMethodList">
            <el-checkbox v-for="dict in nc_soothe_method" :key="dict.value" :value="dict.value">{{ dict.label }}</el-checkbox>
          </el-checkbox-group>
        </el-form-item>
        <el-form-item label="安抚效果" prop="sootheEffect">
          <el-select v-model="form.sootheEffect" placeholder="请选择" clearable style="width: 100%">
            <el-option v-for="dict in nc_soothe_effect" :key="dict.value" :label="dict.label" :value="dict.value" />
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

<script setup name="NursingCry">
import { listCry, getCry, addCry, updateCry, delCry, chartCry } from "@/api/nursing/cry";
import { createRecordLock, nowDateTime } from "@/utils/nursingLock";
import { bindChart, disposeChart, lineBarOption, nameInitial, sootheRate } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_cry_intensity, nc_soothe_effect, nc_soothe_method } = proxy.useDict("nc_cry_intensity", "nc_soothe_effect", "nc_soothe_method");
const nursingStore = useNursingStore();
const recordLock = createRecordLock("cry");

const recordList = ref([]);
const open = ref(false);
const loading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");
const dateRange = ref([]);
const hourChartRef = ref(null);
const sootheChartRef = ref(null);
let hourChart = null;
let sootheChart = null;

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    babyId: undefined,
    intensity: undefined
  },
  rules: {
    startTime: [{ required: true, message: "开始时间不能为空", trigger: "change" }],
    intensity: [{ required: true, message: "请选择程度", trigger: "change" }]
  }
});
const { queryParams, form, rules } = toRefs(data);

function splitMethods(value) {
  return value ? String(value).split(",").filter(Boolean) : [];
}

function getList() {
  if (!nursingStore.currentBabyId) {
    recordList.value = [];
    total.value = 0;
    return;
  }
  queryParams.value.babyId = nursingStore.currentBabyId;
  loading.value = true;
  listCry(proxy.addDateRange(queryParams.value, dateRange.value)).then(response => {
    recordList.value = response.rows;
    total.value = response.total;
  }).finally(() => {
    loading.value = false;
  });
  renderChart();
}

function methodLabel(code) {
  const hit = (nc_soothe_method.value || []).find(item => item.value === code);
  return hit ? hit.label : code;
}

function renderChart() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  chartCry(nursingStore.currentBabyId, 14).then(res => {
    const data = res.data || {};
    const hours = data.hours || [];
    const soothe = data.soothe || [];
    nextTick(() => {
      hourChart = bindChart(hourChartRef.value, hourChart);
      if (hourChart) {
        hourChart.setOption(lineBarOption(hours.map(item => item.label + "时"), [
          { name: "次数", type: "bar", data: hours.map(item => item.count || 0) }
        ], "次"));
      }
      sootheChart = bindChart(sootheChartRef.value, sootheChart);
      if (sootheChart) {
        sootheChart.setOption(lineBarOption(soothe.map(item => methodLabel(item.label)), [
          { name: "成功率%", type: "bar", data: soothe.map(item => sootheRate(item)) }
        ], "%"));
      }
    });
  });
}

function reset() {
  form.value = {
    cryId: undefined,
    babyId: nursingStore.currentBabyId,
    startTime: nowDateTime(),
    endTime: undefined,
    intensity: "mild",
    possibleCause: undefined,
    sootheMethods: undefined,
    sootheMethodList: [],
    sootheEffect: undefined,
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function cancel() { open.value = false; }
function onDialogClosed() { recordLock.release(); reset(); }
function handleQuery() { queryParams.value.pageNum = 1; getList(); }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery(); }
function handleAdd() { reset(); open.value = true; title.value = "记一笔哭闹"; }

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.cryId).then(() => getCry(row.cryId)).then(response => {
    form.value = { ...response.data, sootheMethodList: splitMethods(response.data.sootheMethods) };
    open.value = true;
    title.value = "修改哭闹记录";
  }).catch(() => { recordLock.release(); });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const payload = { ...form.value, sootheMethods: (form.value.sootheMethodList || []).join(",") };
    delete payload.sootheMethodList;
    const req = form.value.cryId != undefined ? updateCry(payload) : addCry(payload);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.cryId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

function handleDelete(row) {
  proxy.$modal.confirm("是否确认删除这条哭闹记录？").then(() => delCry(row.cryId)).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) cancel();
  handleQuery();
});
onUnmounted(() => {
  recordLock.release();
  hourChart = disposeChart(hourChart);
  sootheChart = disposeChart(sootheChart);
});
getList();
</script>
