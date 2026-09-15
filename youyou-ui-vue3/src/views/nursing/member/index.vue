<template>
  <div class="app-container">
    <nursing-baby-guide />

    <el-form v-if="nursingStore.currentBabyId" :model="queryParams" ref="queryRef" :inline="true" v-show="showSearch">
      <el-form-item label="称呼" prop="displayName">
        <el-input v-model="queryParams.displayName" placeholder="称呼" clearable style="width: 160px" @keyup.enter="handleQuery" />
      </el-form-item>
      <el-form-item label="角色" prop="roleTag">
        <el-select v-model="queryParams.roleTag" placeholder="角色标签" clearable style="width: 140px">
          <el-option v-for="dict in nc_family_role" :key="dict.value" :label="dict.label" :value="dict.value" />
        </el-select>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="handleQuery">搜索</el-button>
        <el-button icon="Refresh" @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <el-row :gutter="10" class="mb8" v-if="nursingStore.currentBabyId">
      <el-col :span="1.5">
        <el-button type="primary" plain icon="Plus" @click="handleAdd" v-hasPermi="['nursing:member:add']">新增家人</el-button>
      </el-col>
      <right-toolbar v-model:showSearch="showSearch" @queryTable="getList"></right-toolbar>
    </el-row>

    <el-table v-if="nursingStore.currentBabyId" v-loading="loading" :data="memberList">
      <el-table-column label="成员" min-width="160">
        <template #default="scope">
          <div class="who">
            <el-avatar :size="26" :src="avatarSrc(scope.row.avatar) || undefined">{{ (scope.row.displayName || "?").slice(0, 1) }}</el-avatar>
            <span>{{ scope.row.displayName }}</span>
            <span v-if="scope.row.onlineFlag === '1'" class="who-dot" title="已在线" />
          </div>
        </template>
      </el-table-column>
      <el-table-column label="角色" align="center" prop="roleTag" width="100">
        <template #default="scope">
          <dict-tag :options="nc_family_role" :value="scope.row.roleTag" />
        </template>
      </el-table-column>
      <el-table-column label="登录名" prop="userName" width="140" />
      <el-table-column label="在线" align="center" width="80">
        <template #default="scope">
          <el-tag v-if="scope.row.onlineFlag === '1'" type="success" size="small">在线</el-tag>
          <el-tag v-else type="info" size="small">离线</el-tag>
        </template>
      </el-table-column>
      <el-table-column label="最后心跳" align="center" prop="lastHeartbeat" width="170">
        <template #default="scope">
          <span>{{ parseTime(scope.row.lastHeartbeat) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="状态" align="center" width="90">
        <template #default="scope">
          <el-switch
            v-model="scope.row.status"
            active-value="0"
            inactive-value="1"
            :disabled="scope.row.roleTag === 'mom'"
            v-hasPermi="['nursing:member:disable']"
            @change="handleStatusChange(scope.row)"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" align="center" class-name="small-padding fixed-width" width="220">
        <template #default="scope">
          <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)" v-hasPermi="['nursing:member:edit']">修改</el-button>
          <el-button link type="primary" icon="Key" @click="handleResetPwd(scope.row)" v-hasPermi="['nursing:member:resetPwd']">重置密码</el-button>
        </template>
      </el-table-column>
    </el-table>

    <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />

    <el-dialog :title="title" v-model="open" width="520px" append-to-body>
      <el-form ref="memberRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="称呼" prop="displayName">
          <el-input v-model="form.displayName" placeholder="如：爸爸" />
        </el-form-item>
        <el-form-item label="角色标签" prop="roleTag">
          <el-select v-model="form.roleTag" placeholder="请选择" style="width: 100%" :disabled="form.roleTag === 'mom'">
            <el-option
              v-for="dict in nc_family_role"
              :key="dict.value"
              :label="dict.label"
              :value="dict.value"
              :disabled="dict.value === 'mom'"
            />
          </el-select>
        </el-form-item>
        <el-form-item v-if="form.memberId == undefined" label="登录名" prop="userName">
          <el-input v-model="form.userName" placeholder="字母开头，独立账号" />
        </el-form-item>
        <el-form-item v-if="form.memberId == undefined" label="初始密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="至少 5 位" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitForm">确 定</el-button>
        <el-button @click="cancel">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingMember">
import { listMember, getMember, addMember, updateMember, changeMemberStatus, resetMemberPwd } from "@/api/nursing/member";
import { avatarSrc } from "@/utils/nursingChart";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_family_role } = proxy.useDict("nc_family_role");
const nursingStore = useNursingStore();

const memberList = ref([]);
const open = ref(false);
const loading = ref(false);
const showSearch = ref(true);
const total = ref(0);
const title = ref("");

const data = reactive({
  form: {},
  queryParams: {
    pageNum: 1,
    pageSize: 10,
    babyId: undefined,
    displayName: undefined,
    roleTag: undefined
  },
  rules: {
    displayName: [{ required: true, message: "称呼不能为空", trigger: "blur" }],
    roleTag: [{ required: true, message: "角色标签不能为空", trigger: "change" }],
    userName: [
      { required: true, message: "登录名不能为空", trigger: "blur" },
      { pattern: /^[a-zA-Z][a-zA-Z0-9_]{1,19}$/, message: "字母开头，2-20 位字母数字或下划线", trigger: "blur" }
    ],
    password: [
      { required: true, message: "初始密码不能为空", trigger: "blur" },
      { min: 5, max: 20, message: "密码长度 5-20 位", trigger: "blur" }
    ]
  }
});

const { queryParams, form, rules } = toRefs(data);

function getList() {
  if (!nursingStore.currentBabyId) {
    memberList.value = [];
    total.value = 0;
    return;
  }
  queryParams.value.babyId = nursingStore.currentBabyId;
  loading.value = true;
  listMember(queryParams.value).then(response => {
    memberList.value = response.rows;
    total.value = response.total;
    loading.value = false;
  }).catch(() => {
    loading.value = false;
  });
}

function cancel() {
  open.value = false;
  reset();
}

function reset() {
  form.value = {
    memberId: undefined,
    babyId: nursingStore.currentBabyId,
    displayName: undefined,
    roleTag: "dad",
    userName: undefined,
    password: undefined
  };
  proxy.resetForm("memberRef");
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
  title.value = "新增家人独立账号";
}

function handleUpdate(row) {
  reset();
  getMember(row.memberId).then(response => {
    form.value = response.data;
    open.value = true;
    title.value = "修改成员资料";
  });
}

function submitForm() {
  proxy.$refs["memberRef"].validate(valid => {
    if (!valid) return;
    form.value.babyId = nursingStore.currentBabyId;
    if (form.value.memberId != undefined) {
      updateMember(form.value).then(() => {
        proxy.$modal.msgSuccess("修改成功");
        open.value = false;
        getList();
      });
    } else {
      addMember(form.value).then(() => {
        proxy.$modal.msgSuccess("新增成功");
        open.value = false;
        getList();
      });
    }
  });
}

function handleStatusChange(row) {
  const text = row.status === "0" ? "启用" : "停用";
  proxy.$modal.confirm('确认要"' + text + '""' + row.displayName + '"吗？停用不删除，历史记录仍显示姓名。').then(function() {
    return changeMemberStatus({ memberId: row.memberId, status: row.status });
  }).then(() => {
    proxy.$modal.msgSuccess(text + "成功");
  }).catch(() => {
    row.status = row.status === "0" ? "1" : "0";
  });
}

function handleResetPwd(row) {
  proxy.$prompt('请输入"' + row.displayName + '"的新密码', "重置密码", {
    confirmButtonText: "确定",
    cancelButtonText: "取消",
    inputPattern: /^.{5,20}$/,
    inputErrorMessage: "密码长度 5-20 位"
  }).then(({ value }) => {
    return resetMemberPwd({ memberId: row.memberId, password: value });
  }).then(() => {
    proxy.$modal.msgSuccess("重置成功");
  }).catch(() => {});
}

watch(() => nursingStore.currentBabyId, () => {
  handleQuery();
});

getList();
</script>
