import * as THREE from 'three'

// ==================== 超写实材质系统 ====================

/**
 * 创建超写实沥青纹理 - 带磨损、裂缝、修补
 */
function createGTA_AsphaltTexture() {
  const canvas = document.createElement('canvas')
  canvas.width = 2048
  canvas.height = 2048
  const ctx = canvas.getContext('2d')

  // 基础深灰沥青 - 不均匀底色
  const gradient = ctx.createLinearGradient(0, 0, 0, 2048)
  gradient.addColorStop(0, '#2d2d2d')
  gradient.addColorStop(0.5, '#333333')
  gradient.addColorStop(1, '#2a2a2a')
  ctx.fillStyle = gradient
  ctx.fillRect(0, 0, 2048, 2048)

  // 添加沥青颗粒 - 多层噪点模拟真实路面
  for (let layer = 0; layer < 3; layer++) {
    const size = 2 + layer * 2
    const count = 50000 - layer * 15000
    const alpha = 0.3 - layer * 0.1

    for (let i = 0; i < count; i++) {
      const x = Math.random() * 2048
      const y = Math.random() * 2048
      const gray = 20 + Math.random() * 60
      ctx.fillStyle = `rgba(${gray}, ${gray}, ${gray}, ${alpha})`
      ctx.fillRect(x, y, size, size)
    }
  }

  // 添加裂缝 - 真实道路裂缝
  ctx.strokeStyle = '#1a1a1a'
  ctx.lineWidth = 1
  for (let i = 0; i < 15; i++) {
    ctx.beginPath()
    let x = Math.random() * 2048
    let y = Math.random() * 2048
    ctx.moveTo(x, y)

    for (let j = 0; j < 20; j++) {
      x += (Math.random() - 0.5) * 50
      y += (Math.random() - 0.5) * 50
      ctx.lineTo(x, y)
    }
    ctx.stroke()
  }

  // 添加修补痕迹 - 道路修补的方形补丁
  for (let i = 0; i < 8; i++) {
    const x = Math.random() * 1900 + 74
    const y = Math.random() * 1900 + 74
    const w = 30 + Math.random() * 80
    const h = 30 + Math.random() * 80

    // 补丁 - 比周围略深
    ctx.fillStyle = '#252525'
    ctx.fillRect(x, y, w, h)

    // 补丁边缘 - 略浅
    ctx.strokeStyle = '#3a3a3a'
    ctx.lineWidth = 2
    ctx.strokeRect(x, y, w, h)
  }

  // 添加油污/水渍
  for (let i = 0; i < 25; i++) {
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    const radius = 30 + Math.random() * 80
    const stainGrad = ctx.createRadialGradient(x, y, 0, x, y, radius)
    stainGrad.addColorStop(0, 'rgba(15, 15, 15, 0.5)')
    stainGrad.addColorStop(0.5, 'rgba(20, 20, 20, 0.3)')
    stainGrad.addColorStop(1, 'rgba(30, 30, 30, 0)')
    ctx.fillStyle = stainGrad
    ctx.beginPath()
    ctx.arc(x, y, radius, 0, Math.PI * 2)
    ctx.fill()
  }

  // 添加轮胎磨损痕迹 - 纵向条纹
  ctx.globalAlpha = 0.15
  ctx.fillStyle = '#1a1a1a'
  for (let i = 0; i < 50; i++) {
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    const w = 20 + Math.random() * 40
    const h = 100 + Math.random() * 300
    ctx.fillRect(x, y, w, h)
  }
  ctx.globalAlpha = 1

  const texture = new THREE.CanvasTexture(canvas)
  texture.wrapS = THREE.RepeatWrapping
  texture.wrapT = THREE.RepeatWrapping
  texture.repeat.set(2, 2)
  texture.anisotropy = 16
  return texture
}

/**
 * 创建超写实混凝土纹理 - 带浇筑痕迹、模板印、风化
 */
function createGTA_ConcreteTexture() {
  const canvas = document.createElement('canvas')
  canvas.width = 2048
  canvas.height = 2048
  const ctx = canvas.getContext('2d')

  // 基础混凝土色 - 不均匀底色
  const baseGrad = ctx.createRadialGradient(1024, 1024, 0, 1024, 1024, 1500)
  baseGrad.addColorStop(0, '#7a7a7a')
  baseGrad.addColorStop(1, '#6b6b6b')
  ctx.fillStyle = baseGrad
  ctx.fillRect(0, 0, 2048, 2048)

  // 添加模板接缝痕迹 - 混凝土浇筑的方形痕迹
  ctx.strokeStyle = '#5a5a5a'
  ctx.lineWidth = 2
  const panelSize = 512
  for (let x = 0; x <= 2048; x += panelSize) {
    ctx.beginPath()
    ctx.moveTo(x, 0)
    ctx.lineTo(x, 2048)
    ctx.stroke()
  }
  for (let y = 0; y <= 2048; y += panelSize) {
    ctx.beginPath()
    ctx.moveTo(0, y)
    ctx.lineTo(2048, y)
    ctx.stroke()
  }

  // 添加砂眼和小孔
  for (let i = 0; i < 20000; i++) {
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    const size = 1 + Math.random() * 3
    ctx.fillStyle = `rgba(40, 40, 40, ${0.2 + Math.random() * 0.3})`
    ctx.beginPath()
    ctx.arc(x, y, size, 0, Math.PI * 2)
    ctx.fill()
  }

  // 添加风化痕迹 - 不规则的深浅变化
  for (let i = 0; i < 50; i++) {
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    const rx = 50 + Math.random() * 200
    const ry = 50 + Math.random() * 200
    const weatherGrad = ctx.createRadialGradient(x, y, 0, x, y, Math.max(rx, ry))
    weatherGrad.addColorStop(0, `rgba(${100 + Math.random() * 40}, ${100 + Math.random() * 40}, ${100 + Math.random() * 40}, 0.3)`)
    weatherGrad.addColorStop(1, 'rgba(0, 0, 0, 0)')
    ctx.fillStyle = weatherGrad
    ctx.beginPath()
    ctx.ellipse(x, y, rx, ry, Math.random() * Math.PI, 0, Math.PI * 2)
    ctx.fill()
  }

  // 添加水渍/污渍
  for (let i = 0; i < 30; i++) {
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    const rx = 30 + Math.random() * 100
    const ry = 100 + Math.random() * 300
    ctx.fillStyle = 'rgba(30, 30, 30, 0.15)'
    ctx.beginPath()
    ctx.ellipse(x, y, rx, ry, Math.random() * 0.5, 0, Math.PI * 2)
    ctx.fill()
  }

  // 添加细微划痕
  ctx.strokeStyle = '#8a8a8a'
  ctx.lineWidth = 0.5
  for (let i = 0; i < 200; i++) {
    ctx.beginPath()
    const x = Math.random() * 2048
    const y = Math.random() * 2048
    ctx.moveTo(x, y)
    ctx.lineTo(x + (Math.random() - 0.5) * 100, y + (Math.random() - 0.5) * 100)
    ctx.stroke()
  }

  const texture = new THREE.CanvasTexture(canvas)
  texture.wrapS = THREE.RepeatWrapping
  texture.wrapT = THREE.RepeatWrapping
  texture.repeat.set(1, 1)
  texture.anisotropy = 16
  return texture
}

/**
 * 创建轮胎纹理
 */
function createGTA_TireTexture() {
  const canvas = document.createElement('canvas')
  canvas.width = 512
  canvas.height = 512
  const ctx = canvas.getContext('2d')

  // 轮胎黑
  ctx.fillStyle = '#1a1a1a'
  ctx.fillRect(0, 0, 512, 512)

  // 胎纹 - V字形
  ctx.strokeStyle = '#0d0d0d'
  ctx.lineWidth = 8
  for (let i = -100; i < 600; i += 20) {
    ctx.beginPath()
    ctx.moveTo(0, i)
    ctx.lineTo(256, i + 100)
    ctx.lineTo(512, i)
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(0, i + 10)
    ctx.lineTo(256, i + 110)
    ctx.lineTo(512, i + 10)
    ctx.stroke()
  }

  // 横向纹路
  for (let i = 0; i < 512; i += 40) {
    ctx.beginPath()
    ctx.moveTo(i, 0)
    ctx.lineTo(i, 512)
    ctx.stroke()
  }

  const texture = new THREE.CanvasTexture(canvas)
  return texture
}

// ==================== 材质创建 ====================

// 写实材质系统 - 使用LambertMaterial配合纹理增强真实感
export function createMaterials() {
  // 创建程序化纹理
  const asphaltTexture = createGTA_AsphaltTexture()
  const concreteTexture = createGTA_ConcreteTexture()

  return {
    // 沥青道路 - 带纹理
    road: new THREE.MeshLambertMaterial({
      color: 0x333333,
      map: asphaltTexture
    }),

    // 混凝土地面 - 带纹理
    ground: new THREE.MeshLambertMaterial({
      color: 0x757575,
      map: concreteTexture
    }),

    // 道路标线 - 微黄的发光效果
    line: new THREE.MeshBasicMaterial({
      color: 0xfff8dc
    }),

    // 墙体 - 带混凝土纹理
    wall: new THREE.MeshLambertMaterial({
      color: 0x888888,
      map: concreteTexture
    }),

    // 墙体装饰条 - 深灰色
    wallTrim: new THREE.MeshLambertMaterial({
      color: 0x404040
    }),

    // 柱子 - 白色混凝土
    pillar: new THREE.MeshLambertMaterial({
      color: 0xe8e8e8
    }),

    // 车辆窗户 - 深蓝色玻璃感
    carWindow: new THREE.MeshLambertMaterial({
      color: 0x1a2332,
      transparent: true,
      opacity: 0.75
    }),

    // 轮胎 - 纯黑橡胶
    carWheel: new THREE.MeshLambertMaterial({
      color: 0x151515
    }),

    // 金属材质 - 银灰色
    metal: new THREE.MeshLambertMaterial({
      color: 0x999999
    }),

    // 黄黑警示条纹
    warningStripe: createWarningStripeMaterial(),

    // 发光材质 - 暖白色
    emissive: new THREE.MeshBasicMaterial({
      color: 0xfff8e7
    })
  }
}

// 创建黄黑警示条纹材质
function createWarningStripeMaterial() {
  const canvas = document.createElement('canvas')
  canvas.width = 128
  canvas.height = 128
  const ctx = canvas.getContext('2d')

  // 黄色背景
  ctx.fillStyle = '#ffcc00'
  ctx.fillRect(0, 0, 128, 128)

  // 黑色斜条纹
  ctx.fillStyle = '#000000'
  ctx.beginPath()
  for (let i = -128; i < 256; i += 32) {
    ctx.moveTo(i, 0)
    ctx.lineTo(i + 64, 0)
    ctx.lineTo(i + 64 - 128, 128)
    ctx.lineTo(i - 128, 128)
  }
  ctx.fill()

  const texture = new THREE.CanvasTexture(canvas)
  texture.wrapS = THREE.RepeatWrapping
  texture.wrapT = THREE.RepeatWrapping
  texture.repeat.set(4, 1)

  return new THREE.MeshLambertMaterial({
    map: texture
  })
}

// 材质缓存，避免创建过多材质实例
const materialCache = new Map()

export function createSpaceMaterial(color) {
  // 使用颜色值作为缓存键
  const colorKey = typeof color === 'number' ? color : color.getHex()

  if (!materialCache.has(colorKey)) {
    // 使用 MeshLambertMaterial 减少GPU uniform占用，同时支持光照
    materialCache.set(colorKey, new THREE.MeshLambertMaterial({
      color
    }))
  }

  return materialCache.get(colorKey)
}

// 清除材质缓存（需要时调用）
export function clearMaterialCache() {
  materialCache.clear()
}

// ==================== 车位建模 ====================

// 共享标线材质 - 使用BasicMaterial减少uniform
const sharedLineMat = new THREE.MeshBasicMaterial({
  color: 0xffffff
})

// 共享限位器材质
const sharedStopperMat = new THREE.MeshLambertMaterial({
  color: 0xff6600
})

export function createSpaceGeometry(width, depth, facing, materials) {
  const group = new THREE.Group()

  // 使用共享标线材质

  const lineThickness = 0.2   // 加粗标线以适应更大比例
  const lineHeight = 0.08

  // 根据朝向调整
  let zBackOffset = depth / 2 - 0.1
  let zFrontOffset = -depth / 2 + 0.1
  let xLeftOffset = -width / 2 + 0.1
  let xRightOffset = width / 2 - 0.1

  if (facing === 's' || facing === 'south') {
    [zBackOffset, zFrontOffset] = [zFrontOffset, zBackOffset]
  } else if (facing === 'e' || facing === 'east') {
    // 东向 - 入口在西边
  } else if (facing === 'w' || facing === 'west') {
    // 西向 - 入口在东边
  }

  // 左线
  const leftLine = new THREE.Mesh(
    new THREE.BoxGeometry(lineThickness, lineHeight, depth - 0.2),
    sharedLineMat
  )
  leftLine.position.set(xLeftOffset, lineHeight / 2, 0)
  leftLine.castShadow = true
  leftLine.receiveShadow = true
  group.add(leftLine)

  // 右线
  const rightLine = new THREE.Mesh(
    new THREE.BoxGeometry(lineThickness, lineHeight, depth - 0.2),
    sharedLineMat
  )
  rightLine.position.set(xRightOffset, lineHeight / 2, 0)
  rightLine.castShadow = true
  rightLine.receiveShadow = true
  group.add(rightLine)

  // 后线（挡板端）- 根据朝向使用不同方向
  let backLine

  switch (facing) {
    case 'e':
    case 'east':
      backLine = new THREE.Mesh(
        new THREE.BoxGeometry(lineThickness, lineHeight, depth),
        sharedLineMat
      )
      backLine.position.set(xLeftOffset, lineHeight / 2, 0)
      break
    case 'w':
    case 'west':
      backLine = new THREE.Mesh(
        new THREE.BoxGeometry(lineThickness, lineHeight, depth),
        sharedLineMat
      )
      backLine.position.set(xRightOffset, lineHeight / 2, 0)
      break
    default:
      // n/s 或其他默认情况
      backLine = new THREE.Mesh(
        new THREE.BoxGeometry(width, lineHeight, lineThickness),
        sharedLineMat
      )
      backLine.position.set(0, lineHeight / 2, zBackOffset)
  }
  backLine.castShadow = true
  backLine.receiveShadow = true
  group.add(backLine)

  // 橡胶限位器 (放大以适应新车位比例)
  const stopperGeo = new THREE.BoxGeometry(2.4, 0.22, 0.38)

  const stopper = new THREE.Mesh(stopperGeo, sharedStopperMat)
  const stopperOffset = depth / 2 - 0.6

  switch (facing) {
    case 'n':
    case 'north':
      stopper.position.set(0, 0.075, stopperOffset)
      break
    case 's':
    case 'south':
      stopper.position.set(0, 0.075, -stopperOffset)
      break
    case 'e':
    case 'east':
      stopper.rotation.y = Math.PI / 2
      stopper.position.set(-stopperOffset, 0.075, 0)
      break
    case 'w':
    case 'west':
      stopper.rotation.y = Math.PI / 2
      stopper.position.set(stopperOffset, 0.075, 0)
      break
  }
  stopper.castShadow = true
  stopper.receiveShadow = true
  group.add(stopper)

  // 限位器条纹
  for (let i = -0.5; i <= 0.5; i += 0.5) {
    const stripe = new THREE.Mesh(
      new THREE.BoxGeometry(0.08, 0.16, 0.27),
      new THREE.MeshLambertMaterial({ color: 0x333333 })
    )
    stripe.position.set(i, 0, 0)
    stopper.add(stripe)
  }

  return group
}

// ==================== 地面标识 ====================

// 标签材质缓存
const labelTextureCache = new Map()
const labelMaterialCache = new Map()
const labelGeometry = new THREE.PlaneGeometry(5.2, 2.6)

export function createGroundLabel(text, isVip = false, isDisabled = false) {
  const cacheKey = `${text}-${isVip}-${isDisabled}`

  // 检查缓存
  if (labelMaterialCache.has(cacheKey)) {
    const mesh = new THREE.Mesh(labelGeometry, labelMaterialCache.get(cacheKey))
    mesh.rotation.x = -Math.PI / 2
    mesh.position.y = 0.12
    return mesh
  }

  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  canvas.width = 128  // 降低分辨率
  canvas.height = 64

  // 透明背景
  ctx.fillStyle = 'rgba(255, 255, 255, 0)'
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  let textColor = '#ffffff'
  let bgColor = 'rgba(0, 0, 0, 0.6)'

  if (isVip) {
    textColor = '#ffd700'
    bgColor = 'rgba(128, 0, 128, 0.7)'
  } else if (isDisabled) {
    textColor = '#ffffff'
    bgColor = 'rgba(0, 128, 128, 0.7)'
  }

  // 背景
  ctx.fillStyle = bgColor
  ctx.fillRect(2, 2, canvas.width - 4, canvas.height - 4)

  // 文字
  ctx.font = 'bold 28px Arial'
  ctx.fillStyle = textColor
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(text, canvas.width / 2, canvas.height / 2)

  const texture = new THREE.CanvasTexture(canvas)
  texture.needsUpdate = false

  const material = new THREE.MeshBasicMaterial({
    map: texture,
    transparent: true,
    opacity: 0.9
  })

  // 缓存材质
  labelMaterialCache.set(cacheKey, material)

  const mesh = new THREE.Mesh(labelGeometry, material)
  mesh.rotation.x = -Math.PI / 2
  mesh.position.y = 0.12

  return mesh
}

// ==================== 状态指示灯 ====================

// 共享状态灯材质 - 使用BasicMaterial减少uniform
const statusLightMaterialCache = new Map()
const lampBaseMaterial = new THREE.MeshLambertMaterial({
  color: 0x333333
})

function getStatusLightMaterial(color) {
  if (!statusLightMaterialCache.has(color)) {
    statusLightMaterialCache.set(color, new THREE.MeshBasicMaterial({
      color,
      transparent: true,
      opacity: 0.9
    }))
  }
  return statusLightMaterialCache.get(color)
}

export function createStatusLight(color) {
  const group = new THREE.Group()

  // 灯座 - 简化
  const base = new THREE.Mesh(
    new THREE.CylinderGeometry(0.38, 0.45, 0.38, 12),
    lampBaseMaterial
  )
  base.position.y = 0.19
  group.add(base)

  // 发光球 - 简化几何体
  const lightGeo = new THREE.SphereGeometry(0.3, 12, 12)
  const lightMat = getStatusLightMaterial(color)
  const light = new THREE.Mesh(lightGeo, lightMat)
  light.position.y = 0.52
  group.add(light)

  // 点光源 - 可选，如果性能有问题可以移除
  // const pointLight = new THREE.PointLight(color, 0.5, 5)
  // pointLight.position.set(0, 0.9, 0)
  // group.add(pointLight)

  return group
}

// ==================== 标准轿车模型 ====================
// 标准轿车尺寸：长4.6m × 宽1.8m × 高1.4m

export function createCar(areaType) {
  const carGroup = new THREE.Group()

  const isLarge = areaType === '大型车'
  const baseScale = isLarge ? 1.1 : 1.0

  // 车身颜色选择
  const carColors = [
    0x1a1a1a, // 黑色
    0xf5f5f5, // 白色
    0x8b0000, // 深红
    0x003366, // 深蓝
    0x808080, // 银灰
    0x2d4a3e  // 墨绿
  ]
  const bodyColor = carColors[Math.floor(Math.random() * carColors.length)]

  // 材质定义
  const bodyMaterial = new THREE.MeshLambertMaterial({ color: bodyColor })
  const glassMaterial = new THREE.MeshLambertMaterial({ color: 0x1a1a2e, transparent: true, opacity: 0.75 })
  const chromeMaterial = new THREE.MeshLambertMaterial({ color: 0xe0e0e0 })
  const plasticMaterial = new THREE.MeshLambertMaterial({ color: 0x1a1a1a })
  const tireMaterial = new THREE.MeshLambertMaterial({ color: 0x151515 })
  const lightWhite = new THREE.MeshBasicMaterial({ color: 0xffffee })
  const lightRed = new THREE.MeshBasicMaterial({ color: 0xff0000 })
  const lightOrange = new THREE.MeshBasicMaterial({ color: 0xff8800 })

  // ========== 车身主体 - 分段式精细建模 ==========

  // ========== 车身主体 - 标准轿车比例 ==========
  // 标准轿车尺寸：长4.6m × 宽1.8m × 高1.4m (车头朝+Z方向)

  // 1. 车身主体 - 下部
  const bodyLowerGeo = new THREE.BoxGeometry(1.8, 0.7, 4.6)
  const bodyLower = new THREE.Mesh(bodyLowerGeo, bodyMaterial)
  bodyLower.position.set(0, 0.55, 0)
  bodyLower.castShadow = true
  bodyLower.receiveShadow = true
  carGroup.add(bodyLower)

  // 2. 车身主体 - 上部（座舱）
  const cabinGeo = new THREE.BoxGeometry(1.6, 0.6, 2.4)
  const cabin = new THREE.Mesh(cabinGeo, bodyMaterial)
  cabin.position.set(0, 1.2, -0.2)
  cabin.castShadow = true
  carGroup.add(cabin)

  // 3. 引擎盖（前部）
  const hoodGeo = new THREE.BoxGeometry(1.7, 0.08, 1.6)
  const hood = new THREE.Mesh(hoodGeo, bodyMaterial)
  hood.position.set(0, 0.95, 1.5)
  hood.castShadow = true
  carGroup.add(hood)

  // 4. 后备箱盖（后部）
  const trunkGeo = new THREE.BoxGeometry(1.7, 0.08, 1.2)
  const trunk = new THREE.Mesh(trunkGeo, bodyMaterial)
  trunk.position.set(0, 0.95, -1.7)
  trunk.castShadow = true
  carGroup.add(trunk)

  // 5. 车顶
  const roofGeo = new THREE.BoxGeometry(1.55, 0.06, 2.2)
  const roof = new THREE.Mesh(roofGeo, bodyMaterial)
  roof.position.set(0, 1.53, -0.2)
  roof.castShadow = true
  carGroup.add(roof)

  // ========== 车窗系统 ==========

  // 前挡风玻璃
  const frontWindshieldGeo = new THREE.PlaneGeometry(1.5, 0.55)
  const frontWindshield = new THREE.Mesh(frontWindshieldGeo, glassMaterial)
  frontWindshield.position.set(0, 1.2, 1.01)
  frontWindshield.rotation.x = -0.25
  carGroup.add(frontWindshield)

  // 后挡风玻璃
  const rearWindshieldGeo = new THREE.PlaneGeometry(1.5, 0.55)
  const rearWindshield = new THREE.Mesh(rearWindshieldGeo, glassMaterial)
  rearWindshield.position.set(0, 1.2, -1.41)
  rearWindshield.rotation.x = 0.25
  rearWindshield.rotation.y = Math.PI
  carGroup.add(rearWindshield)

  // 左侧车窗
  const sideWindowGeo = new THREE.PlaneGeometry(2.0, 0.5)
  const leftWindow = new THREE.Mesh(sideWindowGeo, glassMaterial)
  leftWindow.position.set(-0.81, 1.25, -0.2)
  leftWindow.rotation.y = -Math.PI / 2
  carGroup.add(leftWindow)

  // 右侧车窗
  const rightWindow = new THREE.Mesh(sideWindowGeo, glassMaterial)
  rightWindow.position.set(0.81, 1.25, -0.2)
  rightWindow.rotation.y = Math.PI / 2
  carGroup.add(rightWindow)

  // ========== 车灯系统 ==========

  // 前大灯 - 左侧
  const headlightGeo = new THREE.BoxGeometry(0.35, 0.15, 0.08)
  const leftHeadlight = new THREE.Mesh(headlightGeo, lightWhite)
  leftHeadlight.position.set(-0.6, 0.7, 2.31)
  carGroup.add(leftHeadlight)

  // 前大灯 - 右侧
  const rightHeadlight = new THREE.Mesh(headlightGeo, lightWhite)
  rightHeadlight.position.set(0.6, 0.7, 2.31)
  carGroup.add(rightHeadlight)

  // 尾灯 - 左侧
  const taillightGeo = new THREE.BoxGeometry(0.3, 0.18, 0.06)
  const leftTaillight = new THREE.Mesh(taillightGeo, lightRed)
  leftTaillight.position.set(-0.6, 0.75, -2.31)
  carGroup.add(leftTaillight)

  // 尾灯 - 右侧
  const rightTaillight = new THREE.Mesh(taillightGeo, lightRed)
  rightTaillight.position.set(0.6, 0.75, -2.31)
  carGroup.add(rightTaillight)

  // 转向灯 - 侧面
  const turnSignalGeo = new THREE.BoxGeometry(0.04, 0.08, 0.15)
  const leftTurnSignal = new THREE.Mesh(turnSignalGeo, lightOrange)
  leftTurnSignal.position.set(-0.91, 0.7, 2.0)
  carGroup.add(leftTurnSignal)

  const rightTurnSignal = new THREE.Mesh(turnSignalGeo, lightOrange)
  rightTurnSignal.position.set(0.91, 0.7, 2.0)
  carGroup.add(rightTurnSignal)

  // ========== 车轮系统 ==========
  // 车轮位置：前轴到后轴约2.7m，轮距约1.6m
  const wheelPositions = [
    { x: -0.75, z: 1.35 },  // 左前
    { x: 0.75, z: 1.35 },   // 右前
    { x: -0.75, z: -1.35 }, // 左后
    { x: 0.75, z: -1.35 }   // 右后
  ]

  wheelPositions.forEach(pos => {
    const wheelGroup = new THREE.Group()

    // 轮胎
    const tireGeo = new THREE.CylinderGeometry(0.32, 0.32, 0.22, 24)
    tireGeo.rotateZ(Math.PI / 2)
    const tire = new THREE.Mesh(tireGeo, tireMaterial)
    tire.castShadow = true
    wheelGroup.add(tire)

    // 轮毂
    const rimGeo = new THREE.CylinderGeometry(0.2, 0.2, 0.23, 16)
    rimGeo.rotateZ(Math.PI / 2)
    const rim = new THREE.Mesh(rimGeo, chromeMaterial)
    wheelGroup.add(rim)

    // 轮毂辐条 - 简单五辐
    for (let i = 0; i < 5; i++) {
      const angle = (i / 5) * Math.PI * 2
      const spoke = new THREE.Mesh(
        new THREE.BoxGeometry(0.18, 0.03, 0.02),
        chromeMaterial
      )
      spoke.rotation.z = angle
      spoke.position.x = pos.x > 0 ? 0.02 : -0.02
      wheelGroup.add(spoke)
    }

    wheelGroup.position.set(pos.x, 0.32, pos.z)
    carGroup.add(wheelGroup)
  })

  // ========== 细节部件 ==========

  // 进气格栅
  const grilleGeo = new THREE.BoxGeometry(1.4, 0.25, 0.04)
  const grille = new THREE.Mesh(grilleGeo, plasticMaterial)
  grille.position.set(0, 0.55, 2.31)
  carGroup.add(grille)

  // 保险杠 - 前
  const frontBumperGeo = new THREE.BoxGeometry(1.82, 0.25, 0.15)
  const frontBumper = new THREE.Mesh(frontBumperGeo, bodyMaterial)
  frontBumper.position.set(0, 0.32, 2.35)
  carGroup.add(frontBumper)

  // 保险杠 - 后
  const rearBumperGeo = new THREE.BoxGeometry(1.82, 0.28, 0.15)
  const rearBumper = new THREE.Mesh(rearBumperGeo, bodyMaterial)
  rearBumper.position.set(0, 0.34, -2.35)
  carGroup.add(rearBumper)

  // 后视镜
  const mirrorGeo = new THREE.BoxGeometry(0.2, 0.12, 0.08)
  const leftMirror = new THREE.Mesh(mirrorGeo, bodyMaterial)
  leftMirror.position.set(-1.0, 1.05, 0.8)
  carGroup.add(leftMirror)

  const rightMirror = new THREE.Mesh(mirrorGeo, bodyMaterial)
  rightMirror.position.set(1.0, 1.05, 0.8)
  carGroup.add(rightMirror)

  // 门把手
  const handleGeo = new THREE.BoxGeometry(0.08, 0.04, 0.02)
  const leftFrontHandle = new THREE.Mesh(handleGeo, chromeMaterial)
  leftFrontHandle.position.set(-0.91, 0.85, 0.6)
  carGroup.add(leftFrontHandle)

  const leftRearHandle = new THREE.Mesh(handleGeo, chromeMaterial)
  leftRearHandle.position.set(-0.91, 0.85, -0.4)
  carGroup.add(leftRearHandle)

  const rightFrontHandle = new THREE.Mesh(handleGeo, chromeMaterial)
  rightFrontHandle.position.set(0.91, 0.85, 0.6)
  carGroup.add(rightFrontHandle)

  const rightRearHandle = new THREE.Mesh(handleGeo, chromeMaterial)
  rightRearHandle.position.set(0.91, 0.85, -0.4)
  carGroup.add(rightRearHandle)

  // 车牌
  const plateGeo = new THREE.PlaneGeometry(0.5, 0.15)
  const plateTexture = createGTALicensePlate()
  const plateMat = new THREE.MeshBasicMaterial({ map: plateTexture })

  // 前车牌
  const frontPlate = new THREE.Mesh(plateGeo, plateMat)
  frontPlate.position.set(0, 0.42, 2.41)
  carGroup.add(frontPlate)

  // 后车牌
  const rearPlate = new THREE.Mesh(plateGeo, plateMat)
  rearPlate.position.set(0, 0.45, -2.41)
  rearPlate.rotation.y = Math.PI
  carGroup.add(rearPlate)

  // 排气管
  const exhaustGeo = new THREE.CylinderGeometry(0.04, 0.04, 0.12, 12)
  exhaustGeo.rotateX(Math.PI / 2)

  const leftExhaust = new THREE.Mesh(exhaustGeo, chromeMaterial)
  leftExhaust.position.set(-0.5, 0.25, -2.42)
  carGroup.add(leftExhaust)

  const rightExhaust = new THREE.Mesh(exhaustGeo, chromeMaterial)
  rightExhaust.position.set(0.5, 0.25, -2.42)
  carGroup.add(rightExhaust)

  // 整体缩放
  carGroup.scale.set(baseScale, baseScale, baseScale)

  return carGroup
}

function createGTALicensePlate() {
  const canvas = document.createElement('canvas')
  canvas.width = 256
  canvas.height = 80
  const ctx = canvas.getContext('2d')

  // 黄底
  ctx.fillStyle = '#ffcc00'
  ctx.fillRect(0, 0, 256, 80)

  // 黑字
  ctx.font = 'bold 48px Arial'
  ctx.fillStyle = '#000000'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'

  // 随机车牌号
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let plate = ''
  for (let i = 0; i < 6; i++) {
    plate += chars[Math.floor(Math.random() * chars.length)]
  }
  ctx.fillText(plate, 128, 40)

  const texture = new THREE.CanvasTexture(canvas)
  return texture
}

// ==================== 道路标线 ====================

// 共享道路标线材质 - 使用StandardMaterial
const sharedRoadLineMat = new THREE.MeshBasicMaterial({
  color: 0xffffff
})

export function createRoadMarking(length, isDashed = true) {
  const group = new THREE.Group()

  const lineMat = sharedRoadLineMat

  if (isDashed) {
    const dashLength = 2.5
    const gapLength = 2.0
    const dashCount = Math.floor(length / (dashLength + gapLength))

    for (let i = 0; i < dashCount; i++) {
      const x = -length / 2 + i * (dashLength + gapLength) + dashLength / 2
      const dash = new THREE.Mesh(
        new THREE.BoxGeometry(dashLength, 0.06, 0.18),
        lineMat
      )
      dash.position.set(x, 0.03, 0)
      dash.castShadow = true
      dash.receiveShadow = true
      group.add(dash)
    }
  } else {
    const line = new THREE.Mesh(
      new THREE.BoxGeometry(length, 0.06, 0.18),
      lineMat
    )
    line.position.y = 0.03
    line.castShadow = true
    line.receiveShadow = true
    group.add(line)
  }

  return group
}

// ==================== 文字标识 ====================

export function createTextSprite(text, color = '#ffffff') {
  const canvas = document.createElement('canvas')
  const ctx = canvas.getContext('2d')
  canvas.width = 512
  canvas.height = 128

  // 黑色半透明背景
  ctx.fillStyle = 'rgba(0, 0, 0, 0.7)'
  ctx.fillRect(0, 0, canvas.width, canvas.height)

  // 边框
  ctx.strokeStyle = color
  ctx.lineWidth = 4
  ctx.strokeRect(2, 2, canvas.width - 4, canvas.height - 4)

  // 文字
  ctx.font = 'bold 72px Arial'
  ctx.fillStyle = color
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText(text, canvas.width / 2, canvas.height / 2)

  const texture = new THREE.CanvasTexture(canvas)
  const material = new THREE.SpriteMaterial({ map: texture, transparent: true })
  const sprite = new THREE.Sprite(material)
  sprite.scale.set(20, 5, 1)
  return sprite
}

// ==================== 动画 ====================

export function animateCarEntrance(carGroup, duration = 1000, targetScale = 1, targetY = 0.05) {
  const startTime = Date.now()
  const startY = 2
  carGroup.scale.set(0.01 * targetScale, 0.01 * targetScale, 0.01 * targetScale)
  carGroup.position.y = startY

  const animate = () => {
    const elapsed = Date.now() - startTime
    const progress = Math.min(elapsed / duration, 1)
    const ease = 1 - Math.pow(1 - progress, 3)

    carGroup.scale.set(ease * targetScale, ease * targetScale, ease * targetScale)
    // 从高处降落，最终停在目标Y位置
    carGroup.position.y = startY * (1 - ease) + targetY * ease

    if (progress < 1) {
      requestAnimationFrame(animate)
    }
  }
  animate()
}
