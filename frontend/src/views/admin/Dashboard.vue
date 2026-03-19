<template>
  <div class="dashboard">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>数据大屏</span>
          <el-button type="primary" @click="refreshData" :loading="refreshing">
            <el-icon><Refresh /></el-icon>
            刷新
          </el-button>
        </div>
      </template>

      <div class="dashboard-content">
      <!-- 统计卡片 -->
    <div class="stats-grid">
      <StatCard
        v-for="(stat, index) in stats"
        :key="stat.key"
        v-bind="stat"
        :class="`delay-${index * 100}`"
      />
    </div>

    <!-- 图表 + 最新记录 左右布局 -->
    <div class="charts-section">
      <div class="chart-card main-chart">
        <div class="chart-header">
          <h3>24小时车流量趋势</h3>
          <el-radio-group v-model="timeRange" size="small">
            <el-radio-button label="today">今日</el-radio-button>
            <el-radio-button label="week">本周</el-radio-button>
            <el-radio-button label="month">本月</el-radio-button>
          </el-radio-group>
        </div>
        <div ref="trafficChart" class="chart-container"></div>
      </div>

      <div class="recent-records-card">
        <div class="card-header">
          <h3>最新记录</h3>
          <el-link type="primary" @click="$router.push('/records')">查看全部</el-link>
        </div>
        <div class="records-list">
          <div v-for="record in recentRecords" :key="record.id" class="record-item">
            <div class="plate-badge">{{ record.plate }}</div>
            <div class="record-info">
              <el-tag :type="record.type === 'entry' ? 'success' : 'warning'" size="small">
                {{ record.type === 'entry' ? '入场' : '出场' }}
              </el-tag>
              <span class="record-time">{{ record.time }}</span>
            </div>
            <span v-if="record.fee" class="fee-amount">¥{{ record.fee }}</span>
          </div>
        </div>
      </div>
    </div>
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, watch, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import StatCard from '@/components/charts/StatCard.vue'
import { getRealTimeData, getChartData, getRecords } from '@/api/parking'
import dayjs from 'dayjs'

const stats = ref([
  { key: 'active',     icon: 'Van',           value: 0, label: '当前停车数', suffix: '辆', color: '#2563eb', progress: 0 },
  { key: 'today',      icon: 'TrendCharts',   value: 0, label: '今日入场',   suffix: '辆', color: '#10b981', progress: 0 },
  { key: 'revenue',    icon: 'Money',         value: 0, label: '今日收入',   prefix: '¥', color: '#f59e0b', progress: 0 },
  { key: 'available',  icon: 'OfficeBuilding', value: 0, label: '剩余车位',  suffix: '个', color: '#ef4444' }
])

const recentRecords = ref([])
const trafficChart = ref(null)
let trafficChartInstance = null
const timeRange = ref('today')
const refreshing = ref(false)

// ---- 格式化时间 ----
const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const diff = dayjs().diff(dayjs(dateStr), 'minute')
  if (diff < 1) return '刚刚'
  if (diff < 60) return `${diff}分钟前`
  if (diff < 1440) return `${Math.floor(diff / 60)}小时前`
  return dayjs(dateStr).format('MM-DD HH:mm')
}

// ---- 统计卡片 ----
const loadStats = async () => {
  const data = await getRealTimeData()
  const total = data.totalSpaces || 1
  const active = data.activeCount || 0
  stats.value[0].value = active
  stats.value[0].progress = Math.round((active / total) * 100)
  stats.value[1].value = data.todayEntry || 0
  stats.value[2].value = Number(data.todayRevenue || 0)
  stats.value[3].value = data.availableSpaces || 0
}

// ---- 折线图 ----
const initChart = () => {
  trafficChartInstance = echarts.init(trafficChart.value)
  trafficChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['入场'], top: 0, textStyle: { fontSize: 12 } },
    grid: { left: 10, right: 10, bottom: 10, top: 30, containLabel: true },
    xAxis: { type: 'category', data: [], axisLabel: { fontSize: 11 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 11 } },
    series: [
      { name: '入场', type: 'line', smooth: true, data: [], itemStyle: { color: '#10b981' }, areaStyle: { opacity: 0.2 } }
    ]
  })
}

const loadChart = async () => {
  if (!trafficChartInstance) return
  try {
    let xData = [], entryData = []

    if (timeRange.value === 'today') {
      const today = dayjs().format('YYYY-MM-DD')
      const res = await getChartData('hourly', { startDate: today })
      const raw = res.data || []
      // 填满24小时，没有数据的小时补0
      const map = {}
      raw.forEach(item => { map[item.hour] = Number(item.count) })
      xData = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}:00`)
      entryData = xData.map((_, i) => map[i] || 0)
    } else {
      const endDate = dayjs().format('YYYY-MM-DD')
      const startDate = timeRange.value === 'week'
        ? dayjs().subtract(6, 'day').format('YYYY-MM-DD')
        : dayjs().subtract(29, 'day').format('YYYY-MM-DD')
      const res = await getChartData('daily', { startDate, endDate })
      const raw = res.data || []
      xData = raw.map(item => item.date)
      entryData = raw.map(item => Number(item.entryCount))
    }

    trafficChartInstance.setOption({
      xAxis: { data: xData },
      series: [{ data: entryData }]
    })
  } catch (e) {
    console.error('图表数据加载失败', e)
  }
}

// ---- 最新记录 ----
const loadRecords = async () => {
  try {
    const res = await getRecords({ page: 1, size: 10 })
    const list = res.records || res.list || []
    recentRecords.value = list.map(r => ({
      id: r.recordId,
      plate: r.plateNumber,
      type: r.exitTime ? 'exit' : 'entry',
      time: formatTime(r.exitTime || r.entryTime),
      fee: r.feeAmount ? Number(r.feeAmount).toFixed(2) : null
    }))
  } catch (e) {
    console.error('记录加载失败', e)
  }
}

// ---- 刷新全部 ----
const refreshData = async () => {
  refreshing.value = true
  try {
    await Promise.all([loadStats(), loadChart(), loadRecords()])
    ElMessage.success('数据已更新')
  } catch (e) {
    console.error(e)
  } finally {
    refreshing.value = false
  }
}

watch(timeRange, () => loadChart())

let refreshTimer = null

onMounted(async () => {
  initChart()
  await Promise.all([loadStats(), loadChart(), loadRecords()])
  refreshTimer = setInterval(() => Promise.all([loadStats(), loadRecords()]), 30000)
  window.addEventListener('resize', () => trafficChartInstance?.resize())
})

onUnmounted(() => {
  clearInterval(refreshTimer)
  trafficChartInstance?.dispose()
})
</script>

<style scoped lang="scss">
.dashboard {
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
      padding: 16px;
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

  .dashboard-content {
    height: 100%;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }
}

// 统计卡片
.stats-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  flex-shrink: 0;
}

// 图表 + 最新记录
.charts-section {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 12px;
  flex: 1;
  min-height: 0;

  .chart-card {
    background: white;
    border-radius: 12px;
    padding: 12px;
    display: flex;
    flex-direction: column;

    .chart-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
      flex-shrink: 0;

      h3 {
        font-size: 14px;
        font-weight: 600;
        color: #1e293b;
        margin: 0;
      }
    }

    .chart-container {
      flex: 1;
      min-height: 0;
    }
  }

  .recent-records-card {
    background: white;
    border-radius: 12px;
    padding: 12px;
    display: flex;
    flex-direction: column;
    min-height: 0;

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;
      flex-shrink: 0;

      h3 {
        font-size: 14px;
        font-weight: 600;
        color: #1e293b;
        margin: 0;
      }
    }

    .records-list {
      display: flex;
      flex-direction: column;
      gap: 6px;
      flex: 1;
      overflow-y: auto;

      .record-item {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 6px 10px;
        background: #f8fafc;
        border-radius: 8px;

        .plate-badge {
          padding: 4px 10px;
          background: linear-gradient(135deg, #2563eb, #1d4ed8);
          color: white;
          font-weight: 600;
          font-size: 12px;
          border-radius: 6px;
          min-width: 70px;
          text-align: center;
        }

        .record-info {
          flex: 1;
          display: flex;
          align-items: center;
          gap: 8px;

          .record-time {
            font-size: 12px;
            color: #94a3b8;
          }
        }

        .fee-amount {
          font-size: 14px;
          font-weight: 700;
          color: #f59e0b;
        }
      }
    }
  }
}

// 响应式
@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
  }

  .charts-section {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .dashboard {
    padding: 16px;

    :deep(.el-card__body) {
      padding: 12px;
    }
  }

  .card-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .stats-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 8px;
  }

  .charts-section {
    gap: 8px;

    .chart-card {
      padding: 8px;

      .chart-header h3 {
        font-size: 13px;
      }
    }
  }

  .charts-section .recent-records-card {
    padding: 10px;

    h3 {
      font-size: 13px;
      margin-bottom: 8px;
    }

    .records-list .record-item {
      padding: 5px 8px;

      .plate-badge {
        padding: 3px 8px;
        font-size: 11px;
        min-width: 60px;
      }

      .record-info {
        gap: 6px;
      }

      .record-time {
        font-size: 11px;
      }

      .fee-amount {
        font-size: 12px;
      }
    }
  }
}

@media (max-width: 480px) {
  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style>
