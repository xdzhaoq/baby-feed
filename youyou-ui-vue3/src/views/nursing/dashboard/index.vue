<template>
  <div class="app-container">
    <template v-if="isAdmin && adminMode">
      <el-row :gutter="16" class="mb8">
        <el-col :xs="12" :sm="6">
          <el-card shadow="never" class="stat-card">
            <div class="label">宝宝档案</div>
            <div class="value">{{ admin.babyCount || 0 }} <span class="unit">位</span></div>
            <div class="extra">家庭 {{ admin.familyCount || 0 }} 户</div>
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="6">
          <el-card shadow="never" class="stat-card">
            <div class="label">待完善</div>
            <div class="value">{{ admin.incompleteCount || 0 }} <span class="unit">户</span></div>
            <div class="extra">{{ (admin.incompleteCount || 0) > 0 ? "有家庭还只有妈妈，可提醒补成员" : "妈妈之外已有家人" }}</div>
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="6">
          <el-card shadow="never" class="stat-card">
            <div class="label">今日需关注</div>
            <div class="value" :class="{ danger: admin.alertBabyCount > 0 }">{{ admin.alertBabyCount || 0 }} <span class="unit">位</span></div>
            <div class="extra">点卡片查看该宝宝详情</div>
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="6">
          <el-card shadow="never" class="stat-card">
            <div class="label">当前在线</div>
            <div class="value">{{ admin.onlinePeopleCount || 0 }} <span class="unit">人</span></div>
            <div class="extra" :class="{ danger: admin.silentBabyCount > 0 }">今日尚未记喂养 {{ admin.silentBabyCount || 0 }} 位</div>
          </el-card>
        </el-col>
      </el-row>

      <el-row class="mb8">
        <el-col :span="24">
          <el-button type="primary" plain icon="Plus" @click="goCreateBaby" v-hasPermi="['nursing:baby:add']">新增宝宝档案</el-button>
        </el-col>
      </el-row>

      <el-empty v-if="!(admin.babies && admin.babies.length)" description="还没有宝宝档案，先新建一位并指定妈妈" />
      <el-row v-else :gutter="16">
        <el-col v-for="card in admin.babies" :key="card.babyId" :xs="24" :sm="12" :md="8">
          <el-card shadow="never" class="baby-card" :class="card.alertLevel" @click="inspectBaby(card)">
            <div class="baby-card-head">
              <strong>{{ card.babyName }}</strong>
              <span class="sub">日龄 {{ card.ageDays ?? "—" }} 天</span>
            </div>
            <div class="sub">成员 {{ card.memberNames || "—" }} · 在线 {{ card.onlineCount || 0 }}</div>
            <div v-if="card.incomplete" class="tag-line warn">家庭成员偏少，可提醒妈妈补录爸爸/老人</div>
            <div v-if="card.alertTitle" class="tag-line" :class="card.alertLevel">{{ card.alertTitle }}</div>
            <div class="sub">护理待办 {{ card.unfinishedCare || 0 }} 项 · 今日喂养 {{ card.feedCount || 0 }} 次</div>
            <el-button link type="primary">查看今日照护</el-button>
          </el-card>
        </el-col>
      </el-row>
    </template>

    <template v-else>
      <nursing-baby-guide />

      <template v-if="nursingStore.currentBabyId">
        <el-row :gutter="16" class="mb8">
          <el-col :span="24">
            <el-card shadow="never">
              <template #header>
                <span v-if="isAdmin">协查 · {{ overview.babyName || nursingStore.currentBaby?.babyName }}</span>
                <span v-else>今日概览 · {{ overview.babyName || nursingStore.currentBaby?.babyName }}</span>
                <span v-if="overview.ageDays != null" class="sub"> · 日龄 {{ overview.ageDays }} 天</span>
                <el-button v-if="isAdmin" link type="primary" class="back-link" @click="backAdmin">返回家庭总览</el-button>
              </template>
              <div class="sub">
                当前照看人
                <strong>{{ overview.currentCaretaker || (overview.onlineNames && overview.onlineNames[0]) || "还没有交接记录" }}</strong>
                <span class="gap">最近一次喂养：</span>
                <span v-if="overview.lastFeedTime">
                  {{ parseTime(overview.lastFeedTime) }}（{{ overview.lastFeedOperator }}）
                  · 参考下次 {{ parseTime(overview.nextFeedTime) }}
                  <span v-if="!isAdmin && overview.nextFeedOperator">，可由 {{ overview.nextFeedOperator }} 负责</span>
                  （按间隔 3 小时估算）
                </span>
                <span v-else>暂无喂养记录</span>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-row v-if="overview.alerts && overview.alerts.length" :gutter="16" class="mb8">
          <el-col :span="24">
            <div
              v-for="(item, index) in overview.alerts"
              :key="index"
              class="alert-bar"
              :class="item.level"
              @click="openGuide(item)"
            >
              <strong>{{ item.level === 'red' ? '需要尽快处理' : '需要关注' }} · {{ item.title }}</strong>
              <div>{{ item.hint }}</div>
              <span v-if="item.level === 'red'" class="link">点击查看应急指引</span>
            </div>
          </el-col>
        </el-row>

        <el-row v-if="!isAdmin && overview.unreadMentions && overview.unreadMentions.length" :gutter="16" class="mb8">
          <el-col :span="24">
            <el-card shadow="never">
              <template #header>
                有人 @ 了你
                <el-button link type="primary" @click="readAllMentions">全部标为已读</el-button>
              </template>
              <div v-for="item in overview.unreadMentions" :key="item.mentionId" class="mention-row">
                <div>
                  <strong>{{ item.authorName }}</strong>：{{ item.content }}
                  <div class="sub">{{ parseTime(item.createTime) }}</div>
                </div>
                <el-button link type="primary" @click="readMention(item)">知道了</el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>

        <el-row :gutter="16">
          <el-col :xs="12" :sm="8" :md="6">
            <el-card shadow="never" class="stat-card">
              <div class="label">今日喂养</div>
              <div class="value">{{ overview.feedCount || 0 }} <span class="unit">次</span></div>
              <div class="extra">奶量合计 {{ overview.feedAmountMl || 0 }} ml</div>
            </el-card>
          </el-col>
          <el-col :xs="12" :sm="8" :md="6">
            <el-card shadow="never" class="stat-card">
              <div class="label">今日睡眠</div>
              <div class="value">{{ formatMinutes(overview.sleepMinutes || 0) }}</div>
              <div class="extra">按入睡日期统计已结束时长</div>
            </el-card>
          </el-col>
          <el-col :xs="12" :sm="8" :md="6">
            <el-card shadow="never" class="stat-card">
              <div class="label">今日尿布</div>
              <div class="value">{{ overview.diaperCount || 0 }} <span class="unit">次</span></div>
              <div class="extra" :class="{ danger: overview.diaperAbnormalCount > 0 }">
                异常性状 {{ overview.diaperAbnormalCount || 0 }} 次 · 尿湿 {{ overview.peeCount || 0 }} 次
              </div>
            </el-card>
          </el-col>
          <el-col :xs="12" :sm="8" :md="6">
            <el-card shadow="never" class="stat-card">
              <div class="label">今日哭闹</div>
              <div class="value">{{ formatMinutes(overview.cryMinutes || 0) }}</div>
              <div class="extra">疫苗待关注 {{ overview.vaccineSoonCount || 0 }} 剂</div>
            </el-card>
          </el-col>
        </el-row>

        <el-card shadow="never" class="mt16">
          <template #header>今日待办 · 未完成 {{ overview.unfinishedCare || 0 }} 项</template>
          <el-empty v-if="!(overview.careTodos && overview.careTodos.length)" description="今天的护理事项都完成了" />
          <div v-for="item in overview.careTodos" :key="item.itemId" class="todo-row">
            <span>{{ item.itemName }}</span>
            <el-button v-if="!isAdmin" link type="primary" @click="completeCare(item)" v-hasPermi="['nursing:care:edit']">完成</el-button>
            <span v-else class="sub">家人可在护理清单勾选</span>
          </div>
        </el-card>

        <el-row :gutter="16" class="mt16">
          <el-col :xs="24" :md="10">
            <el-card shadow="never">
              <template #header>体重趋势</template>
              <div v-if="overview.growthPoints && overview.growthPoints.length" ref="miniChartRef" style="height: 180px" />
              <el-empty v-else description="还没有生长记录" />
            </el-card>
          </el-col>
          <el-col :xs="24" :md="14">
            <el-card shadow="never">
              <template #header>近期照片</template>
              <div v-if="overview.recentMedia && overview.recentMedia.length" class="thumbs">
                <div v-for="item in overview.recentMedia" :key="item.mediaId" class="thumb">
                  <img v-if="item.mediaType !== 'video'" :src="mediaPreviewSrc(item.mediaId)" :alt="item.fileName" />
                  <div v-else class="video-placeholder">视频</div>
                </div>
              </div>
              <el-empty v-else description="相册还是空的" />
            </el-card>
          </el-col>
        </el-row>
      </template>
    </template>

    <el-dialog :title="guide.title" v-model="guideOpen" width="560px" append-to-body>
      <pre class="guide-body">{{ guide.content }}</pre>
    </el-dialog>
  </div>
</template>

<script setup name="NursingDashboard">
import { getTodayOverview, getAdminOverview, getKnowledge } from "@/api/nursing/dashboard";
import { mediaPreviewSrc } from "@/api/nursing/media";
import { toggleCare } from "@/api/nursing/care";
import { markMentionRead, markAllMentionsRead } from "@/api/nursing/collab";
import { formatMinutes, nowDate } from "@/utils/nursingLock";
import useNursingStore from "@/store/modules/nursing";
import useUserStore from "@/store/modules/user";
import { useRouter } from "vue-router";
import * as echarts from "echarts";

const router = useRouter();
const nursingStore = useNursingStore();
const userStore = useUserStore();
const isAdmin = computed(() => Number(userStore.id) === 1);
const adminMode = ref(true);
const admin = ref({});
const overview = ref({});
const guideOpen = ref(false);
const guide = ref({ title: "", content: "" });
const miniChartRef = ref(null);
let miniChart = null;

function loadAdmin() {
  getAdminOverview().then(res => {
    admin.value = res.data || {};
  }).catch(() => {
    admin.value = {};
  });
}

function loadToday() {
  if (!nursingStore.currentBabyId) {
    overview.value = {};
    return;
  }
  getTodayOverview(nursingStore.currentBabyId).then(res => {
    overview.value = res.data || {};
    nextTick(() => renderMiniChart());
  }).catch(() => {
    overview.value = {};
  });
}

function inspectBaby(card) {
  nursingStore.switchBaby(card.babyId);
  adminMode.value = false;
  loadToday();
}

function backAdmin() {
  adminMode.value = true;
  loadAdmin();
}

function goCreateBaby() {
  router.push("/overview/baby");
}

function renderMiniChart() {
  const points = overview.value.growthPoints || [];
  if (!miniChartRef.value) {
    return;
  }
  if (!points.length) {
    if (miniChart) {
      miniChart.dispose();
      miniChart = null;
    }
    return;
  }
  if (!miniChart) {
    miniChart = echarts.init(miniChartRef.value);
  }
  miniChart.setOption({
    grid: { left: 32, right: 12, top: 16, bottom: 24 },
    xAxis: {
      type: "category",
      data: points.map(item => (item.measureDate || "").toString().slice(0, 10)),
      axisLabel: { fontSize: 10 }
    },
    yAxis: { type: "value", name: "kg", nameTextStyle: { fontSize: 10 } },
    series: [{
      type: "line",
      smooth: true,
      data: points.map(item => item.weightKg),
      itemStyle: { color: "#DE8F74" },
      areaStyle: { color: "rgba(222, 143, 116, 0.18)" }
    }]
  });
}

function completeCare(item) {
  toggleCare({
    babyId: nursingStore.currentBabyId,
    itemId: item.itemId,
    careDate: nowDate(),
    completed: "1"
  }).then(() => loadToday());
}

function openGuide(item) {
  if (item.level !== "red" || !item.kbId) {
    return;
  }
  getKnowledge(item.kbId).then(res => {
    guide.value = { title: res.data.title, content: res.data.content };
    guideOpen.value = true;
  }).catch(() => {});
}

function readMention(item) {
  markMentionRead(item.mentionId).then(() => loadToday());
}

function readAllMentions() {
  markAllMentionsRead(nursingStore.currentBabyId).then(() => loadToday());
}

watch(() => nursingStore.currentBabyId, () => {
  if (!isAdmin.value || !adminMode.value) {
    loadToday();
  }
});

onMounted(() => {
  if (isAdmin.value) {
    adminMode.value = true;
    loadAdmin();
  } else {
    loadToday();
  }
  window.addEventListener('nursing-saved', onRecordSaved);
});

onUnmounted(() => {
  window.removeEventListener('nursing-saved', onRecordSaved);
});

function onRecordSaved() {
  if (isAdmin.value && adminMode.value) {
    loadAdmin();
  } else {
    loadToday();
  }
}
</script>

<style scoped>
.sub { color: #606266; }
.gap { margin-left: 16px; }
.stat-card { margin-bottom: 16px; }
.label { color: #909399; font-size: 13px; }
.value { font-size: 26px; font-weight: 600; margin: 8px 0 4px; }
.unit { font-size: 14px; font-weight: 400; color: #909399; }
.extra { color: #909399; font-size: 12px; }
.danger { color: #f56c6c; }
.mt16 { margin-top: 8px; }
.todo-row { display: flex; justify-content: space-between; align-items: center; padding: 8px 0; border-bottom: 1px solid #f5f5f5; }
.alert-bar { border-radius: 8px; padding: 12px 16px; margin-bottom: 8px; }
.alert-bar.red { background: #fef0f0; color: #c45656; cursor: pointer; }
.alert-bar.yellow { background: #fdf6ec; color: #b88230; }
.alert-bar .link { font-size: 12px; }
.guide-body { white-space: pre-wrap; font-family: inherit; line-height: 1.6; }
.mention-row { display: flex; justify-content: space-between; gap: 12px; padding: 8px 0; border-bottom: 1px solid #f4ece2; }
.thumbs { display: grid; grid-template-columns: repeat(3, 1fr); gap: 8px; }
.thumb { height: 88px; border-radius: 10px; overflow: hidden; background: #f4ece2; }
.thumb img { width: 100%; height: 100%; object-fit: cover; }
.video-placeholder { height: 100%; display: flex; align-items: center; justify-content: center; color: #909399; font-size: 12px; }
.back-link { float: right; }
.baby-card { margin-bottom: 16px; cursor: pointer; border: 1px solid #efe3d6; }
.baby-card.red { border-color: #e8b4ae; background: #fff8f6; }
.baby-card.yellow { border-color: #ead3a8; background: #fffdf6; }
.baby-card-head { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 6px; }
.tag-line { font-size: 12px; margin: 8px 0; }
.tag-line.red { color: #c45656; }
.tag-line.yellow, .tag-line.warn { color: #b88230; }
</style>
