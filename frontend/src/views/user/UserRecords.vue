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

      <el-table :data="records" stripe v-loading="loading" style="width:100%">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="plateNumber" label="车牌号" min-width="120" />
        <el-table-column prop="entryTime" label="入场时间" min-width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.entryTime) }}
          </template>
        </el-table-column>
        <el-table-column prop="exitTime" label="出场时间" min-width="160">
          <template #default="{ row }">
            {{ row.exitTime ? formatDateTime(row.exitTime) : '停车中' }}
          </template>
        </el-table-column>
        <el-table-column prop="parkingMinutes" label="停车时长" min-width="100">
          <template #default="{ row }">
            {{ row.parkingMinutes ? formatDuration(row.parkingMinutes) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="feeAmount" label="应付金额" min-width="100">
          <template #default="{ row }">
            <span :class="{ 'unpaid': row.payStatus === 0 }">
              ¥{{ row.feeAmount ?? 0 }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="payStatus" label="支付状态" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getPayStatusType(row.payStatus)">
              {{ getPayStatusText(row.payStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button
              v-if="row.payStatus === 0 && row.exitTime"
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
            <el-tag v-else-if="!row.exitTime" type="warning" size="small">
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

    <!-- 支付弹窗 -->
    <el-dialog
      v-model="payDialogVisible"
      :title="payStep === 'select' ? '停车费用支付' : (payStep === 'qr' ? '扫码支付' : '支付成功')"
      width="420px"
      center
      :close-on-click-modal="false"
      @close="onPayDialogClose"
    >
      <div v-if="currentRecord" class="pay-dialog-content">

        <!-- 步骤1：选择支付方式 -->
        <template v-if="payStep === 'select'">
          <div class="pay-info">
            <div class="info-row">
              <span class="label">车牌号</span>
              <span class="value plate-font">{{ currentRecord.plateNumber }}</span>
            </div>
            <div class="info-row">
              <span class="label">入场时间</span>
              <span class="value">{{ formatDateTime(currentRecord.entryTime) }}</span>
            </div>
            <div class="info-row">
              <span class="label">出场时间</span>
              <span class="value">{{ formatDateTime(currentRecord.exitTime) }}</span>
            </div>
            <div class="info-row">
              <span class="label">停车时长</span>
              <span class="value">{{ formatDuration(currentRecord.parkingMinutes) }}</span>
            </div>
          </div>

          <div class="pay-amount">
            <span class="amount-label">应付金额</span>
            <span class="amount-value">¥{{ currentRecord.feeAmount || currentRecord.payableAmount || '0.00' }}</span>
          </div>

          <div class="pay-methods">
            <div
              class="pay-method wechat"
              :class="{ active: selectedPayMethod === 'wechat' }"
              @click="selectedPayMethod = 'wechat'"
            >
              <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48 48'%3E%3Ccircle cx='24' cy='24' r='24' fill='%2307C160'/%3E%3Cpath d='M20 16c-5 0-9 3.4-9 7.5 0 2.3 1.3 4.3 3.3 5.7L13 32l3.8-1.9c1 .3 2 .4 3.2.4 5 0 9-3.4 9-7.5S25 16 20 16zm-2.5 4.5a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4zm5 0a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4zm3.5 5c0 3.3-3.6 6-8 6-.9 0-1.8-.1-2.6-.4L13 32l1.2-2.8C12.9 28 12 26.6 12 25c0-3.3 3.6-6 8-6s8 2.7 8 6zm-1 0' fill='white'/%3E%3C/svg%3E" class="pay-icon-img" alt="wechat" />
              <span>微信支付</span>
              <el-icon class="check-icon"><CircleCheckFilled /></el-icon>
            </div>
            <div
              class="pay-method alipay"
              :class="{ active: selectedPayMethod === 'alipay' }"
              @click="selectedPayMethod = 'alipay'"
            >
              <img src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48 48'%3E%3Ccircle cx='24' cy='24' r='24' fill='%231677FF'/%3E%3Ctext x='24' y='31' text-anchor='middle' font-size='22' font-weight='bold' fill='white' font-family='Arial'%3E%E6%94%AF%3C/text%3E%3C/svg%3E" class="pay-icon-img" alt="alipay" />
              <span>支付宝</span>
              <el-icon class="check-icon"><CircleCheckFilled /></el-icon>
            </div>
          </div>
        </template>

        <!-- 步骤2：扫码支付 -->
        <template v-else-if="payStep === 'qr'">
          <div class="qr-section">
            <div class="qr-header">
              <div class="qr-method-badge" :class="selectedPayMethod">
                {{ selectedPayMethod === 'wechat' ? '微信支付' : '支付宝' }}
              </div>
              <div class="qr-amount">¥{{ orderInfo?.amount }}</div>
            </div>

            <!-- 模拟二维码（用 canvas 绘制格子图案） -->
            <div class="qr-box">
              <canvas ref="qrCanvas" width="180" height="180" class="qr-canvas" />
              <div v-if="qrExpired" class="qr-expired-mask">
                <el-icon :size="32"><RefreshRight /></el-icon>
                <p>二维码已过期</p>
                <el-button size="small" @click="refreshOrder">刷新</el-button>
              </div>
            </div>

            <p class="qr-tip">
              <el-icon><PhoneFilled /></el-icon>
              请使用{{ selectedPayMethod === 'wechat' ? '微信' : '支付宝' }} App 扫描上方二维码
            </p>

            <div class="qr-countdown">
              <el-icon><Timer /></el-icon>
              二维码有效期：<span :class="{ urgent: countdown <= 60 }">{{ formatCountdown(countdown) }}</span>
            </div>

            <div class="qr-status">
              <el-icon class="spin"><Loading /></el-icon>
              等待支付...（演示模式：10秒后自动完成）
            </div>
          </div>
        </template>

        <!-- 步骤3：支付成功 -->
        <template v-else-if="payStep === 'success'">
          <div class="pay-success">
            <el-icon :size="64" color="#07C160"><CircleCheckFilled /></el-icon>
            <h3>支付成功</h3>
            <p class="success-plate">{{ currentRecord.plateNumber }}</p>
            <p class="success-amount">¥{{ orderInfo?.amount }}</p>
            <p class="success-method">{{ selectedPayMethod === 'wechat' ? '微信支付' : '支付宝' }} · {{ formatDateTime(new Date().toISOString()) }}</p>
          </div>
        </template>
      </div>

      <template #footer>
        <template v-if="payStep === 'select'">
          <el-button @click="payDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="payLoading" @click="createOrder">
            立即支付 ¥{{ currentRecord?.feeAmount || currentRecord?.payableAmount }}
          </el-button>
        </template>
        <template v-else-if="payStep === 'qr'">
          <el-button @click="cancelOrder">取消支付</el-button>
        </template>
        <template v-else-if="payStep === 'success'">
          <el-button type="primary" @click="onPaySuccess">完成</el-button>
        </template>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Van, Search, CircleCheckFilled, RefreshRight, PhoneFilled, Timer, Loading } from '@element-plus/icons-vue'
import { getRecordsByPlate, createPayOrder, queryPayOrder } from '@/api/parking'

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
const payStep = ref('select') // select | qr | success
const orderInfo = ref(null)
const countdown = ref(300)
const qrExpired = ref(false)
const qrCanvas = ref(null)

let pollTimer = null
let countdownTimer = null

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
    .reduce((sum, r) => sum + (Number(r.feeAmount) || 0), 0)
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

// 打开支付弹窗
const handlePay = (row) => {
  currentRecord.value = row
  selectedPayMethod.value = 'wechat'
  payStep.value = 'select'
  orderInfo.value = null
  qrExpired.value = false
  payDialogVisible.value = true
}

// 创建订单并进入扫码步骤
const createOrder = async () => {
  if (!currentRecord.value) return
  payLoading.value = true
  try {
    const res = await createPayOrder(currentRecord.value.recordId, selectedPayMethod.value)
    orderInfo.value = res
    payStep.value = 'qr'
    countdown.value = 300
    qrExpired.value = false
    await nextTick()
    drawQrCode()
    startCountdown()
    startPolling(res.orderId)
  } catch (e) {
    ElMessage.error('创建订单失败：' + (e.message || '未知错误'))
  } finally {
    payLoading.value = false
  }
}

// 绘制模拟二维码
const drawQrCode = () => {
  const canvas = qrCanvas.value
  if (!canvas) return
  const ctx = canvas.getContext('2d')
  const size = 180
  const cells = 25
  const cellSize = size / cells

  ctx.fillStyle = '#fff'
  ctx.fillRect(0, 0, size, size)

  // 用订单号做种子生成伪随机格子
  const seed = (orderInfo.value?.orderId || 'mock').split('').reduce((a, c) => a + c.charCodeAt(0), 0)
  const rand = (i) => ((seed * 1103515245 + i * 12345) >>> 0) % 100

  ctx.fillStyle = '#000'
  for (let r = 0; r < cells; r++) {
    for (let c = 0; c < cells; c++) {
      // 保留三个角的定位块
      const inCorner = (r < 7 && c < 7) || (r < 7 && c >= cells - 7) || (r >= cells - 7 && c < 7)
      if (inCorner || rand(r * cells + c) < 45) {
        ctx.fillRect(c * cellSize, r * cellSize, cellSize - 0.5, cellSize - 0.5)
      }
    }
  }
  // 绘制三个定位框（白底+黑边+中心点）
  ;[[0, 0], [0, cells - 7], [cells - 7, 0]].forEach(([row, col]) => {
    ctx.fillStyle = '#fff'
    ctx.fillRect(col * cellSize + cellSize, row * cellSize + cellSize, 5 * cellSize, 5 * cellSize)
    ctx.fillStyle = '#000'
    ctx.strokeStyle = '#000'
    ctx.lineWidth = cellSize
    ctx.strokeRect((col + 0.5) * cellSize, (row + 0.5) * cellSize, 6 * cellSize, 6 * cellSize)
    ctx.fillRect((col + 2) * cellSize, (row + 2) * cellSize, 3 * cellSize, 3 * cellSize)
  })

  // 中间叠加支付方式 logo 颜色遮罩
  const color = selectedPayMethod.value === 'wechat' ? 'rgba(7,193,96,0.15)' : 'rgba(22,119,255,0.15)'
  ctx.fillStyle = color
  ctx.beginPath()
  ctx.roundRect(size / 2 - 22, size / 2 - 22, 44, 44, 8)
  ctx.fill()
  ctx.fillStyle = selectedPayMethod.value === 'wechat' ? '#07C160' : '#1677FF'
  ctx.font = 'bold 13px Arial'
  ctx.textAlign = 'center'
  ctx.fillText(selectedPayMethod.value === 'wechat' ? '微信' : '支付宝', size / 2, size / 2 + 5)
}

// 倒计时
const startCountdown = () => {
  clearInterval(countdownTimer)
  countdownTimer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(countdownTimer)
      qrExpired.value = true
      stopPolling()
    }
  }, 1000)
}

const formatCountdown = (s) => {
  const m = Math.floor(s / 60)
  const sec = s % 60
  return `${m}:${String(sec).padStart(2, '0')}`
}

// 轮询订单状态
const startPolling = (orderId) => {
  stopPolling()
  pollTimer = setInterval(async () => {
    try {
      const res = await queryPayOrder(orderId)
      if (res.paid) {
        stopPolling()
        clearInterval(countdownTimer)
        payStep.value = 'success'
      }
    } catch (e) {
      // 订单过期等错误，停止轮询
      stopPolling()
    }
  }, 2000)
}

const stopPolling = () => {
  if (pollTimer) { clearInterval(pollTimer); pollTimer = null }
}

// 刷新订单
const refreshOrder = () => {
  qrExpired.value = false
  createOrder()
}

// 取消支付
const cancelOrder = () => {
  stopPolling()
  clearInterval(countdownTimer)
  payStep.value = 'select'
}

// 支付成功后关闭
const onPaySuccess = () => {
  payDialogVisible.value = false
  handleSearch()
}

// 弹窗关闭时清理
const onPayDialogClose = () => {
  stopPolling()
  clearInterval(countdownTimer)
}

onUnmounted(() => {
  stopPolling()
  clearInterval(countdownTimer)
})

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
    border-radius: 10px;
    padding: 14px 16px;
    margin-bottom: 16px;

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 6px 0;
      border-bottom: 1px solid #f1f5f9;

      &:last-child { border-bottom: none; }

      .label { font-size: 13px; color: #94a3b8; }
      .value { font-size: 13px; color: #1e293b; font-weight: 500; }
      .plate-font { font-family: 'Courier New', monospace; font-size: 15px; letter-spacing: 2px; }
    }
  }

  .pay-amount {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px;
    background: linear-gradient(135deg, #fffbeb, #fef3c7);
    border-radius: 10px;
    margin-bottom: 16px;

    .amount-label { font-size: 13px; color: #92400e; margin-bottom: 4px; }
    .amount-value { font-size: 32px; font-weight: 700; color: #f59e0b; }
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
      padding: 14px 10px;
      border: 2px solid #e2e8f0;
      border-radius: 12px;
      cursor: pointer;
      transition: all 0.25s;
      position: relative;

      &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }

      &.wechat.active { border-color: #07C160; background: #f0fdf4; }
      &.alipay.active { border-color: #1677FF; background: #eff6ff; }

      .pay-icon-img { width: 36px; height: 36px; border-radius: 8px; }

      span { font-size: 13px; color: #374151; font-weight: 500; }

      .check-icon {
        position: absolute;
        top: 6px;
        right: 6px;
        font-size: 16px;
        opacity: 0;
        transition: opacity 0.2s;
      }

      &.wechat.active .check-icon { opacity: 1; color: #07C160; }
      &.alipay.active .check-icon { opacity: 1; color: #1677FF; }
    }
  }

  // 扫码页
  .qr-section {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;

    .qr-header {
      text-align: center;
      .qr-method-badge {
        display: inline-block;
        padding: 3px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        margin-bottom: 6px;
        &.wechat { background: #f0fdf4; color: #07C160; }
        &.alipay { background: #eff6ff; color: #1677FF; }
      }
      .qr-amount { font-size: 28px; font-weight: 700; color: #1e293b; }
    }

    .qr-box {
      position: relative;
      width: 180px;
      height: 180px;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      overflow: hidden;

      .qr-canvas { display: block; }

      .qr-expired-mask {
        position: absolute;
        inset: 0;
        background: rgba(255,255,255,0.92);
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 6px;
        color: #64748b;
        font-size: 13px;
      }
    }

    .qr-tip {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: #64748b;
      margin: 0;
    }

    .qr-countdown {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 12px;
      color: #94a3b8;

      span { font-weight: 600; color: #374151; }
      span.urgent { color: #ef4444; }
    }

    .qr-status {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 12px;
      color: #94a3b8;
    }
  }

  // 支付成功
  .pay-success {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    padding: 16px 0;

    h3 { font-size: 22px; font-weight: 600; color: #1e293b; margin: 0; }
    .success-plate { font-family: 'Courier New', monospace; font-size: 18px; letter-spacing: 3px; color: #374151; margin: 0; }
    .success-amount { font-size: 28px; font-weight: 700; color: #07C160; margin: 0; }
    .success-method { font-size: 12px; color: #94a3b8; margin: 0; }
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
.spin { animation: spin 1s linear infinite; }
</style>
