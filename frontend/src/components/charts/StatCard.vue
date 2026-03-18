<template>
  <div class="stat-card" :class="{ 'has-trend': showTrend }" :style="cardStyle">
    <div class="card-bg">
      <div class="gradient-circle" :style="{ background: gradient }"></div>
    </div>

    <div class="card-content">
      <div class="card-header">
        <div class="icon-wrapper" :style="{ background: iconBg, color: color }">
          <el-icon size="24">
            <component :is="icon" />
          </el-icon>
        </div>
        <div v-if="showTrend" class="trend-badge" :class="trendType">
          <el-icon>
            <ArrowUp v-if="trendType === 'up'" />
            <ArrowDown v-else />
          </el-icon>
          <span>{{ trendValue }}%</span>
        </div>
      </div>

      <div class="card-body">
        <div class="stat-value" :style="{ color: valueColor }">
          <span class="prefix">{{ prefix }}</span>
          <CountUp :end="Number(value)" :duration="2" />
          <span class="suffix">{{ suffix }}</span>
        </div>
        <div class="stat-label">{{ label }}</div>
      </div>

      <div class="card-footer">
        <div class="progress-bar" v-if="progress !== undefined">
          <div class="progress-track">
            <div
              class="progress-fill"
              :style="{ width: progress + '%', background: gradient }"
            ></div>
          </div>
          <span class="progress-text">{{ progress }}%</span>
        </div>
        <div class="footer-text" v-else>{{ footerText }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import CountUp from './CountUp.vue'

const props = defineProps({
  icon: { type: String, required: true },
  value: { type: [Number, String], required: true },
  label: { type: String, required: true },
  prefix: { type: String, default: '' },
  suffix: { type: String, default: '' },
  color: { type: String, default: '#2563eb' },
  showTrend: { type: Boolean, default: false },
  trendType: { type: String, default: 'up' },
  trendValue: { type: [Number, String], default: 0 },
  progress: { type: Number, default: undefined },
  footerText: { type: String, default: '' }
})

const gradient = computed(() => `linear-gradient(135deg, ${props.color}, ${adjustColor(props.color, -20)})`)
const iconBg = computed(() => `${props.color}15`)
const valueColor = computed(() => props.color)

const cardStyle = computed(() => ({
  '--card-color': props.color
}))

const adjustColor = (color, amount) => {
  const num = parseInt(color.replace('#', ''), 16)
  const r = Math.max(0, Math.min(255, (num >> 16) + amount))
  const g = Math.max(0, Math.min(255, ((num >> 8) & 0x00FF) + amount))
  const b = Math.max(0, Math.min(255, (num & 0x0000FF) + amount))
  return `#${((r << 16) | (g << 8) | b).toString(16).padStart(6, '0')}`
}
</script>

<style scoped lang="scss">
.stat-card {
  position: relative;
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(20px) saturate(180%);
  -webkit-backdrop-filter: blur(20px) saturate(180%);
  border: 1px solid rgba(255, 255, 255, 0.5);
  border-radius: 16px;
  padding: 12px 16px;
  overflow: hidden;
  box-shadow: var(--shadow-sm);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;

  &:hover {
    transform: translateY(-4px);
    box-shadow: var(--shadow-md), var(--shadow-glow-soft);
    background: rgba(255, 255, 255, 0.85);

    .gradient-circle {
      transform: scale(1.1);
    }

    .icon-wrapper {
      transform: scale(1.1) rotate(5deg);
    }
  }

  .card-bg {
    position: absolute;
    top: -50%;
    right: -20%;
    width: 200px;
    height: 200px;
    pointer-events: none;

    .gradient-circle {
      width: 100%;
      height: 100%;
      border-radius: 50%;
      opacity: 0.08;
      transition: transform 0.5s ease;
    }
  }

  .card-content {
    position: relative;
    z-index: 1;

    .card-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 8px;

      .icon-wrapper {
        width: 40px;
        height: 40px;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;

        .el-icon {
          font-size: 20px;
        }
      }

      .trend-badge {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 6px 12px;
        border-radius: 20px;
        font-size: 13px;
        font-weight: 600;

        &.up {
          background: rgba(16, 185, 129, 0.12);
          color: #059669;
        }

        &.down {
          background: rgba(239, 68, 68, 0.12);
          color: #dc2626;
        }

        .el-icon {
          font-size: 14px;
        }
      }
    }

    .card-body {
      margin-bottom: 8px;

      .stat-value {
        font-size: 24px;
        font-weight: 700;
        margin-bottom: 4px;
        display: flex;
        align-items: baseline;
        gap: 4px;

        .prefix, .suffix {
          font-size: 14px;
          font-weight: 500;
          opacity: 0.8;
        }
      }

      .stat-label {
        font-size: 12px;
        color: var(--text-muted);
        font-weight: 500;
      }
    }

    .card-footer {
      .progress-bar {
        display: flex;
        align-items: center;
        gap: 8px;

        .progress-track {
          flex: 1;
          height: 4px;
          background: rgba(203, 213, 225, 0.4);
          border-radius: 2px;
          overflow: hidden;

          .progress-fill {
            height: 100%;
            border-radius: 2px;
            transition: width 1s ease;
          }
        }

        .progress-text {
          font-size: 11px;
          font-weight: 600;
          color: var(--text-muted);
        }
      }

      .footer-text {
        font-size: 11px;
        color: var(--text-placeholder);
      }
    }
  }
}
</style>
