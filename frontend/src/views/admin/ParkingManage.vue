<template>
  <div class="parking-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>停车管理</span>
          <el-input
            v-model="searchPlate"
            placeholder="搜索车牌号"
            clearable
            style="width: 200px"
            @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon><Search /></el-icon>
            </template>
          </el-input>
        </div>
      </template>

      <el-table :data="records" v-loading="loading" stripe>
        <el-table-column prop="plateNumber" label="车牌号" width="120">
          <template #default="{ row }">
            <div class="plate-number">
              <el-icon><Car /></el-icon>
              <span>{{ row.plateNumber }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="entryTime" label="入场时间" width="180" />
        <el-table-column prop="entryGate" label="入口" width="100" />
        <el-table-column prop="spaceCode" label="车位" width="100">
          <template #default="{ row }">
            <el-tag v-if="row.spaceCode" size="small" type="info">
              {{ row.spaceCode }}
            </el-tag>
            <span v-else class="text-muted">--</span>
          </template>
        </el-table-column>
        <el-table-column prop="parkingDuration" label="停车时长" width="120">
          <template #default="{ row }">
            <span v-if="row.parkingDuration">{{ formatDuration(row.parkingDuration) }}</span>
            <span v-else class="text-muted">进行中</span>
          </template>
        </el-table-column>
        <el-table-column prop="payStatus" label="支付状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getPayStatusType(row.payStatus)" size="small">
              {{ getPayStatusText(row.payStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="payableAmount" label="应付金额" width="100">
          <template #default="{ row }">
            <span class="amount">¥{{ row.payableAmount?.toFixed(2) || '0.00' }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="showDetail(row)">
              详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="pagination"
        v-model:current-page="page"
        v-model:page-size="size"
        :total="total"
        :page-sizes="[10, 20, 50]"
        layout="total, sizes, prev, pager, next"
        @current-change="fetchRecords"
        @size-change="fetchRecords"
      />
    </el-card>

    <!-- 车辆详情对话框 -->
    <el-dialog
      v-model="detailVisible"
      title="车辆详情"
      width="900px"
      destroy-on-close
      class="detail-dialog"
    >
      <div v-loading="detailLoading" class="detail-content">
        <!-- 当前停车信息 -->
        <div class="current-info">
          <h4>当前停车信息</h4>
          <el-descriptions :column="3" border>
            <el-descriptions-item label="车牌号">{{ currentVehicle?.plateNumber }}</el-descriptions-item>
            <el-descriptions-item label="车位">{{ currentVehicle?.spaceCode || '--' }}</el-descriptions-item>
            <el-descriptions-item label="入场时间">{{ currentVehicle?.entryTime }}</el-descriptions-item>
            <el-descriptions-item label="停车时长">
              {{ currentVehicle?.parkingDuration ? formatDuration(currentVehicle.parkingDuration) : '进行中' }}
            </el-descriptions-item>
            <el-descriptions-item label="应付金额">¥{{ currentVehicle?.payableAmount?.toFixed(2) || '0.00' }}</el-descriptions-item>
            <el-descriptions-item label="支付状态">
              <el-tag :type="getPayStatusType(currentVehicle?.payStatus)" size="small">
                {{ getPayStatusText(currentVehicle?.payStatus) }}
              </el-tag>
            </el-descriptions-item>
          </el-descriptions>
        </div>

        <!-- 最近停车记录 -->
        <div class="recent-records">
          <h4>近5次停车记录</h4>
          <el-table :data="recentRecords" size="small" stripe max-height="250">
            <el-table-column prop="entryTime" label="入场时间" width="160" />
            <el-table-column prop="exitTime" label="出场时间" width="160">
              <template #default="{ row }">
                <span v-if="row.exitTime">{{ row.exitTime }}</span>
                <span v-else class="text-muted">--</span>
              </template>
            </el-table-column>
            <el-table-column prop="parkingDuration" label="停车时长" width="120">
              <template #default="{ row }">
                <span v-if="row.parkingDuration">{{ formatDuration(row.parkingDuration) }}</span>
                <span v-else class="text-muted">--</span>
              </template>
            </el-table-column>
            <el-table-column prop="actualAmount" label="实付金额" width="100">
              <template #default="{ row }">
                <span class="amount">¥{{ row.actualAmount?.toFixed(2) || '0.00' }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="payStatus" label="状态" width="100">
              <template #default="{ row }">
                <el-tag :type="getPayStatusType(row.payStatus)" size="small">
                  {{ getPayStatusText(row.payStatus) }}
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Search, Car } from '@element-plus/icons-vue'
import { getRecords, getVehicleDetail } from '@/api/parking'

const records = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)
const searchPlate = ref('')

// 详情相关
const detailVisible = ref(false)
const detailLoading = ref(false)
const currentVehicle = ref(null)
const recentRecords = ref([])

const fetchRecords = async () => {
  loading.value = true
  try {
    const params = {
      page: page.value,
      size: size.value,
      status: 0
    }
    if (searchPlate.value.trim()) {
      params.plateNumber = searchPlate.value.trim()
    }
    const res = await getRecords(params)
    records.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
    ElMessage.error('获取停车记录失败')
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  page.value = 1
  fetchRecords()
}

const showDetail = async (row) => {
  detailVisible.value = true
  detailLoading.value = true
  currentVehicle.value = row

  try {
    // 调用API获取车辆详情和最近停车记录
    const res = await getVehicleDetail(row.plateNumber)
    if (res) {
      currentVehicle.value = { ...row, ...res.vehicleInfo }
      recentRecords.value = res.recentRecords || []
    }
  } catch (error) {
    console.error(error)
    // 如果API失败，只显示当前记录
    recentRecords.value = []
  } finally {
    detailLoading.value = false
  }
}

const formatDuration = (minutes) => {
  if (!minutes) return '--'
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  if (hours > 0) {
    return `${hours}小时${mins > 0 ? mins + '分钟' : ''}`
  }
  return `${mins}分钟`
}

const getPayStatusType = (status) => {
  const map = { 0: 'danger', 1: 'success', 2: 'info', 3: 'warning' }
  return map[status] || 'info'
}

const getPayStatusText = (status) => {
  const map = { 0: '未支付', 1: '已支付', 2: '免费', 3: '欠费' }
  return map[status] || '未知'
}

onMounted(fetchRecords)
</script>

<style scoped lang="scss">
.parking-manage {
  padding: 24px;
  height: 100%;
  box-sizing: border-box;

  :deep(.el-card) {
    height: 100%;
    display: flex;
    flex-direction: column;

    .el-card__body {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;

    span {
      font-size: 18px;
      font-weight: 600;
      color: #1e293b;
    }
  }

  .plate-number {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 600;
    color: #2563eb;

    .el-icon {
      font-size: 16px;
    }
  }

  .amount {
    font-weight: 600;
    color: #f59e0b;
  }

  .text-muted {
    color: #94a3b8;
  }

  .el-table {
    flex: 1;
    overflow: auto;
  }

  .pagination {
    margin-top: 20px;
    justify-content: flex-end;
    flex-shrink: 0;
  }
}

// 详情对话框样式
.detail-dialog {
  :deep(.el-dialog__body) {
    padding: 20px;
  }
}

.detail-content {
  h4 {
    font-size: 16px;
    font-weight: 600;
    color: #1e293b;
    margin: 0 0 16px 0;
    padding-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
  }

  .current-info {
    margin-bottom: 24px;
  }

  .recent-records {
    .amount {
      font-weight: 600;
      color: #f59e0b;
    }

    .text-muted {
      color: #94a3b8;
    }
  }
}

// 响应式
@media (max-width: 768px) {
  .parking-manage {
    padding: 16px;

    .card-header {
      flex-direction: column;
      align-items: stretch;

      .el-input {
        width: 100% !important;
      }
    }

    .pagination {
      justify-content: center;
    }
  }

}
</style>
