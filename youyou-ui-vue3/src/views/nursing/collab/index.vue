<template>
  <div class="app-container nursing-page">
    <nursing-baby-guide />

    <el-tabs v-if="nursingStore.currentBabyId" v-model="activeTab">
      <el-tab-pane label="值班交接" name="handover">
        <el-row :gutter="10" class="mb8">
          <el-col :span="1.5">
            <el-button type="primary" plain icon="Plus" @click="openHandover" v-hasPermi="['nursing:handover:add']">记一笔交接</el-button>
          </el-col>
        </el-row>
        <el-table v-loading="handoverLoading" :data="handoverList">
          <el-table-column label="交接时间" align="center" width="170">
            <template #default="scope">{{ parseTime(scope.row.handoverTime) }}</template>
          </el-table-column>
          <el-table-column label="交给" min-width="180">
            <template #default="scope">{{ scope.row.fromUserName }} → {{ scope.row.toUserName }}</template>
          </el-table-column>
          <el-table-column label="备注" prop="notes" min-width="200" :show-overflow-tooltip="true" />
        </el-table>
        <pagination v-show="handoverTotal > 0" :total="handoverTotal" v-model:page="handoverQuery.pageNum" v-model:limit="handoverQuery.pageSize" @pagination="loadHandover" />
      </el-tab-pane>

      <el-tab-pane label="留言板" name="message">
        <el-form :inline="true" class="mb8">
          <el-form-item label="@提醒">
            <el-select v-model="messageForm.mentionUserIds" multiple filterable placeholder="选择家庭成员" style="width: 260px">
              <el-option v-for="item in members" :key="item.userId" :label="item.displayName" :value="item.userId" :disabled="item.userId === userStore.id" />
            </el-select>
          </el-form-item>
        </el-form>
        <el-input v-model="messageForm.content" type="textarea" :rows="3" maxlength="1000" show-word-limit placeholder="写给家人的留言，被 @ 的人会在仪表盘看到提醒" />
        <div class="mt8">
          <el-button type="primary" @click="submitMessage" v-hasPermi="['nursing:message:add']">发布留言</el-button>
        </div>
        <el-timeline class="mt16">
          <el-timeline-item v-for="item in messageList" :key="item.messageId" :timestamp="parseTime(item.createTime)">
            <strong>{{ item.authorName }}</strong>
            <div class="msg">{{ item.content }}</div>
            <div v-if="item.mentions && item.mentions.length" class="sub">
              @ {{ item.mentions.map(m => m.mentionedName).join("、") }}
            </div>
          </el-timeline-item>
        </el-timeline>
        <el-empty v-if="!messageList.length" description="还没有留言" />
        <pagination v-show="messageTotal > 0" :total="messageTotal" v-model:page="messageQuery.pageNum" v-model:limit="messageQuery.pageSize" @pagination="loadMessage" />
      </el-tab-pane>

      <el-tab-pane label="操作日志" name="log">
        <el-form :inline="true" class="mb8">
          <el-form-item label="模块">
            <el-select v-model="logQuery.moduleCode" clearable placeholder="全部" style="width: 160px" @change="loadLog">
              <el-option v-for="item in modules" :key="item.value" :label="item.label" :value="item.value" />
            </el-select>
          </el-form-item>
        </el-form>
        <el-table v-loading="logLoading" :data="logList">
          <el-table-column label="时间" align="center" width="170">
            <template #default="scope">{{ parseTime(scope.row.createTime) }}</template>
          </el-table-column>
          <el-table-column label="操作人" prop="operatorName" width="120" />
          <el-table-column label="模块" prop="moduleCode" width="110" />
          <el-table-column label="动作" prop="actionCode" width="90" />
          <el-table-column label="说明" prop="summary" min-width="220" :show-overflow-tooltip="true" />
        </el-table>
        <pagination v-show="logTotal > 0" :total="logTotal" v-model:page="logQuery.pageNum" v-model:limit="logQuery.pageSize" @pagination="loadLog" />
      </el-tab-pane>
    </el-tabs>

    <el-dialog title="值班交接" v-model="handoverOpen" width="480px" append-to-body>
      <el-form ref="handoverRef" :model="handoverForm" :rules="handoverRules" label-width="100px">
        <el-form-item label="交给谁" prop="toUserId">
          <el-select v-model="handoverForm.toUserId" style="width: 100%" placeholder="选择家庭成员">
            <el-option v-for="item in members" :key="item.userId" :label="item.displayName" :value="item.userId" :disabled="item.userId === userStore.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="交接时间" prop="handoverTime">
          <el-date-picker v-model="handoverForm.handoverTime" type="datetime" value-format="YYYY-MM-DD HH:mm:ss" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注" prop="notes">
          <el-input v-model="handoverForm.notes" type="textarea" :rows="3" maxlength="500" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitHandover">确 定</el-button>
        <el-button @click="handoverOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingCollab">
import { listHandover, addHandover, listMessage, addMessage, listOperLog } from "@/api/nursing/collab";
import { listMember } from "@/api/nursing/member";
import { nowDateTime } from "@/utils/nursingLock";
import useNursingStore from "@/store/modules/nursing";
import useUserStore from "@/store/modules/user";

const { proxy } = getCurrentInstance();
const nursingStore = useNursingStore();
const userStore = useUserStore();

const activeTab = ref("handover");
const members = ref([]);
const handoverLoading = ref(false);
const handoverList = ref([]);
const handoverTotal = ref(0);
const handoverQuery = reactive({ pageNum: 1, pageSize: 10, babyId: undefined });
const handoverOpen = ref(false);
const handoverForm = ref({});
const handoverRules = {
  toUserId: [{ required: true, message: "请选择交接给谁", trigger: "change" }],
  handoverTime: [{ required: true, message: "请填写交接时间", trigger: "change" }]
};
const messageList = ref([]);
const messageTotal = ref(0);
const messageQuery = reactive({ pageNum: 1, pageSize: 10, babyId: undefined });
const messageForm = reactive({ content: "", mentionUserIds: [] });
const logLoading = ref(false);
const logList = ref([]);
const logTotal = ref(0);
const logQuery = reactive({ pageNum: 1, pageSize: 10, babyId: undefined, moduleCode: undefined });
const modules = [
  { value: "feeding", label: "喂养" },
  { value: "sleep", label: "睡眠" },
  { value: "diaper", label: "尿布" },
  { value: "cry", label: "哭闹" },
  { value: "care", label: "护理" },
  { value: "health", label: "健康" },
  { value: "growth", label: "生长" },
  { value: "media", label: "相册" },
  { value: "handover", label: "交接" },
  { value: "message", label: "留言" },
  { value: "member", label: "成员" },
  { value: "baby", label: "档案" }
];

function loadMembers() {
  if (!nursingStore.currentBabyId) {
    members.value = [];
    return;
  }
  listMember({ babyId: nursingStore.currentBabyId, pageNum: 1, pageSize: 50, status: "0" }).then(res => {
    members.value = res.rows || [];
  }).catch(() => {
    members.value = [];
  });
}

function loadHandover() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  handoverLoading.value = true;
  handoverQuery.babyId = nursingStore.currentBabyId;
  listHandover(handoverQuery).then(res => {
    handoverList.value = res.rows || [];
    handoverTotal.value = res.total || 0;
  }).finally(() => {
    handoverLoading.value = false;
  });
}

function loadMessage() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  messageQuery.babyId = nursingStore.currentBabyId;
  listMessage(messageQuery).then(res => {
    messageList.value = res.rows || [];
    messageTotal.value = res.total || 0;
  });
}

function loadLog() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  logLoading.value = true;
  logQuery.babyId = nursingStore.currentBabyId;
  listOperLog(logQuery).then(res => {
    logList.value = res.rows || [];
    logTotal.value = res.total || 0;
  }).finally(() => {
    logLoading.value = false;
  });
}

function openHandover() {
  handoverForm.value = { babyId: nursingStore.currentBabyId, handoverTime: nowDateTime(), toUserId: undefined, notes: "" };
  handoverOpen.value = true;
}

function submitHandover() {
  proxy.$refs["handoverRef"].validate(valid => {
    if (!valid) {
      return;
    }
    addHandover(handoverForm.value).then(() => {
      proxy.$modal.msgSuccess("交接已记下");
      handoverOpen.value = false;
      loadHandover();
    });
  });
}

function submitMessage() {
  if (!messageForm.content || !messageForm.content.trim()) {
    proxy.$modal.msgWarning("请填写留言");
    return;
  }
  addMessage({
    babyId: nursingStore.currentBabyId,
    content: messageForm.content.trim(),
    mentionUserIds: messageForm.mentionUserIds
  }).then(() => {
    proxy.$modal.msgSuccess("留言已发布");
    messageForm.content = "";
    messageForm.mentionUserIds = [];
    loadMessage();
  });
}

function reloadAll() {
  loadMembers();
  loadHandover();
  loadMessage();
  loadLog();
}

watch(() => nursingStore.currentBabyId, () => {
  handoverQuery.pageNum = 1;
  messageQuery.pageNum = 1;
  logQuery.pageNum = 1;
  reloadAll();
});

reloadAll();
</script>

<style scoped>
.mt8 { margin-top: 8px; }
.mt16 { margin-top: 16px; }
.msg { white-space: pre-wrap; margin-top: 4px; }
.sub { color: #909399; font-size: 12px; margin-top: 4px; }
</style>
