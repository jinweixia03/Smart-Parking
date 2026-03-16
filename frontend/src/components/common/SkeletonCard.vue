<template>
  <div class="skeleton-card">
    <div class="skeleton-header">
      <div class="skeleton-icon shimmer"></div>
      <div class="skeleton-badge shimmer"></div>
    </div>
    <div class="skeleton-body">
      <div class="skeleton-value shimmer"></div>
      <div class="skeleton-label shimmer"></div>
    </div>
    <div class="skeleton-footer">
      <div class="skeleton-progress shimmer"></div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.skeleton-card {
  background: white;
  border-radius: 20px;
  padding: 24px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);

  .skeleton-header {
    display: flex;
    justify-content: space-between;
    margin-bottom: 20px;

    .skeleton-icon {
      width: 56px;
      height: 56px;
      border-radius: 16px;
    }

    .skeleton-badge {
      width: 60px;
      height: 28px;
      border-radius: 20px;
    }
  }

  .skeleton-body {
    margin-bottom: 20px;

    .skeleton-value {
      width: 60%;
      height: 40px;
      border-radius: 8px;
      margin-bottom: 12px;
    }

    .skeleton-label {
      width: 40%;
      height: 20px;
      border-radius: 4px;
    }
  }

  .skeleton-footer {
    .skeleton-progress {
      width: 100%;
      height: 6px;
      border-radius: 3px;
    }
  }

  .shimmer {
    background: linear-gradient(
      90deg,
      #f1f5f9 25%,
      #e2e8f0 50%,
      #f1f5f9 75%
    );
    background-size: 200% 100%;
    animation: shimmer 1.5s infinite;
  }
}

@keyframes shimmer {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
</style>
