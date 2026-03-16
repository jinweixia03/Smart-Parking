<template>
  <nav class="breadcrumb">
    <el-icon class="home-icon" @click="$router.push('/')"><HomeFilled /></el-icon>
    <span class="separator">/</span>
    <transition-group name="breadcrumb">
      <template v-for="(item, index) in breadcrumbs" :key="item.path">
        <span v-if="index > 0" class="separator">/</span>
        <span
          class="breadcrumb-item"
          :class="{ 'is-last': index === breadcrumbs.length - 1 }"
          @click="handleClick(item)"
        >
          {{ item.title }}
        </span>
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
    title: item.meta.title
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
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #64748b;

  .home-icon {
    color: #2563eb;
    cursor: pointer;
    transition: transform 0.3s ease;

    &:hover {
      transform: scale(1.1);
    }
  }

  .separator {
    color: #cbd5e1;
  }

  .breadcrumb-item {
    cursor: pointer;
    transition: all 0.3s ease;
    padding: 4px 8px;
    border-radius: 6px;

    &:hover {
      color: #2563eb;
      background: rgba(37, 99, 235, 0.1);
    }

    &.is-last {
      color: #1e293b;
      font-weight: 600;
      cursor: default;

      &:hover {
        background: none;
      }
    }
  }
}

.breadcrumb-enter-active,
.breadcrumb-leave-active {
  transition: all 0.3s ease;
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