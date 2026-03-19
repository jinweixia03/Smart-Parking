<template>
  <div class="space-manage-2-5d">
    <!-- 3D 画布容器 -->
    <div ref="canvasContainer" class="canvas-container">
      <div v-if="isLoading" class="loading-overlay">
        <div class="loading-spinner"></div>
        <span>加载 3D 停车场...</span>
      </div>
    </div>

    <!-- 左上角综合控制面板 -->
    <div class="control-panel">
      <!-- 统计数据 -->
      <div class="section stats-section">
        <div class="stat-row" v-for="(stat, index) in stats" :key="index">
          <div class="stat-dot" :class="stat.class"></div>
          <span class="stat-label">{{ stat.label }}</span>
          <span class="stat-value">{{ stat.value }}{{ stat.suffix }}</span>
        </div>
      </div>

      <div class="divider" />

      <!-- 楼层切换 -->
      <div class="section">
        <div class="section-title">楼层</div>
        <div class="floor-buttons">
          <button
            v-for="floor in FLOORS"
            :key="floor.code"
            :class="['floor-btn', { active: currentFloor === floor.code }]"
            @click="handleSwitchFloor(floor.code)"
          >
            <el-icon><OfficeBuilding /></el-icon>
            <span>{{ floor.name }}</span>
          </button>
        </div>
      </div>

      <div class="divider" />

      <!-- 图例 -->
      <div class="section">
        <div class="section-title">区域图例</div>
        <div class="legend-items">
          <div class="legend-item" v-for="(item, index) in legendItems" :key="index">
            <div class="legend-box" :style="item.style || {}"></div>
            <span>{{ item.label }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 选中车位详情（右上角保留） -->
    <div v-if="selectedSpace" class="space-detail-panel">
      <div class="panel-header">
        <h3>车位详情</h3>
        <el-icon class="close-btn" @click="handleCloseDetail"><Close /></el-icon>
      </div>
      <div class="panel-body">
        <div class="detail-item" v-for="(item, index) in detailItems" :key="index">
          <span class="label">{{ item.label }}</span>
          <span :class="['value', item.class]" v-if="item.value">{{ item.value }}</span>
          <span :class="['status-badge', item.statusClass]" v-else>{{ item.statusText }}</span>
        </div>
      </div>
    </div>

    <!-- 操作提示 -->
    <div class="controls-hint">
      <el-icon><Mouse /></el-icon>
      <span>拖拽平移 | 滚轮缩放 | 点击查看</span>
    </div>

    <!-- 视角控制 -->
    <div class="view-controls">
      <button class="view-btn" @click="resetCamera" title="重置视角">
        <el-icon><RefreshRight /></el-icon>
      </button>
      <button class="view-btn" :class="{ active: autoRotate }" @click="toggleAutoRotate" title="自动旋转">
        <el-icon><Refresh /></el-icon>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch, nextTick, onMounted, onUnmounted } from 'vue'
import { Check, Close, Star, PieChart, OfficeBuilding, RefreshRight, Refresh, Mouse } from '@element-plus/icons-vue'
import { useParkingLot } from '@/composables/useParkingLot.js'
import { useThreeScene } from '@/composables/useThreeScene.js'
import { useParkingBuilder } from '@/composables/useParkingBuilder.js'
import { FLOORS, SPACE_STATUS } from '@/constants/parking.js'
import { getAreas } from '@/api/parking.js'

// ==================== 状态管理 ====================
const canvasContainer = ref(null)
const autoRotate = ref(false)

const {
  spaces,
  currentFloor,
  selectedSpace,
  floorSpaces,
  freeCount,
  occupiedCount,
  vipCount,
  occupancyRate,
  initData,
  switchFloor,
  selectSpace,
  closeDetail,
  formatTime
} = useParkingLot()

// ==================== Three.js 场景 ====================
const {
  scene,
  spaceMeshes,
  carMeshes,
  materials,
  isLoading,
  setSelectedMesh,
  clearSelectedMesh,
  resetCamera,
  toggleAutoRotate: toggleRotate
} = useThreeScene(canvasContainer, handleSpaceClick)

const { build } = useParkingBuilder(scene, materials, spaceMeshes, carMeshes)

// ==================== 计算属性 ====================
const stats = computed(() => [
  { icon: 'Check', label: '空闲', value: freeCount.value, suffix: '', class: 'free' },
  { icon: 'Close', label: '占用', value: occupiedCount.value, suffix: '', class: 'occupied' },
  { icon: 'Star', label: 'VIP', value: vipCount.value, suffix: '', class: 'vip' },
  { icon: 'PieChart', label: '占用率', value: occupancyRate.value, suffix: '%', class: 'rate' }
])

const detailItems = computed(() => {
  const s = selectedSpace.value
  if (!s) return []
  const items = [
    { label: '车位编号', value: s.spaceCode },
    { label: '状态', statusText: s.status === SPACE_STATUS.FREE ? '空闲' : '占用', statusClass: s.status === SPACE_STATUS.FREE ? 'free' : 'occupied' },
    { label: '区域类型', value: s.areaType || '-' },
  ]
  if (s.status === SPACE_STATUS.OCCUPIED) {
    items.push({ label: '车牌号', value: s.currentPlate || '-', class: 'plate' })
    items.push({ label: '入场时间', value: formatTime(s.entryTime) })
    if (s.entryTime) {
      const mins = Math.floor((Date.now() - new Date(s.entryTime)) / 60000)
      const h = Math.floor(mins / 60), m = mins % 60
      items.push({ label: '已停时长', value: h > 0 ? `${h}小时${m}分` : `${m}分钟` })
    }
  }
  return items
})

// ==================== 区域图例数据 ====================
const areaList = ref([])

const loadAreas = async () => {
  try {
    const res = await getAreas()
    const data = res.data || res
    if (data && Array.isArray(data)) {
      areaList.value = data
    }
  } catch (error) {
    areaList.value = [
      { areaCode: 'A', areaName: 'A区-普通', areaType: '普通' },
      { areaCode: 'B', areaName: 'B区-充电桩', areaType: '充电桩' },
      { areaCode: 'C', areaName: 'C区-东向', areaType: '普通' },
      { areaCode: 'D', areaName: 'D区-VIP', areaType: 'VIP' }
    ]
  }
}

// 按 areaCode 匹配颜色，与 3D 场景一致
const areaCodeColorMap = {
  A: { bg: 'rgba(72, 187, 120, 0.3)', border: '#48bb78' },
  B: { bg: 'rgba(66, 153, 225, 0.3)', border: '#4299e1' },
  C: { bg: 'rgba(139, 92, 246, 0.3)', border: '#8b5cf6' },
  D: { bg: 'rgba(245, 158, 11, 0.3)', border: '#f59e0b' },
}

const legendItems = computed(() => {
  const items = areaList.value.map(area => {
    const code = (area.areaCode || 'A').toUpperCase()
    const color = areaCodeColorMap[code] || areaCodeColorMap.A
    return {
      label: `${area.areaCode}区 · ${area.areaType}`,
      style: { background: color.bg, borderColor: color.border }
    }
  })
  items.push(
    { label: '占用', style: { background: 'rgba(245, 101, 101, 0.3)', borderColor: '#f56565' } }
  )
  return items
})

// ==================== 方法 ====================
function handleSpaceClick(space) {
  clearSelectedMesh()
  selectSpace(space)
  const meshData = spaceMeshes.get(space.spaceCode)
  if (meshData) {
    setSelectedMesh(meshData.ground)
  }
}

function handleSwitchFloor(floorCode) {
  clearSelectedMesh()
  switchFloor(floorCode)
}

function handleCloseDetail() {
  closeDetail()
  clearSelectedMesh()
}

function toggleAutoRotate() {
  autoRotate.value = !autoRotate.value
  toggleRotate(autoRotate.value)
}

// ==================== 初始化 ====================
initData()
loadAreas()

watch(currentFloor, () => {
  nextTick(() => {
    if (scene.value) {
      build(floorSpaces.value)
    }
  })
})

let initCheckInterval
let refreshInterval

function checkAndBuild() {
  if (scene.value && floorSpaces.value.length > 0) {
    build(floorSpaces.value)
    clearInterval(initCheckInterval)
  }
}

// 刷新车位数据并重绘
async function refreshSpaces() {
  await initData()
  if (scene.value) {
    build(floorSpaces.value)
  }
}

onMounted(() => {
  initCheckInterval = setInterval(checkAndBuild, 100)
  setTimeout(() => clearInterval(initCheckInterval), 5000)
  // 每30秒自动刷新
  refreshInterval = setInterval(refreshSpaces, 30000)
})

onUnmounted(() => {
  clearInterval(initCheckInterval)
  clearInterval(refreshInterval)
})
</script>

<style scoped lang="scss">
.space-manage-2-5d {
  position: relative;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 50%, #e2e8f0 100%);
  overflow: hidden;
}

.canvas-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  canvas {
    display: block;
    width: 100%;
    height: 100%;
  }
}

.loading-overlay {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(247, 250, 252, 0.95);
  gap: 16px;
  z-index: 100;
  .loading-spinner {
    width: 48px;
    height: 48px;
    border: 3px solid rgba(59, 130, 246, 0.2);
    border-top-color: #3b82f6;
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  span { font-size: 14px; color: #64748b; }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// 左上角综合控制面板
.control-panel {
  position: absolute;
  top: 16px;
  left: 16px;
  width: 220px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.96);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 14px;

  .section { display: flex; flex-direction: column; gap: 8px; }

  .section-title {
    font-size: 11px;
    font-weight: 700;
    color: #a0aec0;
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  .divider {
    height: 1px;
    background: #e2e8f0;
  }

  // 统计行
  .stats-section { gap: 8px; }
  .stat-row {
    display: flex;
    align-items: center;
    gap: 10px;
    .stat-dot {
      width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0;
      &.free     { background: #48bb78; box-shadow: 0 0 6px rgba(72,187,120,0.5); }
      &.occupied { background: #f56565; box-shadow: 0 0 6px rgba(245,101,101,0.5); }
      &.vip      { background: #f59e0b; box-shadow: 0 0 6px rgba(245,158,11,0.5); }
      &.rate     { background: #4299e1; box-shadow: 0 0 6px rgba(66,153,225,0.5); }
    }
    .stat-label { font-size: 13px; color: #718096; flex: 1; }
    .stat-value { font-size: 18px; font-weight: 700; color: #2d3748; }
  }

  // 楼层按钮
  .floor-buttons { display: flex; gap: 8px; }
  .floor-btn {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 10px 8px;
    border: 1.5px solid #e2e8f0;
    border-radius: 10px;
    background: #f8fafc;
    color: #718096;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
    &:hover { background: rgba(66, 153, 225, 0.08); border-color: #4299e1; color: #4299e1; }
    &.active { background: linear-gradient(135deg, #4299e1, #3182ce); border-color: #4299e1; color: white; box-shadow: 0 4px 12px rgba(66,153,225,0.4); }
    .el-icon { font-size: 15px; }
  }

  // 图例
  .legend-items { display: flex; flex-direction: column; gap: 8px; }
  .legend-item {
    display: flex; align-items: center; gap: 10px; font-size: 13px; color: #4a5568;
  }
  .legend-box {
    width: 16px; height: 16px; border-radius: 4px; border: 2px solid; flex-shrink: 0;
  }
}

// 详情面板（右上角）
.space-detail-panel {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 240px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.96);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.15);
  z-index: 10;

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 14px;
    padding-bottom: 12px;
    border-bottom: 1px solid #e2e8f0;
    h3 { font-size: 16px; font-weight: 700; color: #2d3748; margin: 0; }
    .close-btn {
      width: 28px; height: 28px;
      display: flex; align-items: center; justify-content: center;
      border-radius: 8px; cursor: pointer; color: #a0aec0; font-size: 16px;
      &:hover { background: rgba(245, 101, 101, 0.1); color: #f56565; }
    }
  }

  .panel-body { display: flex; flex-direction: column; gap: 10px; }

  .detail-item {
    display: flex; justify-content: space-between; align-items: center;
    .label { font-size: 13px; color: #a0aec0; }
    .value {
      font-size: 14px; font-weight: 600; color: #2d3748;
      &.plate {
        padding: 4px 10px;
        background: linear-gradient(135deg, #4299e1, #3182ce);
        color: white; border-radius: 6px;
        font-family: 'Courier New', monospace;
        font-size: 14px;
        letter-spacing: 2px;
      }
    }
    .status-badge {
      padding: 4px 12px; border-radius: 20px; font-size: 13px; font-weight: 600;
      &.free { background: rgba(72, 187, 120, 0.12); color: #38a169; }
      &.occupied { background: rgba(245, 101, 101, 0.12); color: #e53e3e; }
    }
  }
}

// 操作提示
.controls-hint {
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  color: #718096;
  font-size: 11px;
  z-index: 10;
  white-space: nowrap;
  .el-icon { font-size: 12px; color: #4299e1; }
}

// 视角控制
.view-controls {
  position: absolute;
  bottom: 8px;
  right: 8px;
  display: flex;
  gap: 4px;
  z-index: 10;

  .view-btn {
    width: 32px; height: 32px;
    border: none; border-radius: 8px;
    background: rgba(255, 255, 255, 0.95);
    color: #718096; font-size: 14px;
    cursor: pointer; transition: all 0.3s ease;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    display: flex; align-items: center; justify-content: center;
    &:hover { background: #4299e1; color: white; }
    &.active { background: #4299e1; color: white; }
  }
}

@media (max-width: 768px) {
  .control-panel { width: 150px; padding: 10px; }
  .space-detail-panel { width: 160px; padding: 10px; }
}
</style>
