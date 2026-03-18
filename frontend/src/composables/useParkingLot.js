import { ref, computed } from 'vue'
import { FLOORS, COLORS, LAYOUT, SPACE_STATUS, SPACE_TYPES } from '@/constants/parking.js'
import { getSpaces } from '@/api/parking.js'

export function useParkingLot() {
  const spaces = ref([])
  const currentFloor = ref(1) // 使用数字 1 或 2
  const selectedSpace = ref(null)

  // 根据 floor 字段筛选（后端返回 1 或 2）
  const floorSpaces = computed(() =>
    spaces.value.filter(s => s.floor === currentFloor.value)
  )

  const freeCount = computed(() =>
    floorSpaces.value.filter(s => s.status === SPACE_STATUS.FREE).length
  )

  const occupiedCount = computed(() =>
    floorSpaces.value.filter(s => s.status === SPACE_STATUS.OCCUPIED).length
  )

  const vipCount = computed(() =>
    floorSpaces.value.filter(s => s.spaceType === SPACE_TYPES.VIP).length
  )

  const occupancyRate = computed(() => {
    if (floorSpaces.value.length === 0) return 0
    return Math.round((occupiedCount.value / floorSpaces.value.length) * 100)
  })

  async function initData() {
    try {
      const data = await getSpaces()
      console.log('获取车位数据:', data)
      if (data && Array.isArray(data)) {
        spaces.value = data
        console.log(`共获取 ${data.length} 个车位, 一层: ${data.filter(s => s.floor === 1).length}, 二层: ${data.filter(s => s.floor === 2).length}`)
      }
    } catch (error) {
      console.error('获取车位数据失败:', error)
    }
  }

  function switchFloor(floorCode) {
    // floorCode 可能是 'F1' 或 'B1'，转换为数字 1 或 2
    const floorMap = { 'F1': 1, 'B1': 2 }
    currentFloor.value = floorMap[floorCode] || 1
    selectedSpace.value = null
  }

  function selectSpace(space) {
    selectedSpace.value = space
  }

  function closeDetail() {
    selectedSpace.value = null
  }

  function formatTime(timeStr) {
    if (!timeStr) return '-'
    const date = new Date(timeStr)
    return date.toLocaleString('zh-CN', {
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  }

  return {
    spaces,
    currentFloor,
    selectedSpace,
    FLOORS,
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
  }
}
