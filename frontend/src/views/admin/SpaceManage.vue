<template>
  <div class="space-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>车位管理</span>
          <el-radio-group v-model="filterStatus" @change="fetchSpaces">
            <el-radio-button label="">全部</el-radio-button>
            <el-radio-button :label="0">空闲</el-radio-button>
            <el-radio-button :label="1">占用</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-row :gutter="20">
        <el-col :span="6" v-for="space in spaces" :key="space.spaceId">
          <el-card
            class="space-card"
            :class="{ 'occupied': space.status === 1 }"
            shadow="hover"
          >
            <div class="space-info">
              <div class="space-code">{{ space.spaceCode }}</div>
              <div class="space-type">{{ space.spaceType }}</div>
              <el-tag :type="space.status === 0 ? 'success' : 'danger'">
                {{ space.status === 0 ? '空闲' : '占用' }}
              </el-tag>
              <div v-if="space.currentPlate" class="current-plate">
                {{ space.currentPlate }}
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getSpaces } from '@/api/parking'

const spaces = ref([])
const filterStatus = ref('')

const fetchSpaces = async () => {
  try {
    const res = await getSpaces()
    spaces.value = filterStatus.value !== ''
      ? res.filter(s => s.status === filterStatus.value)
      : res
  } catch (error) {
    console.error(error)
  }
}

onMounted(fetchSpaces)
</script>

<style scoped lang="scss">
.space-manage {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .space-card {
    margin-bottom: 20px;
    text-align: center;

    &.occupied {
      background-color: #fef0f0;
    }

    .space-info {
      .space-code {
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 10px;
      }

      .space-type {
        color: #909399;
        margin-bottom: 10px;
      }

      .current-plate {
        margin-top: 10px;
        color: #f56c6c;
        font-weight: bold;
      }
    }
  }
}
</style>
