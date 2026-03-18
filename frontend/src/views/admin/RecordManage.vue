<template>
  <div class="record-manage-2-5d">
    <!-- 页面标题区 -->
    <div class="page-header">
      <div class="header-left">
        <div class="title-icon">
          <el-icon><Document /></el-icon>
        </div>
        <div class="title-content">
          <h1 class="page-title">停车记录</h1>
          <p class="page-subtitle">查看和管理所有停车记录</p>
        </div>
      </div>
      <div class="header-actions">
        <div class="search-box">
          <el-icon class="search-icon"><Search /></el-icon>
          <el-input
            v-model="searchForm.plateNumber"
            placeholder="搜索车牌号..."
            clearable
            @keyup.enter="fetchRecords"
          />
        </div>
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 240px"
          @change="handleDateChange"
        />
        <button class="action-btn primary" @click="fetchRecords">
          <el-icon><Search /></el-icon>
          查询
        </button>
        <button class="action-btn" @click="refreshData">
          <el-icon><Refresh /></el-icon>
          刷新
        </button>
        <button class="action-btn export" @click="exportData">
          <el-icon><Download /></el-icon>
          导出
        </button>
      </div>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-cards">
      <div class="stat-card" v-for="(stat, index) in stats" :key="index" :style="{ animationDelay: `${index * 100}ms` }">
        <div class="stat-icon" :style="{ background: stat.bgColor }">
          <el-icon><component :is="stat.icon" /></el-icon>
        </div>
        <div class="stat-content">
          <span class="stat-value">{{ stat.value }}</span>
          <span class="stat-label">{{ stat.label }}</span>
        </div>
        <div class="stat-trend" :class="stat.trend">
          <el-icon><ArrowUp v-if="stat.trend === 'up'" /><ArrowDown v-else /></el-icon>
          <span>{{ stat.trendValue }}%</span>
        </div>
      </div>
    </div>

    <!-- 数据表格区 -->
    <div class="data-table-container">
      <div class="table-header">
        <div class="table-tabs">
          <button
            v-for="tab in tabs"
            :key="tab.key"
            :class="['tab-btn', { active: currentTab === tab.key }]"
            @click="currentTab = tab.key"
          >
            {{ tab.label }}
            <span class="tab-badge" v-if="tab.count">{{ tab.count }}</span>
          </button>
        </div>
        <div class="table-actions">
          <el-radio-group v-model="viewMode" size="small">
            <el-radio-button label="list">
              <el-icon><List /></el-icon>
            </el-radio-button>
            <el-radio-button label="card">
              <el-icon><Grid /></el-icon>
            </el-radio-button>
          </el-radio-group>
        </div>
      </div>

      <!-- 列表视图 -->
      <div v-show="viewMode === 'list'" class="table-content">
        <el-table
          :data="filteredRecords"
          v-loading="loading"
          stripe
          style="width: 100%"
          :header-cell-style="headerStyle"
        >
          <el-table-column type="index" label="#" width="60" align="center" />

          <el-table-column label="车牌号" width="140">
            <template #default="{ row }">
              <div class="plate-tag">
                <span class="plate-text">{{ row.plateNumber }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="spaceCode" label="车位" width="100" align="center">
            <template #default="{ row }">
              <span class="space-code">{{ row.spaceCode }}</span>
            </template>
          </el-table-column>

          <el-table-column label="入场时间" width="180">
            <template #default="{ row }">
              <div class="time-cell">
                <el-icon><Calendar /></el-icon>
                <span>{{ formatDateTime(row.entryTime) }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="出场时间" width="180">
            <template #default="{ row }">
              <div class="time-cell" v-if="row.exitTime">
                <el-icon><Timer /></el-icon>
                <span>{{ formatDateTime(row.exitTime) }}</span>
              </div>
              <span v-else class="text-muted">--</span>
            </template>
          </el-table-column>

          <el-table-column label="停车时长" width="120" align="center">
            <template #default="{ row }">
              <span class="duration">{{ formatDuration(row.parkingMinutes) }}</span>
            </template>
          </el-table-column>

          <el-table-column label="费用" width="180">
            <template #default="{ row }">
              <div class="fee-cell">
                <div class="fee-row">
                  <span class="fee-label">应付:</span>
                  <span class="fee-value">¥{{ row.payableAmount?.toFixed(2) }}</span>
                </div>
                <div class="fee-row" v-if="row.paidAmount > 0">
                  <span class="fee-label">实付:</span>
                  <span class="fee-value paid">¥{{ row.paidAmount?.toFixed(2) }}</span>
                </div>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="状态" width="100" align="center" fixed="right">
            <template #default="{ row }">
              <div class="status-tag" :class="getStatusClass(row)">
                <span class="status-dot"></span>
                {{ getStatusText(row) }}
              </div>
            </template>
          </el-table-column>

          <el-table-column label="操作" width="100" align="center" fixed="right">
            <template #default="{ row }">
              <el-dropdown trigger="click">
                <button class="action-menu-btn">
                  <el-icon><MoreFilled /></el-icon>
                </button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="viewDetail(row)">
                      <el-icon><View /></el-icon>查看详情
                    </el-dropdown-item>
                    <el-dropdown-item @click="printRecord(row)">
                      <el-icon><Printer /></el-icon>打印票据
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 卡片视图 -->
      <div v-show="viewMode === 'card'" class="card-view">
        <div
          v-for="(record, index) in filteredRecords"
          :key="record.id"
          class="record-card"
          :style="{ animationDelay: `${index * 50}ms` }"
        >
          <div class="card-header">
            <div class="plate-tag large">{{ record.plateNumber }}</div>
            <div class="status-tag" :class="getStatusClass(record)">
              {{ getStatusText(record) }}
            </div>
          </div>
          <div class="card-body">
            <div class="info-row">
              <span class="label">车位</span>
              <span class="value">{{ record.spaceCode }}</span>
            </div>
            <div class="info-row">
              <span class="label">入场</span>
              <span class="value">{{ formatDateTime(record.entryTime) }}</span>
            </div>
            <div class="info-row">
              <span class="label">出场</span>
              <span class="value">{{ record.exitTime ? formatDateTime(record.exitTime) : '--' }}</span>
            </div>
            <div class="info-row">
              <span class="label">时长</span>
              <span class="value duration">{{ formatDuration(record.parkingMinutes) }}</span>
            </div>
          </div>
          <div class="card-footer">
            <div class="fee-section">
              <span class="fee-amount">¥{{ record.paidAmount?.toFixed(2) || '0.00' }}</span>
              <span class="fee-label">实付金额</span>
            </div>
            <button class="detail-btn" @click="viewDetail(record)">查看详情</button>
          </div>
        </div>
      </div>

      <!-- 分页 -->
      <div class="table-pagination">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="size"
          :total="total"
          :page-sizes="[8, 16, 24, 32]"
          layout="total, sizes, prev, pager, next, jumper"
          @current-change="fetchRecords"
          @size-change="fetchRecords"
        />
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog
      v-model="detailVisible"
      title="停车记录详情"
      width="480px"
      destroy-on-close
      class="detail-dialog"
    >
      <div v-if="currentRecord" class="detail-content">
        <div class="detail-header">
          <div class="plate-display">{{ currentRecord.plateNumber }}</div>
          <div class="status-badge" :class="getStatusClass(currentRecord)">
            {{ getStatusText(currentRecord) }}
          </div>
        </div>
        <div class="detail-grid">
          <div class="detail-item">
            <span class="label">车位编号</span>
            <span class="value">{{ currentRecord.spaceCode }}</span>
          </div>
          <div class="detail-item">
            <span class="label">入场时间</span>
            <span class="value">{{ formatDateTime(currentRecord.entryTime) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">出场时间</span>
            <span class="value">{{ currentRecord.exitTime ? formatDateTime(currentRecord.exitTime) : '--' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">停车时长</span>
            <span class="value">{{ formatDuration(currentRecord.parkingMinutes) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">应付金额</span>
            <span class="value">¥{{ currentRecord.payableAmount?.toFixed(2) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">实付金额</span>
            <span class="value highlight">¥{{ currentRecord.paidAmount?.toFixed(2) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">支付方式</span>
            <span class="value">{{ currentRecord.payMethod || '微信' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">记录编号</span>
            <span class="value">{{ currentRecord.id }}</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  Document, Search, Refresh, Download, ArrowUp, ArrowDown,
  List, Grid, Calendar, Timer, MoreFilled, View, Printer
} from '@element-plus/icons-vue'
import { getRecords } from '@/api/parking'
import { ElMessage } from 'element-plus'

// ==================== 状态管理 ====================
const records = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(8)
const total = ref(0)
const searchForm = ref({ plateNumber: '' })
const dateRange = ref(null)
const currentTab = ref('all')
const viewMode = ref('list')
const detailVisible = ref(false)
const currentRecord = ref(null)

// 统计
const stats = ref([
  { icon: 'Car', label: '今日停车', value: 128, trend: 'up', trendValue: 12, bgColor: 'linear-gradient(135deg, #3b82f6, #2563eb)' },
  { icon: 'Money', label: '今日收入', value: '¥2,846', trend: 'up', trendValue: 8, bgColor: 'linear-gradient(135deg, #10b981, #059669)' },
  { icon: 'Timer', label: '平均时长', value: '2.5h', trend: 'down', trendValue: 5, bgColor: 'linear-gradient(135deg, #f59e0b, #d97706)' },
  { icon: 'User', label: '活跃车辆', value: 86, trend: 'up', trendValue: 15, bgColor: 'linear-gradient(135deg, #8b5cf6, #7c3aed)' }
])

// 标签
const tabs = [
  { key: 'all', label: '全部记录', count: 0 },
  { key: 'active', label: '停车中', count: 12 },
  { key: 'completed', label: '已完成', count: 156 },
  { key: 'unpaid', label: '未支付', count: 3 }
]

// 过滤后的记录
const filteredRecords = computed(() => {
  let result = records.value
  if (currentTab.value === 'active') {
    result = result.filter(r => r.status === 0)
  } else if (currentTab.value === 'completed') {
    result = result.filter(r => r.status === 1 && r.payStatus === 1)
  } else if (currentTab.value === 'unpaid') {
    result = result.filter(r => r.status === 1 && r.payStatus === 0)
  }
  return result
})

// 表格头部样式
const headerStyle = {
  background: 'linear-gradient(135deg, #f0f9ff, #e0f2fe)',
  color: '#1e293b',
  fontWeight: 600,
  fontSize: '13px'
}

// ==================== 方法 ====================
const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await getRecords({
      page: page.value,
      size: size.value,
      plateNumber: searchForm.value.plateNumber
    })
    records.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
    generateMockData()
  } finally {
    loading.value = false
  }
}

const generateMockData = () => {
  const mockData = []
  for (let i = 1; i <= 32; i++) {
    const isActive = Math.random() > 0.7
    mockData.push({
      id: `REC${String(i).padStart(6, '0')}`,
      plateNumber: `京A${Math.floor(Math.random() * 90000 + 10000)}`,
      spaceCode: `F1-A${String(Math.floor(Math.random() * 18) + 1).padStart(2, '0')}`,
      entryTime: new Date(Date.now() - Math.random() * 86400000 * 3).toISOString(),
      exitTime: isActive ? null : new Date(Date.now() - Math.random() * 3600000).toISOString(),
      parkingMinutes: isActive ? Math.floor(Math.random() * 300) : Math.floor(Math.random() * 600 + 30),
      payableAmount: Math.floor(Math.random() * 50 + 10),
      paidAmount: isActive ? 0 : Math.floor(Math.random() * 50 + 10),
      payStatus: isActive ? 0 : 1,
      status: isActive ? 0 : 1
    })
  }
  records.value = mockData
  total.value = 156
}

const getStatusClass = (row) => {
  if (row.status === 0) return 'active'
  if (row.payStatus === 1) return 'completed'
  return 'unpaid'
}

const getStatusText = (row) => {
  if (row.status === 0) return '停车中'
  if (row.payStatus === 1) return '已完成'
  return '未支付'
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return '--'
  const date = new Date(dateStr)
  return date.toLocaleString('zh-CN', {
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatDuration = (minutes) => {
  if (!minutes) return '--'
  if (minutes < 60) return `${minutes}分钟`
  const hours = Math.floor(minutes / 60)
  const mins = minutes % 60
  if (mins === 0) return `${hours}小时`
  return `${hours}小时${mins}分钟`
}

const handleDateChange = () => {
  fetchRecords()
}

const refreshData = () => {
  fetchRecords()
  ElMessage.success('数据已刷新')
}

const exportData = () => {
  ElMessage.info('导出功能开发中')
}

const viewDetail = (row) => {
  currentRecord.value = row
  detailVisible.value = true
}

const printRecord = (row) => {
  ElMessage.info('打印功能开发中')
}

onMounted(() => {
  fetchRecords()
})
</script>

<style scoped lang="scss">
@use '@/styles/parking-2.5d-theme.scss' as *;

.record-manage-2-5d {
  min-height: 100%;
  padding: 24px;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f1f5f9 100%);
}

// 页面标题
.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;

  .header-left {
    display: flex;
    align-items: center;
    gap: 16px;

    .title-icon {
      width: 56px;
      height: 56px;
      background: linear-gradient(135deg, #3b82f6, #2563eb);
      border-radius: 16px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 28px;
      box-shadow: 0 8px 24px rgba(59, 130, 246, 0.3);
    }

    .title-content {
      .page-title {
        font-size: 24px;
        font-weight: 700;
        color: #1e293b;
        margin: 0;
      }

      .page-subtitle {
        font-size: 14px;
        color: #64748b;
        margin: 4px 0 0;
      }
    }
  }

  .header-actions {
    display: flex;
    align-items: center;
    gap: 12px;

    .search-box {
      position: relative;
      display: flex;
      align-items: center;

      .search-icon {
        position: absolute;
        left: 12px;
        color: #94a3b8;
        font-size: 16px;
      }

      :deep(.el-input) {
        .el-input__wrapper {
          padding-left: 36px;
          border-radius: 12px;
          background: rgba(255, 255, 255, 0.8);
          box-shadow: 0 2px 8px rgba(15, 23, 42, 0.06);
        }
      }
    }

    .action-btn {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 20px;
      border: 1px solid rgba(59, 130, 246, 0.2);
      border-radius: 10px;
      background: rgba(255, 255, 255, 0.8);
      color: #64748b;
      font-size: 14px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        background: rgba(59, 130, 246, 0.1);
        border-color: rgba(59, 130, 246, 0.4);
        color: #3b82f6;
      }

      &.primary {
        background: linear-gradient(135deg, #3b82f6, #2563eb);
        border-color: transparent;
        color: white;

        &:hover {
          box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
          transform: translateY(-2px);
        }
      }

      &.export {
        border-color: rgba(16, 185, 129, 0.3);
        color: #10b981;

        &:hover {
          background: rgba(16, 185, 129, 0.1);
        }
      }
    }
  }
}

// 统计卡片
.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 24px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  @include glass-glacier;
  border-radius: 16px;
  animation: slideUp 0.5s ease forwards;
  opacity: 0;
  transform: translateY(20px);

  .stat-icon {
    width: 52px;
    height: 52px;
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 24px;
  }

  .stat-content {
    flex: 1;
    display: flex;
    flex-direction: column;

    .stat-value {
      font-size: 24px;
      font-weight: 700;
      color: #1e293b;
    }

    .stat-label {
      font-size: 13px;
      color: #64748b;
      margin-top: 2px;
    }
  }

  .stat-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;

    &.up {
      background: rgba(16, 185, 129, 0.1);
      color: #059669;
    }

    &.down {
      background: rgba(239, 68, 68, 0.1);
      color: #dc2626;
    }
  }
}

@keyframes slideUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// 数据表格容器
.data-table-container {
  @include glass-glacier;
  border-radius: 20px;
  padding: 24px;

  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;

    .table-tabs {
      display: flex;
      gap: 8px;

      .tab-btn {
        position: relative;
        padding: 10px 20px;
        border: none;
        border-radius: 10px;
        background: transparent;
        color: #64748b;
        font-size: 14px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover {
          background: rgba(59, 130, 246, 0.1);
          color: #3b82f6;
        }

        &.active {
          background: linear-gradient(135deg, #3b82f6, #2563eb);
          color: white;
        }

        .tab-badge {
          position: absolute;
          top: 4px;
          right: 4px;
          min-width: 18px;
          height: 18px;
          padding: 0 6px;
          background: #ef4444;
          color: white;
          font-size: 11px;
          border-radius: 9px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
      }
    }
  }
}

// 表格样式
:deep(.el-table) {
  background: transparent;
  border-radius: 12px;
  overflow: hidden;

  .el-table__header-wrapper {
    th {
      background: linear-gradient(135deg, #f0f9ff, #e0f2fe) !important;
      color: #1e293b;
      font-weight: 600;
      font-size: 13px;
      padding: 16px 12px;
    }
  }

  .el-table__body-wrapper {
    td {
      padding: 16px 12px;
      color: #475569;
    }

    tr:hover > td {
      background: rgba(59, 130, 246, 0.05) !important;
    }
  }
}

.plate-tag {
  display: inline-flex;
  align-items: center;
  padding: 8px 16px;
  background: linear-gradient(135deg, #3b82f6, #2563eb);
  color: white;
  border-radius: 8px;
  font-weight: 600;
  font-size: 14px;
  font-family: 'JetBrains Mono', monospace;

  &.large {
    padding: 10px 20px;
    font-size: 16px;
  }
}

.space-code {
  padding: 6px 12px;
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
}

.time-cell {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #475569;

  .el-icon {
    color: #94a3b8;
  }
}

.duration {
  padding: 6px 12px;
  background: rgba(245, 158, 11, 0.1);
  color: #d97706;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 500;
}

.fee-cell {
  display: flex;
  flex-direction: column;
  gap: 4px;

  .fee-row {
    display: flex;
    align-items: center;
    gap: 8px;

    .fee-label {
      font-size: 12px;
      color: #94a3b8;
    }

    .fee-value {
      font-weight: 600;
      color: #1e293b;

      &.paid {
        color: #059669;
      }
    }
  }
}

.status-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 13px;
  font-weight: 500;

  .status-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }

  &.active {
    background: rgba(59, 130, 246, 0.1);
    color: #2563eb;

    .status-dot {
      background: #3b82f6;
      box-shadow: 0 0 8px rgba(59, 130, 246, 0.5);
    }
  }

  &.completed {
    background: rgba(16, 185, 129, 0.1);
    color: #059669;

    .status-dot {
      background: #10b981;
    }
  }

  &.unpaid {
    background: rgba(239, 68, 68, 0.1);
    color: #dc2626;

    .status-dot {
      background: #ef4444;
    }
  }
}

.action-menu-btn {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 8px;
  background: rgba(59, 130, 246, 0.1);
  color: #3b82f6;
  cursor: pointer;
  transition: all 0.3s ease;

  &:hover {
    background: #3b82f6;
    color: white;
  }
}

// 卡片视图
.card-view {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  padding: 4px;
}

.record-card {
  @include glass-glacier;
  border-radius: 16px;
  padding: 20px;
  animation: slideUp 0.5s ease forwards;
  opacity: 0;
  transform: translateY(20px);

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .card-body {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding-bottom: 16px;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;

      .label {
        font-size: 13px;
        color: #94a3b8;
      }

      .value {
        font-size: 14px;
        font-weight: 500;
        color: #1e293b;

        &.duration {
          color: #d97706;
        }
      }
    }
  }

  .card-footer {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 16px;

    .fee-section {
      display: flex;
      flex-direction: column;

      .fee-amount {
        font-size: 24px;
        font-weight: 700;
        color: #059669;
      }

      .fee-label {
        font-size: 12px;
        color: #94a3b8;
      }
    }

    .detail-btn {
      padding: 10px 20px;
      background: linear-gradient(135deg, #3b82f6, #2563eb);
      border: none;
      border-radius: 10px;
      color: white;
      font-size: 13px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.3s ease;

      &:hover {
        box-shadow: 0 8px 20px rgba(59, 130, 246, 0.3);
        transform: translateY(-2px);
      }
    }
  }
}

// 分页
.table-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 24px;
  padding-top: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
}

// 详情弹窗
:deep(.detail-dialog) {
  .el-dialog__header {
    background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
    margin: 0;
    padding: 20px 24px;
    border-radius: 20px 20px 0 0;

    .el-dialog__title {
      font-weight: 600;
      color: #1e293b;
    }
  }

  .el-dialog__body {
    padding: 24px;
  }
}

.detail-content {
  .detail-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
    padding-bottom: 20px;
    border-bottom: 1px solid rgba(0, 0, 0, 0.06);

    .plate-display {
      padding: 12px 24px;
      background: linear-gradient(135deg, #3b82f6, #2563eb);
      color: white;
      border-radius: 10px;
      font-size: 20px;
      font-weight: 700;
      font-family: 'JetBrains Mono', monospace;
    }

    .status-badge {
      padding: 8px 20px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 500;

      &.active {
        background: rgba(59, 130, 246, 0.1);
        color: #2563eb;
      }

      &.completed {
        background: rgba(16, 185, 129, 0.1);
        color: #059669;
      }
    }
  }

  .detail-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;

    .detail-item {
      display: flex;
      flex-direction: column;
      gap: 6px;

      .label {
        font-size: 12px;
        color: #94a3b8;
      }

      .value {
        font-size: 15px;
        font-weight: 500;
        color: #1e293b;

        &.highlight {
          color: #059669;
          font-size: 18px;
          font-weight: 700;
        }
      }
    }
  }
}
</style>
