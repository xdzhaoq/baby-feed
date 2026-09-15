<template>
  <div class="app-container nursing-page">
    <el-alert title="分级只给家人一个判断方向，不能替代医生诊断。" type="info" :closable="false" class="mb8" />

    <el-form :inline="true" class="mb8">
      <el-form-item>
        <el-input v-model="keyword" placeholder="搜索关键词，如：发烧、黄疸、脐带" clearable style="width: 280px" @keyup.enter="loadList" />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" icon="Search" @click="loadList">搜索</el-button>
      </el-form-item>
    </el-form>

    <el-radio-group v-model="category" class="mb8" @change="loadList">
      <el-radio-button label="">全部</el-radio-button>
      <el-radio-button label="emergency">急救</el-radio-button>
      <el-radio-button label="feeding">喂养</el-radio-button>
      <el-radio-button label="sleep">睡眠</el-radio-button>
      <el-radio-button label="care">护理</el-radio-button>
    </el-radio-group>

    <el-empty v-if="!list.length" description="没有匹配的条目" />

    <el-row :gutter="16">
      <el-col v-for="item in list" :key="item.kbId" :xs="24" :sm="12" :md="8">
        <el-card shadow="never" class="kb-card" @click="openItem(item)">
          <div class="stars">{{ stars(item.urgency) }}</div>
          <div class="level">{{ levelText(item.urgency) }}</div>
          <h3>{{ item.title }}</h3>
          <div class="keys">{{ item.keywords }}</div>
        </el-card>
      </el-col>
    </el-row>

    <el-dialog :title="current.title" v-model="open" width="640px" append-to-body>
      <div class="stars">{{ stars(current.urgency) }} {{ levelText(current.urgency) }}</div>
      <pre class="body">{{ current.content }}</pre>
    </el-dialog>
  </div>
</template>

<script setup name="NursingKnowledge">
import { listKnowledge } from "@/api/nursing/dashboard";

const keyword = ref("");
const category = ref("emergency");
const list = ref([]);
const open = ref(false);
const current = ref({});

function stars(urgency) {
  const n = Number(urgency) || 1;
  if (n >= 5) {
    return "⭐⭐⭐⭐⭐";
  }
  if (n >= 3) {
    return "⭐⭐⭐";
  }
  return "⭐";
}

function levelText(urgency) {
  const n = Number(urgency) || 1;
  if (n >= 5) {
    return "立即拨打 120";
  }
  if (n >= 3) {
    return "尽快就医";
  }
  return "居家观察";
}

function loadList() {
  listKnowledge(category.value, keyword.value).then(res => {
    list.value = res.data || [];
  }).catch(() => {
    list.value = [];
  });
}

function openItem(item) {
  current.value = item;
  open.value = true;
}

loadList();
</script>

<style scoped>
.kb-card {
  margin-bottom: 16px;
  cursor: pointer;
  border-radius: 16px;
  min-height: 150px;
}
.kb-card:hover { box-shadow: 0 8px 24px rgba(201, 111, 82, 0.12); }
.stars { letter-spacing: 2px; }
.level { color: #c96f52; font-size: 13px; margin: 4px 0 8px; }
h3 { margin: 0 0 8px; font-size: 16px; }
.keys { color: #909399; font-size: 12px; }
.body { white-space: pre-wrap; font-family: inherit; line-height: 1.7; }
</style>
