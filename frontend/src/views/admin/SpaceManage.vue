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
      <div class="panel-title">楼层选择</div>
      <div class="floor-buttons">
        <button
          v-for="floor in FLOORS"
          :key="floor.code"
          :class="['floor-btn', { active: (currentFloor === 1 && floor.code === 'F1') || (currentFloor === 2 && floor.code === 'B1') }]"
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
      <div class="panel-title">图例说明</div>
      <div class="legend-items">
        <div class="legend-item" v-for="(item, index) in legendItems" :key="index">
          <div class="legend-box" :class="item.class"></div>
          <span>{{ item.label }}</span>
        </div>
      </div>
    </div>

    <!-- 操作提示 -->
    <div class="controls-hint">
      <el-icon><Mouse /></el-icon>
      <span>左键/右键拖拽平移 | 滚轮缩放 | 点击车位查看详情</span>
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
  { icon: 'Check', label: '空闲车位', value: freeCount.value, suffix: '', class: 'free' },
  { icon: 'Close', label: '已占用', value: occupiedCount.value, suffix: '', class: 'occupied' },
  { icon: 'Star', label: 'VIP车位', value: vipCount.value, suffix: '', class: 'vip' },
  { icon: 'PieChart', label: '占用率', value: occupancyRate.value, suffix: '%', class: 'rate' }
])

const detailItems = computed(() => [
  { label: '车位编号', value: selectedSpace.value?.spaceCode },
  { label: '当前状态', statusText: selectedSpace.value?.status === SPACE_STATUS.FREE ? '空闲' : '占用', statusClass: selectedSpace.value?.status === SPACE_STATUS.FREE ? 'free' : 'occupied' },
  { label: '车位类型', value: selectedSpace.value?.spaceType },
  ...(selectedSpace.value?.status === SPACE_STATUS.OCCUPIED ? [
    { label: '车牌号码', value: selectedSpace.value?.currentPlate || '-', class: 'plate' },
    { label: '入场时间', value: formatTime(selectedSpace.value?.entryTime) }
  ] : [])
])

const legendItems = [
  { label: '空闲车位', class: 'free' },
  { label: '已占用', class: 'occupied' },
  { label: 'VIP专区', class: 'vip' },
  { label: '残疾人车位', class: 'disabled' }
]

// ==================== 方法 ====================
function handleSpaceClick(space) {
  // 清除之前的高亮
  clearSelectedMesh()

  // 设置新的选中状态
  selectSpace(space)

  // 高亮车位
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

// 监听楼层变化，重新构建停车场
watch(currentFloor, () => {
  nextTick(() => {
    if (scene.value) {
      build(floorSpaces.value)
    }
  })
})

// 初始构建 - 等待 scene 初始化完成
let initCheckInterval
function checkAndBuild() {
  if (scene.value && floorSpaces.value.length > 0) {
    build(floorSpaces.value)
    clearInterval(initCheckInterval)
  }
}

onMounted(() => {
  initCheckInterval = setInterval(checkAndBuild, 100)
  // 5秒后停止检查
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

.top-info-bar {
  position: absolute;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  gap: 16px;
  padding: 16px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 10;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 0 16px;
  border-right: 1px solid rgba(0, 0, 0, 0.1);
  &:last-child { border-right: none; }

  .info-icon {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 20px;
    &.free { background: linear-gradient(135deg, #48bb78, #38a169); }
    &.occupied { background: linear-gradient(135deg, #f56565, #e53e3e); }
    &.vip { background: linear-gradient(135deg, #9f7aea, #805ad5); }
    &.rate { background: linear-gradient(135deg, #4299e1, #3182ce); }
  }

  .info-content {
    display: flex;
    flex-direction: column;
    .info-label { font-size: 12px; color: #718096; }
    .info-value { font-size: 20px; font-weight: 700; color: #2d3748; }
  }
}

.floor-panel {
  position: absolute;
  top: 100px;
  left: 20px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 10;
  min-width: 140px;

  .panel-title { font-size: 14px; font-weight: 600; color: #2d3748; margin-bottom: 12px; }
  .floor-buttons { display: flex; flex-direction: column; gap: 8px; }
  .floor-btn {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 16px;
    border: 1px solid #e2e8f0;
    border-radius: 10px;
    background: rgba(255, 255, 255, 0.5);
    color: #718096;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.3s ease;
    &:hover { background: rgba(66, 153, 225, 0.1); border-color: #4299e1; }
    &.active { background: linear-gradient(135deg, #4299e1, #3182ce); border-color: #4299e1; color: white; }
  }
}

.space-detail-panel {
  position: absolute;
  top: 100px;
  right: 20px;
  width: 280px;
  padding: 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 10;

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
    h3 { font-size: 18px; font-weight: 600; color: #2d3748; margin: 0; }
    .close-btn {
      width: 32px; height: 32px;
      display: flex; align-items: center; justify-content: center;
      border-radius: 8px; cursor: pointer; color: #a0aec0;
      &:hover { background: rgba(245, 101, 101, 0.1); color: #f56565; }
    }
  }
  .panel-body { display: flex; flex-direction: column; gap: 16px; }
  .detail-item {
    display: flex; justify-content: space-between; align-items: center;
    .label { font-size: 13px; color: #a0aec0; }
    .value {
      font-size: 14px; font-weight: 600; color: #2d3748;
      &.plate {
        padding: 6px 14px;
        background: linear-gradient(135deg, #4299e1, #3182ce);
        color: white; border-radius: 6px;
        font-family: 'JetBrains Mono', monospace;
      }
    }
    .status-badge {
      padding: 6px 16px; border-radius: 20px; font-size: 13px; font-weight: 500;
      &.free { background: rgba(72, 187, 120, 0.1); color: #38a169; }
      &.occupied { background: rgba(245, 101, 101, 0.1); color: #e53e3e; }
    }
  }
}

.legend-panel {
  position: absolute;
  bottom: 100px;
  left: 20px;
  padding: 20px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  z-index: 10;

  .panel-title { font-size: 14px; font-weight: 600; color: #2d3748; margin-bottom: 12px; }
  .legend-items { display: flex; flex-direction: column; gap: 10px; }
  .legend-item { display: flex; align-items: center; gap: 10px; font-size: 13px; color: #718096; }
  .legend-box {
    width: 20px; height: 20px; border-radius: 4px; border: 2px solid;
    &.free { background: rgba(72, 187, 120, 0.2); border-color: #48bb78; }
    &.occupied { background: rgba(245, 101, 101, 0.2); border-color: #f56565; }
    &.vip { background: rgba(159, 122, 234, 0.2); border-color: #9f7aea; }
    &.disabled { background: rgba(56, 178, 172, 0.2); border-color: #38b2ac; }
  }
}

.controls-hint {
  position: absolute;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 12px 24px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-radius: 30px;
  color: #718096;
  font-size: 13px;
  z-index: 10;
  .el-icon { font-size: 16px; color: #4299e1; }
}

.view-controls {
  position: absolute;
  bottom: 20px;
  right: 20px;
  display: flex;
  gap: 8px;
  z-index: 10;

  .view-btn {
    width: 44px; height: 44px;
    border: none; border-radius: 12px;
    background: rgba(255, 255, 255, 0.95);
    color: #718096; font-size: 18px;
    cursor: pointer; transition: all 0.3s ease;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    &:hover { background: #4299e1; color: white; transform: translateY(-2px); }
    &.active { background: #4299e1; color: white; }
  }
}
</style>
