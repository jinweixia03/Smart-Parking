<template>
  <span class="count-up">{{ displayValue }}</span>
</template>

<script setup>
import { ref, watch, onMounted } from 'vue'

const props = defineProps({
  start: { type: Number, default: 0 },
  end: { type: Number, required: true },
  duration: { type: Number, default: 2 },
  decimals: { type: Number, default: 0 },
  separator: { type: String, default: ',' }
})

const displayValue = ref('0')
let animationFrame = null

const animate = () => {
  const startTime = performance.now()
  const startValue = props.start
  const endValue = props.end
  const duration = props.duration * 1000

  const step = (currentTime) => {
    const elapsed = currentTime - startTime
    const progress = Math.min(elapsed / duration, 1)

    // Easing function (easeOutExpo)
    const easeProgress = progress === 1 ? 1 : 1 - Math.pow(2, -10 * progress)

    const currentValue = startValue + (endValue - startValue) * easeProgress

    displayValue.value = formatNumber(currentValue)

    if (progress < 1) {
      animationFrame = requestAnimationFrame(step)
    }
  }

  animationFrame = requestAnimationFrame(step)
}

const formatNumber = (num) => {
  const fixed = num.toFixed(props.decimals)
  const parts = fixed.split('.')
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, props.separator)
  return parts.join('.')
}

watch(() => props.end, () => {
  cancelAnimationFrame(animationFrame)
  animate()
})

onMounted(() => {
  animate()
})
</script>
