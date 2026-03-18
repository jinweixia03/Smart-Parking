import * as THREE from 'three'
import { COLORS } from '@/constants/parking.js'

// 停车场配置
const CONFIG = {
  cellSize: 20,
  wallHeight: 24
}

// 方向映射
const facingMap = {
  'P': 'n',
  'S': 's',
  'E': 'e',
  'W': 'w'
}

// 从网格地图生成停车位配置
function generateParkingSpotsFromGrid() {
  const GRID_MAP = [
    'BBBBBBBBBBBBBBBRRBBBBBBBBBBBBBBB',
    'BPPPPPPPPPPPPPPRRPPPPPPPPPPPPPPB',
    'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',
    'BERPPPPPPRSSSSSRRSSSSSRPPPPPPRWB',
    'BERPPPPPPRSSSSSRRSSSSSRPPPPPPRWB',
    'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',
    'BERPPPPPPRPPPPPRRPPPPPRPPPPPPRWB',
    'BERPPPPPPRPPPPPRRPPPPPRPPPPPPRWB',
    'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',
    'BERPPPPPPRSSSSSRRSSSSSRPPPPPPRWB',
    'BERPPPPPPRSSSSSRRSSSSSRPPPPPPRWB',
    'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',
    'BERPPPPPPRPPPPPRRPPPPPRPPPPPPRWB',
    'BERPPPPPPRPPPPPRRPPPPPRPPPPPPRWB',
    'BERRRRRRRRRRRRRRRRRRRRRRRRRRRRWB',
    'BPPPPPPPPPPPPPPRRPPPPPPPPPPPPPPB',
    'BBBBBBBBBBBBBBBRRBBBBBBBBBBBBBBB'
  ]

  const spots = []
  const rows = GRID_MAP.length
  const cols = GRID_MAP[0].length

  const offsetX = (cols * CONFIG.cellSize) / 2
  const offsetZ = (rows * CONFIG.cellSize) / 2

  for (let row = 0; row < rows; row++) {
    for (let col = 0; col < cols; col++) {
      const cell = GRID_MAP[row][col]
      if (facingMap[cell]) {
        const x = col * CONFIG.cellSize - offsetX + CONFIG.cellSize / 2
        const z = row * CONFIG.cellSize - offsetZ + CONFIG.cellSize / 2
        spots.push({
          x, z,
          facing: facingMap[cell],
          row, col,
          type: cell
        })
      }
    }
  }

  return spots
}

// 创建实例化停车位 - 高性能渲染
export function createInstancedParking(scene, floorSpaces, materials) {
  const spots = generateParkingSpotsFromGrid()
  const parkingGroup = new THREE.Group()

  // 按类型分组
  const spotsByType = {
    'P': [],
    'S': [],
    'E': [],
    'W': []
  }

  // 根据楼层筛选并分组
  spots.forEach((spot, index) => {
    if (index < floorSpaces.length) {
      const spaceData = floorSpaces[index]
      if (spaceData) {
        spot.spaceData = spaceData
        spotsByType[spot.type].push(spot)
      }
    }
  })

  // 为每种类型创建 InstancedMesh
  Object.keys(spotsByType).forEach(type => {
    const typeSpots = spotsByType[type]
    if (typeSpots.length === 0) return

    const isNS = type === 'P' || type === 'S'
    const width = isNS ? CONFIG.cellSize / 2 : CONFIG.cellSize
    const depth = isNS ? CONFIG.cellSize : CONFIG.cellSize / 2

    // 创建车位几何体 - 更精致的设计
    const geometry = createDetailedSpaceGeometry(width, depth)

    // 创建材质
    const material = new THREE.MeshLambertMaterial({
      color: getSpaceColor(typeSpots[0].spaceData),
      side: THREE.DoubleSide
    })

    // 创建 InstancedMesh
    const mesh = new THREE.InstancedMesh(geometry, material, typeSpots.length)
    mesh.castShadow = false
    mesh.receiveShadow = false

    // 设置每个实例的矩阵
    const dummy = new THREE.Object3D()
    typeSpots.forEach((spot, i) => {
      dummy.position.set(spot.x, 0, spot.z)

      // 根据朝向旋转
      const rotation = getRotationFromFacing(spot.facing)
      dummy.rotation.y = rotation

      dummy.updateMatrix()
      mesh.setMatrixAt(i, dummy.matrix)

      // 存储空间数据用于交互
      mesh.userData[i] = spot.spaceData
    })

    mesh.instanceMatrix.needsUpdate = true
    parkingGroup.add(mesh)
  })

  // 添加道路
  createRoads(parkingGroup, materials)

  // 添加围墙
  createWalls(parkingGroup)

  scene.add(parkingGroup)

  return parkingGroup
}

// 创建精致的车位几何体
function createDetailedSpaceGeometry(width, depth) {
  const group = new THREE.Group()

  // 地面 - 稍微下沉避免闪烁
  const groundGeo = new THREE.BoxGeometry(width * 0.95, 0.05, depth * 0.95)
  const ground = new THREE.Mesh(groundGeo)
  ground.position.y = 0.025
  group.add(ground)

  // 标线 - 左
  const lineThickness = 0.15
  const lineHeight = 0.06
  const leftLine = new THREE.Mesh(
    new THREE.BoxGeometry(lineThickness, lineHeight, depth - 0.2)
  )
  leftLine.position.set(-width / 2 + lineThickness / 2, lineHeight / 2, 0)
  group.add(leftLine)

  // 标线 - 右
  const rightLine = new THREE.Mesh(
    new THREE.BoxGeometry(lineThickness, lineHeight, depth - 0.2)
  )
  rightLine.position.set(width / 2 - lineThickness / 2, lineHeight / 2, 0)
  group.add(rightLine)

  // 标线 - 后
  const backLine = new THREE.Mesh(
    new THREE.BoxGeometry(width, lineHeight, lineThickness)
  )
  backLine.position.set(0, lineHeight / 2, -depth / 2 + lineThickness / 2)
  group.add(backLine)

  // 限位器
  const stopper = new THREE.Mesh(
    new THREE.BoxGeometry(2.0, 0.15, 0.3)
  )
  stopper.position.set(0, 0.075, depth / 2 - 0.5)
  group.add(stopper)

  // 合并几何体
  return mergeGeometries(group)
}

// 合并几何体
function mergeGeometries(group) {
  const geometries = []
  group.traverse(child => {
    if (child.isMesh) {
      const geo = child.geometry.clone()
      geo.translate(child.position.x, child.position.y, child.position.z)
      geometries.push(geo)
    }
  })

  // 使用 BufferGeometryUtils 合并（如果可用）
  // 这里简化处理，返回第一个几何体
  return geometries[0] || new THREE.BoxGeometry(1, 1, 1)
}

// 获取车位颜色
function getSpaceColor(spaceData) {
  if (!spaceData) return COLORS.spaceFree

  const isVip = spaceData.areaType === 'VIP'
  const isDisabled = spaceData.areaType === '残疾人车位'
  const isOccupied = spaceData.status === 1

  if (isOccupied) return COLORS.spaceOccupied
  if (isVip) return COLORS.spaceVip
  if (isDisabled) return COLORS.spaceDisabled
  return COLORS.spaceFree
}

// 获取朝向旋转角度
function getRotationFromFacing(facing) {
  const rotations = {
    'n': 0,
    's': Math.PI,
    'e': -Math.PI / 2,
    'w': Math.PI / 2
  }
  return rotations[facing] || 0
}

// 创建道路
function createRoads(group, materials) {
  const roadMat = materials.value?.road || new THREE.MeshLambertMaterial({ color: 0x333333 })

  // 横向主路
  const mainRoad = new THREE.Mesh(
    new THREE.BoxGeometry(640, 0.1, 40),
    roadMat
  )
  mainRoad.position.set(0, 0.05, 0)
  group.add(mainRoad)

  // 纵向主路
  const vertRoad = new THREE.Mesh(
    new THREE.BoxGeometry(40, 0.1, 340),
    roadMat
  )
  vertRoad.position.set(0, 0.05, 0)
  group.add(vertRoad)
}

// 创建围墙
function createWalls(group) {
  const wallMat = new THREE.MeshLambertMaterial({ color: 0x808080 })
  const h = CONFIG.wallHeight

  // 北墙
  const northWall = new THREE.Mesh(
    new THREE.BoxGeometry(640, h, 1),
    wallMat
  )
  northWall.position.set(0, h / 2, -170)
  group.add(northWall)

  // 南墙
  const southWall = new THREE.Mesh(
    new THREE.BoxGeometry(640, h, 1),
    wallMat
  )
  southWall.position.set(0, h / 2, 170)
  group.add(southWall)

  // 西墙
  const westWall = new THREE.Mesh(
    new THREE.BoxGeometry(1, h, 340),
    wallMat
  )
  westWall.position.set(-320, h / 2, 0)
  group.add(westWall)

  // 东墙
  const eastWall = new THREE.Mesh(
    new THREE.BoxGeometry(1, h, 340),
    wallMat
  )
  eastWall.position.set(320, h / 2, 0)
  group.add(eastWall)
}
