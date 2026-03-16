<template>
  <teleport to="body">
    <transition name="dialog">
      <div v-if="modelValue" class="motion-dialog-overlay" @click="handleOverlayClick">
        <transition name="dialog-content">
          <div
            v-if="modelValue"
            class="motion-dialog"
            :style="{ width }"
            @click.stop
          >
            <div class="dialog-header">
              <div class="dialog-title">
                <h3>{{ title }}</h3>
                <p v-if="subtitle">{{ subtitle }}</p>
              </div>
              <button class="close-btn" @click="handleClose">
                <el-icon><Close /></el-icon>
              </button>
            </div>
            <div class="dialog-body">
              <slot />
            </div>
          </div>
        </transition>
      </div>
    </transition>
  </teleport>
</template>

<script setup>
const props = defineProps({
  modelValue: { type: Boolean, default: false },
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' },
  width: { type: String, default: '500px' },
  closeOnClickOverlay: { type: Boolean, default: true }
})

const emit = defineEmits(['update:modelValue', 'close'])

const handleClose = () => {
  emit('update:modelValue', false)
  emit('close')
}

const handleOverlayClick = () => {
  if (props.closeOnClickOverlay) {
    handleClose()
  }
}
</script>

<style scoped lang="scss">
.motion-dialog-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15, 23, 42, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 24px;
}

.motion-dialog {
  background: white;
  border-radius: 24px;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;

  .dialog-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    padding: 24px 24px 0;

    .dialog-title {
      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1e293b;
      }

      p {
        font-size: 14px;
        color: #64748b;
        margin-top: 4px;
      }
    }

    .close-btn {
      width: 36px;
      height: 36px;
      border: none;
      background: #f1f5f9;
      border-radius: 10px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      color: #64748b;
      transition: all 0.3s ease;

      &:hover {
        background: #e2e8f0;
        color: #1e293b;
        transform: rotate(90deg);
      }
    }
  }

  .dialog-body {
    padding: 24px;
    overflow-y: auto;
  }
}

// 遮罩层动画
.dialog-enter-active,
.dialog-leave-active {
  transition: opacity 0.3s ease;
}

.dialog-enter-from,
.dialog-leave-to {
  opacity: 0;
}

// 内容动画
.dialog-content-enter-active {
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.dialog-content-leave-active {
  transition: all 0.3s ease;
}

.dialog-content-enter-from {
  opacity: 0;
  transform: scale(0.9) translateY(20px);
}

.dialog-content-leave-to {
  opacity: 0;
  transform: scale(0.95);
}
</style>
