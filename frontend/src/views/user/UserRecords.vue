<template>
  <div class="user-records">
    <el-card class="search-card">
      <template #header>
        <div class="card-header">
          <span class="title">查询我的停车记录</span>
          <span class="subtitle">输入车牌号查询在该停车场的所有记录</span>
        </div>
      </template>

      <div class="search-box">
        <el-input
          v-model="plateNumber"
          placeholder="请输入车牌号，如：京A·12345"
          size="large"
          clearable
          @keyup.enter="handleSearch"
          class="plate-input"
        >
          <template #prefix>
            <el-icon><Van /></el-icon>
          </template>
        </el-input>
        <el-button
          type="primary"
          size="large"
          :loading="loading"
          @click="handleSearch"
          class="search-btn"
        >
          <el-icon><Search /></el-icon>
          查询记录
        </el-button>
      </div>

      <!-- 快捷车牌选择 -->
      <div v-if="savedPlates.length > 0" class="quick-plates">
        <span class="label">常用车牌：</span>
        <el-tag
          v-for="plate in savedPlates"
          :key="plate"
          class="plate-tag"
          effect="plain"
          @click="plateNumber = plate"
        >
          {{ plate }}
        </el-tag>
      </div>
    </el-card>

    <!-- 统计信息 -->
    <el-row v-if="records.length > 0" :gutter="16" class="stats-row">
      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-value">{{ records.length }}</div>
          <div class="stat-label">总记录数</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-value">{{ unpaidCount }}</div>
          <div class="stat-label">待支付</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-value">¥{{ totalPaid }}</div>
          <div class="stat-label">已支付</div>
        </div>
      </el-col>
      <el-col :span="6">
        <div class="stat-card">
          <div class="stat-value">¥{{ totalUnpaid }}</div>
          <div class="stat-label">待支付金额</div>
        </div>
      </el-col>
    </el-row>

    <!-- 记录列表 -->
    <el-card v-if="records.length > 0" class="records-card">
      <template #header>
        <div class="card-header">
          <span>查询结果</span>
          <el-tag type="info">{{ plateNumber }}</el-tag>
        </div>
      </template>

      <el-table :data="records" stripe v-loading="loading">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="plateNumber" label="车牌号" width="120" />
        <el-table-column prop="entryTime" label="入场时间" width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.entryTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="exitTime" label="出场时间" width="160">
          <template #default="{ row }">
            {{ row.exitTime ? formatDateTime(row.exitTime) : '停车中' }}
          </template>
        </el-table-column>
        <el-table-column prop="parkingMinutes" label="停车时长" width="100">
          <template #default="{ row }">
            {{ row.parkingMinutes ? formatDuration(row.parkingMinutes) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="payableAmount" label="应付金额" width="100">
          <template #default="{ row }">
            <span :class="{ 'unpaid': row.payStatus === 0 }">
              ¥{{ row.payableAmount || 0 }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="payStatus" label="支付状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getPayStatusType(row.payStatus)">
              {{ getPayStatusText(row.payStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.payStatus === 0 && row.status === 1"
              type="primary"
              size="small"
              @click="handlePay(row)"
            >
              支付
            </el-button>
            <el-tag v-else-if="row.payStatus === 1" type="success" size="small">
              已完成
            </el-tag>
            <el-tag v-else-if="row.payStatus === 2" type="info" size="small">
              免费
            </el-tag>
            <el-tag v-else-if="row.status === 0" type="warning" size="small">
              停车中
            </el-tag>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 空状态 -->
    <el-empty
      v-else-if="searched"
      description="未找到该车牌的停车记录"
      class="empty-state"
    >
      <el-button type="primary" @click="plateNumber = ''; searched = false">
        重新查询
      </el-button>
    </el-empty>

    <!-- 支付对话框 -->
    <el-dialog
      v-model="payDialogVisible"
      title="支付停车费用"
      width="400px"
      center
    >
      <div v-if="currentRecord" class="pay-dialog-content">
        <div class="pay-info">
          <div class="info-row">
            <span class="label">车牌号：</span>
            <span class="value">{{ currentRecord.plateNumber }}</span>
          </div>
          <div class="info-row">
            <span class="label">入场时间：</span>
            <span class="value">{{ formatDateTime(currentRecord.entryTime) }}</span>
          </div>
          <div class="info-row">
            <span class="label">出场时间：</span>
            <span class="value">{{ formatDateTime(currentRecord.exitTime) }}</span>
          </div>
          <div class="info-row">
            <span class="label">停车时长：</span>
            <span class="value">{{ formatDuration(currentRecord.parkingMinutes) }}</span>
          </div>
        </div>

        <div class="pay-amount">
          <span class="label">应付金额：</span>
          <span class="amount">¥{{ currentRecord.payableAmount }}</span>
        </div>

        <div class="pay-methods">
          <div
            v-for="method in payMethods"
            :key="method.value"
            class="pay-method"
            :class="{ active: selectedPayMethod === method.value }"
            @click="selectedPayMethod = method.value"
          >
            <el-icon size="24"><component :is="method.icon" /></el-icon>
            <span>{{ method.label }}</span>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button @click="payDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="payLoading" @click="confirmPay">
          确认支付 ¥{{ currentRecord?.payableAmount }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Van, Search } from '@element-plus/icons-vue'
import { getRecordsByPlate, payRecord } from '@/api/parking'

const plateNumber = ref('')
const records = ref([])
const loading = ref(false)
const searched = ref(false)
const savedPlates = ref([])

// 支付相关
const payDialogVisible = ref(false)
const currentRecord = ref(null)
const selectedPayMethod = ref('wechat')
const payLoading = ref(false)

const payMethods = [
  { value: 'wechat', label: '微信支付', icon: 'ChatDotRound' },
  { value: 'alipay', label: '支付宝', icon: 'Money' }
]

// 统计信息
const unpaidCount = computed(() => {
  return records.value.filter(r => r.payStatus === 0).length
})

const totalPaid = computed(() => {
  return records.value
    .filter(r => r.payStatus === 1)
    .reduce((sum, r) => sum + (r.paidAmount || 0), 0)
    .toFixed(2)
})

const totalUnpaid = computed(() => {
  return records.value
    .filter(r => r.payStatus === 0)
    .reduce((sum, r) => sum + (r.payableAmount || 0), 0)
    .toFixed(2)
})

// 加载保存的车牌号
onMounted(() => {
  const saved = localStorage.getItem('saved_plates')
  if (saved) {
    try {
      savedPlates.value = JSON.parse(saved)
    } catch (e) {
      console.error('Failed to parse saved plates:', e)
    }
  }
})

// 查询记录
const handleSearch = async () => {
  if (!plateNumber.value.trim()) {
    ElMessage.warning('请输入车牌号')
    return
  }

  loading.value = true
  searched.value = false

  try {
    const res = await getRecordsByPlate(plateNumber.value.trim())
    records.value = res || []
    searched.value = true

    // 保存车牌号到常用列表
    savePlate(plateNumber.value.trim())
  } catch (error) {
    ElMessage.error('查询失败：' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

// 保存车牌号
const savePlate = (plate) => {
  if (!savedPlates.value.includes(plate)) {
    savedPlates.value.unshift(plate)
    if (savedPlates.value.length > 5) {
      savedPlates.value.pop()
    }
    localStorage.setItem('saved_plates', JSON.stringify(savedPlates.value))
  }
}

// 支付
const handlePay = (row) => {
  currentRecord.value = row
  selectedPayMethod.value = 'wechat'
  payDialogVisible.value = true
}

// 确认支付
const confirmPay = async () => {
  if (!currentRecord.value) return

  payLoading.value = true
  try {
    await payRecord(currentRecord.value.recordId, selectedPayMethod.value)
    ElMessage.success('支付成功')
    payDialogVisible.value = false

    // 刷新记录
    handleSearch()
  } catch (error) {
    ElMessage.error('支付失败：' + (error.message || '未知错误'))
  } finally {
    payLoading.value = false
  }
}

// 格式化日期时间
const formatDateTime = (datetime) => {
  if (!datetime) return '-'
  const date = new Date(datetime)
  return date.toLocaleString('zh-CN', {
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 格式化停车时长
const formatDuration = (minutes) => {
  if (!minutes) return '-'
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  if (hours > 0) {
    return `${hours}小时${mins}分钟`
  }
  return `${mins}分钟`
}

// 支付状态样式
const getPayStatusType = (status) => {
  switch (status) {
    case 0: return 'danger'
    case 1: return 'success'
    case 2: return 'info'
    default: return ''
  }
}

// 支付状态文本
const getPayStatusText = (status) => {
  switch (status) {
    case 0: return '未支付'
    case 1: return '已支付'
    case 2: return '免费'
    default: return '未知'
  }
}
</script>

<style scoped lang="scss">
.user-records {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.search-card {
  margin-bottom: 24px;

  .card-header {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .title {
      font-size: 18px;
      font-weight: 600;
      color: #1e293b;
    }

    .subtitle {
      font-size: 13px;
      color: #94a3b8;
    }
  }

  .search-box {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;

    .plate-input {
      flex: 1;
    }

    .search-btn {
      min-width: 120px;
    }
  }

  .quick-plates {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;

    .label {
      font-size: 13px;
      color: #64748b;
    }

    .plate-tag {
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        background: #e0e7ff;
        border-color: #6366f1;
        color: #6366f1;
      }
    }
  }
}

.stats-row {
  margin-bottom: 24px;

  .stat-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

    .stat-value {
      font-size: 28px;
      font-weight: 700;
      color: #6366f1;
      margin-bottom: 4px;
    }

    .stat-label {
      font-size: 13px;
      color: #64748b;
    }
  }
}

.records-card {
  .card-header {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .unpaid {
    color: #ef4444;
    font-weight: 600;
  }
}

.empty-state {
  padding: 60px 0;
}

.pay-dialog-content {
  .pay-info {
    background: #f8fafc;
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 20px;

    .info-row {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;

      &:last-child {
        margin-bottom: 0;
      }

      .label {
        color: #64748b;
      }

      .value {
        color: #1e293b;
        font-weight: 500;
      }
    }
  }

  .pay-amount {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    background: #fef3c7;
    border-radius: 8px;
    margin-bottom: 20px;

    .label {
      font-size: 14px;
      color: #92400e;
    }

    .amount {
      font-size: 24px;
      font-weight: 700;
      color: #f59e0b;
    }
  }

  .pay-methods {
    display: flex;
    gap: 12px;

    .pay-method {
      flex: 1;
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 8px;
      padding: 16px;
      border: 2px solid #e2e8f0;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.3s;

      &:hover {
        border-color: #cbd5e1;
      }

      &.active {
        border-color: #6366f1;
        background: #eef2ff;
      }

      span {
        font-size: 13px;
        color: #64748b;
      }
    }
  }
}
</style>
