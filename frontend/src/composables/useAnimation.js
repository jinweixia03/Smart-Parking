import { ref, onMounted, onUnmounted } from 'vue'

/**
 * 数字滚动动画
 */
export function useCountUp(start, end, duration = 2000) {
  const current = ref(start)
  let animationFrame = null

  const animate = () => {
    const startTime = performance.now()

    const step = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const easeProgress = 1 - Math.pow(1 - progress, 3)

      current.value = Math.floor(start + (end - start) * easeProgress)

      if (progress < 1) {
        animationFrame = requestAnimationFrame(step)
      }
    }

    animationFrame = requestAnimationFrame(step)
  }

  onMounted(() => {
    if (start !== end) animate()
  })

  onUnmounted(() => {
    if (animationFrame) cancelAnimationFrame(animationFrame)
  })

  return current
}

/**
 * 渐入动画观察器
 */
export function useIntersectionObserver(options = {}) {
  const elementRef = ref(null)
  const isVisible = ref(false)

  onMounted(() => {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          isVisible.value = true
          observer.unobserve(entry.target)
        }
      })
    }, {
      threshold: 0.1,
      ...options
    })

    if (elementRef.value) {
      observer.observe(elementRef.value)
    }
  })

  return { elementRef, isVisible }
}

/**
 * 鼠标跟随效果
 */
export function useMouseFollow() {
  const x = ref(0)
  const y = ref(0)

  const handleMouseMove = (e) => {
    x.value = e.clientX
    y.value = e.clientY
  }

  onMounted(() => {
    window.addEventListener('mousemove', handleMouseMove)
  })

  onUnmounted(() => {
    window.removeEventListener('mousemove', handleMouseMove)
  })

  return { x, y }
}

/**
 * 防抖函数
 */
export function useDebounce(fn, delay = 300) {
  let timer = null

  return (...args) => {
    if (timer) clearTimeout(timer)
    timer = setTimeout(() => {
      fn.apply(this, args)
    }, delay)
  }
}

/**
 * 节流函数
 */
export function useThrottle(fn, limit = 300) {
  let inThrottle = false

  return (...args) => {
    if (!inThrottle) {
      fn.apply(this, args)
      inThrottle = true
      setTimeout(() => inThrottle = false, limit)
    }
  }
}
