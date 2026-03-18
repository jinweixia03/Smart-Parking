// ==================== 停车场常量配置 ====================

// 楼层配置
export const FLOORS = [
  { code: 'F1', name: '表面层', level: 0 },
  { code: 'B1', name: '地下一层', level: -1 }
]

// 车位类型
export const SPACE_TYPES = {
  NORMAL: '普通车位',
  VIP: 'VIP',
  DISABLED: '残疾人车位'
}

// 车位状态
export const SPACE_STATUS = {
  FREE: 0,
  OCCUPIED: 1
}

// 颜色配置
export const COLORS = {
  ground: 0x4a5568,
  road: 0x2d3748,
  roadLine: 0xffffff,
  spaceFree: 0x48bb78,
  spaceOccupied: 0xf56565,
  spaceVip: 0x9f7aea,
  spaceDisabled: 0x38b2ac,
  spaceLine: 0xffffff,
  carBody: [0xe53e3e, 0x3182ce, 0x38a169, 0xd69e2e, 0x805ad5, 0xdd6b20, 0x718096],
  carWindow: 0x1a202c,
  carWheel: 0x171923,
  carLightFront: 0xffffcc,
  carLightBack: 0xff4444
}

// 布局配置
export const LAYOUT = {
  // 场地尺寸
  fieldWidth: 160,
  fieldDepth: 120,

  // 车道配置
  mainRoad: {
    width: 14,
    z: 0,
    halfWidth: 7
  },

  // 车位配置
  space: {
    width: 6,
    depth: 10,
    gapX: 0.5,
    gapZ: 1
  },

  // 北侧区域
  north: {
    row1: { z: -12, facing: 'north' },
    row2: { z: -24, facing: 'south' }
  },

  // 南侧区域
  south: {
    row1: { z: 12, facing: 'south' },
    row2: { z: 24, facing: 'north' }
  },

  // 每行车位数量
  spacesPerRow: 12
}

// 相机配置
export const CAMERA_CONFIG = {
  d: 100,
  position: { x: 80, y: 80, z: 80 },
  target: { x: 0, y: 0, z: 0 },
  minZoom: 1,
  maxZoom: 5,
  panLimit: 100,
  polarAngle: Math.PI / 3
}

// 灯光配置
export const LIGHT_CONFIG = {
  ambient: { intensity: 0.5 },
  main: {
    position: { x: 60, y: 100, z: 60 },
    intensity: 0.8,
    shadowMapSize: 2048
  },
  fill: {
    position: { x: -60, y: 40, z: -60 },
    intensity: 0.3
  }
}
