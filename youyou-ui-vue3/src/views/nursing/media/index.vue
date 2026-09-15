<template>
  <div class="app-container nursing-page">
    <nursing-baby-guide />

    <template v-if="nursingStore.currentBabyId">
      <el-alert
        title="文件保存在家庭服务器（按宝宝隔离）"
        type="info"
        :closable="false"
        class="mb8"
        description="照片和视频写入本机 RustFS，按当前宝宝目录存放，不会上传到第三方云。"
      />

      <div class="album-toolbar">
        <div class="album-toolbar-group">
          <span class="bar-label">查看</span>
          <el-select v-model="queryParams.tagCode" placeholder="全部标签" clearable style="width: 140px" @change="getList">
            <el-option v-for="dict in nc_media_tag" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </div>
        <div class="album-toolbar-group">
          <span class="bar-label">上传到</span>
          <el-select v-model="uploadTag" style="width: 120px">
            <el-option v-for="dict in nc_media_tag" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
          <el-upload
            ref="uploadRef"
            class="album-upload"
            :http-request="httpRequest"
            :show-file-list="false"
            :multiple="true"
            :limit="12"
            :on-exceed="onExceed"
            :on-change="onUploadChange"
            accept=".jpg,.jpeg,.png,.webp,.gif,.mp4,image/jpeg,image/png,image/webp,image/gif,video/mp4"
            v-hasPermi="['nursing:media:add']"
          >
            <el-button type="primary" icon="Upload">上传照片/视频</el-button>
          </el-upload>
          <el-button type="success" plain icon="Download" :disabled="!selectedIds.length" @click="handleBatchDownload" v-hasPermi="['nursing:media:download']">批量下载</el-button>
          <el-button type="danger" plain icon="Delete" :disabled="!selectedIds.length" @click="handleBatchDelete" v-hasPermi="['nursing:media:remove']">批量删除</el-button>
        </div>
      </div>

      <el-empty v-if="!loading && !mediaList.length" description="还没有照片或视频，先上传一张吧" />

      <div v-loading="loading">
        <div v-for="group in groupedMedia" :key="group.day" class="day-block">
          <div class="day-label">{{ group.day }}</div>
          <div class="media-grid">
            <div v-for="item in group.items" :key="item.mediaId" class="media-card" :class="{ selected: selectedIds.includes(item.mediaId) }">
              <el-checkbox class="pick" :model-value="selectedIds.includes(item.mediaId)" @change="toggleSelect(item.mediaId)" />
              <div class="thumb" @click="openViewer(item)">
                <img v-if="item.mediaType !== 'video'" :src="mediaPreviewSrc(item.mediaId)" :alt="item.fileName" @error="onPreviewError" />
                <div v-else class="video-placeholder">
                  <span class="play">▶</span>
                </div>
                <span v-if="item.mediaType === 'video'" class="badge">视频</span>
              </div>
              <div class="meta">
                <dict-tag :options="nc_media_tag" :value="item.tagCode" />
                <div class="name" :title="item.fileName">{{ item.fileName }}</div>
                <div class="sub">
                  <span class="who"><span class="who-ava">{{ (item.uploaderName || "?").slice(0, 1) }}</span>{{ item.uploaderName }}</span>
                  · {{ parseTime(item.createTime, "{h}:{i}") }}
                </div>
                <div class="ops">
                  <el-button link type="primary" @click="openViewer(item)">查看</el-button>
                  <el-button link type="primary" @click="handleEdit(item)" v-hasPermi="['nursing:media:edit']">备注</el-button>
                  <el-button link type="primary" @click="handleDownload(item)" v-hasPermi="['nursing:media:download']">下载</el-button>
                  <el-button link type="danger" @click="handleDelete(item)" v-hasPermi="['nursing:media:remove']">删除</el-button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <pagination v-show="total > 0" :total="total" v-model:page="queryParams.pageNum" v-model:limit="queryParams.pageSize" @pagination="getList" />
    </template>

    <el-dialog v-model="viewerOpen" width="820px" append-to-body class="lightbox">
      <template #header>
        <span>{{ current?.fileName }}</span>
      </template>
      <div class="viewer" v-if="current">
        <el-button class="nav prev" circle icon="ArrowLeft" @click="shift(-1)" />
        <video v-if="current.mediaType === 'video'" :key="'v-' + current.mediaId" :src="mediaPreviewSrc(current.mediaId)" controls style="max-width: 100%; max-height: 70vh" />
        <img v-else :key="'i-' + current.mediaId" :src="mediaPreviewSrc(current.mediaId)" :alt="current.fileName" style="max-width: 100%; max-height: 70vh" />
        <el-button class="nav next" circle icon="ArrowRight" @click="shift(1)" />
      </div>
      <div v-if="current" class="viewer-meta">
        <div>{{ current.description || "还没有文字描述" }}</div>
        <div class="sub">上传者 {{ current.uploaderName }} · {{ parseTime(current.createTime) }}</div>
        <div v-if="current.healthCheckDate" class="sub">关联自检 {{ parseTime(current.healthCheckDate, "{y}-{m}-{d}") }}</div>
      </div>
    </el-dialog>

    <el-dialog title="修改标签与描述" v-model="editOpen" width="480px" append-to-body>
      <el-form ref="formRef" :model="form" label-width="90px">
        <el-form-item label="标签">
          <el-select v-model="form.tagCode" style="width: 100%">
            <el-option v-for="dict in nc_media_tag" :key="dict.value" :label="dict.label" :value="dict.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述">
          <el-input v-model="form.description" type="textarea" :rows="3" maxlength="500" show-word-limit />
        </el-form-item>
        <el-form-item label="关联自检">
          <el-select v-model="form.healthCheckId" clearable placeholder="可选" style="width: 100%">
            <el-option v-for="item in healthOptions" :key="item.checkId" :label="parseTime(item.checkDate, '{y}-{m}-{d}')" :value="item.checkId" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button type="primary" @click="submitEdit">确 定</el-button>
        <el-button @click="editOpen = false">取 消</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup name="NursingMedia">
import { listMedia, uploadMedia, updateMedia, delMedia, downloadMediaFile, downloadMediaBatch, mediaPreviewSrc } from "@/api/nursing/media";
import { listHealth } from "@/api/nursing/health";
import useNursingStore from "@/store/modules/nursing";

const { proxy } = getCurrentInstance();
const { nc_media_tag } = proxy.useDict("nc_media_tag");
const nursingStore = useNursingStore();

const loading = ref(false);
const uploadRef = ref();
const mediaList = ref([]);
const total = ref(0);
const selectedIds = ref([]);
const uploadTag = ref("daily");
const viewerOpen = ref(false);
const currentIndex = ref(0);
const editOpen = ref(false);
const form = ref({});
const healthOptions = ref([]);
const queryParams = reactive({
  pageNum: 1,
  pageSize: 12,
  babyId: undefined,
  tagCode: undefined
});

const current = computed(() => mediaList.value[currentIndex.value] || null);

const groupedMedia = computed(() => {
  const buckets = [];
  const index = {};
  mediaList.value.forEach(item => {
    const day = proxy.parseTime(item.createTime, "{y}-{m}-{d}") || "未标注日期";
    if (!index[day]) {
      index[day] = { day, items: [] };
      buckets.push(index[day]);
    }
    index[day].items.push(item);
  });
  return buckets;
});

function getList() {
  if (!nursingStore.currentBabyId) {
    mediaList.value = [];
    return;
  }
  loading.value = true;
  queryParams.babyId = nursingStore.currentBabyId;
  listMedia(queryParams).then(res => {
    mediaList.value = res.rows || [];
    total.value = res.total || 0;
    selectedIds.value = selectedIds.value.filter(id => mediaList.value.some(item => item.mediaId === id));
  }).finally(() => {
    loading.value = false;
  });
}

function loadHealth() {
  if (!nursingStore.currentBabyId) {
    return;
  }
  listHealth({ babyId: nursingStore.currentBabyId, pageNum: 1, pageSize: 90 }).then(res => {
    healthOptions.value = res.rows || [];
  }).catch(() => {
    healthOptions.value = [];
  });
}

function httpRequest(options) {
  const formData = new FormData();
  formData.append("file", options.file);
  formData.append("babyId", nursingStore.currentBabyId);
  formData.append("tagCode", uploadTag.value || "daily");
  return uploadMedia(formData, event => {
    if (event.total) {
      options.onProgress({ percent: Math.round((event.loaded / event.total) * 100) });
    }
  }).then(() => {
    options.onSuccess();
    proxy.$modal.msgSuccess("已保存到家庭服务器");
    getList();
  }).catch(err => {
    options.onError(err);
  });
}

function onExceed() {
  proxy.$modal.msgWarning("一次最多选择 12 个文件");
}

function onUploadChange(file, fileList) {
  const busy = fileList.some(item => item.status === "uploading" || item.status === "ready");
  if (!busy) {
    uploadRef.value && uploadRef.value.clearFiles();
  }
}

function onPreviewError(event) {
  const el = event && event.target;
  if (el && el.style) {
    el.style.display = "none";
    if (el.parentNode && !el.parentNode.querySelector(".no-url")) {
      const hint = document.createElement("div");
      hint.className = "no-url";
      hint.textContent = "家庭存储暂时无法预览";
      el.parentNode.appendChild(hint);
    }
  }
}

function toggleSelect(id) {
  const idx = selectedIds.value.indexOf(id);
  if (idx >= 0) {
    selectedIds.value.splice(idx, 1);
  } else {
    selectedIds.value.push(id);
  }
}

function openViewer(item) {
  currentIndex.value = mediaList.value.findIndex(row => row.mediaId === item.mediaId);
  viewerOpen.value = true;
}

function shift(step) {
  if (!mediaList.value.length) {
    return;
  }
  const next = currentIndex.value + step;
  if (next < 0 || next >= mediaList.value.length) {
    return;
  }
  currentIndex.value = next;
}

function handleEdit(item) {
  form.value = {
    mediaId: item.mediaId,
    babyId: item.babyId,
    tagCode: item.tagCode,
    description: item.description,
    healthCheckId: item.healthCheckId
  };
  loadHealth();
  editOpen.value = true;
}

function submitEdit() {
  updateMedia(form.value).then(() => {
    proxy.$modal.msgSuccess("已更新");
    editOpen.value = false;
    getList();
  });
}

function handleDownload(item) {
  downloadMediaFile(item.mediaId, item.fileName);
}

function handleDelete(item) {
  proxy.$modal.confirm("删除后会同时从家庭服务器移除文件，确定吗？").then(() => {
    return delMedia(item.mediaId, nursingStore.currentBabyId);
  }).then(() => {
    proxy.$modal.msgSuccess("已删除");
    getList();
  }).catch(() => {});
}

function handleBatchDelete() {
  proxy.$modal.confirm("将删除选中的 " + selectedIds.value.length + " 个文件，并同步删除家庭服务器对象。").then(() => {
    return delMedia(selectedIds.value.join(","), nursingStore.currentBabyId);
  }).then(() => {
    proxy.$modal.msgSuccess("已删除");
    selectedIds.value = [];
    getList();
  }).catch(() => {});
}

function handleBatchDownload() {
  downloadMediaBatch(nursingStore.currentBabyId, selectedIds.value);
}

watch(() => nursingStore.currentBabyId, () => {
  queryParams.pageNum = 1;
  selectedIds.value = [];
  getList();
});

getList();
</script>

<style scoped>
.album-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 12px 20px;
  margin-bottom: 16px;
}
.album-toolbar-group {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 8px;
}
.bar-label {
  color: #909399;
  font-size: 13px;
  white-space: nowrap;
}
.album-upload :deep(.el-upload-list) {
  display: none;
}
.media-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
  gap: 16px;
}
.day-block { margin-bottom: 20px; }
.day-label { font-weight: 600; color: #c96f52; margin-bottom: 10px; }
.media-card {
  background: #fff;
  border-radius: 16px;
  overflow: hidden;
  position: relative;
  box-shadow: 0 8px 24px rgba(201, 111, 82, 0.08);
}
.media-card.selected {
  outline: 2px solid var(--pri, #de8f74);
}
.pick {
  position: absolute;
  top: 8px;
  left: 8px;
  z-index: 2;
}
.thumb {
  height: 160px;
  background: #f4ece2;
  cursor: pointer;
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}
.thumb img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.no-url { color: #909399; font-size: 12px; padding: 12px; text-align: center; }
.video-placeholder {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e8ddd2;
}
.video-placeholder .play {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: rgba(0, 0, 0, 0.45);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  padding-left: 3px;
}
.badge {
  position: absolute;
  right: 8px;
  bottom: 8px;
  background: rgba(0, 0, 0, 0.55);
  color: #fff;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 10px;
}
.meta { padding: 10px 12px 8px; }
.name { margin-top: 4px; font-size: 13px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.sub { color: #909399; font-size: 12px; margin-top: 4px; }
.ops { margin-top: 4px; }
.viewer { display: flex; align-items: center; justify-content: center; position: relative; min-height: 240px; }
.nav { position: absolute; top: 50%; transform: translateY(-50%); }
.nav.prev { left: 0; }
.nav.next { right: 0; }
.viewer-meta { margin-top: 12px; }
</style>
