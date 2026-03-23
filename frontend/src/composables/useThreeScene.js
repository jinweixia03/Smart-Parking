import { ref, shallowRef, onMounted, onUnmounted } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { CAMERA_CONFIG, LIGHT_CONFIG } from '@/constants/parking.js'
import { createMaterials, createTextSprite } from '@/utils/threeUtils.js'

export function useThreeScene(containerRef, onSpaceClick) {
  let camera, renderer, controls
  let parkingGroup = null
  let raycaster, mouse
  let animationId = null
  let hoveredMesh = null
  let selectedMesh = null

  const scene = shallowRef(null)
  const isLoading = ref(false)
  const materials = ref({})
  const spaceMeshes = new Map()
  const carMeshes = new Map()

  function init() {
    if (!containerRef.value) return

    const container = containerRef.value
    const width = container.clientWidth
    const height = container.clientHeight

    // 场景 - 使用纯色背景
    scene.value = new THREE.Scene()
    scene.value.background = new THREE.Color(0xdfe9f3)

    // 场景雾效 - 增加深度感
    scene.value.fog = new THREE.FogExp2(0xdfe9f3, 0.0005)

    // 透视相机 - GTA使用透视而非正交
    // 场景尺寸: 32×20m = 640m 宽, 17×20m = 340m 深 (规模放大2倍)
    const aspect = width / height
    camera = new THREE.PerspectiveCamera(45, aspect, 10, 3000)
    camera.position.set(125, 100, 125)  // 超近距离观看
    camera.lookAt(0, 0, 0)

    // 渲染器 - 照片级真实渲染设置
    renderer = new THREE.WebGLRenderer({
      antialias: true,
      alpha: false,
      powerPreference: 'high-performance',
      stencil: false,
      depth: true
    })
    renderer.setSize(width, height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    // 阴影设置 - 高质量软阴影
    renderer.shadowMap.enabled = true
    renderer.shadowMap.type = THREE.PCFSoftShadowMap
    renderer.shadowMap.autoUpdate = true

    // 色调映射 - 让高光和阴影更真实
    renderer.toneMapping = THREE.ACESFilmicToneMapping
    renderer.toneMappingExposure = 1.0

    // 颜色空间
    renderer.outputColorSpace = THREE.SRGBColorSpace

    container.appendChild(renderer.domElement)

    // 控制器
    setupControls()

    // 灯光
    setupLights()

    // 材质
    materials.value = createMaterials()

    // 射线检测
    raycaster = new THREE.Raycaster()
    mouse = new THREE.Vector2()

    // 事件
    renderer.domElement.addEventListener('click', handleClick)
    renderer.domElement.addEventListener('mousemove', handleMouseMove)
    window.addEventListener('resize', handleResize)

    animate()
  }

  function setupControls() {
    controls = new OrbitControls(camera, renderer.domElement)
    controls.enableDamping = true
    controls.dampingFactor = 0.05

    // 严格限制视角，防止看到背景（加强3倍）
    controls.enableRotate = true
    controls.minPolarAngle = Math.PI / 3   // 最小仰角（60度），严格限制
    controls.maxPolarAngle = Math.PI / 2.5  // 最大仰角（72度），几乎不能仰视
    controls.minDistance = 125  // 固定最小距离
    controls.maxDistance = 150   // 固定最大距离，极窄范围

    // 初始视角
    controls.target.set(0, 0, 0)

    controls.mouseButtons = {
      LEFT: THREE.MOUSE.ROTATE,
      MIDDLE: THREE.MOUSE.DOLLY,
      RIGHT: THREE.MOUSE.PAN
    }

    // 限制右键平移只能水平移动（平行于地面）
    controls.screenSpacePanning = false
  }

  function setupLights() {
    // 半球光 - 模拟天空和地面的自然环境光
    // 天空色偏蓝，地面色偏暖，创造自然光照
    const hemiLight = new THREE.HemisphereLight(0x87ceeb, 0xe0c8a0, 0.6)
    hemiLight.position.set(0, 200, 0)
    scene.value.add(hemiLight)

    // 主光源（太阳光）- 偏暖色模拟真实阳光
    const sunLight = new THREE.DirectionalLight(0xfff5e6, 1.5)
    sunLight.position.set(300, 400, 200)
    sunLight.castShadow = true

    // 高质量阴影设置
    sunLight.shadow.mapSize.width = 4096
    sunLight.shadow.mapSize.height = 4096
    sunLight.shadow.camera.near = 10
    sunLight.shadow.camera.far = 2000
    sunLight.shadow.camera.left = -800
    sunLight.shadow.camera.right = 800
    sunLight.shadow.camera.top = 800
    sunLight.shadow.camera.bottom = -800
    sunLight.shadow.bias = -0.0001
    sunLight.shadow.radius = 2  // 软阴影半径
    scene.value.add(sunLight)

    // 补光 - 模拟天空散射光（蓝色调）
    const fillLight = new THREE.DirectionalLight(0xcce0ff, 0.4)
    fillLight.position.set(-200, 100, -200)
    scene.value.add(fillLight)

    // 环境光 - 轻微提升整体亮度
    const ambientLight = new THREE.AmbientLight(0x404040, 0.2)
    scene.value.add(ambientLight)
  }

  function handleClick(event) {
    if (!camera || !raycaster || !scene.value) return

    const rect = renderer.domElement.getBoundingClientRect()
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

    raycaster.setFromCamera(mouse, camera)

    // 获取场景中所有的车位对象
    const allObjects = []
    scene.value.traverse(obj => {
      if (obj.userData && obj.userData.type === 'space') {
        allObjects.push(obj)
      }
    })

    if (allObjects.length === 0) return

    const intersects = raycaster.intersectObjects(allObjects, false)

    if (intersects.length > 0) {
      const space = intersects[0].object.userData.spaceData
      onSpaceClick(space)
    }
  }

  function handleMouseMove(event) {
    if (!camera || !raycaster || !scene.value) return

    const rect = renderer.domElement.getBoundingClientRect()
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1

    raycaster.setFromCamera(mouse, camera)

    // 获取场景中所有的车位对象
    const allObjects = []
    scene.value.traverse(obj => {
      if (obj.userData && obj.userData.type === 'space') {
        allObjects.push(obj)
      }
    })

    if (allObjects.length === 0) return

    const intersects = raycaster.intersectObjects(allObjects, false)
    const spaceObject = intersects[0] // 第一个相交的对象

    // 简化鼠标交互，避免材质操作错误
    if (spaceObject && spaceObject.object !== hoveredMesh) {
      hoveredMesh = spaceObject.object
      renderer.domElement.style.cursor = 'pointer'
    } else if (!spaceObject && hoveredMesh) {
      hoveredMesh = null
      renderer.domElement.style.cursor = 'default'
    }
  }

  function handleResize() {
    if (!camera || !renderer || !containerRef.value) return

    const width = containerRef.value.clientWidth
    const height = containerRef.value.clientHeight

    camera.aspect = width / height
    camera.updateProjectionMatrix()
    renderer.setSize(width, height)
  }

  function animate() {
    animationId = requestAnimationFrame(animate)
    if (controls) controls.update()

    // 指示灯脉冲效果 (简化，避免过多计算)
    // 禁用脉冲效果以减少GPU负担

    if (renderer && scene && camera) {
      renderer.render(scene.value, camera)
    }
  }

  function setSelectedMesh(mesh) {
    selectedMesh = mesh
  }

  function clearSelectedMesh() {
    selectedMesh = null
  }

  function resetCamera() {
    if (!camera || !controls) return
    camera.position.set(125, 100, 125)  // 同步新的默认相机位置
    camera.lookAt(0, 0, 0)
    controls.target.set(0, 0, 0)
    controls.update()
  }

  function toggleAutoRotate(enabled) {
    if (controls) {
      controls.autoRotate = enabled
    }
  }

  // 聚焦到指定车位位置
  function focusOnSpace(x, z, duration = 1000) {
    if (!camera || !controls) return

    console.log('focusOnSpace called:', x, z)

    // 保存原始限制
    const originalMinDistance = controls.minDistance
    const originalMaxDistance = controls.maxDistance

    // 临时放宽距离限制，允许相机移动到车位附近
    controls.minDistance = 50
    controls.maxDistance = 500

    // 计算目标相机位置（从斜上方俯视车位）
    // 使用与默认视角相同的相对偏移
    const offsetX = 60
    const offsetY = 80
    const offsetZ = 60

    const targetPosition = new THREE.Vector3(x + offsetX, offsetY, z + offsetZ)
    const targetLookAt = new THREE.Vector3(x, 0, z)

    console.log('Target camera position:', targetPosition.x, targetPosition.y, targetPosition.z)
    console.log('Target lookAt:', targetLookAt.x, targetLookAt.y, targetLookAt.z)

    // 保存起始位置
    const startPosition = camera.position.clone()
    const startTarget = controls.target.clone()

    // 动画开始时间
    const startTime = Date.now()

    function animateCamera() {
      const elapsed = Date.now() - startTime
      const progress = Math.min(elapsed / duration, 1)

      // 使用缓动函数使动画更平滑
      const easeProgress = 1 - Math.pow(1 - progress, 3) // easeOutCubic

      // 插值计算当前位置
      camera.position.lerpVectors(startPosition, targetPosition, easeProgress)
      controls.target.lerpVectors(startTarget, targetLookAt, easeProgress)

      // 每帧都更新控制器
      controls.update()

      if (progress < 1) {
        requestAnimationFrame(animateCamera)
      } else {
        // 动画完成后恢复原始限制
        controls.minDistance = originalMinDistance
        controls.maxDistance = originalMaxDistance
        controls.update()
        console.log('Camera animation completed')
      }
    }

    animateCamera()
  }

  function destroy() {
    if (animationId) cancelAnimationFrame(animationId)

    if (renderer) {
      renderer.domElement.removeEventListener('click', handleClick)
      renderer.domElement.removeEventListener('mousemove', handleMouseMove)
      window.removeEventListener('resize', handleResize)
      renderer.dispose()
    }

    spaceMeshes.clear()
    carMeshes.clear()
  }

  onMounted(() => {
    init()
    isLoading.value = false
  })
  onUnmounted(destroy)

  return {
    scene,
    camera,
    renderer,
    controls,
    parkingGroup,
    spaceMeshes,
    carMeshes,
    materials,
    isLoading,
    setSelectedMesh,
    clearSelectedMesh,
    resetCamera,
    toggleAutoRotate,
    focusOnSpace
  }
}
