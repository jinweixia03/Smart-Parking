<template>
  <div class="loading-spinner" :class="{ 'fullscreen': fullscreen }">
    <div class="spinner-container">
      <div class="spinner-ring">
        <div></div>
        <div></div>
        <div></div>
        <div></div>
      </div>
      <div v-if="text" class="spinner-text">{{ text }}</div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  fullscreen: { type: Boolean, default: false },
  text: { type: String, default: '加载中...' }
})
</script>

<style scoped lang="scss">
.loading-spinner {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;

  &.fullscreen {
    position: fixed;
    inset: 0;
    background: rgba(255, 255, 255, 0.9);
    backdrop-filter: blur(4px);
    z-index: 9999;
  }
}

.spinner-container {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

.spinner-ring {
  display: inline-block;
  position: relative;
  width: 64px;
  height: 64px;

  div {
    box-sizing: border-box;
    display: block;
    position: absolute;
    width: 51px;
    height: 51px;
    margin: 6px;
    border: 4px solid #6366f1;
    border-radius: 50%;
    animation: spinner-ring 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
    border-color: #6366f1 transparent transparent transparent;

    &:nth-child(1) { animation-delay: -0.45s; }
    &:nth-child(2) { animation-delay: -0.3s; }
    &:nth-child(3) { animation-delay: -0.15s; }
  }
}

.spinner-text {
  font-size: 14px;
  color: #64748b;
  font-weight: 500;
}

@keyframes spinner-ring {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
