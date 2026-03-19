import { ref, computed } from 'vue'
import { FLOORS, COLORS, LAYOUT, SPACE_STATUS, SPACE_TYPES } from '@/constants/parking.js'
import { getSpaces, getCurrentParking } from '@/api/parking.js'

export function useParkingLot() {
  const spaces = ref([])
  const currentFloor = ref(1) // 与数据库一致：1=一层, 2=二层
  const selectedSpace = ref(null)

  // 根据 floor 字段筛选（后端返回 1 或 2）
  const floorSpaces = computed(() =>
    spaces.value.filter(s => Number(s.floor) === currentFloor.value)
  )

  const freeCount = computed(() =>
    floorSpaces.value.filter(s => s.status === SPACE_STATUS.FREE).length
  )

  const occupiedCount = computed(() =>
    floorSpaces.value.filter(s => s.status === SPACE_STATUS.OCCUPIED).length
  )

  const vipCount = computed(() =>
    floorSpaces.value.filter(s => s.areaType === SPACE_TYPES.VIP || s.areaCode === 'D').length
  )

  const occupancyRate = computed(() => {
    if (floorSpaces.value.length === 0) return 0
    return Math.round((occupiedCount.value / floorSpaces.value.length) * 100)
  })

  // 适配后端数据格式
  // 后端: { spaceCode: 'A001', floor: 1, areaCode: 'A', areaType: '普通' }
  function adaptSpaceData(data) {
    if (!data || !Array.isArray(data)) return []

    return data.map((space) => {
      // 保留原始数据
      const adapted = { ...space }

      // 确保 areaType 存在（根据 areaCode 推断）
      if (!adapted.areaType && adapted.areaCode) {
        const typeMap = {
          'A': '普通',
          'B': '充电桩',
          'C': '普通',
          'D': 'VIP'
        }
        adapted.areaType = typeMap[adapted.areaCode] || '普通'
      }

      return adapted
    })
  }

  async function initData() {
    try {
      const res = await getSpaces()
      console.log('获取车位数据:', res)
      // 处理后端返回的 Result 结构
      const rawData = res.data || res
      if (rawData && Array.isArray(rawData)) {
        spaces.value = adaptSpaceData(rawData)
        console.log(`共获取 ${spaces.value.length} 个车位, 一层: ${spaces.value.filter(s => s.floor === 1).length}, 二层: ${spaces.value.filter(s => s.floor === 2).length}`)
      }
    } catch (error) {
      console.error('获取车位数据失败:', error)
    }
  }

  function switchFloor(floorCode) {
    // floorCode 直接是数字 1 或 2
    currentFloor.value = Number(floorCode) || 1
    selectedSpace.value = null
  }

  async function selectSpace(space) {
    selectedSpace.value = { ...space }
    // 占用中的车位，补充查询入场时间
    if (space.status === SPACE_STATUS.OCCUPIED && space.currentPlate) {
      try {
        const record = await getCurrentParking(space.currentPlate)
        if (record) {
          selectedSpace.value = { ...space, entryTime: record.entryTime, recordId: record.recordId }
        }
      } catch (e) {
        // 查询失败不影响展示
      }
    }
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
