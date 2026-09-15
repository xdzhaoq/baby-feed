<template>
  <div class="app-container">
    <el-form :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="宝宝姓名" prop="babyName">
        <el-input v-model="queryParams.babyName" placeholder="请输入宝宝姓名" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="妈妈登录名" prop="momUserName">
        <el-input v-model="queryParams.momUserName" placeholder="请输入妈妈登录名" clearable style="width: 200px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-alert class="mb8" type="info" :closable="false" title="新建宝宝必须指定妈妈登录名。建好后点「设为当前」，或到右上角下拉里选中，才能记喂养和睡眠。" />

    <el-row :gutter="10" class="mb8">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:baby:add']">新增宝宝</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-loading="loading" :data="babyList">
      <el-table-column label="宝宝" prop="babyName" min-width="120" />
      <el-table-column label="昵称" prop="nickname" width="100" />
      <el-table-column label="性别" align="center" prop="gender" width="80">
        <template #default="scope">
          <dict-tag :options="sys_user_sex" :value="scope.row.gender" />
        </template>
      </el-table-column>
      <el-table-column label="出生日期" align="center" prop="birthDate" width="120">
        <template #default="scope">
          <span>{{ parseTime(scope.row.birthDate, '{y}-{m}-{d}') }}</span>
        </template>
      </el-table-column>
      <el-table-column label="出生体重kg" align="center" prop="birthWeightKg" width="110" />
      <el-table-column label="妈妈登录名" prop="momUserName" width="130" />
      <el-table-column label="媒体目录" prop="mediaDir" min-width="140" :show-overflow-tooltip="true" />
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="260">
        <template #default="scope">
          <el-button v-if="nursingStore.currentBabyId === scope.row.babyId" link type="success">当前照看</el-button>
          <el-button v-else link type="primary" @click="nursingStore.switchBaby(scope.row.babyId)">设为当前</el-button>
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:baby:edit']">修改</el-button>
          <el-button link type="primary" icon="Delete" @click="handleDelete(scope.row)" v-hasPermi="['nursing:baby:remove']">删除</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="640px" append-to-body class="nursing-dialog" align-center>
      <el-form ref="babyRef" :model="form" :rules="rules" label-width="110px">
        <el-row>
          <el-col :span="12">
            <el-form-item label="宝宝姓名" prop="babyName">
              <el-input v-model="form.babyName" placeholder="请输入宝宝姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="昵称" prop="nickname">
              <el-input v-model="form.nickname" placeholder="可选" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="性别" prop="gender">
              <el-select v-model="form.gender" placeholder="请选择" style="width: 100%">
                <el-option v-for="dict in sys_user_sex" :key="dict.value" :label="dict.label" :value="dict.value" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="出生日期" prop="birthDate">
              <el-date-picker v-model="form.birthDate" type="date" value-format="YYYY-MM-DD" placeholder="选择日期" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="出生体重 kg" prop="birthWeightKg">
              <el-input-number v-model="form.birthWeightKg" :min="0" :max="10" :precision="3" :step="0.1" controls-position="right" placeholder="如 3.20" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="出生身长 cm" prop="birthHeightCm">
              <el-input-number v-model="form.birthHeightCm" :min="0" :max="80" :precision="1" :step="0.5" controls-position="right" placeholder="如 50.0" style="width: 100%" />
            </el-form-item>
          </el-col>
          <el-col :span="8">
            <el-form-item label="出生头围 cm" prop="birthHeadCm">
              <el-input-number v-model="form.birthHeadCm" :min="0" :max="50" :precision="1" :step="0.5" controls-position="right" placeholder="如 34.0" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-divider content-position="left">妈妈账号（必填）</el-divider>
        <el-alert
          v-if="form.babyId == undefined"
          title="登录名不存在会自动创建妈妈账号；已存在且角色是妈妈则只关联、不改密码。支持二胎。"
          type="info"
          :closable="false"
          class="mb8"
        />
        <el-row>
          <el-col :span="12">
            <el-form-item label="妈妈称呼" prop="momDisplayName">
              <el-input v-model="form.momDisplayName" placeholder="如：妈妈" :disabled="form.babyId != undefined" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="妈妈登录名" prop="momUserName">
              <el-input v-model="form.momUserName" placeholder="字母开头" :disabled="form.babyId != undefined" />
            </el-form-item>
          </el-col>
          <el-col :span="12" v-if="form.babyId == undefined">
            <el-form-item label="初始密码" prop="momPassword">
              <el-input v-model="form.momPassword" type="password" show-password placeholder="新建账号时必填，已存在妈妈可留空" />
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

<script setup name="NursingBaby">
import { listBaby, getBaby, addBaby, updateBaby, delBaby } from "@/api/nursing/baby";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { sys_user_sex } = proxy.useDict("sys_user_sex");
const nursingStore = useNursingStore();

const babyList = ref([]);
const open = ref(false);
const loading = ref(true);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    babyName: undefined,
    momUserName: undefined
  },
  rules: {
    babyName: [{ required: true, message: "宝宝姓名不能为空", trigger: "blur" }],
    birthDate: [{ required: true, message: "出生日期不能为空", trigger: "change" }],
    birthWeightKg: [{ type: "number", max: 10, message: "体重按千克填写，如 3.2，不要填克数", trigger: "change" }],
    birthHeightCm: [{ type: "number", max: 80, message: "身长按厘米填写，一般 40～60", trigger: "change" }],
    birthHeadCm: [{ type: "number", max: 50, message: "头围按厘米填写，一般 30～40", trigger: "change" }],
    momDisplayName: [{ required: true, message: "必须填写妈妈称呼", trigger: "blur" }],
    momUserName: [
      { required: true, message: "必须填写妈妈登录名", trigger: "blur" },
      { pattern: /^[a-zA-Z][a-zA-Z0-9_]{1,19}$/, message: "字母开头，2-20 位字母数字或下划线", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

function getList() {
  loading.value = true;
  listBaby(queryParams.value).then(response => {
    babyList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  });
}

function cancel() {
  open.value = false;
  reset();
}

function reset() {
  form.value = {
    babyId: undefined,
    babyName: undefined,
    nickname: undefined,
    gender: "2",
    birthDate: undefined,
    birthWeightKg: undefined,
    birthHeightCm: undefined,
    birthHeadCm: undefined,
    momDisplayName: undefined,
    momUserName: undefined,
    momPassword: undefined
  };
  proxy.resetForm("babyRef");
}

function handleQuery() {
  queryParams.value.pageNum = 1;
  getList();
}

function resetQuery() {
  proxy.resetForm("queryRef");
  handleQuery();
}

function handleAdd() {
  reset();
  open.value = true;
  title.value = "新增宝宝（必须指定妈妈）";
}

function handleUpdate(row) {
  reset();
  getBaby(row.babyId).then(response => {
    form.value = response.data;
    form.value.momDisplayName = "妈妈";
    open.value = true;
    title.value = "修改宝宝档案";
  });
}

function submitForm() {
  proxy.$refs["babyRef"].validate(valid => {
    if (!valid) return;
    if (form.value.babyId != undefined) {
      updateBaby(form.value).then(() => {
        proxy.$modal.msgSuccess("修改成功");
        open.value = false;
        getList();
        nursingStore.loadMine();
      });
    } else {
      addBaby(form.value).then(() => {
        proxy.$modal.msgSuccess("新增成功");
        open.value = false;
        getList();
        nursingStore.loadMine();
      });
    }
  });
}

function handleDelete(row) {
  proxy.$modal.confirm('是否确认删除宝宝"' + row.babyName + '"？历史记录将保留操作人姓名。').then(function() {
    return delBaby(row.babyId);
  }).then(() => {
    getList();
    nursingStore.loadMine();
    proxy.$modal.msgSuccess("删除成功");
  }).catch(() => {});
}

getList();
</script>
