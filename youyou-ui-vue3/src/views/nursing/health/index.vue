<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-tabs v-if="nursingStore.currentBabyId" v-model="activeTab">
      <el-tab-pane label="每日自检" name="check">
        <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
          <el-form-item label="日期">
            <el-date-picker v-model="dateRange" value-format="YYYY-MM-DD" type="daterange" range-separator="-" start-placeholder="开始" end-placeholder="结束" style="width: 240px" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
            <el-button icon="Refresh" @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:health:add']">记今日自检</el-button>
          </el-col>
          <right-toolbar v-model:showSearch="showSearch" @queryTable="getList" />
        </el-row>
        <el-table v-loading="loading" :data="checkList" :row-class-name="healthRowClass">
          <el-table-column label="日期" align="center" prop="checkDate" width="120">
            <template #default="scope">{{ parseTime(scope.row.checkDate, '{y}-{m}-{d}') }}</template>
          </el-table-column>
          <el-table-column label="晨温" align="center" width="80">
            <template #default="scope">
              <span :class="{ fever: isFever(scope.row.tempAm) }">{{ scope.row.tempAm ?? "—" }}</span>
            </template>
          </el-table-column>
          <el-table-column label="晚温" align="center" width="80">
            <template #default="scope">
              <span :class="{ fever: isFever(scope.row.tempPm) }">{{ scope.row.tempPm ?? "—" }}</span>
            </template>
          </el-table-column>
          <el-table-column label="黄疸" align="center" width="130">
            <template #default="scope">
              <dict-tag :options="nc_jaundice" :value="scope.row.jaundice" />
            </template>
          </el-table-column>
          <el-table-column label="脐带" align="center" width="110">
            <template #default="scope">
              <dict-tag :options="nc_umbilical" :value="scope.row.umbilical" />
            </template>
          </el-table-column>
          <el-table-column label="精神" align="center" width="110">
            <template #default="scope">
              <dict-tag :options="nc_spirit" :value="scope.row.spirit" />
            </template>
          </el-table-column>
          <el-table-column label="操作人" width="120">
            <template #default="scope">
              <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="120">
            <template #default="scope">
              <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:health:edit']">修改</el-button>
            </template>
          </el-table-column>
        </el-table>
        <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
      </el-tab-pane>

      <el-tab-pane label="疫苗时间表" name="vaccine">
        <el-alert title="内置为 0–6 月龄国家免疫规划，仅供参考。可自行增删（如维生素 K1），以当地接种单位安排为准。到期前会在仪表盘提醒。" type="info" :closable="false" class="mb8" />
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="handleAddVaccine" v-hasPermi="['nursing:vaccine:edit']">新增接种项</el-button>
          </el-col>
        </el-row>
        <el-table v-loading="vaccineLoading" :data="vaccineList">
          <el-table-column label="疫苗" prop="vaccineName" min-width="140" />
          <el-table-column label="剂次" align="center" width="90">
            <template #default="scope">{{ scope.row.doseNo }} / {{ scope.row.totalDoses }}</template>
          </el-table-column>
          <el-table-column label="建议日龄" align="center" width="100">
            <template #default="scope">{{ scope.row.dueAgeDays === 0 ? '出生当天' : scope.row.dueAgeDays + ' 天' }}</template>
          </el-table-column>
          <el-table-column label="建议日期" align="center" width="120">
            <template #default="scope">{{ parseTime(scope.row.dueDate, '{y}-{m}-{d}') }}</template>
          </el-table-column>
          <el-table-column label="状态" align="center" width="110">
            <template #default="scope">
              <el-tag v-if="scope.row.status === 'done'" type="success">已接种</el-tag>
              <el-tag v-else-if="scope.row.status === 'overdue'" type="danger">已过期</el-tag>
              <el-tag v-else-if="scope.row.status === 'soon'" type="warning">即将到期</el-tag>
              <el-tag v-else type="info">未到时间</el-tag>
            </template>
          </el-table-column>
          <el-table-column label="接种日" align="center" width="120">
            <template #default="scope">{{ scope.row.inoculateDate ? parseTime(scope.row.inoculateDate, '{y}-{m}-{d}') : '—' }}</template>
          </el-table-column>
          <el-table-column label="操作人" width="120">
            <template #default="scope">
              <span class="who"><span class="who-ava">{{ nameInitial(scope.row.operatorName) }}</span>{{ scope.row.operatorName }}</span>
            </template>
          </el-table-column>
          <el-table-column label="操作" align="center" width="200">
            <template #default="scope">
              <el-button v-if="scope.row.status !== 'done'" link type="primary" @click="onMark(scope.row, '1')" v-hasPermi="['nursing:vaccine:edit']">标记已接种</el-button>
              <el-button v-else link type="warning" @click="onMark(scope.row, '0')" v-hasPermi="['nursing:vaccine:edit']">撤销</el-button>
              <el-button link type="danger" @click="handleDeleteVaccine(scope.row)" v-hasPermi="['nursing:vaccine:edit']">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-tab-pane>
    </el-tabs>

    <el-dialog :title="title" v-model="open" width="620px" append-to-body @closed="onDialogClosed">
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="日期" prop="checkDate">
          <el-date-picker v-model="form.checkDate" type="date" value-format="YYYY-MM-DD" :disabled="form.checkId != undefined" style="width: 100%" />
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="晨温 ℃" prop="tempAm">
              <el-input-number v-model="form.tempAm" :min="34" :max="42" :precision="1" :step="0.1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="晚温 ℃" prop="tempPm">
              <el-input-number v-model="form.tempPm" :min="34" :max="42" :precision="1" :step="0.1" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="黄疸" prop="jaundice">
          <el-radio-group v-model="form.jaundice">
            <el-radio v-for="dict in nc_jaundice" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="脐带" prop="umbilical">
          <el-radio-group v-model="form.umbilical">
            <el-radio v-for="dict in nc_umbilical" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="精神" prop="spirit">
          <el-radio-group v-model="form.spirit">
            <el-radio v-for="dict in nc_spirit" :key="dict.value" :value="dict.value">{{ dict.label }}</el-radio>
          </el-radio-group>
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

    <el-dialog title="新增接种项" v-model="vaccineOpen" width="480px" append-to-body class="nursing-dialog">
      <el-form ref="vaccineFormRef" :model="vaccineForm" :rules="vaccineRules" label-width="110px">
        <el-form-item label="名称" prop="vaccineName">
          <el-input v-model="vaccineForm.vaccineName" placeholder="如：维生素K1" maxlength="80" />
        </el-form-item>
        <el-form-item label="编码" prop="vaccineCode">
          <el-input v-model="vaccineForm.vaccineCode" placeholder="选填，如 K1" maxlength="30" />
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="第几剂" prop="doseNo">
              <el-input-number v-model="vaccineForm.doseNo" :min="1" :max="10" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="共几剂" prop="totalDoses">
              <el-input-number v-model="vaccineForm.totalDoses" :min="1" :max="10" controls-position="right" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="建议日龄" prop="dueAgeDays">
          <el-input-number v-model="vaccineForm.dueAgeDays" :min="0" :max="730" controls-position="right" style="width: 100%" />
          <div class="form-tip">出生当天填 0；满月约 30 天。建议日期按宝宝生日自动计算。</div>
        </el-form-item>
        <el-form-item label="提前提醒" prop="remindBefore">
          <el-input-number v-model="vaccineForm.remindBefore" :min="0" :max="30" controls-position="right" style="width: 100%" />
          <div class="form-tip">到期前几天在仪表盘提醒，默认 3 天。</div>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="vaccineForm.remark" placeholder="选填" maxlength="200" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitVaccine">确 定</el-button>
        <el-button @click="vaccineOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingHealth">
import { listHealth, getHealth, addHealth, updateHealth, listVaccine, markVaccine, addVaccineSchedule, delVaccineSchedule } from "@/api/nursing/health";
import { createRecordLock, nowDate } from "@/utils/nursingLock";
import { nameInitial } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_jaundice, nc_umbilical, nc_spirit } = proxy.useDict("nc_jaundice", "nc_umbilical", "nc_spirit");
const nursingStore = useNursingStore();
const recordLock = createRecordLock("health");

const activeTab = ref("check");
const checkList = ref([]);
const vaccineList = ref([]);
const open = ref(false);
const loading = ref(false);
const vaccineLoading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");
const dateRange = ref([]);

const data = reactive({
  form: {},
  queryParams: { pageNum: 1, pageSize: 10, babyId: undefined },
  rules: { checkDate: [{ required: true, message: "请选择日期", trigger: "change" }] }
});
const { queryParams, form, rules } = toRefs(data);

function getList() {
  if (!nursingStore.currentBabyId) {
    checkList.value = [];
    total.value = 0;
    return;
  }
  queryParams.value.babyId = nursingStore.currentBabyId;
  loading.value = true;
  listHealth(proxy.addDateRange(queryParams.value, dateRange.value)).then(res => {
    checkList.value = res.rows;
    total.value = res.total;
  }).finally(() => { loading.value = false; });
}

function loadVaccine() {
  if (!nursingStore.currentBabyId) {
    vaccineList.value = [];
    return;
  }
  vaccineLoading.value = true;
  listVaccine(nursingStore.currentBabyId).then(res => {
    vaccineList.value = res.data || [];
  }).finally(() => { vaccineLoading.value = false; });
}

function reset() {
  form.value = {
    checkId: undefined,
    babyId: nursingStore.currentBabyId,
    checkDate: nowDate(),
    tempAm: undefined,
    tempPm: undefined,
    jaundice: "none",
    umbilical: "dry",
    spirit: "good",
    notes: undefined,
    rev: undefined
  };
  proxy.resetForm("formRef");
}

function isFever(val) {
  return val != null && Number(val) >= 38;
}

function healthRowClass({ row }) {
  return isFever(row.tempAm) || isFever(row.tempPm) ? "row-abnormal" : "";
}

function onDialogClosed() { recordLock.release(); reset(); }
function handleQuery() { queryParams.value.pageNum = 1; getList(); }
function resetQuery() { dateRange.value = []; proxy.resetForm("queryRef"); handleQuery(); }
function handleAdd() { reset(); open.value = true; title.value = "记一笔健康自检"; }

function handleUpdate(row) {
  reset();
  recordLock.acquire(nursingStore.currentBabyId, row.checkId).then(() => getHealth(row.checkId)).then(res => {
    form.value = res.data;
    open.value = true;
    title.value = "修改健康自检";
  }).catch(() => { recordLock.release(); });
}

function submitForm() {
  proxy.$refs["formRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    const req = form.value.checkId != undefined ? updateHealth(form.value) : addHealth(form.value);
    req.then(() => {
      proxy.$modal.msgSuccess(form.value.checkId != undefined ? "修改成功" : "新增成功");
      open.value = false;
      getList();
    });
  });
}

const vaccineOpen = ref(false);
const vaccineForm = ref({});
const vaccineRules = {
  vaccineName: [{ required: true, message: "名称不能为空", trigger: "blur" }],
  dueAgeDays: [{ required: true, message: "请填写建议日龄", trigger: "change" }]
};

function handleAddVaccine() {
  vaccineForm.value = {
    vaccineName: "",
    vaccineCode: "",
    doseNo: 1,
    totalDoses: 1,
    dueAgeDays: 0,
    remindBefore: 3,
    remark: ""
  };
  vaccineOpen.value = true;
}

function submitVaccine() {
  proxy.$refs["vaccineFormRef"].validate(valid => {
    if (!valid) return;
    addVaccineSchedule(nursingStore.currentBabyId, vaccineForm.value).then(() => {
      proxy.$modal.msgSuccess("已添加");
      vaccineOpen.value = false;
      loadVaccine();
    });
  });
}

function handleDeleteVaccine(row) {
  proxy.$modal.confirm('确认删除「' + row.vaccineName + '」第 ' + row.doseNo + ' 剂？接种标记也会一并去掉。').then(() => {
    return delVaccineSchedule(row.scheduleId, nursingStore.currentBabyId);
  }).then(() => {
    proxy.$modal.msgSuccess("已删除");
    loadVaccine();
  }).catch(() => {});
}

function onMark(row, inoculated) {
  const text = inoculated === "1" ? "标记已接种" : "撤销接种标记";
  proxy.$modal.confirm("确认" + text + "「" + row.vaccineName + "」第 " + row.doseNo + " 剂？").then(() => {
    return markVaccine({
      babyId: nursingStore.currentBabyId,
      scheduleId: row.scheduleId,
      inoculated,
      inoculateDate: inoculated === "1" ? nowDate() : undefined
    });
  }).then(() => {
    proxy.$modal.msgSuccess("已更新");
    loadVaccine();
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  if (open.value) open.value = false;
  handleQuery();
  loadVaccine();
});
watch(activeTab, val => { if (val === "vaccine") loadVaccine(); });
onUnmounted(() => { recordLock.release(); });
getList();
loadVaccine();
</script>

<style scoped>
.fever { color: #c4574f; font-weight: 600; }
:deep(.row-abnormal) { background: #f8e0dc !important; }
.form-tip { color: #909399; font-size: 12px; line-height: 1.4; margin-top: 4px; }
</style>
