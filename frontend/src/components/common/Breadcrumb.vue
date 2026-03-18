<template>
  <nav class="harmony-breadcrumb">
    <div class="breadcrumb-start">
      <div class="home-btn" @click="$router.push('/')">
        <el-icon><HomeFilled /></el-icon>
      </div>
      <div class="divider">
        <el-icon><ArrowRight /></el-icon>
      </div>
    </div>

    <transition-group name="breadcrumb" tag="div" class="breadcrumb-list">
      <template v-for="(item, index) in breadcrumbs" :key="item.path">
        <div
          v-if="index > 0"
          class="divider"
        >
          <el-icon><ArrowRight /></el-icon>
        </div>
        <div
          class="breadcrumb-item"
          :class="{ 'is-last': index === breadcrumbs.length - 1 }"
          @click="handleClick(item)"
        >
          <el-icon v-if="item.icon && index === breadcrumbs.length - 1" class="item-icon">
            <component :is="item.icon" />
          </el-icon>
          <span class="item-text">{{ item.title }}</span>
        </div>
      </template>
    </transition-group>
  </nav>
</template>

<script setup>
import { ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()
const breadcrumbs = ref([])

const getBreadcrumbs = () => {
  const matched = route.matched.filter(item => item.meta?.title)
  breadcrumbs.value = matched.map(item => ({
    path: item.path,
    title: item.meta.title,
    icon: item.meta.icon
  }))
}

const handleClick = (item) => {
  if (item.path !== route.path) {
    router.push(item.path)
  }
}

watch(() => route.path, getBreadcrumbs, { immediate: true })
</script>

<style scoped lang="scss">
@use '@/styles/harmony-theme.scss' as *;

.harmony-breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;

  .breadcrumb-start {
    display: flex;
    align-items: center;
    gap: 8px;

    .home-btn {
      width: 36px;
      height: 36px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 10px;
      background: rgba(0, 125, 255, 0.1);
      border: 1px solid rgba(0, 125, 255, 0.2);
      color: $harmony-primary-light;
      cursor: pointer;
      transition: all $transition-normal;

      &:hover {
        background: rgba(0, 125, 255, 0.2);
        transform: scale(1.05);
      }
    }
  }

  .breadcrumb-list {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .divider {
    display: flex;
    align-items: center;
    color: $text-muted;
    font-size: 12px;
  }

  .breadcrumb-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 8px 14px;
    border-radius: 10px;
    color: $text-secondary;
    font-size: 14px;
    cursor: pointer;
    transition: all $transition-normal;

    &:hover {
      background: rgba(255, 255, 255, 0.05);
      color: $text-primary;
    }

    &.is-last {
      background: rgba(0, 125, 255, 0.1);
      border: 1px solid rgba(0, 125, 255, 0.2);
      color: $harmony-primary-light;
      font-weight: 500;
      cursor: default;

      .item-icon {
        color: $harmony-primary-light;
      }
    }

    .item-icon {
      font-size: 16px;
      color: $text-tertiary;
    }

    .item-text {
      white-space: nowrap;
    }
  }
}

// 动画
.breadcrumb-enter-active,
.breadcrumb-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.breadcrumb-enter-from {
  opacity: 0;
  transform: translateX(-10px);
}

.breadcrumb-leave-to {
  opacity: 0;
  transform: translateX(10px);
}
</style>
