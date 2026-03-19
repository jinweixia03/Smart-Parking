<template>
  <div class="record-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>停车记录</span>
          <div class="header-actions">
            <el-input
              v-model="searchForm.plateNumber"
              placeholder="搜索车牌号"
              style="width: 200px"
              clearable
              @keyup.enter="fetchRecords"
            >
              <template #append>
                <el-button @click="fetchRecords">
                  <el-icon><Search /></el-icon>
                </el-button>
              </template>
            </el-input>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              style="width: 240px"
              @change="handleDateChange"
            />
            <el-button type="primary" @click="fetchRecords">
              <el-icon><Search /></el-icon>查询
            </el-button>
            <el-button @click="refreshData">
              <el-icon><Refresh /></el-icon>刷新
            </el-button>
          </div>
        </div>
      </template>

      <!-- 内容区域 -->
      <div class="record-content">
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
        <div v-if="stat.showTrend" class="stat-trend" :class="stat.trend">
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
      <div v-if="viewMode === 'list'" class="table-wrapper">
        <el-table
          :data="filteredRecords"
          v-loading="loading"
          stripe
          height="100%"
          style="width: 100%"
          :header-cell-style="headerStyle"
        >
          <el-table-column type="index" label="#" width="50" align="center" />

          <el-table-column label="车牌号" width="120">
            <template #default="{ row }">
              <div class="plate-tag">
                <span class="plate-text">{{ row.plateNumber }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column prop="spaceCode" label="车位" width="90" align="center" class-name="col-space">
            <template #default="{ row }">
              <span class="space-code">{{ row.spaceCode }}</span>
            </template>
          </el-table-column>

          <el-table-column label="入场时间" width="160" class-name="col-time">
            <template #default="{ row }">
              <div class="time-cell">
                <el-icon><Calendar /></el-icon>
                <span>{{ formatDateTime(row.entryTime) }}</span>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="出场时间" width="160" class-name="col-time">
            <template #default="{ row }">
              <div class="time-cell" v-if="row.exitTime">
                <el-icon><Timer /></el-icon>
                <span>{{ formatDateTime(row.exitTime) }}</span>
              </div>
              <span v-else class="text-muted">--</span>
            </template>
          </el-table-column>

          <el-table-column label="停车时长" width="110" align="center" class-name="col-duration">
            <template #default="{ row }">
              <span class="duration">{{ formatDuration(row) }}</span>
            </template>
          </el-table-column>

          <el-table-column label="费用" width="140" class-name="col-fee">
            <template #default="{ row }">
              <div class="fee-cell">
                <div class="fee-row">
                  <span class="fee-label">费用:</span>
                  <span class="fee-value">¥{{ row.feeAmount?.toFixed(2) || '0.00' }}</span>
                </div>
              </div>
            </template>
          </el-table-column>

          <el-table-column label="状态" width="100" align="center">
            <template #default="{ row }">
              <div class="status-tag" :class="getStatusClass(row)">
                <span class="status-dot"></span>
                {{ getStatusText(row) }}
              </div>
            </template>
          </el-table-column>

          <el-table-column label="操作" width="80" align="center">
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
      <div v-else-if="viewMode === 'card'" class="card-view">
        <div
          v-for="(record, index) in filteredRecords"
          :key="record.recordId"
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
              <span class="value duration">{{ formatDuration(record) }}</span>
            </div>
          </div>
          <div class="card-footer">
            <div class="fee-section">
              <span class="fee-amount">¥{{ record.feeAmount?.toFixed(2) || '0.00' }}</span>
              <span class="fee-label">停车费用</span>
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
            <span class="value">{{ formatDuration(currentRecord) }}</span>
          </div>
          <div class="detail-item">
            <span class="label">停车费用</span>
            <span class="value">¥{{ currentRecord.feeAmount?.toFixed(2) || '0.00' }}</span>
          </div>
          <div class="detail-item">
            <span class="label">记录编号</span>
            <span class="value">{{ currentRecord.recordId }}</span>
          </div>
        </div>
      </div>
    </el-dialog>
  </el-card>
</div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import {
  Document, Search, Refresh, Download, ArrowUp, ArrowDown,
  List, Grid, Calendar, Timer, MoreFilled, View, Printer,
  Van, User, Money
} from '@element-plus/icons-vue'
import { getRecords, getTodayStats } from '@/api/parking'
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

// 统计（从数据库加载）
const stats = ref([
  { icon: 'Van', label: '今日停车', value: 0, trend: 'up', trendValue: 0, showTrend: false, bgColor: 'linear-gradient(135deg, #3b82f6, #2563eb)' },
  { icon: 'Money', label: '今日收入', value: '¥0', trend: 'up', trendValue: 0, showTrend: false, bgColor: 'linear-gradient(135deg, #10b981, #059669)' },
  { icon: 'Timer', label: '平均时长', value: '0h', trend: 'down', trendValue: 0, showTrend: false, bgColor: 'linear-gradient(135deg, #f59e0b, #d97706)' },
  { icon: 'User', label: '活跃车辆', value: 0, trend: 'up', trendValue: 0, showTrend: false, bgColor: 'linear-gradient(135deg, #8b5cf6, #7c3aed)' }
])

// 加载统计数据
const loadStats = async () => {
  try {
    const data = await getTodayStats()
    stats.value[0].value = data.entryCount || 0
    stats.value[0].trendValue = data.entryTrend || 0
    stats.value[0].trend = data.entryTrend >= 0 ? 'up' : 'down'

    stats.value[1].value = '¥' + (data.revenue || 0).toLocaleString()
    stats.value[1].trendValue = Math.abs(data.revenueTrend || 0)
    stats.value[1].trend = data.revenueTrend >= 0 ? 'up' : 'down'

    stats.value[2].value = (data.avgHours || 0) + 'h'

    stats.value[3].value = data.activeCount || 0
  } catch (e) {
    console.error('加载统计数据失败', e)
  }
}

// 标签
const tabs = ref([
  { key: 'all', label: '全部记录', count: 0 },
  { key: 'active', label: '停车中', count: 0 },
  { key: 'completed', label: '已完成', count: 0 },
  { key: 'unpaid', label: '未支付', count: 0 }
])

// 加载各标签统计数量
const loadTabCounts = async () => {
  try {
    const [allRes, activeRes, unpaidRes, exitedRes] = await Promise.all([
      getRecords({ page: 1, size: 1 }),
      getRecords({ page: 1, size: 1, status: 0 }),
      getRecords({ page: 1, size: 1, status: 1, payStatus: 0 }),
      getRecords({ page: 1, size: 1, status: 1 })
    ])
    tabs.value[0].count = allRes.total || 0
    tabs.value[1].count = activeRes.total || 0
    tabs.value[2].count = Math.max(0, (exitedRes.total || 0) - (unpaidRes.total || 0))
    tabs.value[3].count = unpaidRes.total || 0
  } catch (e) {
    console.error('加载标签统计失败', e)
  }
}

// 根据 tab 换算为后端参数
const tabToParams = (tab) => {
  if (tab === 'active') return { status: 0 }
  if (tab === 'completed') return { status: 1, payStatus: 1 }
  if (tab === 'unpaid') return { status: 1, payStatus: 0 }
  return {}
}

const filteredRecords = computed(() => records.value)

watch(currentTab, () => {
  page.value = 1
  fetchRecords()
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
    const params = {
      page: page.value,
      size: size.value,
      plateNumber: searchForm.value.plateNumber,
      ...tabToParams(currentTab.value)
    }
    if (dateRange.value && dateRange.value.length === 2) {
      params.startDate = dateRange.value[0].toISOString().slice(0, 10)
      params.endDate = dateRange.value[1].toISOString().slice(0, 10)
    }
    const res = await getRecords(params)
    records.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
    ElMessage.error('加载停车记录失败，请检查网络连接')
    records.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}


const getStatusClass = (row) => {
  if (!row.exitTime) return 'active'
  if (row.payStatus === 1 || row.payStatus === 2) return 'completed'
  return 'unpaid'
}

const getStatusText = (row) => {
  if (!row.exitTime) return '停车中'
  if (row.payStatus === 1 || row.payStatus === 2) return '已完成'
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

const formatDuration = (row) => {
  if (!row.entryTime) return '--'
  const start = new Date(row.entryTime)
  const end = row.exitTime ? new Date(row.exitTime) : new Date()
  const minutes = Math.floor((end - start) / (1000 * 60))
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
  loadStats()
  loadTabCounts()
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
  loadStats()
  loadTabCounts()
})
</script>

<style scoped lang="scss">
@use '@/styles/parking-2.5d-theme.scss' as *;

.record-manage {
  padding: 24px;
  height: 100%;
  box-sizing: border-box;
  background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 50%, #f1f5f9 100%);

  :deep(.el-card) {
    height: 100%;
    display: flex;
    flex-direction: column;

    .el-card__body {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      padding: 0;
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

  .header-actions {
    display: flex;
    align-items: center;
    gap: 12px;
    flex-wrap: wrap;
  }

  .record-content {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    gap: 16px;
    overflow: hidden;
  }
}

// 统计卡片
.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  flex-shrink: 0;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 16px;
  @include glass-glacier;
  border-radius: 12px;
  animation: slideUp 0.5s ease forwards;
  opacity: 0;
  transform: translateY(20px);

  .stat-icon {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 18px;
  }

  .stat-content {
    flex: 1;
    display: flex;
    flex-direction: column;

    .stat-value {
      font-size: 20px;
      font-weight: 700;
      color: #1e293b;
    }

    .stat-label {
      font-size: 12px;
      color: #64748b;
      margin-top: 2px;
    }
  }

  .stat-trend {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 12px;
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
  border-radius: 16px;
  padding: 16px 20px;
  width: 100%;
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  min-height: 0;

  .table-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 12px;
    flex-shrink: 0;
    gap: 12px;

    .table-tabs {
      display: flex;
      gap: 6px;
      flex-wrap: wrap;

      .tab-btn {
        position: relative;
        padding: 8px 16px;
        border: none;
        border-radius: 8px;
        background: transparent;
        color: #64748b;
        font-size: 13px;
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
          top: 2px;
          right: 2px;
          min-width: 16px;
          height: 16px;
          padding: 0 5px;
          background: #ef4444;
          color: white;
          font-size: 10px;
          border-radius: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
        }
      }
    }
  }
}

.table-wrapper {
  flex: 1;
  overflow: hidden;
  min-height: 0;
  width: 100%;
  display: flex;
  flex-direction: column;

  :deep(.el-table) {
    width: 100% !important;
    flex: 1;
    height: 100% !important;

    .el-table__inner-wrapper {
      height: 100%;
    }

    .el-table__body-wrapper {
      flex: 1;
      overflow-y: auto;
    }
  }
}

// 表格样式
:deep(.el-table) {
  width: 100% !important;
  background: transparent;
  border-radius: 12px;
  overflow: hidden;
  flex: 1;

  .el-table__header,
  .el-table__body,
  .el-table__footer {
    width: 100% !important;
    table-layout: fixed !important;
  }

  .el-table__header-wrapper {
    th {
      background: linear-gradient(135deg, #f0f9ff, #e0f2fe) !important;
      color: #1e293b;
      font-weight: 600;
      font-size: 12px;
      padding: 10px 8px;
    }

    .cell {
      width: 100% !important;
    }
  }

  .el-table__body-wrapper {
    td {
      padding: 10px 8px;
      color: #475569;
      font-size: 13px;

      .cell {
        width: 100% !important;
        padding: 0 4px;
      }
    }

    tr:hover > td {
      background: rgba(59, 130, 246, 0.05) !important;
    }
  }

  // 响应式：小屏幕下固定列保持显示
  @media (max-width: 1200px) {
    .el-table__body-wrapper {
      overflow-x: auto;
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
// 卡片视图
.card-view {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 20px;
  padding: 4px;
  flex: 1;
  overflow-y: auto;
  min-height: 0;
  align-content: start;
  position: relative;
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
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid rgba(0, 0, 0, 0.06);
  flex-shrink: 0;
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

// 响应式
@media (max-width: 1400px) {
  .stats-cards {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 1200px) {
  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
  }

  // 中等屏幕：卡片视图改为2列
  .card-view {
    grid-template-columns: repeat(2, 1fr);
  }

  // 中等屏幕：隐藏车位、时长、入场时间列
  :deep(.el-table) {
    .col-space,
    .col-duration,
    .col-time:nth-child(3) {
      display: none !important;
    }
  }

  .data-table-container {
    padding: 12px 16px;
  }
}

@media (max-width: 992px) {
  // 小屏幕：隐藏出场时间列
  :deep(.el-table) {
    .col-time {
      display: none !important;
    }
  }
}

@media (max-width: 768px) {
  .record-manage {
    padding: 16px;

    :deep(.el-card__body) {
      padding: 12px;
    }
  }

  .card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;

    .header-actions {
      width: 100%;
      flex-wrap: wrap;

      .el-input,
      .el-date-picker {
        width: 100% !important;
      }
    }
  }

  .record-content {
    gap: 12px;
  }

  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;

    .stat-card {
      padding: 10px 12px;

      .stat-icon {
        width: 32px;
        height: 32px;
        font-size: 14px;
      }

      .stat-content {
        .stat-value {
          font-size: 16px;
        }

        .stat-label {
          font-size: 11px;
        }
      }

      .stat-trend {
        padding: 2px 6px;
        font-size: 10px;
      }
    }
  }

  .data-table-container {
    padding: 12px;
    border-radius: 12px;
  }

  .table-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 12px;

    .table-tabs {
      flex-wrap: wrap;
      width: 100%;

      .tab-btn {
        padding: 6px 12px;
        font-size: 12px;
        flex: 1;
        min-width: 70px;
      }
    }
  }

  // 手机端：只显示车牌、费用、状态、操作
  :deep(.el-table) {
    .col-space,
    .col-time,
    .col-duration {
      display: none !important;
    }

    .el-table__header-wrapper th,
    .el-table__body-wrapper td {
      padding: 8px 4px;
      font-size: 12px;
    }

    .plate-tag {
      padding: 4px 8px;
      font-size: 12px;
    }
  }

  .card-view {
    grid-template-columns: 1fr;
    gap: 12px;

    .record-card {
      padding: 16px;
    }
  }

  .table-pagination {
    justify-content: center;
    flex-wrap: wrap;
    gap: 8px;
  }

  .table-wrapper {
    overflow-x: hidden;
  }

  .fee-cell {
    .fee-row {
      gap: 4px;

      .fee-label {
        font-size: 10px;
      }

      .fee-value {
        font-size: 12px;
      }
    }
  }

  .status-tag {
    padding: 4px 8px;
    font-size: 11px;
  }

  .action-menu-btn {
    width: 28px;
    height: 28px;
  }
}

@media (max-width: 480px) {
  .record-manage {
    padding: 12px;

    :deep(.el-card__body) {
      padding: 8px;
    }
  }

  .stats-cards {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;

    .stat-card {
      padding: 8px;
      gap: 8px;

      .stat-icon {
        width: 28px;
        height: 28px;
        font-size: 12px;
      }

      .stat-content {
        .stat-value {
          font-size: 14px;
        }

        .stat-label {
          font-size: 10px;
        }
      }
    }
  }

  .data-table-container {
    padding: 10px;
  }

  .table-header .table-tabs {
    .tab-btn {
      padding: 5px 8px;
      font-size: 11px;
    }
  }

  :deep(.el-table) {
    .col-fee {
      width: 100px !important;
    }

    .fee-cell {
      .fee-row:first-child {
        display: none; // 隐藏应付金额
      }
    }
  }

  .record-content {
    gap: 10px;
  }
}
</style>
