<template>
  <div class="simulation-page">
    <!-- 页面头部 -->
    <div class="page-header">
      <div class="header-title">
        <el-icon class="title-icon"><VideoCamera /></el-icon>
        <div class="title-content">
          <h1>车牌检测</h1>
          <p>上传车牌图片，AI自动识别并展示检测结果</p>
        </div>
      </div>
    </div>

    <!-- 主体内容 -->
    <div class="main-content">
      <!-- 左侧：操作面板 -->
      <div class="operation-panel">

        <!-- 图片上传 -->
        <el-card class="upload-card">
          <template #header>
            <div class="card-header">
              <el-icon><Picture /></el-icon>
              <span>上传车牌图片</span>
              <el-tag v-if="recognitionResult" type="success" size="small" effect="dark">已识别</el-tag>
              <el-tag v-else-if="recognizing" type="warning" size="small" effect="dark">识别中</el-tag>
            </div>
          </template>

          <el-upload
            class="uploader"
            drag
            :auto-upload="false"
            :on-change="handleFileChange"
            accept="image/*"
            :show-file-list="false"
          >
            <el-icon :size="32" class="upload-icon"><UploadFilled /></el-icon>
            <div class="upload-text">点击或拖拽上传图片</div>
            <div class="upload-tip">支持 JPG / PNG / JPEG，上传后自动识别</div>
          </el-upload>
        </el-card>

        <!-- 车牌号 + 操作选择 -->
        <el-card class="action-card">
          <template #header>
            <div class="card-header">
              <el-icon><EditPen /></el-icon>
              <span>车牌 &amp; 操作</span>
            </div>
          </template>

          <div class="action-body">
            <el-input
              v-model="plateNumber"
              placeholder="车牌号（AI识别后自动填入，可手动修改）"
              size="large"
              maxlength="10"
              clearable
              @keyup.enter="canExecute && executeAction()"
            >
              <template #prefix><el-icon><EditPen /></el-icon></template>
            </el-input>

            <div class="action-buttons-grid">
              <div
                class="action-item entry"
                :class="{ active: selectedAction === 'entry' }"
                @click="selectedAction = 'entry'"
              >
                <div class="action-icon">
                  <el-icon :size="24"><ArrowRight /></el-icon>
                </div>
                <div class="action-title">车辆入场</div>
              </div>

              <div
                class="action-item exit"
                :class="{ active: selectedAction === 'exit' }"
                @click="selectedAction = 'exit'"
              >
                <div class="action-icon">
                  <el-icon :size="24"><ArrowLeft /></el-icon>
                </div>
                <div class="action-title">车辆出场</div>
              </div>
            </div>

            <el-button
              type="primary"
              size="large"
              class="execute-btn"
              :loading="processing"
              :disabled="!canExecute"
              @click="executeAction"
            >
              <el-icon><CircleCheck /></el-icon>
              {{ processing ? '处理中...' : '执行操作' }}
            </el-button>
          </div>
        </el-card>
      </div>

      <!-- 右侧：检测结果 -->
      <div class="result-panel">
        <el-card class="result-card">
          <template #header>
            <div class="card-header">
              <el-icon><View /></el-icon>
              <span>检测结果</span>
              <template v-if="recognitionResult">
                <el-tag type="success" size="small" effect="plain">
                  识别置信度 {{ ((recognitionResult.rec_confidence || recognitionResult.confidence || 0) * 100).toFixed(1) }}%
                </el-tag>
                <el-tag type="info" size="small" effect="plain" v-if="recognitionResult.total_time">
                  耗时 {{ recognitionResult.total_time }}ms
                </el-tag>
              </template>
              <el-button v-if="previewUrl" size="small" @click="resetImage" style="margin-left:auto">
                <el-icon><RefreshRight /></el-icon> 重新上传
              </el-button>
            </div>
          </template>

          <div class="result-body">
            <!-- 无图状态 -->
            <div v-if="!previewUrl" class="result-empty">
              <el-icon :size="64" color="#d1d5db"><Picture /></el-icon>
              <p>上传图片后，检测结果将在此展示</p>
            </div>

            <!-- 识别中 -->
            <div v-else-if="recognizing" class="result-loading">
              <div class="loading-img-wrapper">
                <img :src="previewUrl" class="loading-img" />
                <div class="scan-overlay">
                  <div class="scan-line"></div>
                </div>
              </div>
              <p class="loading-text">
                <el-icon class="spin"><Loading /></el-icon>
                AI正在识别车牌...
              </p>
            </div>

            <!-- 检测结果 -->
            <div v-else class="result-content">
              <!-- 图片 + 检测框 -->
              <div class="img-stage">
                <canvas ref="canvasRef" class="result-canvas" />
              </div>

              <!-- 底部信息条 -->
              <div class="result-info-bar" v-if="recognitionResult">
                <div class="info-plate">
                  <span class="info-label">识别车牌</span>
                  <span class="info-value">{{ recognitionResult.plate_number || '未检测到' }}</span>
                </div>
                <div class="info-divider" />
                <div class="info-metrics">
                  <div class="metric">
                    <span class="metric-label">定位置信度</span>
                    <span class="metric-value" :class="(recognitionResult.detect_confidence||0)>0.8?'good':'warn'">
                      {{ recognitionResult.detect_confidence ? (recognitionResult.detect_confidence*100).toFixed(1)+'%' : 'N/A' }}
                    </span>
                  </div>
                  <div class="metric">
                    <span class="metric-label">识别置信度</span>
                    <span class="metric-value" :class="(recognitionResult.rec_confidence||0)>0.8?'good':'warn'">
                      {{ recognitionResult.rec_confidence ? (recognitionResult.rec_confidence*100).toFixed(1)+'%' : 'N/A' }}
                    </span>
                  </div>
                  <div class="metric" v-if="recognitionResult.total_time">
                    <span class="metric-label">检测耗时</span>
                    <span class="metric-value">{{ recognitionResult.total_time }}ms</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 成功弹窗 -->
    <el-dialog
      v-model="successDialogVisible"
      width="360px"
      :show-close="false"
      :close-on-click-modal="false"
      class="success-dialog"
      align-center
    >
      <div class="success-content">
        <el-icon :size="52" color="#67c23a"><CircleCheckFilled /></el-icon>
        <h3>操作成功</h3>
        <p>{{ successMessage }}</p>
        <div class="success-plate">{{ lastPlate }}</div>
        <div v-if="successExtra && successExtra.feeAmount != null" class="success-fee">
          <div class="fee-label">停车费用</div>
          <div class="fee-amount">¥{{ Number(successExtra.feeAmount).toFixed(2) }}</div>
          <div class="fee-duration" v-if="successExtra.duration">停车时长：{{ successExtra.duration }}分钟</div>
          <el-tag v-if="successExtra.feeAmount === 0" type="success">免费</el-tag>
          <el-tag v-else-if="successExtra.needPay" type="warning">待支付</el-tag>
          <el-tag v-else type="success">已结算</el-tag>
        </div>
        <el-button type="primary" style="margin-top:16px" @click="successDialogVisible = false">确定</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { ElMessage } from 'element-plus'
import {
  VideoCamera,
  ArrowLeft,
  ArrowRight,
  EditPen,
  CircleCheck,
  CircleCheckFilled,
  UploadFilled,
  RefreshRight,
  Loading,
  View,
  Picture
} from '@element-plus/icons-vue'
import { recognizePlate as recognizeApi } from '@/api/algorithm'
import { entry, exit } from '@/api/parking'

const plateNumber = ref('')
const selectedAction = ref('')
const processing = ref(false)

const selectedFile = ref(null)
const previewUrl = ref('')
const recognizing = ref(false)
const recognitionResult = ref(null)

const canvasRef = ref(null)

// 等待 canvas 挂载
const waitForCanvas = () => new Promise(resolve => {
  const check = () => {
    if (canvasRef.value) return resolve(canvasRef.value)
    requestAnimationFrame(check)
  }
  check()
})

// 在原图尺寸的 canvas 上画图+框，然后用 CSS max-width/max-height 缩放展示
const drawCanvas = async (bbox = null) => {
  if (!previewUrl.value) return
  const canvas = await waitForCanvas()

  const img = new Image()
  img.src = previewUrl.value
  await new Promise(resolve => { img.onload = resolve })

  // canvas 设为原图尺寸，1:1 绘制
  canvas.width  = img.naturalWidth
  canvas.height = img.naturalHeight

  const ctx = canvas.getContext('2d')
  ctx.drawImage(img, 0, 0)

  if (bbox && bbox.length === 4) {
    const [x1, y1, x2, y2] = bbox
    const bw = x2 - x1
    const bh = y2 - y1

    ctx.strokeStyle = '#10b981'
    ctx.lineWidth = Math.max(3, img.naturalWidth * 0.003)
    ctx.strokeRect(x1, y1, bw, bh)

    const label = recognitionResult.value?.plate_number || ''
    const fs = Math.max(16, img.naturalWidth * 0.02)
    ctx.font = `bold ${fs}px monospace`
    const tw = ctx.measureText(label).width
    const tagH = fs + 10
    const tagY = y1 >= tagH ? y1 - tagH : y2

    ctx.fillStyle = '#10b981'
    ctx.beginPath()
    ctx.roundRect(x1, tagY, tw + 16, tagH, 4)
    ctx.fill()

    ctx.fillStyle = '#fff'
    ctx.fillText(label, x1 + 8, tagY + fs + 2)
  }
}

const successDialogVisible = ref(false)
const successMessage = ref('')
const successExtra = ref(null)
const lastPlate = ref('')

const canExecute = computed(() => plateNumber.value.trim() && selectedAction.value && !processing.value)

const handleFileChange = (uploadFile) => {
  if (!uploadFile.raw || !uploadFile.raw.type.startsWith('image/')) {
    ElMessage.error('请上传图片文件')
    return
  }
  selectedFile.value = uploadFile.raw
  previewUrl.value = URL.createObjectURL(uploadFile.raw)
  recognitionResult.value = null
  plateNumber.value = ''
  startRecognition()
}

const startRecognition = async () => {
  if (!selectedFile.value) return
  recognizing.value = true
  recognitionResult.value = null
  try {
    const res = await recognizeApi(selectedFile.value)
    recognitionResult.value = res || {}
    plateNumber.value = res?.plate_number || ''
    if (!res?.plate_number) {
      ElMessage.warning('未检测到车牌，请手动输入')
    } else {
      ElMessage.success('识别成功：' + res.plate_number)
    }
    recognizing.value = false  // 先关掉扫描动画，canvas 才会渲染出来
    await drawCanvas(res?.bbox || null)
  } catch (e) {
    recognizing.value = false
    ElMessage.error('识别失败：' + (e.message || '未知错误'))
  }
}

const resetImage = () => {
  selectedFile.value = null
  previewUrl.value = ''
  recognitionResult.value = null
  plateNumber.value = ''
}

const executeAction = async () => {
  const plate = plateNumber.value.trim()
  if (!plate || !selectedAction.value) return
  processing.value = true
  try {
    if (selectedAction.value === 'entry') {
      await entry(plate, selectedFile.value)
      successMessage.value = `车辆 ${plate} 已成功入场`
      successExtra.value = null
    } else {
      const res = await exit(plate, selectedFile.value)
      successMessage.value = `车辆 ${plate} 已成功出场`
      successExtra.value = res || null
    }
    lastPlate.value = plate
    successDialogVisible.value = true
    selectedAction.value = ''
  } catch (e) {
    ElMessage.error('操作失败：' + (e.message || '未知错误'))
  } finally {
    processing.value = false
  }
}
</script>

<style scoped lang="scss">
.simulation-page {
  height: 100%;
  padding: 20px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f7fa;
}

.page-header {
  flex-shrink: 0;
  margin-bottom: 14px;

  .header-title {
    display: flex;
    align-items: center;
    gap: 14px;

    .title-icon {
      width: 42px;
      height: 42px;
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 20px;
      flex-shrink: 0;
    }

    .title-content {
      h1 { font-size: 20px; font-weight: 600; color: #1e293b; margin: 0 0 2px 0; }
      p  { font-size: 13px; color: #64748b; margin: 0; }
    }
  }
}

.main-content {
  flex: 1;
  min-height: 0;
  display: flex;
  gap: 14px;
}

// ── 左侧 ──
.operation-panel {
  width: 340px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  color: #374151;
  flex-wrap: wrap;
}

.upload-card {
  flex-shrink: 0;

  :deep(.el-card__body) { padding: 12px; }

  .uploader {
    :deep(.el-upload) { width: 100%; }
    :deep(.el-upload-dragger) {
      width: 100%;
      height: 100px;
      padding: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border-radius: 8px;
      border: 1.5px dashed #d1d5db;
      background: #fafafa;
      gap: 4px;

      &:hover { border-color: #6366f1; }
    }
  }

  .upload-icon { color: #9ca3af; }
  .upload-text { font-size: 13px; color: #6b7280; }
  .upload-tip  { font-size: 11px; color: #9ca3af; }
}

.action-card {
  flex: 1;
  min-height: 0;

  :deep(.el-card__body) {
    padding: 12px;
    height: calc(100% - 48px);
    box-sizing: border-box;
    display: flex;
    flex-direction: column;
  }
}

.action-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  min-height: 0;
}

.action-buttons-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  flex: 1;
  min-height: 0;
}

.action-item {
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 12px 8px;

  &:hover { transform: translateY(-1px); box-shadow: 0 4px 12px -2px rgba(0,0,0,0.1); }
  &.active.entry { border-color: #10b981; background: rgba(16,185,129,0.06); }
  &.active.exit  { border-color: #f59e0b; background: rgba(245,158,11,0.06); }

  .action-icon {
    width: 44px;
    height: 44px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;

    .entry & { background: linear-gradient(135deg,#10b981,#34d399); color: white; }
    .exit  & { background: linear-gradient(135deg,#f59e0b,#fbbf24); color: white; }
  }

  .action-title { font-size: 14px; font-weight: 600; color: #374151; }
}

.execute-btn {
  width: 100%;
  height: 40px;
  font-size: 14px;
  flex-shrink: 0;
}

// ── 右侧 ──
.result-panel {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
}

.result-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;

  :deep(.el-card__body) {
    flex: 1;
    min-height: 0;
    padding: 0;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }
}

.result-body {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

.result-empty {
  text-align: center;
  color: #9ca3af;
  p { margin-top: 16px; font-size: 14px; }
}

// 识别中：显示图片 + 扫描线动画
.result-loading {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;

  .loading-img-wrapper {
    flex: 1;
    min-height: 0;
    position: relative;
    overflow: hidden;
    background: #111827;
    display: flex;
    align-items: center;
    justify-content: center;

    .loading-img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
      opacity: 0.7;
    }

    .scan-overlay {
      position: absolute;
      inset: 0;
      overflow: hidden;

      .scan-line {
        position: absolute;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, transparent, #10b981, transparent);
        animation: scan 2s ease-in-out infinite;
      }
    }
  }

  .loading-text {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 10px;
    font-size: 14px;
    color: #6b7280;
    background: #fff;
    border-top: 1px solid #e5e7eb;
    margin: 0;
  }
}

@keyframes scan {
  0%   { top: 0; }
  50%  { top: calc(100% - 3px); }
  100% { top: 0; }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to   { transform: rotate(360deg); }
}
.spin { animation: spin 1s linear infinite; }

// 检测结果
.result-content {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.img-stage {
  flex: 1;
  min-height: 0;
  background: #111827;
  display: flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
}

// canvas 原图尺寸绘制，CSS 缩放展示，框坐标永远精确
.result-canvas {
  display: block;
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.result-info-bar {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 10px 16px;
  background: #fff;
  border-top: 1px solid #e5e7eb;

  .info-plate {
    display: flex;
    flex-direction: column;
    gap: 2px;

    .info-label { font-size: 11px; color: #9ca3af; }
    .info-value {
      font-size: 20px;
      font-weight: 700;
      color: #166534;
      font-family: 'Courier New', monospace;
      letter-spacing: 4px;
    }
  }

  .info-divider {
    width: 1px;
    height: 36px;
    background: #e5e7eb;
    flex-shrink: 0;
  }

  .info-metrics {
    display: flex;
    gap: 20px;
    flex: 1;

    .metric {
      display: flex;
      flex-direction: column;
      gap: 2px;

      .metric-label { font-size: 11px; color: #9ca3af; }
      .metric-value {
        font-size: 14px;
        font-weight: 600;
        color: #374151;
        &.good { color: #059669; }
        &.warn { color: #d97706; }
      }
    }
  }
}

// ── 成功弹窗 ──
.success-dialog {
  :deep(.el-dialog__header) { display: none; }
  :deep(.el-dialog__body) { padding: 28px; }
}

.success-content {
  text-align: center;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;

  h3 { font-size: 20px; font-weight: 600; color: #374151; margin: 0; }
  p  { font-size: 13px; color: #6b7280; margin: 0; }

  .success-plate {
    font-size: 26px;
    font-weight: 700;
    color: #166534;
    letter-spacing: 5px;
    font-family: 'Courier New', monospace;
    padding: 12px 20px;
    background: linear-gradient(135deg, #f0fdf4, #dcfce7);
    border-radius: 8px;
    width: 100%;
    box-sizing: border-box;
  }

  .success-fee {
    width: 100%;
    padding: 10px 16px;
    background: linear-gradient(135deg, #fffbeb, #fef3c7);
    border-radius: 8px;
    box-sizing: border-box;

    .fee-label    { font-size: 11px; color: #92400e; }
    .fee-amount   { font-size: 24px; font-weight: 700; color: #d97706; }
    .fee-duration { font-size: 11px; color: #92400e; margin-bottom: 4px; }
  }
}
</style>
