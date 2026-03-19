import * as THREE from 'three'
import { COLORS, AREA_COLORS, AREA_COLORS_OCCUPIED } from '@/constants/parking.js'
import {
  createSpaceGeometry,
  createGroundLabel,
  createStatusLight,
  createCar,
  animateCarEntrance,
  createSpaceMaterial
} from '@/utils/threeUtils.js'

// 停车场配置 - 基于真实车位比例 (宽5m : 深10m = 1:2)
const CONFIG = {
  cellSize: 20,       // 基础网格单元 20米 - 规模放大2倍
  roadWidth: 2,       // 道路宽度 40米（2格 × 20m）
  wallHeight: 24      // 围墙高度同步放大
}

// 网格地图定义 - 真实比例停车场 (20m单元格，规模放大2倍)
// 每个格子20m×20m，包含一个完整车位(10m×20m)和周边通道
// P = 北向车位(入口在南)  S = 南向车位(入口在北)
// E = 东向车位(入口在西)  W = 西向车位(入口在东)
// R = 道路(2格宽=40m, 符合双向车道)
// B = 边界墙  . = 空白
//
// 布局特点:
// - 中间双纵向车道(RR)贯穿全场
// - 横向车道(R)将停车场分为多个区域
// - 左右两侧对称布置竖向车位(E/W)
// - 新能源车位(S)穿插分布在各区域
// - 南墙大门位置对应中间纵向道路
const GRID_MAP = [
  'BBBBBBBBBBBBBBBRRBBBBBBBBBBBBBBB',
  'B.NNNNNNNNNNNNNRRNNNNNNNNNNNNN.B',  // 最上行：P车位紧贴北墙
  'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',  // 横向道路
  'BERSSSSSSRSSSSSRRSSSSSRSSSSSSRWB',  // 左右竖向车位 + 中间S
  'BERNNNNNNRNNNNNRRNNNNNRNNNNNNRWB',
  'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',  // 中间再分道路
  'BERSSSSSSRSSSSSRRSSSSSRSSSSSSRWB',  // 左右竖向车位 + 中间P
  'BERNNNNNNRNNNNNRRNNNNNRNNNNNNRWB',
  'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',  // 横向道路
  'BERSSSSSSRSSSSSRRSSSSSRSSSSSSRWB',
  'BERNNNNNNRNNNNNRRNNNNNRNNNNNNRWB',
  'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',  // 中间再分道路
  'BERSSSSSSRSSSSSRRSSSSSRSSSSSSRWB',
  'BERNNNNNNRNNNNNRRNNNNNRNNNNNNRWB',
  'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',  // 横向道路（含大门）
  'B.SSSSSSSSSSSSSRRSSSSSSSSSSSSS.B',  // 最下行：P车位紧贴南墙
  'BBBBBBBBBBBBBBBRRBBBBBBBBBBBBBBB'
]


// 从网格地图生成停车位配置
// 每个MAP字符代表一个车位
function generateParkingSpotsFromGrid() {
  const spots = []
  const rows = GRID_MAP.length
  const cols = GRID_MAP[0].length

  const offsetX = (cols * CONFIG.cellSize) / 2
  const offsetZ = (rows * CONFIG.cellSize) / 2

  const facingMap = {
    'P': 'n',
    'N': 'n',  // 北向车位
    'S': 's',  // 南向车位
    'E': 'e',
    'W': 'w'
  }

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      const cell = GRID_MAP[row][col]
      if (facingMap[cell]) {
        const x = col * CONFIG.cellSize - offsetX + CONFIG.cellSize / 2
        const z = row * CONFIG.cellSize - offsetZ + CONFIG.cellSize / 2
        spots.push([x, z, facingMap[cell], row, col])
      }
    }
  }

  return spots
}

// 生成道路区域配置
function generateRoadsFromGrid() {
  const roads = []
  const rows = GRID_MAP.length
  const cols = GRID_MAP[0].length

  const offsetX = (cols * CONFIG.cellSize) / 2
  const offsetZ = (rows * CONFIG.cellSize) / 2

  // 使用并查集或连通区域检测来合并相邻的道路单元格
  const visited = Array(rows).fill(null).map(() => Array(cols).fill(false))

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      if (GRID_MAP[row][col] === 'R' && !visited[row][col]) {
        // 寻找水平方向的连续道路
        let endCol = col
        while (endCol < cols && GRID_MAP[row][endCol] === 'R' && !visited[row][endCol]) {
          visited[row][endCol] = true
          endCol++
        }

        // 检查是否能向下扩展成矩形
        let endRow = row + 1
        let canExtend = true
        while (canExtend && endRow < rows) {
          for (let c = col; c < endCol; c++) {
            if (GRID_MAP[endRow][c] !== 'R' || visited[endRow][c]) {
              canExtend = false
              break
            }
          }
          if (canExtend) {
            for (let c = col; c < endCol; c++) {
              visited[endRow][c] = true
            }
            endRow++
          }
        }

        const width = (endCol - col) * CONFIG.cellSize
        const depth = (endRow - row) * CONFIG.cellSize
        const x = col * CONFIG.cellSize - offsetX + width / 2
        // MAP行与Z坐标直接对应: 第0行(北) → Z负方向, 第16行(南) → Z正方向
        const z = row * CONFIG.cellSize - offsetZ + depth / 2

        roads.push({ x, z, width, depth })
      }
    }
  }

  return roads
}

// 停车位和道路数据
const PARKING_SPOTS = generateParkingSpotsFromGrid()
const ROADS = generateRoadsFromGrid()

export function useParkingBuilder(scene, materials, spaceMeshes, carMeshes) {
  let parkingGroup = null

  function build(floorSpaces) {
    if (parkingGroup) {
      scene.value.remove(parkingGroup)
      spaceMeshes.clear()
      carMeshes.clear()
    }

    parkingGroup = new THREE.Group()

    createGround()
    createWallsAndGate()
    createRoads()
    createParkingSpaces(floorSpaces)
    createMarkings()
    createSurroundingStreet()

    scene.value.add(parkingGroup)
    return parkingGroup
  }

  function createGround() {
    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length
    const width = cols * CONFIG.cellSize
    const depth = rows * CONFIG.cellSize

    // 主地面 - 使用带纹理的材质
    const ground = new THREE.Mesh(
      new THREE.BoxGeometry(width + 100, 2, depth + 100),
      materials.value.ground
    )
    ground.position.y = -1
    ground.receiveShadow = true
    parkingGroup.add(ground)

    // 添加地面细节 - 随机污渍和磨损
    createGroundDetails(width, depth)
  }

  // 创建地面细节
  function createGroundDetails(width, depth) {
    const stainMat = new THREE.MeshLambertMaterial({
      color: 0x3a3a3a,
      transparent: true,
      opacity: 0.4
    })

    // 随机油污/污渍
    for (let i = 0; i < 15; i++) {
      const x = (Math.random() - 0.5) * width * 0.8
      const z = (Math.random() - 0.5) * depth * 0.8
      const radius = 5 + Math.random() * 10

      const stain = new THREE.Mesh(
        new THREE.CircleGeometry(radius, 16),
        stainMat
      )
      stain.rotation.x = -Math.PI / 2
      stain.position.set(x, 0.01, z)
      parkingGroup.add(stain)
    }
  }

  function createWallsAndGate() {
    // 围墙材质 - 使用混凝土纹理
    const wallMat = materials.value.wall
    const trimMat = materials.value.wallTrim
    const pillarMat = materials.value.pillar
    const h = CONFIG.wallHeight

    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length
    const offsetX = (cols * CONFIG.cellSize) / 2
    const offsetZ = (rows * CONFIG.cellSize) / 2

    // 找出最外层车位的边界
    const facingMap = { 'P': 'n', 'S': 's', 'E': 'e', 'W': 'w' }
    let minRow = rows, maxRow = -1, minCol = cols, maxCol = -1

    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        if (facingMap[GRID_MAP[row][col]]) {
          minRow = Math.min(minRow, row)
          maxRow = Math.max(maxRow, row)
          minCol = Math.min(minCol, col)
          maxCol = Math.max(maxCol, col)
        }
      }
    }

    // 计算墙壁位置（紧贴车位边缘）
    const northZ = minRow * CONFIG.cellSize - offsetZ + CONFIG.cellSize / 2 - 36
    const southZ = maxRow * CONFIG.cellSize - offsetZ + CONFIG.cellSize / 2 + 16
    const westX = minCol * CONFIG.cellSize - offsetX + CONFIG.cellSize / 2 - 16
    const eastX = maxCol * CONFIG.cellSize - offsetX + CONFIG.cellSize / 2 + 16

    const wallWidth = eastX - westX
    const wallDepth = southZ - northZ

    // ===== 超写实围墙系统 =====
    const wallThickness = 2
    const pillarSize = 4
    const pillarHeight = h + 3

    // 创建简洁连续围墙
    function createSimpleWall(x, y, z, w, h_val, d, isHorizontal) {
      const wallGroup = new THREE.Group()
      wallGroup.position.set(x, y, z)

      // 单一连续墙体
      const wall = new THREE.Mesh(
        new THREE.BoxGeometry(
          isHorizontal ? w : wallThickness,
          h_val,
          isHorizontal ? wallThickness : d
        ),
        wallMat
      )
      wall.position.y = h_val / 2
      wall.castShadow = true
      wall.receiveShadow = true
      wallGroup.add(wall)

      // 无墙顶压顶石，简洁设计
      return wallGroup
    }

    // 创建精致柱子的函数
    function createDetailedPillar(x, z, h_val) {
      const pillarGroup = new THREE.Group()
      pillarGroup.position.set(x, 0, z)

      // 柱身 - 简洁设计，与地面一体
      const shaft = new THREE.Mesh(
        new THREE.BoxGeometry(pillarSize, h_val, pillarSize),
        pillarMat
      )
      shaft.position.y = h_val / 2
      shaft.castShadow = true
      shaft.receiveShadow = true
      pillarGroup.add(shaft)

      // 柱头 - 简洁压顶
      const cap = new THREE.Mesh(
        new THREE.BoxGeometry(pillarSize + 0.3, 0.8, pillarSize + 0.3),
        trimMat
      )
      cap.position.y = h_val + 0.4
      cap.castShadow = true
      pillarGroup.add(cap)

      return pillarGroup
    }

    // 计算北边大门位置（用于预留出口）
    const northRoadRow = 1
    let northRoadStart = -1, northRoadEnd = -1
    for (let col = 0; col < cols; col++) {
      if (GRID_MAP[northRoadRow][col] === 'R') {
        if (northRoadStart === -1) northRoadStart = col
        northRoadEnd = col
      }
    }
    const northGateWidth = 2 * CONFIG.cellSize
    const northGateCenterX = (northRoadStart + northRoadEnd + 1) * CONFIG.cellSize / 2 - offsetX

    // 北边门柱尺寸
    const northPillarW = 8
    const northPillarD = 8
    const northPillarH = h + 15

    // 北墙左段
    const northLeftWallEnd = northGateCenterX - northGateWidth / 2 - northPillarW / 2 - 0.1
    const northLeftWallWidth = northLeftWallEnd - westX
    if (northLeftWallWidth > 0) {
      const northLeftWall = new THREE.Mesh(new THREE.BoxGeometry(northLeftWallWidth, h, wallThickness), wallMat)
      northLeftWall.position.set(westX + northLeftWallWidth / 2, h / 2, northZ)
      northLeftWall.castShadow = true
      northLeftWall.receiveShadow = true
      parkingGroup.add(northLeftWall)
    }

    // 北墙右段
    const northRightWallStart = northGateCenterX + northGateWidth / 2 + northPillarW / 2 + 0.1
    const northRightWallWidth = eastX - northRightWallStart
    if (northRightWallWidth > 0) {
      const northRightWall = new THREE.Mesh(new THREE.BoxGeometry(northRightWallWidth, h, wallThickness), wallMat)
      northRightWall.position.set(eastX - northRightWallWidth / 2, h / 2, northZ)
      northRightWall.castShadow = true
      northRightWall.receiveShadow = true
      parkingGroup.add(northRightWall)
    }

    // 北墙其他装饰柱子（左端和右端）
    const northPillarSize = 3
    const northPillarHeight = h + 3
    // 左端柱子
    const northLeftEndPillar = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarSize, northPillarHeight, northPillarSize),
      pillarMat
    )
    northLeftEndPillar.position.set(westX + northPillarSize / 2, northPillarHeight / 2, northZ)
    northLeftEndPillar.castShadow = true
    northLeftEndPillar.receiveShadow = true
    parkingGroup.add(northLeftEndPillar)

    // 右端柱子
    const northRightEndPillar = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarSize, northPillarHeight, northPillarSize),
      pillarMat
    )
    northRightEndPillar.position.set(eastX - northPillarSize / 2, northPillarHeight / 2, northZ)
    northRightEndPillar.castShadow = true
    northRightEndPillar.receiveShadow = true
    parkingGroup.add(northRightEndPillar)

    // 大门两侧的小柱子
    const northGateLeftPillarX = northGateCenterX - northGateWidth / 2 - northPillarW / 2
    const northSmallPillar1 = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarSize, northPillarHeight, northPillarSize),
      pillarMat
    )
    northSmallPillar1.position.set(northGateLeftPillarX - northPillarSize / 2 - 0.1, northPillarHeight / 2, northZ)
    northSmallPillar1.castShadow = true
    northSmallPillar1.receiveShadow = true
    parkingGroup.add(northSmallPillar1)

    const northGateRightPillarX = northGateCenterX + northGateWidth / 2 + northPillarW / 2
    const northSmallPillar2 = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarSize, northPillarHeight, northPillarSize),
      pillarMat
    )
    northSmallPillar2.position.set(northGateRightPillarX + northPillarSize / 2 + 0.1, northPillarHeight / 2, northZ)
    northSmallPillar2.castShadow = true
    northSmallPillar2.receiveShadow = true
    parkingGroup.add(northSmallPillar2)

    // 西墙
    const westSegments = 3
    const westSegmentDepth = (wallDepth - (westSegments + 1) * pillarSize) / westSegments
    for (let i = 0; i < westSegments; i++) {
      const wallZ = northZ + pillarSize + westSegmentDepth / 2 + i * (westSegmentDepth + pillarSize)
      const wall = createSimpleWall(westX, 0, wallZ, wallThickness, h, westSegmentDepth, false)
      parkingGroup.add(wall)
    }

    // 西墙柱子
    for (let i = 0; i <= westSegments; i++) {
      const pillarZ = northZ + pillarSize / 2 + i * (westSegmentDepth + pillarSize)
      const pillar = createDetailedPillar(westX, pillarZ, pillarHeight)
      parkingGroup.add(pillar)
    }

    // 东墙
    const eastSegments = 3
    const eastSegmentDepth = (wallDepth - (eastSegments + 1) * pillarSize) / eastSegments
    for (let i = 0; i < eastSegments; i++) {
      const wallZ = northZ + pillarSize + eastSegmentDepth / 2 + i * (eastSegmentDepth + pillarSize)
      const wall = createSimpleWall(eastX, 0, wallZ, wallThickness, h, eastSegmentDepth, false)
      parkingGroup.add(wall)
    }

    // 东墙柱子
    for (let i = 0; i <= eastSegments; i++) {
      const pillarZ = northZ + pillarSize / 2 + i * (eastSegmentDepth + pillarSize)
      const pillar = createDetailedPillar(eastX, pillarZ, pillarHeight)
      parkingGroup.add(pillar)
    }

    // ===== 超写实大门系统 =====
    // 南墙 - 开门（底部道路中间作为入口）
    const roadRow = rows - 2 // 倒数第二行是道路
    let roadStart = -1, roadEnd = -1
    for (let col = 0; col < cols; col++) {
      if (GRID_MAP[roadRow][col] === 'R') {
        if (roadStart === -1) roadStart = col
        roadEnd = col
      }
    }

    // 大门占道路中间2个单元格
    const gateWidth = 2 * CONFIG.cellSize
    const gateCenterX = (roadStart + roadEnd + 1) * CONFIG.cellSize / 2 - offsetX

    // 门柱尺寸（先定义）- 增大气派感
    const pillarW = 8
    const pillarD = 8
    const pillarH = h + 15

    // 南墙左段 - 与门柱不重叠
    const leftWallEnd = gateCenterX - gateWidth / 2 - pillarW / 2 - 0.1
    const leftWallWidth = leftWallEnd - westX
    if (leftWallWidth > 0) {
      const leftWall = new THREE.Mesh(new THREE.BoxGeometry(leftWallWidth, h, wallThickness), wallMat)
      leftWall.position.set(westX + leftWallWidth / 2, h / 2, southZ)
      leftWall.castShadow = true
      leftWall.receiveShadow = true
      parkingGroup.add(leftWall)
    }

    // 南墙右段 - 与门柱不重叠
    const rightWallStart = gateCenterX + gateWidth / 2 + pillarW / 2 + 0.1
    const rightWallWidth = eastX - rightWallStart
    if (rightWallWidth > 0) {
      const rightWall = new THREE.Mesh(new THREE.BoxGeometry(rightWallWidth, h, wallThickness), wallMat)
      rightWall.position.set(eastX - rightWallWidth / 2, h / 2, southZ)
      rightWall.castShadow = true
      rightWall.receiveShadow = true
      parkingGroup.add(rightWall)
    }

    // ===== 简洁门柱系统 =====
    // 左门柱 - 简洁设计
    const leftPillar = new THREE.Mesh(
      new THREE.BoxGeometry(pillarW, pillarH, pillarD),
      pillarMat
    )
    leftPillar.position.set(gateCenterX - gateWidth / 2 - pillarW / 2, pillarH / 2, southZ)
    leftPillar.castShadow = true
    leftPillar.receiveShadow = true
    parkingGroup.add(leftPillar)

    // 右门柱 - 简洁设计
    const rightPillar = new THREE.Mesh(
      new THREE.BoxGeometry(pillarW, pillarH, pillarD),
      pillarMat
    )
    rightPillar.position.set(gateCenterX + gateWidth / 2 + pillarW / 2, pillarH / 2, southZ)
    rightPillar.castShadow = true
    rightPillar.receiveShadow = true
    parkingGroup.add(rightPillar)

    // ===== 气派门楣系统 =====
    // 大气门楣结构
    const lintelHeight = 8
    const lintelDepth = pillarD + 2

    // 主门楣 - 横跨两柱之间
    const lintelWidth = gateWidth + pillarW * 2 + 4
    const lintel = new THREE.Mesh(
      new THREE.BoxGeometry(lintelWidth, lintelHeight, lintelDepth),
      pillarMat
    )
    lintel.position.set(gateCenterX, pillarH + lintelHeight / 2, southZ)
    lintel.castShadow = true
    lintel.receiveShadow = true
    parkingGroup.add(lintel)

    // 门楣顶部装饰层
    const topCap = new THREE.Mesh(
      new THREE.BoxGeometry(lintelWidth + 2, 1.5, lintelDepth + 1),
      trimMat
    )
    topCap.position.set(gateCenterX, pillarH + lintelHeight + 0.75, southZ)
    topCap.castShadow = true
    parkingGroup.add(topCap)

    // 门楣底部装饰层
    const bottomCap = new THREE.Mesh(
      new THREE.BoxGeometry(lintelWidth + 1, 1.0, lintelDepth + 0.5),
      new THREE.MeshLambertMaterial({ color: 0x333333 })
    )
    bottomCap.position.set(gateCenterX, pillarH + 0.5, southZ)
    bottomCap.castShadow = true
    parkingGroup.add(bottomCap)

    // 中央标识牌背景
    const signBg = new THREE.Mesh(
      new THREE.BoxGeometry(gateWidth * 0.8, 4, 0.5),
      new THREE.MeshLambertMaterial({ color: 0x1a365d })
    )
    signBg.position.set(gateCenterX, pillarH + lintelHeight / 2, southZ + lintelDepth / 2 + 0.25)
    signBg.castShadow = true
    parkingGroup.add(signBg)

    // ===== 大门连接道路 =====
    // 创建从大门到外部街道的连接道路
    const connectionRoadLength = 100
    const connectionRoadWidth = gateWidth + 10
    const connectionRoad = new THREE.Mesh(
      new THREE.BoxGeometry(connectionRoadWidth, 0.15, connectionRoadLength),
      materials.value.road
    )
    connectionRoad.position.set(gateCenterX, -0.02, southZ + connectionRoadLength / 2)
    connectionRoad.receiveShadow = true
    parkingGroup.add(connectionRoad)

    // 减速带
    const speedBump = new THREE.Mesh(
      new THREE.BoxGeometry(connectionRoadWidth - 10, 0.15, 3),
      new THREE.MeshLambertMaterial({ color: 0xffcc00 })
    )
    speedBump.position.set(gateCenterX, 0.075, southZ + 30)
    speedBump.castShadow = true
    speedBump.receiveShadow = true
    parkingGroup.add(speedBump)

    // 减速带黑色条纹
    for (let i = 0; i < 5; i++) {
      const stripe = new THREE.Mesh(
        new THREE.BoxGeometry(0.3, 0.16, 2.8),
        new THREE.MeshBasicMaterial({ color: 0x000000 })
      )
      stripe.position.set(gateCenterX - 8 + i * 4, 0.08, southZ + 30)
      parkingGroup.add(stripe)
    }

    // ===== 现代智能闸机系统 =====
    // 创建正常高度闸机 - 位于连接道路两侧，不与大门的柱子重叠
    const barrierHeight = 3
    const barrierWidth = 1.5
    const barrierDepth = 1

    function createBarrier(gateX, isLeft) {
      const barrierGroup = new THREE.Group()
      barrierGroup.position.set(gateX, 0, southZ + 60)

      // 闸机主体 - 正常高度
      const body = new THREE.Mesh(
        new THREE.BoxGeometry(barrierWidth, barrierHeight, barrierDepth),
        new THREE.MeshLambertMaterial({ color: 0xc0c0c0 })
      )
      body.position.y = barrierHeight / 2
      body.castShadow = true
      barrierGroup.add(body)

      // 顶部LED指示灯
      const led = new THREE.Mesh(
        new THREE.SphereGeometry(0.3, 12, 12),
        new THREE.MeshBasicMaterial({ color: 0x00ff00 })
      )
      led.position.set(0, barrierHeight + 0.3, 0)
      barrierGroup.add(led)

      // 显示屏
      const screen = new THREE.Mesh(
        new THREE.BoxGeometry(barrierWidth - 0.3, 0.8, 0.1),
        new THREE.MeshBasicMaterial({ color: 0x000000 })
      )
      screen.position.set(0, barrierHeight - 0.6, barrierDepth / 2 + 0.05)
      barrierGroup.add(screen)

      // 栏杆臂
      const armLength = gateWidth / 2 + 5
      const arm = new THREE.Mesh(
        new THREE.BoxGeometry(armLength, 0.1, 0.3),
        new THREE.MeshBasicMaterial({ color: 0xffffff })
      )
      arm.position.set(isLeft ? armLength / 2 - barrierWidth / 2 : -armLength / 2 + barrierWidth / 2, barrierHeight - 0.3, 0)
      barrierGroup.add(arm)

      // 红白警示条纹
      for (let i = 0; i < 5; i++) {
        const stripe = new THREE.Mesh(
          new THREE.BoxGeometry(0.8, 0.12, 0.32),
          new THREE.MeshBasicMaterial({ color: i % 2 === 0 ? 0xff0000 : 0xffffff })
        )
        stripe.position.set(
          isLeft ? i * 1.2 - barrierWidth / 2 : -i * 1.2 + barrierWidth / 2,
          barrierHeight - 0.3,
          0
        )
        barrierGroup.add(stripe)
      }

      return barrierGroup
    }

    // 左闸机 - 位于连接道路左侧（与大门柱子错开）
    const leftBarrierX = gateCenterX - gateWidth / 2 - 15
    const leftBarrier = createBarrier(leftBarrierX, true)
    parkingGroup.add(leftBarrier)

    // 右闸机 - 位于连接道路右侧（与大门柱子错开）
    const rightBarrierX = gateCenterX + gateWidth / 2 + 15
    const rightBarrier = createBarrier(rightBarrierX, false)
    parkingGroup.add(rightBarrier)

    // ===== 添加环境装饰 =====
    createEnvironmentDecorations(gateCenterX, southZ, westX, eastX, northZ)

    // ===== 北边第二个大门（出口）=====
    // 使用之前计算的 northGateWidth, northGateCenterX, northPillarW, northPillarD, northPillarH

    // ===== 北边简洁门柱系统 =====
    // 左门柱
    const northLeftPillar = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarW, northPillarH, northPillarD),
      pillarMat
    )
    northLeftPillar.position.set(northGateCenterX - northGateWidth / 2 - northPillarW / 2, northPillarH / 2, northZ)
    northLeftPillar.castShadow = true
    northLeftPillar.receiveShadow = true
    parkingGroup.add(northLeftPillar)

    // 右门柱
    const northRightPillar = new THREE.Mesh(
      new THREE.BoxGeometry(northPillarW, northPillarH, northPillarD),
      pillarMat
    )
    northRightPillar.position.set(northGateCenterX + northGateWidth / 2 + northPillarW / 2, northPillarH / 2, northZ)
    northRightPillar.castShadow = true
    northRightPillar.receiveShadow = true
    parkingGroup.add(northRightPillar)

    // ===== 北边气派门楣系统 =====
    const northLintelHeight = 8
    const northLintelDepth = northPillarD + 2
    const northLintelWidth = northGateWidth + northPillarW * 2 + 4

    // 主门楣
    const northLintel = new THREE.Mesh(
      new THREE.BoxGeometry(northLintelWidth, northLintelHeight, northLintelDepth),
      pillarMat
    )
    northLintel.position.set(northGateCenterX, northPillarH + northLintelHeight / 2, northZ)
    northLintel.castShadow = true
    northLintel.receiveShadow = true
    parkingGroup.add(northLintel)

    // 门楣顶部装饰层
    const northTopCap = new THREE.Mesh(
      new THREE.BoxGeometry(northLintelWidth + 2, 1.5, northLintelDepth + 1),
      trimMat
    )
    northTopCap.position.set(northGateCenterX, northPillarH + northLintelHeight + 0.75, northZ)
    northTopCap.castShadow = true
    parkingGroup.add(northTopCap)

    // 门楣底部装饰层
    const northBottomCap = new THREE.Mesh(
      new THREE.BoxGeometry(northLintelWidth + 1, 1.0, northLintelDepth + 0.5),
      new THREE.MeshLambertMaterial({ color: 0x333333 })
    )
    northBottomCap.position.set(northGateCenterX, northPillarH + 0.5, northZ)
    northBottomCap.castShadow = true
    parkingGroup.add(northBottomCap)

    // 中央标识牌背景
    const northSignBg = new THREE.Mesh(
      new THREE.BoxGeometry(northGateWidth * 0.8, 4, 0.5),
      new THREE.MeshLambertMaterial({ color: 0x1a365d })
    )
    northSignBg.position.set(northGateCenterX, northPillarH + northLintelHeight / 2, northZ - northLintelDepth / 2 - 0.25)
    northSignBg.castShadow = true
    parkingGroup.add(northSignBg)

    // ===== 北边大门连接道路 =====
    const northConnectionRoadLength = 100
    const northConnectionRoadWidth = northGateWidth + 10
    const northConnectionRoad = new THREE.Mesh(
      new THREE.BoxGeometry(northConnectionRoadWidth, 0.15, northConnectionRoadLength),
      materials.value.road
    )
    northConnectionRoad.position.set(northGateCenterX, -0.02, northZ - northConnectionRoadLength / 2)
    northConnectionRoad.receiveShadow = true
    parkingGroup.add(northConnectionRoad)

    // 北边减速带
    const northSpeedBump = new THREE.Mesh(
      new THREE.BoxGeometry(northConnectionRoadWidth - 10, 0.15, 3),
      new THREE.MeshLambertMaterial({ color: 0xffcc00 })
    )
    northSpeedBump.position.set(northGateCenterX, 0.075, northZ - 30)
    northSpeedBump.castShadow = true
    northSpeedBump.receiveShadow = true
    parkingGroup.add(northSpeedBump)

    // 北边减速带黑色条纹
    for (let i = 0; i < 5; i++) {
      const stripe = new THREE.Mesh(
        new THREE.BoxGeometry(0.3, 0.16, 2.8),
        new THREE.MeshBasicMaterial({ color: 0x000000 })
      )
      stripe.position.set(northGateCenterX - 8 + i * 4, 0.08, northZ - 30)
      parkingGroup.add(stripe)
    }

    // ===== 北边现代智能闸机系统 =====
    function createNorthBarrier(gateX, isLeft) {
      const barrierGroup = new THREE.Group()
      barrierGroup.position.set(gateX, 0, northZ - 60)

      // 闸机主体
      const body = new THREE.Mesh(
        new THREE.BoxGeometry(1.5, 3, 1),
        new THREE.MeshLambertMaterial({ color: 0xc0c0c0 })
      )
      body.position.y = 1.5
      body.castShadow = true
      barrierGroup.add(body)

      // 顶部LED指示灯
      const led = new THREE.Mesh(
        new THREE.SphereGeometry(0.3, 12, 12),
        new THREE.MeshBasicMaterial({ color: 0x00ff00 })
      )
      led.position.set(0, 3.3, 0)
      barrierGroup.add(led)

      // 显示屏
      const screen = new THREE.Mesh(
        new THREE.BoxGeometry(1.2, 0.8, 0.1),
        new THREE.MeshBasicMaterial({ color: 0x000000 })
      )
      screen.position.set(0, 2.4, 0.55)
      barrierGroup.add(screen)

      // 栏杆臂
      const armLength = northGateWidth / 2 + 5
      const arm = new THREE.Mesh(
        new THREE.BoxGeometry(armLength, 0.1, 0.3),
        new THREE.MeshBasicMaterial({ color: 0xffffff })
      )
      arm.position.set(isLeft ? armLength / 2 - 0.75 : -armLength / 2 + 0.75, 2.7, 0)
      barrierGroup.add(arm)

      // 红白警示条纹
      for (let i = 0; i < 5; i++) {
        const stripe = new THREE.Mesh(
          new THREE.BoxGeometry(0.8, 0.12, 0.32),
          new THREE.MeshBasicMaterial({ color: i % 2 === 0 ? 0xff0000 : 0xffffff })
        )
        stripe.position.set(
          isLeft ? i * 1.2 - 0.75 : -i * 1.2 + 0.75,
          2.7,
          0
        )
        barrierGroup.add(stripe)
      }

      return barrierGroup
    }

    // 北边左闸机
    const northLeftBarrierX = northGateCenterX - northGateWidth / 2 - 15
    const northLeftBarrier = createNorthBarrier(northLeftBarrierX, true)
    parkingGroup.add(northLeftBarrier)

    // 北边右闸机
    const northRightBarrierX = northGateCenterX + northGateWidth / 2 + 15
    const northRightBarrier = createNorthBarrier(northRightBarrierX, false)
    parkingGroup.add(northRightBarrier)
  }

  // 创建3D立体标识
  function create3DSign(group, x, y, z) {
    // 使用多个立方体拼成文字效果
    const letterMat = new THREE.MeshLambertMaterial({ color: 0xffffff })
    const letterDepth = 0.3

    // 简化的 "P" 字母造型
    const pGroup = new THREE.Group()

    // P的竖线
    const pStem = new THREE.Mesh(
      new THREE.BoxGeometry(0.8, 2, letterDepth),
      letterMat
    )
    pStem.position.set(0, 0, 0)
    pGroup.add(pStem)

    // P的头部
    const pHead = new THREE.Mesh(
      new THREE.BoxGeometry(1.2, 0.6, letterDepth),
      letterMat
    )
    pHead.position.set(0.2, 0.7, 0)
    pGroup.add(pHead)

    // P的中间横线
    const pMid = new THREE.Mesh(
      new THREE.BoxGeometry(1, 0.5, letterDepth),
      letterMat
    )
    pMid.position.set(0.1, 0.2, 0)
    pGroup.add(pMid)

    pGroup.position.set(x - 2, y, z)
    group.add(pGroup)

    // "停车"文字的简化表示 - 使用矩形块
    const textGroup = new THREE.Group()

    // 停字的简化
    const tingBlocks = [
      { x: 0, y: 0.8, w: 0.3, h: 1.5 },
      { x: 0.6, y: 0.8, w: 0.8, h: 0.3 },
      { x: 0.6, y: 0.3, w: 0.8, h: 0.3 },
      { x: 0.6, y: -0.2, w: 0.3, h: 0.8 }
    ]

    tingBlocks.forEach(block => {
      const mesh = new THREE.Mesh(
        new THREE.BoxGeometry(block.w, block.h, letterDepth),
        letterMat
      )
      mesh.position.set(block.x, block.y, 0)
      textGroup.add(mesh)
    })

    // 场字的简化
    const changBlocks = [
      { x: 2, y: 0.8, w: 1.2, h: 0.3 },
      { x: 1.7, y: 0.3, w: 0.3, h: 1.2 },
      { x: 2.3, y: 0.3, w: 0.3, h: 1.2 },
      { x: 2.9, y: 0.3, w: 0.3, h: 1.2 },
      { x: 2.3, y: -0.2, w: 1, h: 0.3 }
    ]

    changBlocks.forEach(block => {
      const mesh = new THREE.Mesh(
        new THREE.BoxGeometry(block.w, block.h, letterDepth),
        letterMat
      )
      mesh.position.set(block.x, block.y, 0)
      textGroup.add(mesh)
    })

    textGroup.position.set(x, y - 0.5, z)
    group.add(textGroup)
  }

  // 创建环境装饰
  function createEnvironmentDecorations(gateCenterX, southZ, westX, eastX, northZ) {
    const metalMat = materials.value.metal
    // 简化警示材质
    const warningMat = new THREE.MeshLambertMaterial({ color: 0xffcc00 })

    // 入口两侧的警示柱
    const bollardPositions = [
      { x: gateCenterX - 25, z: southZ + 10 },
      { x: gateCenterX + 25, z: southZ + 10 },
      { x: gateCenterX - 25, z: southZ + 25 },
      { x: gateCenterX + 25, z: southZ + 25 }
    ]

    bollardPositions.forEach(pos => {
      // 柱子主体
      const bollard = new THREE.Mesh(
        new THREE.CylinderGeometry(0.4, 0.4, 3, 16),
        metalMat
      )
      bollard.position.set(pos.x, 1.5, pos.z)
      bollard.castShadow = true
      parkingGroup.add(bollard)

      // 黄黑警示条纹
      for (let j = 0; j < 3; j++) {
        const stripe = new THREE.Mesh(
          new THREE.CylinderGeometry(0.42, 0.42, 0.4, 16),
          j % 2 === 0 ? warningMat : new THREE.MeshBasicMaterial({ color: 0x000000 })
        )
        stripe.position.set(pos.x, 0.5 + j * 0.8, pos.z)
        parkingGroup.add(stripe)
      }

      // 顶部反光盖
      const cap = new THREE.Mesh(
        new THREE.SphereGeometry(0.4, 16, 8, 0, Math.PI * 2, 0, Math.PI / 2),
        new THREE.MeshBasicMaterial({ color: 0xff0000 })
      )
      cap.position.set(pos.x, 3, pos.z)
      parkingGroup.add(cap)
    })

    // 停车场指示牌
    createParkingSign(gateCenterX - 35, southZ + 20)
    createParkingSign(gateCenterX + 35, southZ + 20)

    // 内部路灯
    createStreetLights(gateCenterX, southZ, westX, eastX, northZ)

    // 监控摄像头
    createSecurityCameras(gateCenterX, southZ, northZ)
  }

  // 创建路灯
  function createStreetLights(gateCenterX, southZ, westX, eastX, northZ) {
    const metalMat = materials.value.metal
    const lampMat = new THREE.MeshBasicMaterial({
      color: 0xffffee
    })

    // 主要道路交叉口的路灯位置
    const lightPositions = [
      { x: gateCenterX - 80, z: southZ - 50 },
      { x: gateCenterX + 80, z: southZ - 50 },
      { x: gateCenterX - 80, z: 0 },
      { x: gateCenterX + 80, z: 0 },
      { x: gateCenterX - 80, z: northZ + 50 },
      { x: gateCenterX + 80, z: northZ + 50 }
    ]

    lightPositions.forEach((pos, index) => {
      // 灯杆
      const pole = new THREE.Mesh(
        new THREE.CylinderGeometry(0.2, 0.3, 12, 12),
        metalMat
      )
      pole.position.set(pos.x, 6, pos.z)
      pole.castShadow = true
      parkingGroup.add(pole)

      // 灯臂
      const arm = new THREE.Mesh(
        new THREE.BoxGeometry(3, 0.3, 0.3),
        metalMat
      )
      arm.position.set(pos.x + (index % 2 === 0 ? 1.5 : -1.5), 11.5, pos.z)
      arm.castShadow = true
      parkingGroup.add(arm)

      // 灯具
      const lamp = new THREE.Mesh(
        new THREE.BoxGeometry(1, 0.4, 0.6),
        lampMat
      )
      lamp.position.set(pos.x + (index % 2 === 0 ? 3 : -3), 11.3, pos.z)
      parkingGroup.add(lamp)

      // 点光源
      const pointLight = new THREE.PointLight(0xffffee, 0.5, 30)
      pointLight.position.set(pos.x + (index % 2 === 0 ? 3 : -3), 10, pos.z)
      parkingGroup.add(pointLight)
    })
  }

  // 创建监控摄像头
  function createSecurityCameras(gateCenterX, southZ, northZ) {
    const metalMat = materials.value.metal
    const cameraBodyMat = new THREE.MeshLambertMaterial({ color: 0x333333 })
    const lensMat = new THREE.MeshBasicMaterial({ color: 0x111111 })

    // 摄像头位置
    const cameraPositions = [
      { x: gateCenterX - 60, z: southZ - 30, rot: Math.PI },
      { x: gateCenterX + 60, z: southZ - 30, rot: Math.PI },
      { x: 0, z: northZ + 30, rot: 0 },
      { x: -120, z: 0, rot: Math.PI / 2 },
      { x: 120, z: 0, rot: -Math.PI / 2 }
    ]

    cameraPositions.forEach(pos => {
      // 支架
      const bracket = new THREE.Mesh(
        new THREE.BoxGeometry(0.3, 0.3, 2),
        metalMat
      )
      bracket.position.set(pos.x, 10, pos.z)
      bracket.rotation.y = pos.rot
      bracket.castShadow = true
      parkingGroup.add(bracket)

      // 摄像头外壳
      const body = new THREE.Mesh(
        new THREE.SphereGeometry(0.6, 16, 16),
        cameraBodyMat
      )
      body.position.set(
        pos.x + Math.sin(pos.rot) * 1,
        10,
        pos.z + Math.cos(pos.rot) * 1
      )
      parkingGroup.add(body)

      // 镜头
      const lens = new THREE.Mesh(
        new THREE.CylinderGeometry(0.3, 0.3, 0.3, 16),
        lensMat
      )
      lens.rotation.x = Math.PI / 2
      lens.rotation.z = pos.rot + Math.PI / 2
      lens.position.set(
        pos.x + Math.sin(pos.rot) * 1.4,
        10,
        pos.z + Math.cos(pos.rot) * 1.4
      )
      parkingGroup.add(lens)

      // 红外灯环
      const irRing = new THREE.Mesh(
        new THREE.RingGeometry(0.15, 0.25, 16),
        new THREE.MeshBasicMaterial({ color: 0x660000 })
      )
      irRing.position.set(
        pos.x + Math.sin(pos.rot) * 1.55,
        10,
        pos.z + Math.cos(pos.rot) * 1.55
      )
      irRing.rotation.y = pos.rot
      parkingGroup.add(irRing)
    })
  }

  // 创建停车场指示牌
  function createParkingSign(x, z) {
    const poleMat = materials.value.metal
    const signMat = new THREE.MeshLambertMaterial({
      color: 0x1e40af
    })

    // 立杆
    const pole = new THREE.Mesh(
      new THREE.CylinderGeometry(0.15, 0.15, 8, 12),
      poleMat
    )
    pole.position.set(x, 4, z)
    pole.castShadow = true
    parkingGroup.add(pole)

    // 指示牌面板
    const signBoard = new THREE.Mesh(
      new THREE.BoxGeometry(4, 2.5, 0.2),
      signMat
    )
    signBoard.position.set(x, 7, z)
    signBoard.castShadow = true
    parkingGroup.add(signBoard)

    // 边框
    const frameMat = new THREE.MeshLambertMaterial({ color: 0xffffff })
    const topFrame = new THREE.Mesh(new THREE.BoxGeometry(4.2, 0.2, 0.3), frameMat)
    topFrame.position.set(x, 8.2, z)
    parkingGroup.add(topFrame)

    const bottomFrame = new THREE.Mesh(new THREE.BoxGeometry(4.2, 0.2, 0.3), frameMat)
    bottomFrame.position.set(x, 5.8, z)
    parkingGroup.add(bottomFrame)

    const leftFrame = new THREE.Mesh(new THREE.BoxGeometry(0.2, 2.7, 0.3), frameMat)
    leftFrame.position.set(x - 2, 7, z)
    parkingGroup.add(leftFrame)

    const rightFrame = new THREE.Mesh(new THREE.BoxGeometry(0.2, 2.7, 0.3), frameMat)
    rightFrame.position.set(x + 2, 7, z)
    parkingGroup.add(rightFrame)

    // 文字标签（使用Canvas纹理）
    const label = createSignLabel('P', '#ffffff')
    label.position.set(x, 7.5, z + 0.15)
    label.scale.set(2, 2, 1)
    parkingGroup.add(label)

    // 文字标签 - 入场
    const subLabel = createSignLabel('入场', '#ffffff', 64)
    subLabel.position.set(x, 6.3, z + 0.15)
    subLabel.scale.set(1.5, 0.8, 1)
    parkingGroup.add(subLabel)
  }

  // 创建指示牌文字
  function createSignLabel(text, color, fontSize = 120) {
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    canvas.width = 256
    canvas.height = 256

    ctx.fillStyle = 'rgba(0, 0, 0, 0)'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    ctx.font = `bold ${fontSize}px Arial`
    ctx.fillStyle = color
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(text, canvas.width / 2, canvas.height / 2)

    const texture = new THREE.CanvasTexture(canvas)
    const material = new THREE.MeshBasicMaterial({
      map: texture,
      transparent: true,
      side: THREE.DoubleSide
    })

    const geometry = new THREE.PlaneGeometry(2, 2)
    return new THREE.Mesh(geometry, material)
  }

  function createRoads() {
    const rMat = materials.value.road

    // 使用网格系统生成的道路数据
    ROADS.forEach(road => {
      const mesh = new THREE.Mesh(
        new THREE.BoxGeometry(road.width, 0.1, road.depth),
        rMat
      )
      mesh.position.set(road.x, 0.05, road.z)
      parkingGroup.add(mesh)
    })

    // 外部连接道路（入口延伸）- 高度略低于内部道路避免z-fighting
    const rows = GRID_MAP.length
    const offsetZ = (rows * CONFIG.cellSize) / 2
    const extRoad = new THREE.Mesh(
      new THREE.BoxGeometry(CONFIG.cellSize * 3, 0.1, CONFIG.cellSize * 3),
      rMat
    )
    extRoad.position.set(0, 0.04, offsetZ + CONFIG.cellSize * 2)
    extRoad.receiveShadow = true
    parkingGroup.add(extRoad)
  }

  function createParkingSpaces(floorSpaces) {
    let index = 0

    PARKING_SPOTS.forEach((spot, i) => {
      if (index >= floorSpaces.length) return

      const [x, z, facing] = spot
      createSpace(floorSpaces[index], x, z, facing, index)
      index++
    })
  }

  function createSpace(space, x, z, facing, spaceIndex = 0) {
    const group = new THREE.Group()
    group.position.set(x, 0, z)

    const isOccupied = space.status === 1

    // 按区域代码取基础色，占用时统一用红色
    const areaCode = (space.areaCode || 'A').toUpperCase()
    let color
    if (isOccupied) {
      color = AREA_COLORS_OCCUPIED[areaCode] || COLORS.spaceOccupied
    } else {
      color = AREA_COLORS[areaCode] || COLORS.spaceFree
    }

    // 使用仿真混凝土材质
    const mat = createSpaceMaterial(color)

    // 车位尺寸 - 放大以适应20m网格，保持1:2比例
    // P/S (北/南向): 宽10m × 深20m
    // E/W (东/西向): 宽20m × 深10m
    const isNS = (facing === 'n' || facing === 's')
    const spaceWidth = isNS ? CONFIG.cellSize / 2 : CONFIG.cellSize
    const spaceDepth = isNS ? CONFIG.cellSize : CONFIG.cellSize / 2

    // 地面 - 混凝土纹理，添加轻微磨损效果
    // 抬高到0.06避免与道路地面产生z-fighting闪烁
    const groundGeo = new THREE.BoxGeometry(spaceWidth, 0.08, spaceDepth)
    const ground = new THREE.Mesh(groundGeo, mat)
    ground.position.y = 0.06
    ground.userData = { type: 'space', spaceData: space }
    ground.receiveShadow = true
    group.add(ground)

    // 添加轮胎磨损痕迹（停车位常见的黑色痕迹）
    if (Math.random() > 0.3) {
      const tireMarkMat = new THREE.MeshLambertMaterial({
        color: 0x2a2a2a,
        transparent: true,
        opacity: 0.3
      })

      // 两条轮胎痕迹
      for (let i = -1; i <= 1; i += 2) {
        const tireMark = new THREE.Mesh(
          new THREE.PlaneGeometry(2, spaceDepth * 0.6),
          tireMarkMat
        )
        tireMark.rotation.x = -Math.PI / 2
        tireMark.position.set(i * spaceWidth * 0.25, 0.09, 0)
        group.add(tireMark)
      }
    }

    // 标线（带限位器）
    const lines = createSpaceGeometry(spaceWidth, spaceDepth, facing, materials.value)
    group.add(lines)

    // 编号标签（根据类型显示不同颜色）
    const label = createGroundLabel(space.spaceCode, false, false)
    // 标签高度由createGroundLabel内部设置，此处只需设置x,z位置

    // 根据朝向旋转标签
    switch (facing) {
      case 's':
      case 'south':
        label.rotation.z = Math.PI
        break
      case 'e':
      case 'east':
        label.rotation.z = -Math.PI / 2
        break
      case 'w':
      case 'west':
        label.rotation.z = Math.PI / 2
        break
    }
    group.add(label)


    // 状态灯（改进版）
    const light = createStatusLight(color)
    const offset = spaceDepth / 2 - 1.2  // 同步调整偏移
    const wOffset = spaceWidth / 2 - 0.6
    switch (facing) {
      case 'n':
      case 'north':
        light.position.set(0, 0, -offset)
        break
      case 's':
      case 'south':
        light.position.set(0, 0, offset)
        break
      case 'e':
      case 'east':
        light.position.set(-wOffset, 0, 0)
        break
      case 'w':
      case 'west':
        light.position.set(wOffset, 0, 0)
        break
    }
    group.add(light)

    // 仅占用状态显示车辆
    if (isOccupied) {
      const car = createCar(space.areaType)

      // 根据车位类型和方向计算合适的汽车比例
      // 车位尺寸: NS方向 10m x 20m, EW方向 20m x 10m
      // 汽车原始尺寸约: 长8.5m, 宽4m
      const isVIP = space.areaType === 'VIP'
      const isDisabled = space.areaType === '残疾人车位'

      // 计算合适的缩放比例，使汽车占车位深度的110%，稍微溢出
      let carScale
      if (isNS) {
        // 北/南向: 车位深20m，汽车占约22m (110%)
        carScale = 22 / 8.5
      } else {
        // 东/西向: 车位深10m，汽车占约11m (110%)
        carScale = 11 / 8.5
      }

      // VIP车位使用稍大的车，残疾人车位使用标准尺寸
      if (isVIP) carScale *= 1.1
      if (isDisabled) carScale *= 1.15

      // 根据朝向调整车辆方向和位置
      // y = 0.10 抬高汽车避免与地面的z-fighting闪烁
      const carY = 0.10
      switch (facing) {
        case 'n':
        case 'north':
          car.rotation.y = 0
          car.position.set(0, carY, spaceDepth * 0.12)
          break
        case 's':
        case 'south':
          car.rotation.y = Math.PI
          car.position.set(0, carY, -spaceDepth * 0.12)
          break
        case 'e':
        case 'east':
          car.rotation.y = -Math.PI / 2
          car.position.set(-spaceWidth * 0.12, carY, 0)
          break
        case 'w':
        case 'west':
          car.rotation.y = Math.PI / 2
          car.position.set(spaceWidth * 0.12, carY, 0)
          break
      }
      car.scale.set(carScale, carScale, carScale)
      group.add(car)

      // 车辆入场动画 - 传入目标缩放比例和Y位置
      animateCarEntrance(car, 800, carScale, carY)
    }

    spaceMeshes.set(space.spaceCode, { group, ground, light })
    parkingGroup.add(group)
  }

  // ========== 手动绘制道路标线（基于网格坐标）==========
  function createMarkings() {
    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length
    const offsetX = (cols * CONFIG.cellSize) / 2
    const offsetZ = (rows * CONFIG.cellSize) / 2

    const whiteMat = new THREE.MeshBasicMaterial({ color: 0xffffff })
    const yellowMat = new THREE.MeshBasicMaterial({ color: 0xffcc00 })

    // 遍历网格，为每个道路格子绘制标线
    for (let row = 0; row < rows; row++) {
      for (let col = 0; col < cols; col++) {
        if (GRID_MAP[row][col] !== 'R') continue

        const x = col * CONFIG.cellSize - offsetX + CONFIG.cellSize / 2
        const z = row * CONFIG.cellSize - offsetZ + CONFIG.cellSize / 2
        const isHorizontal = isHorizontalRoad(row, col)

        // 跳过最底部（南大门）和最顶部（北大门）的横向道路
        if (isHorizontal && (row >= rows - 2 || row <= 2)) continue

        // 交叉口不绘制任何线，保持空白
        const isIntersection = checkIsIntersection(row, col)
        if (isIntersection) continue

        if (isHorizontal) {
          // 横向道路 - 中心双黄线
          createYellowLine(x, z, CONFIG.cellSize, true, yellowMat)
          // 车道分隔虚线（左右各一条）
          createDashLine(x, z - 5, CONFIG.cellSize, true, whiteMat)
          createDashLine(x, z + 5, CONFIG.cellSize, true, whiteMat)
        } else {
          // 纵向道路 - 中心双黄线
          createYellowLine(x, z, CONFIG.cellSize, false, yellowMat)
          // 车道分隔虚线（上下各一条）
          createDashLine(x - 5, z, CONFIG.cellSize, false, whiteMat)
          createDashLine(x + 5, z, CONFIG.cellSize, false, whiteMat)
        }
      }
    }
  }

  // 检查是否为交叉口
  function checkIsIntersection(row, col) {
    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length

    // 检查四个方向是否都有道路
    const hasTop = row > 0 && GRID_MAP[row - 1][col] === 'R'
    const hasBottom = row < rows - 1 && GRID_MAP[row + 1][col] === 'R'
    const hasLeft = col > 0 && GRID_MAP[row][col - 1] === 'R'
    const hasRight = col < cols - 1 && GRID_MAP[row][col + 1] === 'R'

    // 交叉口：上下都有道路且左右都有道路
    return hasTop && hasBottom && hasLeft && hasRight
  }

  // 判断道路方向（横向/纵向）
  function isHorizontalRoad(row, col) {
    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length
    let horizontalCount = 0
    let verticalCount = 0

    // 检查左右
    if (col > 0 && GRID_MAP[row][col - 1] === 'R') horizontalCount++
    if (col < cols - 1 && GRID_MAP[row][col + 1] === 'R') horizontalCount++

    // 检查上下
    if (row > 0 && GRID_MAP[row - 1][col] === 'R') verticalCount++
    if (row < rows - 1 && GRID_MAP[row + 1][col] === 'R') verticalCount++

    return horizontalCount >= verticalCount
  }

  // 创建黄线（双线）
  function createYellowLine(cx, cz, length, isHorizontal, material) {
    const lineWidth = 0.15
    const gap = 0.1

    if (isHorizontal) {
      // 横向 - 两条线分别在中心上下
      const line1 = new THREE.Mesh(
        new THREE.BoxGeometry(length, 0.05, lineWidth),
        material
      )
      line1.position.set(cx, 0.08, cz - gap / 2 - lineWidth / 2)
      parkingGroup.add(line1)

      const line2 = new THREE.Mesh(
        new THREE.BoxGeometry(length, 0.05, lineWidth),
        material
      )
      line2.position.set(cx, 0.08, cz + gap / 2 + lineWidth / 2)
      parkingGroup.add(line2)
    } else {
      // 纵向 - 两条线分别在中心左右
      const line1 = new THREE.Mesh(
        new THREE.BoxGeometry(lineWidth, 0.05, length),
        material
      )
      line1.position.set(cx - gap / 2 - lineWidth / 2, 0.08, cz)
      parkingGroup.add(line1)

      const line2 = new THREE.Mesh(
        new THREE.BoxGeometry(lineWidth, 0.05, length),
        material
      )
      line2.position.set(cx + gap / 2 + lineWidth / 2, 0.08, cz)
      parkingGroup.add(line2)
    }
  }

  // 创建虚线
  function createDashLine(cx, cz, length, isHorizontal, material) {
    const dashLength = 2
    const gapLength = 2
    const lineWidth = 0.12
    const dashCount = Math.floor(length / (dashLength + gapLength))

    for (let i = 0; i < dashCount; i++) {
      const pos = -length / 2 + i * (dashLength + gapLength) + dashLength / 2

      const dash = new THREE.Mesh(
        new THREE.BoxGeometry(
          isHorizontal ? dashLength : lineWidth,
          0.05,
          isHorizontal ? lineWidth : dashLength
        ),
        material
      )

      if (isHorizontal) {
        dash.position.set(cx + pos, 0.08, cz)
      } else {
        dash.position.set(cx, 0.08, cz + pos)
      }

      parkingGroup.add(dash)
    }
  }

  // 创建车位编号标线（已删除区域标识）
  function createSpaceNumberMarkings() {
    // 空函数，区域标识已删除
  }

  // ==================== 周边街道环境 ====================

  function createSurroundingStreet() {
    const streetGroup = new THREE.Group()

    // 获取停车场边界
    const rows = GRID_MAP.length
    const cols = GRID_MAP[0].length
    const offsetX = (cols * CONFIG.cellSize) / 2
    const offsetZ = (rows * CONFIG.cellSize) / 2

    const parkingWidth = cols * CONFIG.cellSize
    const parkingDepth = rows * CONFIG.cellSize

    // 扩展范围
    const streetWidth = 200
    const sidewalkWidth = 30

    // 创建主街道（南向）
    createMainStreet(streetGroup, 0, parkingDepth / 2 + streetWidth / 2 + 50, parkingWidth + 400, streetWidth)

    // 创建东西向街道
    createCrossStreet(streetGroup, -parkingWidth / 2 - streetWidth / 2 - 50, 0, streetWidth, parkingDepth + 300)
    createCrossStreet(streetGroup, parkingWidth / 2 + streetWidth / 2 + 50, 0, streetWidth, parkingDepth + 300)

    // 创建北向街道
    createMainStreet(streetGroup, 0, -parkingDepth / 2 - streetWidth / 2 - 50, parkingWidth + 400, streetWidth)

    // 添加人行道
    createSidewalks(streetGroup, parkingWidth, parkingDepth, streetWidth, sidewalkWidth)

    // 添加绿化带
    createGreenBelts(streetGroup, parkingWidth, parkingDepth, streetWidth)

    // 添加街道设施
    createStreetFacilities(streetGroup, parkingWidth, parkingDepth, streetWidth)

    // 添加街道细节
    createStreetDetails(streetGroup, parkingWidth, parkingDepth, streetWidth)

    parkingGroup.add(streetGroup)
  }

  // 创建主街道
  function createMainStreet(group, centerX, centerZ, width, depth) {
    // 沥青路面 - 降低高度避免与内部道路z-fighting
    const roadMat = materials.value.road
    const road = new THREE.Mesh(
      new THREE.BoxGeometry(width, 0.15, depth),
      roadMat
    )
    road.position.set(centerX, -0.02, centerZ)
    road.receiveShadow = true
    group.add(road)

    // 移除外部街道标线，避免与围墙闪烁
  }

  // 创建横向街道
  function createCrossStreet(group, centerX, centerZ, width, depth) {
    const roadMat = materials.value.road
    const road = new THREE.Mesh(
      new THREE.BoxGeometry(width, 0.15, depth),
      roadMat
    )
    road.position.set(centerX, -0.02, centerZ)
    road.receiveShadow = true
    group.add(road)

    // 移除外部街道标线和停止线，避免与围墙闪烁
    // 只保留道路主体
  }

  // 创建人行道
  function createSidewalks(group, parkingWidth, parkingDepth, streetWidth, sidewalkWidth) {
    const sidewalkMat = new THREE.MeshLambertMaterial({ color: 0x8a8a8a })
    const curbMat = new THREE.MeshLambertMaterial({ color: 0x555555 })

    const positions = [
      // 南人行道
      { x: 0, z: parkingDepth / 2 + streetWidth + sidewalkWidth / 2 + 50, w: parkingWidth + 400, d: sidewalkWidth },
      // 北人行道
      { x: 0, z: -parkingDepth / 2 - streetWidth - sidewalkWidth / 2 - 50, w: parkingWidth + 400, d: sidewalkWidth },
      // 东人行道
      { x: parkingWidth / 2 + streetWidth + sidewalkWidth / 2 + 50, z: 0, w: sidewalkWidth, d: parkingDepth + 200 },
      // 西人行道
      { x: -parkingWidth / 2 - streetWidth - sidewalkWidth / 2 - 50, z: 0, w: sidewalkWidth, d: parkingDepth + 200 }
    ]

    positions.forEach(pos => {
      // 人行道主体
      const sidewalk = new THREE.Mesh(
        new THREE.BoxGeometry(pos.w, 0.3, pos.d),
        sidewalkMat
      )
      sidewalk.position.set(pos.x, 0.15, pos.z)
      sidewalk.receiveShadow = true
      group.add(sidewalk)

      // 人行道纹理（砖块效果）
      createSidewalkBricks(group, pos.x, pos.z, pos.w, pos.d)

      // 路缘石
      const curbHeight = 0.4
      let curbW, curbD, curbX, curbZ

      if (pos.w > pos.d) {
        // 南北向人行道
        curbW = pos.w
        curbD = 1
        curbX = pos.x
        curbZ = pos.z > 0 ? pos.z - pos.d / 2 - 0.5 : pos.z + pos.d / 2 + 0.5
      } else {
        // 东西向人行道
        curbW = 1
        curbD = pos.d
        curbX = pos.x > 0 ? pos.x - pos.w / 2 - 0.5 : pos.x + pos.w / 2 + 0.5
        curbZ = pos.z
      }

      const curb = new THREE.Mesh(
        new THREE.BoxGeometry(curbW, curbHeight, curbD),
        curbMat
      )
      curb.position.set(curbX, curbHeight / 2, curbZ)
      curb.castShadow = true
      group.add(curb)
    })
  }

  // 创建人行道砖块纹理
  function createSidewalkBricks(group, x, z, width, depth) {
    const brickMat = new THREE.MeshBasicMaterial({ color: 0xaaaaaa })
    const brickWidth = 4
    const brickDepth = 2

    const cols = Math.floor(width / brickWidth)
    const rows = Math.floor(depth / brickDepth)

    for (let i = 0; i < cols; i++) {
      for (let j = 0; j < rows; j++) {
        // 只在砖缝处绘制细线，优化性能
        if (i % 4 === 0 || j % 4 === 0) {
          const brick = new THREE.Mesh(
            new THREE.BoxGeometry(brickWidth - 3.8, 0.02, brickDepth - 1.8),
            new THREE.MeshLambertMaterial({ color: 0x888888 })
          )
          brick.position.set(
            x - width / 2 + i * brickWidth + brickWidth / 2,
            0.31,
            z - depth / 2 + j * brickDepth + brickDepth / 2
          )
          group.add(brick)
        }
      }
    }
  }

  // 创建绿化带
  function createGreenBelts(group, parkingWidth, parkingDepth, streetWidth) {
    const grassMat = new THREE.MeshLambertMaterial({ color: 0x4a7c4e })
    const dirtMat = new THREE.MeshLambertMaterial({ color: 0x5c4033 })

    // 主街道两侧绿化带
    const greenBeltPositions = [
      // 南绿化带
      { x: 0, z: parkingDepth / 2 + streetWidth + 30, w: parkingWidth + 300, d: 20 },
      // 北绿化带
      { x: 0, z: -parkingDepth / 2 - streetWidth - 30, w: parkingWidth + 300, d: 20 }
    ]

    greenBeltPositions.forEach(pos => {
      // 土壤层
      const dirt = new THREE.Mesh(
        new THREE.BoxGeometry(pos.w, 0.5, pos.d),
        dirtMat
      )
      dirt.position.set(pos.x, 0.25, pos.z)
      group.add(dirt)

      // 草皮层
      const grass = new THREE.Mesh(
        new THREE.BoxGeometry(pos.w, 0.3, pos.d),
        grassMat
      )
      grass.position.set(pos.x, 0.65, pos.z)
      grass.receiveShadow = true
      group.add(grass)

      // 添加行道树
      const treeCount = Math.floor(pos.w / 40)
      for (let i = 0; i < treeCount; i++) {
        const treeX = pos.x - pos.w / 2 + 30 + i * 40
        createStreetTree(group, treeX, pos.z)
      }
    })
  }

  // 创建精致行道树 - 自然形态
  function createStreetTree(group, x, z) {
    const treeGroup = new THREE.Group()
    treeGroup.position.set(x, 0, z)

    // 树干 - 不规则形状，使用多个圆柱体
    const trunkMat = new THREE.MeshLambertMaterial({ color: 0x4a3728 })
    const trunkHeight = 10 + Math.random() * 5

    // 主树干
    const mainTrunk = new THREE.Mesh(
      new THREE.CylinderGeometry(0.35, 0.5, trunkHeight, 8),
      trunkMat
    )
    mainTrunk.position.y = trunkHeight / 2
    mainTrunk.rotation.z = (Math.random() - 0.5) * 0.1
    mainTrunk.castShadow = true
    treeGroup.add(mainTrunk)

    // 分叉树干
    const branchCount = 2 + Math.floor(Math.random() * 2)
    for (let i = 0; i < branchCount; i++) {
      const branchHeight = 3 + Math.random() * 3
      const branch = new THREE.Mesh(
        new THREE.CylinderGeometry(0.15, 0.25, branchHeight, 6),
        trunkMat
      )
      const angle = (Math.PI / 3) + (Math.random() - 0.5) * 0.5
      const rotY = (i / branchCount) * Math.PI * 2 + Math.random() * 0.5
      branch.position.y = trunkHeight * 0.6 + branchHeight / 2 * Math.sin(angle)
      branch.rotation.z = angle - Math.PI / 2
      branch.rotation.y = rotY
      branch.castShadow = true
      treeGroup.add(branch)
    }

    // 树冠 - 使用大量小球体模拟真实树叶
    const leafColors = [0x4a6741, 0x556b2f, 0x3d5c3d, 0x4f7942, 0x5a7a4a]
    const leafColor = leafColors[Math.floor(Math.random() * leafColors.length)]
    const leafMat = new THREE.MeshLambertMaterial({ color: leafColor })

    // 创建树冠云 - 多个随机分布的球体
    const crownCenter = new THREE.Vector3(
      (Math.random() - 0.5) * 2,
      trunkHeight + 3 + Math.random() * 2,
      (Math.random() - 0.5) * 2
    )

    // 主树冠体积
    const crownRadius = 5 + Math.random() * 3
    const leafClusters = 15 + Math.floor(Math.random() * 10)

    for (let i = 0; i < leafClusters; i++) {
      // 在球形体积内随机分布
      const u = Math.random()
      const v = Math.random()
      const theta = 2 * Math.PI * u
      const phi = Math.acos(2 * v - 1)
      const r = Math.pow(Math.random(), 1/3) * crownRadius

      const lx = crownCenter.x + r * Math.sin(phi) * Math.cos(theta)
      const ly = crownCenter.y + r * Math.sin(phi) * Math.sin(theta) * 0.8 // 略微压扁
      const lz = crownCenter.z + r * Math.cos(phi)

      const clusterSize = 1.5 + Math.random() * 2
      const cluster = new THREE.Mesh(
        new THREE.SphereGeometry(clusterSize, 8, 8),
        leafMat
      )
      cluster.position.set(lx, ly, lz)
      cluster.castShadow = true
      treeGroup.add(cluster)
    }

    // 添加一些突出的枝条（没有叶子）
    for (let i = 0; i < 3; i++) {
      const twig = new THREE.Mesh(
        new THREE.CylinderGeometry(0.05, 0.1, 2 + Math.random() * 2, 4),
        trunkMat
      )
      twig.position.set(
        crownCenter.x + (Math.random() - 0.5) * 4,
        crownCenter.y - 1,
        crownCenter.z + (Math.random() - 0.5) * 4
      )
      twig.rotation.set(
        (Math.random() - 0.5) * 1,
        Math.random() * Math.PI * 2,
        (Math.random() - 0.5) * 1
      )
      treeGroup.add(twig)
    }

    group.add(treeGroup)
  }

  // 创建城市建筑
  function createCityBuildings(group, parkingWidth, parkingDepth, streetWidth) {
    // 商业建筑位置
    const buildingPositions = [
      // 东南角商业区
      { x: parkingWidth / 2 + streetWidth + 100, z: parkingDepth / 2 + streetWidth + 100, type: 'commercial' },
      // 西南角住宅区
      { x: -parkingWidth / 2 - streetWidth - 100, z: parkingDepth / 2 + streetWidth + 100, type: 'residential' },
      // 东北角办公楼
      { x: parkingWidth / 2 + streetWidth + 100, z: -parkingDepth / 2 - streetWidth - 100, type: 'office' },
      // 西北角商场
      { x: -parkingWidth / 2 - streetWidth - 100, z: -parkingDepth / 2 - streetWidth - 100, type: 'mall' }
    ]

    buildingPositions.forEach(pos => {
      createDetailedBuilding(group, pos.x, pos.z, pos.type)
    })
  }

  // 创建精致建筑 - 带分层、檐口、凹凸
  function createDetailedBuilding(group, x, z, type) {
    let width, depth, height, baseColor, trimColor

    switch (type) {
      case 'commercial':
        width = 80
        depth = 60
        height = 40
        baseColor = 0xc4b49a
        trimColor = 0x8b7355
        break
      case 'residential':
        width = 60
        depth = 60
        height = 60
        baseColor = 0xb8b8b8
        trimColor = 0x7a7a7a
        break
      case 'office':
        width = 70
        depth = 70
        height = 80
        baseColor = 0x9ca8b8
        trimColor = 0x5a6a7a
        break
      case 'mall':
        width = 120
        depth = 80
        height = 25
        baseColor = 0xd4a574
        trimColor = 0xa67c52
        break
    }

    // 创建建筑主体 - 分层设计
    const floors = Math.floor(height / 12)
    const floorHeight = height / floors

    for (let f = 0; f < floors; f++) {
      const floorY = f * floorHeight + floorHeight / 2

      // 楼层主体
      const floorGeo = new THREE.BoxGeometry(width, floorHeight - 0.5, depth)
      const floorMat = new THREE.MeshLambertMaterial({
        color: baseColor,
        polygonOffset: true,
        polygonOffsetFactor: 1,
        polygonOffsetUnits: 1
      })
      const floor = new THREE.Mesh(floorGeo, floorMat)
      floor.position.set(x, floorY, z)
      floor.castShadow = true
      floor.receiveShadow = true
      group.add(floor)

      // 楼层分隔线（檐口）
      const trimGeo = new THREE.BoxGeometry(width + 2, 0.5, depth + 2)
      const trimMat = new THREE.MeshLambertMaterial({ color: trimColor })
      const trim = new THREE.Mesh(trimGeo, trimMat)
      trim.position.set(x, floorY + floorHeight / 2, z)
      trim.castShadow = true
      group.add(trim)

      // 添加窗户
      createFloorWindows(group, x, z, width, depth, floorY, floorHeight, type)

      // 添加空调外机（随机）
      if (f > 0 && Math.random() > 0.5) {
        createACUnits(group, x, z, width, depth, floorY, floorHeight)
      }
    }

    // 屋顶设备
    createRooftopEquipment(group, x, z, width, height, depth)

    // 入口
    createBuildingEntrance(group, x, z, width, depth, type, height)
  }

  // 创建楼层窗户
  function createFloorWindows(group, x, z, width, depth, floorY, floorHeight, type) {
    const windowMat = new THREE.MeshLambertMaterial({
      color: 0x3a4a5a,
      transparent: true,
      opacity: 0.85
    })
    const frameMat = new THREE.MeshLambertMaterial({ color: 0x4a4a4a })

    const windowW = 4
    const windowH = floorHeight * 0.7
    const windowCount = Math.floor(width / 12)

    // 前面窗户
    for (let i = 0; i < windowCount; i++) {
      const winX = x - width / 2 + 8 + i * 12

      // 窗框
      const frame = new THREE.Mesh(
        new THREE.BoxGeometry(windowW + 0.5, windowH + 0.5, 0.3),
        frameMat
      )
      frame.position.set(winX, floorY, z + depth / 2 + 0.15)
      group.add(frame)

      // 玻璃
      const glass = new THREE.Mesh(
        new THREE.BoxGeometry(windowW, windowH, 0.2),
        windowMat
      )
      glass.position.set(winX, floorY, z + depth / 2 + 0.2)
      group.add(glass)

      // 窗台
      const sill = new THREE.Mesh(
        new THREE.BoxGeometry(windowW + 1, 0.3, 1),
        frameMat
      )
      sill.position.set(winX, floorY - windowH / 2 - 0.2, z + depth / 2 + 0.5)
      sill.castShadow = true
      group.add(sill)
    }
  }

  // 创建空调外机
  function createACUnits(group, x, z, width, depth, floorY, floorHeight) {
    const acMat = new THREE.MeshLambertMaterial({ color: 0xdddddd })
    const acCount = Math.floor(Math.random() * 3)

    for (let i = 0; i < acCount; i++) {
      const side = Math.random() > 0.5 ? 1 : -1
      const acX = x + side * (width / 2 + 1)
      const acZ = z + (Math.random() - 0.5) * depth * 0.6

      // 外机主体
      const ac = new THREE.Mesh(
        new THREE.BoxGeometry(1.5, 1.2, 2),
        acMat
      )
      ac.position.set(acX, floorY + 1, acZ)
      ac.castShadow = true
      group.add(ac)

      // 支架
      const bracket = new THREE.Mesh(
        new THREE.BoxGeometry(0.2, 0.8, 1.5),
        new THREE.MeshLambertMaterial({ color: 0x555555 })
      )
      bracket.position.set(acX - side * 0.8, floorY + 0.4, acZ)
      group.add(bracket)
    }
  }

  // 创建屋顶设备
  function createRooftopEquipment(group, x, z, width, height, depth) {
    const roofY = height + 2

    // 电梯机房
    const elevatorRoom = new THREE.Mesh(
      new THREE.BoxGeometry(15, 8, 15),
      new THREE.MeshLambertMaterial({ color: 0x888888 })
    )
    elevatorRoom.position.set(x + width / 4, roofY + 4, z + depth / 4)
    elevatorRoom.castShadow = true
    group.add(elevatorRoom)

    // 水箱
    const waterTank = new THREE.Mesh(
      new THREE.CylinderGeometry(6, 6, 5, 16),
      new THREE.MeshLambertMaterial({ color: 0x6699cc })
    )
    waterTank.position.set(x - width / 3, roofY + 2.5, z - depth / 3)
    waterTank.castShadow = true
    group.add(waterTank)

    // 空调机组
    for (let i = 0; i < 3; i++) {
      const unit = new THREE.Mesh(
        new THREE.BoxGeometry(8, 3, 4),
        new THREE.MeshLambertMaterial({ color: 0x999999 })
      )
      unit.position.set(x + (i - 1) * 15, roofY + 1.5, z - depth / 4)
      unit.castShadow = true
      group.add(unit)
    }

    // 天线/避雷针
    const antenna = new THREE.Mesh(
      new THREE.CylinderGeometry(0.1, 0.3, 15, 8),
      new THREE.MeshLambertMaterial({ color: 0x888888 })
    )
    antenna.position.set(x, roofY + 7.5, z)
    group.add(antenna)
  }

  // 创建建筑入口
  function createBuildingEntrance(group, x, z, width, depth, type, height) {
    const doorFrameMat = new THREE.MeshLambertMaterial({ color: 0x3a3a3a })
    const doorMat = new THREE.MeshLambertMaterial({ color: 0x2a2a2a })

    // 入口雨棚
    const canopy = new THREE.Mesh(
      new THREE.BoxGeometry(20, 0.5, 8),
      new THREE.MeshLambertMaterial({ color: 0x555555 })
    )
    canopy.position.set(x, 6, z + depth / 2 + 3)
    canopy.castShadow = true
    group.add(canopy)

    // 雨棚支架
    for (let side = -1; side <= 1; side += 2) {
      const support = new THREE.Mesh(
        new THREE.CylinderGeometry(0.3, 0.3, 6, 8),
        new THREE.MeshLambertMaterial({ color: 0x444444 })
      )
      support.position.set(x + side * 8, 3, z + depth / 2 + 3)
      group.add(support)
    }

    // 门
    const door = new THREE.Mesh(
      new THREE.BoxGeometry(8, 5, 0.5),
      doorMat
    )
    door.position.set(x, 2.5, z + depth / 2 + 0.25)
    group.add(door)

    // 门框
    const doorFrame = new THREE.Mesh(
      new THREE.BoxGeometry(9, 5.5, 0.8),
      doorFrameMat
    )
    doorFrame.position.set(x, 2.75, z + depth / 2 + 0.1)
    group.add(doorFrame)

    // 添加建筑标识
    if (type === 'commercial' || type === 'mall') {
      const sign = createBuildingSign(type === 'mall' ? '购物中心' : '商业大厦')
      sign.position.set(x, height + 5, z + depth / 2 + 2)
      group.add(sign)
    }
  }

  // 创建建筑标识
  function createBuildingSign(text) {
    const canvas = document.createElement('canvas')
    const ctx = canvas.getContext('2d')
    canvas.width = 512
    canvas.height = 128

    ctx.fillStyle = '#1e3a5f'
    ctx.fillRect(0, 0, canvas.width, canvas.height)

    ctx.strokeStyle = '#ffffff'
    ctx.lineWidth = 4
    ctx.strokeRect(4, 4, canvas.width - 8, canvas.height - 8)

    ctx.font = 'bold 48px Arial'
    ctx.fillStyle = '#ffffff'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText(text, canvas.width / 2, canvas.height / 2)

    const texture = new THREE.CanvasTexture(canvas)
    const material = new THREE.MeshBasicMaterial({
      map: texture,
      transparent: true,
      side: THREE.DoubleSide
    })

    const geometry = new THREE.PlaneGeometry(30, 7.5)
    return new THREE.Mesh(geometry, material)
  }

  // 创建街道设施
  function createStreetFacilities(group, parkingWidth, parkingDepth, streetWidth) {
    // 垃圾桶
    const trashCanPositions = [
      { x: parkingWidth / 2 + streetWidth + 20, z: parkingDepth / 2 + 30 },
      { x: -parkingWidth / 2 - streetWidth - 20, z: parkingDepth / 2 + 30 },
      { x: parkingWidth / 2 + streetWidth + 20, z: -parkingDepth / 2 - 30 },
      { x: -parkingWidth / 2 - streetWidth - 20, z: -parkingDepth / 2 - 30 }
    ]

    trashCanPositions.forEach(pos => {
      createTrashCan(group, pos.x, pos.z)
    })

    // 长椅
    const benchPositions = [
      { x: parkingWidth / 2 + streetWidth + 35, z: parkingDepth / 2 + 50, rot: 0 },
      { x: -parkingWidth / 2 - streetWidth - 35, z: parkingDepth / 2 + 50, rot: 0 },
      { x: 0, z: parkingDepth / 2 + streetWidth + 80, rot: Math.PI / 2 }
    ]

    benchPositions.forEach(pos => {
      createBench(group, pos.x, pos.z, pos.rot)
    })

    // 路灯（街道照明）
    const streetLightPositions = [
      { x: parkingWidth / 2 + streetWidth / 2, z: parkingDepth / 2 + streetWidth + 40 },
      { x: -parkingWidth / 2 - streetWidth / 2, z: parkingDepth / 2 + streetWidth + 40 },
      { x: parkingWidth / 2 + streetWidth + 40, z: 0 },
      { x: -parkingWidth / 2 - streetWidth - 40, z: 0 }
    ]

    streetLightPositions.forEach(pos => {
      createStreetLight(group, pos.x, pos.z)
    })
  }

  // 创建垃圾桶
  function createTrashCan(group, x, z) {
    const canMat = new THREE.MeshLambertMaterial({ color: 0x2d5a3d })

    const can = new THREE.Mesh(
      new THREE.CylinderGeometry(1, 1, 3, 12),
      canMat
    )
    can.position.set(x, 1.5, z)
    can.castShadow = true
    group.add(can)

    // 盖子
    const lid = new THREE.Mesh(
      new THREE.CylinderGeometry(1.1, 1, 0.3, 12),
      new THREE.MeshLambertMaterial({ color: 0x1a3d26 })
    )
    lid.position.set(x, 3.15, z)
    group.add(lid)
  }

  // 创建长椅
  function createBench(group, x, z, rotation) {
    const woodMat = new THREE.MeshLambertMaterial({ color: 0x8b4513 })
    const metalMat = materials.value.metal

    const benchGroup = new THREE.Group()

    // 座椅
    const seat = new THREE.Mesh(
      new THREE.BoxGeometry(8, 0.3, 2),
      woodMat
    )
    seat.position.y = 1.5
    seat.castShadow = true
    benchGroup.add(seat)

    // 靠背
    const back = new THREE.Mesh(
      new THREE.BoxGeometry(8, 2, 0.2),
      woodMat
    )
    back.position.set(0, 2.5, -0.9)
    back.rotation.x = -0.1
    back.castShadow = true
    benchGroup.add(back)

    // 支架
    const legGeo = new THREE.BoxGeometry(0.3, 1.5, 2)
    const leg1 = new THREE.Mesh(legGeo, metalMat)
    leg1.position.set(-3.5, 0.75, 0)
    benchGroup.add(leg1)

    const leg2 = new THREE.Mesh(legGeo, metalMat)
    leg2.position.set(3.5, 0.75, 0)
    benchGroup.add(leg2)

    benchGroup.position.set(x, 0, z)
    benchGroup.rotation.y = rotation
    group.add(benchGroup)
  }

  // 创建街道照明灯
  function createStreetLight(group, x, z) {
    const poleMat = materials.value.metal

    const pole = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.4, 10, 12),
      poleMat
    )
    pole.position.set(x, 5, z)
    pole.castShadow = true
    group.add(pole)

    // 灯臂
    const arm = new THREE.Mesh(
      new THREE.BoxGeometry(4, 0.3, 0.3),
      poleMat
    )
    arm.position.set(x + 2, 9.5, z)
    group.add(arm)

    // 灯具
    const lamp = new THREE.Mesh(
      new THREE.BoxGeometry(1.5, 0.4, 0.8),
      new THREE.MeshBasicMaterial({ color: 0xffffee })
    )
    lamp.position.set(x + 4, 9.3, z)
    group.add(lamp)
  }

  // 创建交通标志
  function createTrafficSigns(group, parkingWidth, parkingDepth, streetWidth) {
    // 停车让行标志
    const stopSignPositions = [
      { x: 0, z: parkingDepth / 2 + streetWidth + 20, type: 'parking' },
      { x: parkingWidth / 2 + streetWidth + 20, z: 0, type: 'direction' }
    ]

    stopSignPositions.forEach(pos => {
      createTrafficSign(group, pos.x, pos.z, pos.type)
    })
  }

  // 创建交通标志
  function createTrafficSign(group, x, z, type) {
    const poleMat = materials.value.metal

    const pole = new THREE.Mesh(
      new THREE.CylinderGeometry(0.15, 0.15, 6, 8),
      poleMat
    )
    pole.position.set(x, 3, z)
    pole.castShadow = true
    group.add(pole)

    let signMesh

    if (type === 'parking') {
      // 蓝底白P停车标志
      const signGeo = new THREE.CircleGeometry(2, 32)
      const signMat = new THREE.MeshBasicMaterial({ color: 0x1e40af })
      signMesh = new THREE.Mesh(signGeo, signMat)
      signMesh.position.set(x, 6, z)
      signMesh.rotation.x = -0.2
      group.add(signMesh)

      // P文字
      const label = createSignLabel('P', '#ffffff')
      label.position.set(x, 6, z + 0.1)
      label.rotation.x = -0.2
      group.add(label)
    } else {
      // 方向指示牌
      const signGeo = new THREE.BoxGeometry(8, 3, 0.2)
      const signMat = new THREE.MeshLambertMaterial({ color: 0x1e40af })
      signMesh = new THREE.Mesh(signGeo, signMat)
      signMesh.position.set(x, 6, z)
      group.add(signMesh)

      // 文字
      const label = createSignLabel('停车场', '#ffffff', 48)
      label.position.set(x, 6, z + 0.15)
      group.add(label)
    }
  }

  // 创建街道车辆
  function createStreetVehicles(group, parkingWidth, parkingDepth, streetWidth) {
    // 路边停放的车辆
    const parkedCarPositions = [
      { x: parkingWidth / 2 + streetWidth - 30, z: parkingDepth / 2 + streetWidth / 2, type: 'sedan' },
      { x: parkingWidth / 2 + streetWidth - 60, z: parkingDepth / 2 + streetWidth / 2, type: 'suv' },
      { x: -parkingWidth / 2 - streetWidth + 30, z: parkingDepth / 2 + streetWidth / 2, type: 'sedan' },
      { x: -parkingWidth / 2 - streetWidth + 60, z: parkingDepth / 2 + streetWidth / 2, type: 'van' }
    ]

    parkedCarPositions.forEach(pos => {
      createSimpleCar(group, pos.x, pos.z, pos.type, Math.random() > 0.5 ? 0 : Math.PI)
    })
  }

  // 创建简化版车辆
  function createSimpleCar(group, x, z, type, rotation) {
    const carColors = [0x333333, 0x666666, 0x999999, 0xffffff, 0x1a3a5c, 0x5c0a0a]
    const color = carColors[Math.floor(Math.random() * carColors.length)]
    const carMat = new THREE.MeshLambertMaterial({ color })

    let width, length, height

    switch (type) {
      case 'sedan':
        width = 8
        length = 18
        height = 5
        break
      case 'suv':
        width = 9
        length = 20
        height = 7
        break
      case 'van':
        width = 9
        length = 22
        height = 8
        break
    }

    // 车身
    const body = new THREE.Mesh(
      new THREE.BoxGeometry(width, height * 0.6, length),
      carMat
    )
    body.position.set(x, height * 0.3, z)
    body.castShadow = true
    group.add(body)

    // 车顶
    const roof = new THREE.Mesh(
      new THREE.BoxGeometry(width * 0.8, height * 0.4, length * 0.6),
      carMat
    )
    roof.position.set(x, height * 0.8, z)
    roof.castShadow = true
    group.add(roof)

    // 窗户
    const windowMat = new THREE.MeshBasicMaterial({ color: 0x1a1a1a })
    const windshield = new THREE.Mesh(
      new THREE.BoxGeometry(width * 0.75, height * 0.35, length * 0.55),
      windowMat
    )
    windshield.position.set(x, height * 0.8, z)
    group.add(windshield)

    // 车轮
    const wheelMat = new THREE.MeshLambertMaterial({ color: 0x111111 })
    const wheelPositions = [
      { x: x - width / 2 + 1, z: z - length / 2 + 4 },
      { x: x + width / 2 - 1, z: z - length / 2 + 4 },
      { x: x - width / 2 + 1, z: z + length / 2 - 4 },
      { x: x + width / 2 - 1, z: z + length / 2 - 4 }
    ]

    wheelPositions.forEach(pos => {
      const wheel = new THREE.Mesh(
        new THREE.CylinderGeometry(1.5, 1.5, 0.8, 12),
        wheelMat
      )
      wheel.rotation.z = Math.PI / 2
      wheel.position.set(pos.x, 1.5, pos.z)
      wheel.castShadow = true
      group.add(wheel)
    })
  }

  // 创建街道细节
  function createStreetDetails(group, parkingWidth, parkingDepth, streetWidth) {
    // 井盖
    const manholePositions = [
      { x: 20, z: parkingDepth / 2 + streetWidth / 2 },
      { x: -30, z: parkingDepth / 2 + streetWidth / 2 + 20 },
      { x: 50, z: parkingDepth / 2 + streetWidth / 2 - 15 },
      { x: parkingWidth / 2 + streetWidth / 2, z: 30 },
      { x: parkingWidth / 2 + streetWidth / 2 - 20, z: -20 }
    ]

    manholePositions.forEach(pos => {
      createManhole(group, pos.x, pos.z)
    })

    // 消防栓
    const hydrantPositions = [
      { x: parkingWidth / 2 + streetWidth + 15, z: parkingDepth / 2 + 40 },
      { x: -parkingWidth / 2 - streetWidth - 15, z: -parkingDepth / 2 - 40 }
    ]

    hydrantPositions.forEach(pos => {
      createFireHydrant(group, pos.x, pos.z)
    })
  }

  // 创建井盖
  function createManhole(group, x, z) {
    const coverMat = new THREE.MeshLambertMaterial({ color: 0x444444 })

    const cover = new THREE.Mesh(
      new THREE.CylinderGeometry(2, 2, 0.1, 16),
      coverMat
    )
    cover.position.set(x, 0.15, z)
    cover.receiveShadow = true
    group.add(cover)

    // 井盖纹理细节
    const detailMat = new THREE.MeshBasicMaterial({ color: 0x333333 })
    for (let i = 0; i < 6; i++) {
      const angle = (i / 6) * Math.PI * 2
      const detail = new THREE.Mesh(
        new THREE.BoxGeometry(0.3, 0.05, 1.5),
        detailMat
      )
      detail.position.set(
        x + Math.cos(angle) * 1.2,
        0.21,
        z + Math.sin(angle) * 1.2
      )
      detail.rotation.y = angle
      group.add(detail)
    }
  }

  // 创建消防栓
  function createFireHydrant(group, x, z) {
    const hydrantMat = new THREE.MeshLambertMaterial({ color: 0xcc0000 })

    // 主体
    const body = new THREE.Mesh(
      new THREE.CylinderGeometry(0.8, 0.8, 4, 12),
      hydrantMat
    )
    body.position.set(x, 2, z)
    body.castShadow = true
    group.add(body)

    // 顶部
    const top = new THREE.Mesh(
      new THREE.SphereGeometry(0.8, 12, 6, 0, Math.PI * 2, 0, Math.PI / 2),
      hydrantMat
    )
    top.position.set(x, 4, z)
    group.add(top)

    // 接口
    const capMat = new THREE.MeshLambertMaterial({ color: 0x999999 })
    const cap1 = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.3, 0.8, 8),
      capMat
    )
    cap1.rotation.z = Math.PI / 2
    cap1.position.set(x + 0.8, 2.5, z)
    group.add(cap1)

    const cap2 = new THREE.Mesh(
      new THREE.CylinderGeometry(0.3, 0.3, 0.8, 8),
      capMat
    )
    cap2.rotation.z = Math.PI / 2
    cap2.position.set(x - 0.8, 2.5, z)
    group.add(cap2)
  }

  return { build }
}
