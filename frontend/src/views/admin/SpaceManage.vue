<template>
  <div class="space-manage-2-5d">
    <!-- 3D 画布容器 -->
    <div ref="canvasContainer" class="canvas-container">
      <div v-if="isLoading" class="loading-overlay">
        <div class="loading-spinner"></div>
        <span>加载 3D 停车场...</span>
      </div>
    </div>

    <!-- 顶部信息栏 -->
    <div class="top-info-bar">
      <div class="info-item" v-for="(stat, index) in stats" :key="index">
        <div class="info-icon" :class="stat.class">
          <el-icon><component :is="stat.icon" /></el-icon>
        </div>
        <div class="info-content">
          <span class="info-label">{{ stat.label }}</span>
          <span class="info-value">{{ stat.value }}{{ stat.suffix }}</span>
        </div>
      </div>
    </div>

    <!-- 楼层切换 -->
    <div class="floor-panel">
      <div class="panel-title">楼层</div>
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

    <!-- 选中车位详情 -->
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

    <!-- 图例 -->
    <div class="legend-panel">
      <div class="panel-title">区域</div>
      <div class="legend-items">
        <div class="legend-item" v-for="(item, index) in legendItems.slice(0, 4)" :key="index">
          <div class="legend-box" :class="item.class" :style="item.style || {}"></div>
          <span>{{ item.label.split(' ')[0] }}</span>
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
import { ref, computed, watch, nextTick, onMounted } from 'vue'
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

const detailItems = computed(() => [
  { label: '车位编号', value: selectedSpace.value?.spaceCode },
  { label: '状态', statusText: selectedSpace.value?.status === SPACE_STATUS.FREE ? '空闲' : '占用', statusClass: selectedSpace.value?.status === SPACE_STATUS.FREE ? 'free' : 'occupied' },
  { label: '类型', value: selectedSpace.value?.areaType },
  ...(selectedSpace.value?.status === SPACE_STATUS.OCCUPIED ? [
    { label: '车牌', value: selectedSpace.value?.currentPlate || '-', class: 'plate' },
    { label: '入场', value: formatTime(selectedSpace.value?.entryTime) }
  ] : [])
])

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

const areaTypeColorMap = {
  '普通': { bg: 'rgba(72, 187, 120, 0.2)', border: '#48bb78' },
  'VIP': { bg: 'rgba(245, 158, 11, 0.2)', border: '#f59e0b' },
  '充电桩': { bg: 'rgba(66, 153, 225, 0.2)', border: '#4299e1' },
  '东向': { bg: 'rgba(139, 92, 246, 0.2)', border: '#8b5cf6' }
}

const legendItems = computed(() => {
  const items = []
  areaList.value.forEach(area => {
    const type = area.areaType || '普通'
    const color = areaTypeColorMap[type] || areaTypeColorMap['普通']
    items.push({
      label: `${area.areaName} (${type})`,
      class: `type-${type}`,
      style: { background: color.bg, borderColor: color.border }
    })
  })
  items.push(
    { label: '空闲', class: 'free' },
    { label: '已占用', class: 'occupied' }
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
function checkAndBuild() {
  if (scene.value && floorSpaces.value.length > 0) {
    build(floorSpaces.value)
    clearInterval(initCheckInterval)
  }
}

onMounted(() => {
  initCheckInterval = setInterval(checkAndBuild, 100)
  setTimeout(() => clearInterval(initCheckInterval), 5000)
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

// 顶部信息栏 - 紧凑设计
.top-info-bar {
  position: absolute;
  top: 8px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 4px;
  padding: 8px 16px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 0 10px;
  border-right: 1px solid rgba(0, 0, 0, 0.08);
  &:last-child { border-right: none; }

  .info-icon {
    width: 28px;
    height: 28px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 14px;
    flex-shrink: 0;
    &.free { background: linear-gradient(135deg, #48bb78, #38a169); }
    &.occupied { background: linear-gradient(135deg, #f56565, #e53e3e); }
    &.vip { background: linear-gradient(135deg, #9f7aea, #805ad5); }
    &.rate { background: linear-gradient(135deg, #4299e1, #3182ce); }
  }

  .info-content {
    display: flex;
    flex-direction: column;
    .info-label { font-size: 10px; color: #718096; white-space: nowrap; }
    .info-value { font-size: 16px; font-weight: 700; color: #2d3748; white-space: nowrap; }
  }
}

// 楼层面板 - 极简设计
.floor-panel {
  position: absolute;
  top: 70px;
  left: 8px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  z-index: 10;

  .panel-title { font-size: 11px; font-weight: 600; color: #2d3748; margin-bottom: 6px; }
  .floor-buttons { display: flex; flex-direction: column; gap: 4px; }
  .floor-btn {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 10px;
    border: 1px solid #e2e8f0;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.5);
    color: #718096;
    font-size: 12px;
    cursor: pointer;
    transition: all 0.3s ease;
    white-space: nowrap;
    &:hover { background: rgba(66, 153, 225, 0.1); border-color: #4299e1; }
    &.active { background: linear-gradient(135deg, #4299e1, #3182ce); border-color: #4299e1; color: white; }
    .el-icon { font-size: 14px; }
  }
}

// 详情面板 - 紧凑无滚动
.space-detail-panel {
  position: absolute;
  top: 70px;
  right: 8px;
  width: 200px;
  padding: 12px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  z-index: 10;

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    h3 { font-size: 14px; font-weight: 600; color: #2d3748; margin: 0; }
    .close-btn {
      width: 24px; height: 24px;
      display: flex; align-items: center; justify-content: center;
      border-radius: 6px; cursor: pointer; color: #a0aec0;
      &:hover { background: rgba(245, 101, 101, 0.1); color: #f56565; }
    }
  }
  .panel-body { display: flex; flex-direction: column; gap: 8px; }
  .detail-item {
    display: flex; justify-content: space-between; align-items: center;
    .label { font-size: 11px; color: #a0aec0; }
    .value {
      font-size: 12px; font-weight: 600; color: #2d3748;
      &.plate {
        padding: 3px 8px;
        background: linear-gradient(135deg, #4299e1, #3182ce);
        color: white; border-radius: 4px;
        font-family: 'JetBrains Mono', monospace;
        font-size: 11px;
      }
    }
    .status-badge {
      padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 500;
      &.free { background: rgba(72, 187, 120, 0.1); color: #38a169; }
      &.occupied { background: rgba(245, 101, 101, 0.1); color: #e53e3e; }
    }
  }
}

// 图例 - 极简横向
.legend-panel {
  position: absolute;
  bottom: 50px;
  left: 8px;
  padding: 10px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 10px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  z-index: 10;

  .panel-title { font-size: 11px; font-weight: 600; color: #2d3748; margin-bottom: 6px; }
  .legend-items { display: flex; flex-direction: column; gap: 5px; }
  .legend-item {
    display: flex; align-items: center; gap: 6px; font-size: 11px; color: #718096;
  }
  .legend-box {
    width: 14px; height: 14px; border-radius: 3px; border: 2px solid; flex-shrink: 0;
    &.type-普通 { background: rgba(72, 187, 120, 0.2); border-color: #48bb78; }
    &.type-VIP { background: rgba(245, 158, 11, 0.2); border-color: #f59e0b; }
    &.type-充电桩 { background: rgba(66, 153, 225, 0.2); border-color: #4299e1; }
    &.type-东向 { background: rgba(139, 92, 246, 0.2); border-color: #8b5cf6; }
    &.free { background: rgba(72, 187, 120, 0.2); border-color: #48bb78; }
    &.occupied { background: rgba(245, 101, 101, 0.2); border-color: #f56565; }
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

// 响应式适配 - 所有内容保持可见，无需滚动
@media (max-width: 768px) {
  .top-info-bar {
    gap: 2px;
    padding: 6px 10px;
  }
  .info-item {
    padding: 0 6px;
    .info-icon { width: 24px; height: 24px; font-size: 12px; }
    .info-content {
      .info-label { font-size: 9px; }
      .info-value { font-size: 13px; }
    }
  }
  .floor-panel {
    top: 60px;
    left: 6px;
    padding: 8px;
    .floor-btn {
      padding: 5px 8px;
      font-size: 11px;
    }
  }
  .legend-panel {
    bottom: 45px;
    left: 6px;
    padding: 8px;
  }
  .space-detail-panel {
    top: 60px;
    right: 6px;
    width: 160px;
    padding: 10px;
  }
  .controls-hint {
    font-size: 10px;
    padding: 5px 10px;
  }
  .view-controls {
    .view-btn { width: 28px; height: 28px; font-size: 12px; }
  }
}

@media (max-width: 480px) {
  .top-info-bar {
    padding: 5px 8px;
  }
  .info-item {
    padding: 0 4px;
    .info-icon { width: 22px; height: 22px; font-size: 11px; }
    .info-content {
      .info-label { font-size: 8px; }
      .info-value { font-size: 12px; }
    }
  }
  .space-detail-panel {
    width: 140px;
    padding: 8px;
  }
}

// 高度适配
@media (max-height: 600px) {
  .floor-panel {
    top: 55px;
  }
  .legend-panel {
    bottom: 40px;
  }
  .space-detail-panel {
    top: 55px;
  }
  .controls-hint {
    display: none;
  }
}
</style>
