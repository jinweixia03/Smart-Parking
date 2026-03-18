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

    <!-- 图表区域 -->
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

      <div class="chart-card side-chart">
        <div class="chart-header">
          <h3>区域分布</h3>
        </div>
        <div ref="areaChart" class="chart-container"></div>
      </div>
    </div>

    <!-- 快捷操作和最新记录 -->
    <div class="bottom-section">
      <div class="quick-actions-card">
        <h3>快捷操作</h3>
        <div class="actions-grid">
          <button
            v-for="action in quickActions"
            :key="action.key"
            class="action-item"
            @click="handleQuickAction(action)"
          >
            <div class="action-icon" :style="{ background: action.color + '15', color: action.color }">
              <el-icon><component :is="action.icon" /></el-icon>
            </div>
            <span class="action-label">{{ action.label }}</span>
          </button>
        </div>
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
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import StatCard from '@/components/charts/StatCard.vue'
import { getRealTimeData } from '@/api/parking'

const router = useRouter()

const stats = ref([
  { key: 'active', icon: 'Car', value: 128, label: '当前停车数', suffix: '辆', color: '#2563eb', progress: 85 },
  { key: 'today', icon: 'TrendCharts', value: 356, label: '今日入场', suffix: '辆', color: '#10b981', progress: 72 },
  { key: 'revenue', icon: 'Money', value: 2846, label: '今日收入', prefix: '¥', color: '#f59e0b', progress: 68 },
  { key: 'available', icon: 'OfficeBuilding', value: 42, label: '剩余车位', suffix: '个', color: '#ef4444' }
])

const quickActions = [
  { key: 'entry', label: '车辆入场', icon: 'Plus', color: '#10b981' },
  { key: 'exit', label: '车辆出场', icon: 'Minus', color: '#f59e0b' },
  { key: 'simulation', label: '仿真测试', icon: 'VideoCamera', color: '#8b5cf6' },
  { key: 'records', label: '查看记录', icon: 'Document', color: '#06b6d4' }
]

const recentRecords = ref([
  { id: 1, plate: '京A12345', type: 'entry', time: '2分钟前' },
  { id: 2, plate: '沪B67890', type: 'exit', time: '5分钟前', fee: '15.00' },
  { id: 3, plate: '粤C11111', type: 'entry', time: '8分钟前' },
  { id: 4, plate: '苏D99999', type: 'exit', time: '12分钟前', fee: '8.00' }
])

const trafficChart = ref(null)
const areaChart = ref(null)
let trafficChartInstance = null
let areaChartInstance = null
const timeRange = ref('today')
const refreshing = ref(false)

const initCharts = () => {
  trafficChartInstance = echarts.init(trafficChart.value)
  const hours = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}:00`)

  trafficChartInstance.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['入场', '出场'], top: 0, textStyle: { fontSize: 12 } },
    grid: { left: 10, right: 10, bottom: 10, top: 30, containLabel: true },
    xAxis: { type: 'category', data: hours, axisLabel: { fontSize: 11 } },
    yAxis: { type: 'value', axisLabel: { fontSize: 11 } },
    series: [
      { name: '入场', type: 'line', smooth: true, data: [12, 15, 18, 25, 32, 45, 58, 72, 85, 78, 65, 52, 48, 55, 62, 70, 75, 68, 55, 42, 35, 28, 20, 15], itemStyle: { color: '#10b981' }, areaStyle: { opacity: 0.2 } },
      { name: '出场', type: 'line', smooth: true, data: [8, 10, 12, 15, 22, 28, 35, 42, 48, 55, 62, 58, 52, 48, 45, 42, 38, 35, 42, 48, 52, 45, 35, 25], itemStyle: { color: '#f59e0b' }, areaStyle: { opacity: 0.2 } }
    ]
  })

  areaChartInstance = echarts.init(areaChart.value)
  areaChartInstance.setOption({
    tooltip: { trigger: 'item' },
    legend: { orient: 'vertical', right: 5, top: 'center', textStyle: { fontSize: 11 } },
    series: [{
      type: 'pie',
      radius: ['40%', '65%'],
      center: ['35%', '50%'],
      avoidLabelOverlap: false,
      label: { show: false },
      data: [
        { value: 45, name: 'A区-地面', itemStyle: { color: '#2563eb' } },
        { value: 38, name: 'B区-地下', itemStyle: { color: '#10b981' } },
        { value: 25, name: 'C区-地下', itemStyle: { color: '#f59e0b' } },
        { value: 20, name: 'VIP专区', itemStyle: { color: '#8b5cf6' } }
      ]
    }]
  })
}

const refreshData = async () => {
  refreshing.value = true
  try {
    const data = await getRealTimeData()
    stats.value[0].value = data.activeCount || 128
    stats.value[1].value = data.todayEntry || 356
    stats.value[2].value = data.todayRevenue || 2846
    stats.value[3].value = data.availableSpaces || 42
    ElMessage.success('数据已更新')
  } catch (error) {
    console.error(error)
  } finally {
    refreshing.value = false
  }
}

const handleQuickAction = (action) => {
  if (action.key === 'entry' || action.key === 'exit') {
    ElMessage.info(`${action.label}功能开发中`)
  } else if (action.key === 'simulation') {
    router.push('/simulation')
  } else if (action.key === 'records') {
    router.push('/records')
  }
}

let refreshTimer = null

onMounted(() => {
  initCharts()
  refreshTimer = setInterval(refreshData, 30000)
  window.addEventListener('resize', () => {
    trafficChartInstance?.resize()
    areaChartInstance?.resize()
  })
})

onUnmounted(() => {
  clearInterval(refreshTimer)
  trafficChartInstance?.dispose()
  areaChartInstance?.dispose()
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

// 图表区域
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
}

// 底部区域
.bottom-section {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  flex-shrink: 0;
  height: 160px;

  .quick-actions-card,
  .recent-records-card {
    background: white;
    border-radius: 12px;
    padding: 12px;
    display: flex;
    flex-direction: column;

    h3 {
      font-size: 14px;
      font-weight: 600;
      color: #1e293b;
      margin: 0 0 10px;
    }
  }

  .quick-actions-card {
    .actions-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 10px;
      flex: 1;

      .action-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 6px;
        padding: 8px;
        background: #f8fafc;
        border: none;
        border-radius: 10px;
        cursor: pointer;
        transition: all 0.3s ease;

        &:hover {
          background: white;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .action-icon {
          width: 36px;
          height: 36px;
          border-radius: 10px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 18px;
        }

        .action-label {
          font-size: 12px;
          font-weight: 500;
          color: #1e293b;
        }
      }
    }
  }

  .recent-records-card {
    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;

      h3 {
        margin: 0;
      }
    }

    .records-list {
      display: flex;
      flex-direction: column;
      gap: 6px;
      flex: 1;
      overflow: hidden;

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

  .bottom-section {
    grid-template-columns: 1fr;
    height: auto;
    min-height: 140px;
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

  .bottom-section {
    gap: 8px;
    min-height: auto;

    .quick-actions-card,
    .recent-records-card {
      padding: 10px;

      h3 {
        font-size: 13px;
        margin-bottom: 8px;
      }
    }

    .quick-actions-card .actions-grid {
      grid-template-columns: repeat(2, 1fr);
      gap: 8px;

      .action-item {
        padding: 6px;

        .action-icon {
          width: 32px;
          height: 32px;
          font-size: 16px;
        }

        .action-label {
          font-size: 11px;
        }
      }
    }

    .recent-records-card .records-list .record-item {
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

  .bottom-section .quick-actions-card .actions-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
