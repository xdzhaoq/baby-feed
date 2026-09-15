<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-collapse v-if="tips.length" class="mb8">
      <el-collapse-item title="喂养小贴士（胃容量 / 饥饿信号 / 拍嗝）" name="tips">
        <div v-for="item in tips" :key="item.kbId" class="tip-block">
          <strong>{{ item.title }}</strong>
          <pre>{{ item.content }}</pre>
        </div>
      </el-collapse-item>
    </el-collapse>

    <el-form v-if="nursingStore.currentBabyId" :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="喂养方式" prop="feedMethod">
        <el-select v-model="queryParams.feedMethod" placeholder="全部" clearable style="width: 140px">
          <el-option v-for="dict in nc_feed_method" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button-group>
          <el-button :type="rangeKind === 'today' ? 'primary' : ''" @click="applyRange('today')">今日</el-button>
          <el-button :type="rangeKind === 'week' ? 'primary' : ''" @click="applyRange('week')">近7天</el-button>
          <el-button :type="rangeKind === 'all' ? 'primary' : ''" @click="applyRange('all')">全部</el-button>
        </el-button-group>
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
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:feeding:add']">记一笔喂养</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
    </el-row>

    <el-card v-if="nursingStore.currentBabyId" shadow="never" class="mb8">
      <template #header>奶量与次数趋势</template>
      <div ref="chartRef" style="height: 240px" />
    </el-card>

    <el-table v-if="nursingStore.currentBabyId" v-loading="loading" :data="recordList">
      <el-table-column label="喂养时间" align="center" prop="feedTime" width="170">
        <template #default="scope">
          <span>{{ parseTime(scope.row.feedTime) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="方式" align="center" prop="feedMethod" width="110">
        <template #default="scope">
          <dict-tag :options="nc_feed_method" :value="scope.row.feedMethod" />
        </template>
      </el-table-column>
      <el-table-column label="奶量ml" align="center" prop="amountMl" width="90" />
      <el-table-column label="时长" align="center" width="100">
        <template #default="scope">{{ formatMinutes(scope.row.durationMin) }}</template>
      </el-table-column>
      <el-table-column label="拍嗝" align="center" width="80">
        <template #default="scope">{{ scope.row.burped === '1' ? '已拍' : '未拍' }}</template>
      </el-table-column>
      <el-table-column label="拍嗝时长" align="center" width="100">
        <template #default="scope">{{ scope.row.burped === '1' ? formatMinutes(scope.row.burpDuration) : '—' }}</template>
      </el-table-column>
      <el-table-column label="拍嗝效果" align="center" width="110">
        <template #default="scope">
          <dict-tag v-if="scope.row.burpEffect" :options="nc_burp_effect" :value="scope.row.burpEffect" />
          <span v-else>—</span>
        </template>
      </el-table-column>
      <el-table-column label="喂后表现" prop="afterBehavior" min-width="120" :show-overflow-tooltip="true" />
      <el-table-column label="操作人" width="120">
        <template #default="scope">
          <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
        </template>
      </el-table-column>
      <el-table-column label="备注" prop="notes" min-width="140" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" width="160" class-name="small-padding fixed-width">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:feeding:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:feeding:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="680px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="110px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="喂养时间" prop="feedTime">
              <el-date-picker v-model="form.feedTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" placeholder="选择时间" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="喂养方式" prop="feedMethod">
              <el-select v-model="form.feedMethod" placeholder="请选择" style="width: 100%">
                <el-option v-for="dict in nc_feed_method" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="showAmount">
            <el-form-item label="奶量ml" prop="amountMl">
              <el-input-number v-model="form.amountMl" :min="0" :precision="1" :step="5" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="总时长(分)" prop="durationMin">
              <el-input-number v-model="form.durationMin" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.feedMethod === 'breast'">
            <el-form-item label="左侧(分)" prop="leftDuration">
              <el-input-number v-model="form.leftDuration" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.feedMethod === 'breast'">
            <el-form-item label="右侧(分)" prop="rightDuration">
              <el-input-number v-model="form.rightDuration" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="是否拍嗝" prop="burped">
              <el-radio-group v-model="form.burped">
                <el-radio value="1">已拍嗝</el-radio>
                <el-radio value="0">未拍嗝</el-radio>
              </el-radio-group>
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.burped === '1'">
            <el-form-item label="拍嗝时长(分)" prop="burpDuration">
              <el-input-number v-model="form.burpDuration" :min="0" :step="1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.burped === '1'">
            <el-form-item label="拍嗝效果" prop="burpEffect">
              <el-select v-model="form.burpEffect" placeholder="请选择" clearable style="width: 100%">
                <el-option v-for="dict in nc_burp_effect" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="喂后表现" prop="afterBehavior">
              <el-input v-model="form.afterBehavior" placeholder="如：安稳入睡 / 溢奶" />
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item label="备注" prop="notes">
              <el-input v-model="form.notes" type="textarea" :rows="2" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingFeeding">
import { listFeeding, getFeeding, addFeeding, updateFeeding, delFeeding, chartFeeding } from "@/api/nursing/feeding";
import { listKnowledge } from "@/api/nursing/dashboard";
import { createRecordLock, formatMinutes, nowDateTime, dateRangeOf } from "@/utils/nursingLock";
import { axisDates, bindChart, disposeChart, nameInitial } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_feed_method, nc_burp_effect } = proxy.useDict("nc_feed_method", "nc_burp_effect");
const nursingStore = useNursingStore();
const recordLock = createRecordLock("feeding");

const recordList = ref([]);
const tips = ref([]);
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
    feedMethod: undefined
  },
  rules: {
    feedTime: [{ required: true, message: "喂养时间不能为空", trigger: "change" }],
    feedMethod: [{ required: true, message: "请选择喂养方式", trigger: "change" }]
  }
});
const { queryParams, form, rules } = toRefs(data);
const showAmount = computed(() => form.value.feedMethod && form.value.feedMethod !== "breast");

function getList() {
  if (!nursingStore.currentBabyId) {
    recordList.value = [];
    total.value = 0;
    return;
  }
  queryParams.value.babyId = nursingStore.currentBabyId;
  loading.value = true;
  listFeeding(proxy.addDateRange(queryParams.value, dateRange.value)).then(response => {
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
  const days = rangeKind.value === "all" ? 14 : 7;
  chartFeeding(nursingStore.currentBabyId, days).then(res => {
    const rows = res.data || [];
    nextTick(() => {
      chart = bindChart(chartRef.value, chart);
      if (!chart) {
        return;
      }
      chart.setOption({
        color: ["#DE8F74", "#5E87A8"],
        tooltip: { trigger: "axis" },
        legend: { top: 0 },
        grid: { left: 44, right: 44, top: 32, bottom: 28 },
        xAxis: { type: "category", data: axisDates(rows), axisLabel: { fontSize: 10 } },
        yAxis: [
          { type: "value", name: "次", minInterval: 1 },
          { type: "value", name: "ml" }
        ],
        series: [
          { name: "次数", type: "bar", data: rows.map(item => item.count || 0) },
          { name: "奶量ml", type: "line", smooth: true, yAxisIndex: 1, data: rows.map(item => item.amount || 0) }
        ]
      });
    });
  });
}

function applyRange(kind) {
  rangeKind.value = kind;
  dateRange.value = dateRangeOf(kind);
  handleQuery();
}

function loadTips() {
  listKnowledge("feeding").then(res => {
    tips.value = res.data || [];
  }).catch(() => {
    tips.value = [];
  });
}

function reset() {
  form.value = {
    feedingId: undefined,
    babyId: nursingStore.currentBabyId,
    feedTime: nowDateTime(),
    feedMethod: "breast",
    amountMl: undefined,
    durationMin: undefined,
    leftDuration: undefined,
    rightDuration: undefined,
    burped: "0",
    burpDuration: undefined,
    burpEffect: undefined,
    afterBehavior: undefined,
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function cancel() {
  open.value = false;
}

function onDialogClosed() {
  recordLock.release();
  reset();
}

function handleQuery() {
  queryParams.value.pageNum = 1;
  getList();
}

function resetQuery() {
  dateRange.value = [];
  rangeKind.value = "all";
  proxy.resetForm("queryRef");
  handleQuery();
}

function handleAdd() {
  reset();
  open.value = true;
  title.value = "记一笔喂养";
}

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.feedingId).then(() => {
    return getFeeding(row.feedingId);
  }).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改喂养记录";
  }).catch(() => {
    recordLock.release();
  });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const req = form.value.feedingId != undefined ? updateFeeding(form.value) : addFeeding(form.value);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.feedingId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除这条喂养记录？').then(() => {
    return delFeeding(row.feedingId);
  }).then(() => {
    getList();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) {
    cancel();
  }
  handleQuery();
});

onUnmounted(() => {
  recordLock.release();
  chart = disposeChart(chart);
});

applyRange("week");
loadTips();
</script>

<style scoped>
.tip-block { margin-bottom: 12px; white-space: pre-wrap; }
.tip-block pre { margin: 6px 0 0; font-family: inherit; white-space: pre-wrap; color: #606266; }
</style>
