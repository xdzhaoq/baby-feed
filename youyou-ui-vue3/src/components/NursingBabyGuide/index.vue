<template>
  <div v-if="!nursingStore.currentBabyId" class="baby-guide">
    <div class="baby-guide-title">先选定要照看的宝宝</div>
    <p v-if="nursingStore.babyList.length">
      右上角「当前宝宝」已经能选了。选好一位后，喂养、睡眠这些记录才会记到对应宝宝名下。
    </p>
    <p v-else>
      现在还没有任何宝宝档案。请超管用「总览 → 宝宝档案」新建一位宝宝，并填好妈妈登录名。建好后，顶栏会出现下拉框。
    </p>
    <div class="baby-guide-ops">
      <el-select
        v-if="nursingStore.babyList.length"
        :model-value="nursingStore.currentBabyId"
        placeholder="选择当前宝宝"
        style="width: 220px"
        @change="onSwitch"
      >
        <el-option
          v-for="item in nursingStore.babyList"
          :key="item.babyId"
          :label="item.babyName"
          :value="item.babyId"
        />
      </el-select>
      <el-button v-if="canCreate" type="primary" @click="goCreate">去新建宝宝档案</el-button>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from "vue-router";
import useNursingStore from "@/store/modules/nursing";
import { checkPermi } from "@/utils/permission";

const router = useRouter();
const nursingStore = useNursingStore();
const canCreate = computed(() => checkPermi(["nursing:baby:add"]));

function onSwitch(babyId) {
  nursingStore.switchBaby(babyId);
}

function goCreate() {
  router.push("/overview/baby");
}
</script>

<style scoped>
.baby-guide {
  background: #fff9f3;
  border: 1px solid #efe3d6;
  border-radius: 16px;
  padding: 20px 22px;
  margin-bottom: 16px;
  box-shadow: 0 6px 18px rgba(176, 142, 110, 0.1);
}
.baby-guide-title {
  font-weight: 600;
  color: #c96f52;
  margin-bottom: 8px;
}
.baby-guide p {
  color: #6e5f55;
  margin: 0 0 14px;
  line-height: 1.6;
}
.baby-guide-ops {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
}
</style>
