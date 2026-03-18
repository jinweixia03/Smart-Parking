import { SPACE_STATUS, SPACE_TYPES } from '@/constants/parking.js'

/**
 * 生成模拟车位数据 - 与数据库 parking_space 表结构一致
 * 数据库结构：
 * - 总计508个车位，每层254个（floor: 1=一层, 2=二层）
 * - A区(普通): 每层188个, 共376个
 * - B区(充电桩): 每层40个, 共80个
 * - C区(东向): 每层13个, 共26个
 * - D区(VIP): 每层13个, 共26个
 */
export function generateMockSpaces() {
  const mockSpaces = []

  // 一层 (floor=1)
  mockSpaces.push(...generateFloorSpaces(1))

  // 二层 (floor=2)
  mockSpaces.push(...generateFloorSpaces(2))

  return mockSpaces
}

function generateFloorSpaces(floor) {
  const spaces = []

  // A区：188个普通车位 (A001-A188 或 A201-A388)
  const aStart = floor === 1 ? 1 : 201
  for (let i = 0; i < 188; i++) {
    const num = aStart + i
    const isOccupied = Math.random() > 0.55
    spaces.push(createSpace(floor, 'A', num, '普通', isOccupied))
  }

  // B区：40个充电桩车位 (B001-B040 或 B201-B240)
  const bStart = floor === 1 ? 1 : 201
  for (let i = 0; i < 40; i++) {
    const num = bStart + i
    const isOccupied = Math.random() > 0.55
    spaces.push(createSpace(floor, 'B', num, '充电桩', isOccupied))
  }

  // C区：13个东向车位 (C001-C013 或 C201-C213)
  const cStart = floor === 1 ? 1 : 201
  for (let i = 0; i < 13; i++) {
    const num = cStart + i
    const isOccupied = Math.random() > 0.55
    spaces.push(createSpace(floor, 'C', num, '普通', isOccupied))
  }

  // D区：13个VIP车位 (D001-D013 或 D201-D213)
  const dStart = floor === 1 ? 1 : 201
  for (let i = 0; i < 13; i++) {
    const num = dStart + i
    const isOccupied = Math.random() > 0.55
    spaces.push(createSpace(floor, 'D', num, 'VIP', isOccupied))
  }

  return spaces
}

function createSpace(floor, areaCode, num, areaType, isOccupied) {
  // spaceCode 格式: A001, B001, C001, D001 (一层) 或 A201, B201 (二层)
  const spaceCode = `${areaCode}${String(num).padStart(3, '0')}`

  return {
    spaceId: floor === 1 ? num : num + 254, // 模拟 space_id
    spaceCode,
    floor,
    areaCode,
    areaType,
    status: isOccupied ? SPACE_STATUS.OCCUPIED : SPACE_STATUS.FREE,
    currentPlate: isOccupied ? generatePlate() : null,
    entryTime: isOccupied ? generateEntryTime() : null
  }
}

function generatePlate() {
  const prefix = '京'
  const letter = String.fromCharCode(65 + Math.floor(Math.random() * 26))
  const number = Math.floor(Math.random() * 90000 + 10000)
  return `${prefix}${letter}${number}`
}

function generateEntryTime() {
  return new Date(Date.now() - Math.random() * 3600000 * 8).toISOString()
}
