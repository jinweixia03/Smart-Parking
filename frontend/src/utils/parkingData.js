import { SPACE_STATUS, SPACE_TYPES } from '@/constants/parking.js'

export function generateMockSpaces() {
  const mockSpaces = []

  // F1 表面层：160个车位（新布局更多车位）
  const f1Spaces = 160
  for (let i = 1; i <= f1Spaces; i++) {
    const area = i <= f1Spaces / 2 ? 'A' : 'B'
    let spaceType = SPACE_TYPES.NORMAL
    if (i % 10 === 1) spaceType = SPACE_TYPES.VIP
    else if (i % 15 === 0) spaceType = SPACE_TYPES.DISABLED

    const isOccupied = Math.random() > 0.55
    mockSpaces.push(createSpace('F1', area, i, spaceType, isOccupied))
  }

  // B1 地下一层：80个车位
  const b1Spaces = 80
  for (let i = 1; i <= b1Spaces; i++) {
    const area = i <= b1Spaces / 2 ? 'A' : 'B'
    let spaceType = SPACE_TYPES.NORMAL
    if (i % 10 === 1) spaceType = SPACE_TYPES.VIP
    else if (i % 15 === 0) spaceType = SPACE_TYPES.DISABLED

    const isOccupied = Math.random() > 0.55
    mockSpaces.push(createSpace('B1', area, i, spaceType, isOccupied))
  }

  return mockSpaces
}

function createSpace(floor, area, index, spaceType, isOccupied) {
  return {
    spaceCode: `${floor}-${area}${String(index).padStart(2, '0')}`,
    areaCode: `${floor}-${area}`,
    spaceType,
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
