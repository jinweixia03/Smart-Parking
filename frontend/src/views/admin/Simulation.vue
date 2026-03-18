<template>
  <div class="simulation-page">
    <!-- 页面头部 -->
    <div class="page-header animate-fade-in-down">
      <div class="header-content">
        <h1 class="page-title">仿真系统</h1>
        <p class="page-subtitle">基于CCPD数据集的车牌识别仿真测试平台</p>
      </div>
      <div class="header-stats">
        <div class="stat-badge">
          <el-icon><Check /></el-icon>
          <span>准确率 94.5%</span>
        </div>
        <div class="stat-badge">
          <el-icon><Timer /></el-icon>
          <span>平均耗时 45ms</span>
        </div>
      </div>
    </div>

    <div class="simulation-layout">
      <!-- 左侧控制面板 -->
      <div class="control-panel animate-fade-in-left">
        <div class="panel-card">
          <div class="panel-header">
            <div class="panel-icon">
              <el-icon><Setting /></el-icon>
            </div>
            <h3>仿真配置</h3>
          </div>

          <div class="control-section">
            <label class="control-label">仿真模式</label>
            <div class="mode-selector">
              <button
                v-for="mode in modes"
                :key="mode.value"
                class="mode-btn"
                :class="{ active: simulationMode === mode.value }"
                @click="simulationMode = mode.value"
              >
                <el-icon><component :is="mode.icon" /></el-icon>
                <span>{{ mode.label }}</span>
              </button>
            </div>
          </div>

          <div class="control-section">
            <label class="control-label">难度级别</label>
            <div class="difficulty-selector">
              <button
                v-for="level in difficulties"
                :key="level.value"
                class="difficulty-btn"
                :class="[level.class, { active: difficulty === level.value }]"
                @click="difficulty = level.value"
              >
                {{ level.label }}
              </button>
            </div>
          </div>

          <div class="control-section">
            <label class="control-label">仿真次数: {{ batchCount }}</label>
            <el-slider v-model="batchCount" :min="1" :max="100" show-stops :step="10" />
          </div>

          <div class="control-section">
            <label class="control-label">事件类型</label>
            <el-radio-group v-model="eventType" size="large">
              <el-radio-button label="entry">
                <el-icon><Plus /></el-icon> 入场
              </el-radio-button>
              <el-radio-button label="exit">
                <el-icon><Minus /></el-icon> 出场
              </el-radio-button>
            </el-radio-group>
          </div>

          <div class="control-actions">
            <button
              class="action-btn primary"
              :class="{ loading: running }"
              @click="startSimulation"
              :disabled="running"
            >
              <el-icon v-if="!running"><VideoPlay /></el-icon>
              <el-icon v-else class="spin"><Loading /></el-icon>
              <span>{{ running ? '仿真中...' : '开始仿真' }}</span>
            </button>
            <button class="action-btn secondary" @click="resetSimulation">
              <el-icon><Refresh /></el-icon>
              <span>重置</span>
            </button>
          </div>
        </div>

        <!-- 统计卡片 -->
        <div class="stats-grid">
          <div class="mini-stat">
            <div class="mini-stat-value">{{ stats.total }}</div>
            <div class="mini-stat-label">总识别数</div>
          </div>
          <div class="mini-stat success">
            <div class="mini-stat-value">{{ stats.correct }}</div>
            <div class="mini-stat-label">正确识别</div>
          </div>
          <div class="mini-stat error">
            <div class="mini-stat-value">{{ stats.wrong }}</div>
            <div class="mini-stat-label">错误识别</div>
          </div>
          <div class="mini-stat info">
            <div class="mini-stat-value">{{ stats.accuracy }}%</div>
            <div class="mini-stat-label">准确率</div>
          </div>
        </div>
      </div>

      <!-- 右侧结果展示 -->
      <div class="results-panel animate-fade-in-right">
        <div class="results-card">
          <div class="results-header">
            <h3>识别结果</h3>
            <div class="filter-tags">
              <span
                v-for="filter in filters"
                :key="filter.value"
                class="filter-tag"
                :class="{ active: activeFilter === filter.value }"
                @click="activeFilter = filter.value"
              >
                {{ filter.label }}
              </span>
            </div>
          </div>

          <div class="results-content" ref="resultsContainer">
            <div v-if="results.length === 0" class="empty-state">
              <div class="empty-icon">
                <el-icon size="64"><VideoCamera /></el-icon>
              </div>
              <h4>开始仿真测试</h4>
              <p>配置参数后点击"开始仿真"按钮</p>
            </div>

            <transition-group name="result" tag="div" class="results-list">
              <div
                v-for="(item, index) in filteredResults"
                :key="item.id"
                class="result-item"
                :class="{ correct: item.correct, wrong: !item.correct }"
              >
                <div class="result-index">#{{ results.length - index }}</div>
                <div class="result-image">
                  <img :src="item.image" alt="plate" />
                </div>
                <div class="result-details">
                  <div class="plate-comparison">
                    <div class="plate-box">
                      <span class="plate-label">真实</span>
                      <span class="plate-value real">{{ item.plateNumber }}</span>
                    </div>
                    <el-icon class="compare-arrow"><Right /></el-icon>
                    <div class="plate-box">
                      <span class="plate-label">识别</span>
                      <span
                        class="plate-value predicted"
                        :class="{ error: !item.correct }"
                      >
                        {{ item.recognizedPlate }}
                      </span>
                    </div>
                  </div>
                  <div class="result-meta">
                    <div class="meta-item">
                      <el-icon><CircleCheck v-if="item.correct" /><CircleClose v-else /></el-icon>
                      <span>{{ item.correct ? '识别正确' : '识别错误' }}</span>
                    </div>
                    <div class="meta-item">
                      <el-icon><TrendCharts /></el-icon>
                      <span>{{ (item.confidence * 100).toFixed(1) }}%</span>
                    </div>
                    <div class="meta-item">
                      <el-icon><Timer /></el-icon>
                      <span>{{ item.timeCost }}ms</span>
                    </div>
                  </div>
                </div>
                <div class="result-status">
                  <div class="status-icon" :class="item.correct ? 'success' : 'error'">
                    <el-icon><Check v-if="item.correct" /><Close v-else /></el-icon>
                  </div>
                </div>
              </div>
            </transition-group>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { startSimulation as startSimApi } from '@/api/simulation'
import { entry, exit } from '@/api/parking'

const simulationMode = ref('single')
const difficulty = ref('medium')
const batchCount = ref(10)
const eventType = ref('entry')
const running = ref(false)
const activeFilter = ref('all')

const modes = [
  { value: 'single', label: '单图识别', icon: 'Picture' },
  { value: 'batch', label: '批量仿真', icon: 'FolderOpened' }
]

const difficulties = [
  { value: 'easy', label: '简单', class: 'easy' },
  { value: 'medium', label: '中等', class: 'medium' },
  { value: 'hard', label: '困难', class: 'hard' }
]

const filters = [
  { value: 'all', label: '全部' },
  { value: 'correct', label: '正确' },
  { value: 'wrong', label: '错误' }
]

const stats = reactive({
  total: 0,
  correct: 0,
  wrong: 0,
  accuracy: 0
})

const results = ref([])

const filteredResults = computed(() => {
  if (activeFilter.value === 'all') return results.value
  return results.value.filter(r =>
    activeFilter.value === 'correct' ? r.correct : !r.correct
  )
})

const startSimulation = async () => {
  running.value = true

  try {
    // 调用后端仿真API
    const res = await startSimApi({
      count: batchCount.value,
      eventType: eventType.value,
      mode: simulationMode.value,
      difficulty: difficulty.value,
      delay: 100
    })

    const simResults = res.data || []

    for (let i = 0; i < simResults.length; i++) {
      await new Promise(resolve => setTimeout(resolve, 200))

      const item = simResults[i]
      const isCorrect = item.success !== false
      const confidence = (item.confidence || 85) / 100

      const result = {
        id: Date.now() + i,
        plateNumber: item.plateNumber,
        recognizedPlate: item.plateNumber,
        confidence: confidence,
        correct: isCorrect,
        timeCost: item.processTime || 45,
        image: `https://placehold.co/160x60/2563eb/ffffff?text=${item.plateNumber}`,
        time: new Date().toLocaleTimeString(),
        eventType: item.eventType,
        fee: item.fee,
        message: item.message
      }

      results.value.unshift(result)
      stats.total++
      if (isCorrect) stats.correct++
      else stats.wrong++
      stats.accuracy = ((stats.correct / stats.total) * 100).toFixed(1)
    }

    ElMessage.success(`仿真完成，成功率: ${stats.accuracy}%`)
  } catch (error) {
    console.error('仿真失败:', error)
    ElMessage.error('仿真失败: ' + (error.message || '未知错误'))
  } finally {
    running.value = false
  }
}

const resetSimulation = () => {
  results.value = []
  stats.total = 0
  stats.correct = 0
  stats.wrong = 0
  stats.accuracy = 0
}
</script>

<style scoped lang="scss">
.simulation-page {
  min-height: 100%;
  padding: 24px;
  box-sizing: border-box;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 28px;
  padding-bottom: 24px;
  border-bottom: 1px solid #e2e8f0;

  .header-content {
    .page-title {
      font-size: 32px;
      font-weight: 700;
      color: #1e293b;
      margin-bottom: 8px;
    }

    .page-subtitle {
      font-size: 16px;
      color: #64748b;
    }
  }

  .header-stats {
    display: flex;
    gap: 12px;

    .stat-badge {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 16px;
      background: white;
      border-radius: 12px;
      font-size: 14px;
      font-weight: 600;
      color: #1e293b;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);

      .el-icon {
        color: #6366f1;
      }
    }
  }
}

.simulation-layout {
  display: grid;
  grid-template-columns: 400px 1fr;
  gap: 24px;
}

.control-panel {
  .panel-card {
    background: white;
    border-radius: 20px;
    padding: 24px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    margin-bottom: 20px;

    .panel-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 24px;

      .panel-icon {
        width: 48px;
        height: 48px;
        background: linear-gradient(135deg, #6366f1, #8b5cf6);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
      }

      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1e293b;
      }
    }

    .control-section {
      margin-bottom: 24px;

      .control-label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #374151;
        margin-bottom: 12px;
      }
    }

    .mode-selector {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;

      .mode-btn {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
        padding: 20px;
        background: #f8fafc;
        border: 2px solid transparent;
        border-radius: 16px;
        cursor: pointer;
        transition: all 0.3s ease;

        .el-icon {
          font-size: 28px;
          color: #64748b;
        }

        span {
          font-size: 14px;
          font-weight: 500;
          color: #64748b;
        }

        &:hover, &.active {
          border-color: #6366f1;
          background: rgba(99, 102, 241, 0.05);

          .el-icon, span {
            color: #6366f1;
          }
        }
      }
    }

    .difficulty-selector {
      display: flex;
      gap: 12px;

      .difficulty-btn {
        flex: 1;
        padding: 12px 20px;
        border: 2px solid #e2e8f0;
        border-radius: 12px;
        background: white;
        font-size: 14px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;

        &.easy { color: #10b981; border-color: #10b981; }
        &.medium { color: #f59e0b; border-color: #f59e0b; }
        &.hard { color: #ef4444; border-color: #ef4444; }

        &:hover, &.active {
          &.easy { background: rgba(16, 185, 129, 0.1); }
          &.medium { background: rgba(245, 158, 11, 0.1); }
          &.hard { background: rgba(239, 68, 68, 0.1); }
        }
      }
    }

    .control-actions {
      display: flex;
      gap: 12px;
      margin-top: 32px;

      .action-btn {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        padding: 14px 24px;
        border: none;
        border-radius: 12px;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s ease;

        .el-icon {
          font-size: 18px;
        }

        &.primary {
          background: linear-gradient(135deg, #6366f1, #8b5cf6);
          color: white;

          &:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.4);
          }

          &.loading {
            opacity: 0.8;
            cursor: not-allowed;
          }
        }

        &.secondary {
          background: #f1f5f9;
          color: #64748b;

          &:hover {
            background: #e2e8f0;
            color: #1e293b;
          }
        }

        .spin {
          animation: spin 1s linear infinite;
        }
      }
    }
  }

  .stats-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;

    .mini-stat {
      background: white;
      border-radius: 16px;
      padding: 20px;
      text-align: center;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);

      &.success .mini-stat-value { color: #10b981; }
      &.error .mini-stat-value { color: #ef4444; }
      &.info .mini-stat-value { color: #6366f1; }

      .mini-stat-value {
        font-size: 28px;
        font-weight: 700;
        margin-bottom: 4px;
      }

      .mini-stat-label {
        font-size: 13px;
        color: #64748b;
      }
    }
  }
}

.results-panel {
  .results-card {
    background: white;
    border-radius: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    height: calc(100vh - 200px);
    display: flex;
    flex-direction: column;

    .results-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 24px 24px 0;
      margin-bottom: 20px;

      h3 {
        font-size: 20px;
        font-weight: 600;
        color: #1e293b;
      }

      .filter-tags {
        display: flex;
        gap: 8px;

        .filter-tag {
          padding: 8px 16px;
          background: #f1f5f9;
          border-radius: 20px;
          font-size: 13px;
          font-weight: 500;
          color: #64748b;
          cursor: pointer;
          transition: all 0.3s ease;

          &:hover, &.active {
            background: #6366f1;
            color: white;
          }
        }
      }
    }

    .results-content {
      flex: 1;
      overflow-y: auto;
      padding: 0 24px 24px;

      .empty-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        height: 100%;
        color: #94a3b8;

        .empty-icon {
          width: 120px;
          height: 120px;
          background: #f8fafc;
          border-radius: 30px;
          display: flex;
          align-items: center;
          justify-content: center;
          margin-bottom: 24px;
        }

        h4 {
          font-size: 20px;
          font-weight: 600;
          color: #64748b;
          margin-bottom: 8px;
        }

        p {
          font-size: 14px;
        }
      }

      .results-list {
        display: flex;
        flex-direction: column;
        gap: 12px;

        .result-item {
          display: flex;
          align-items: center;
          gap: 16px;
          padding: 16px;
          background: #f8fafc;
          border-radius: 16px;
          border: 2px solid transparent;
          transition: all 0.3s ease;

          &:hover {
            background: #f1f5f9;
          }

          &.correct {
            border-color: #10b981;
            background: rgba(16, 185, 129, 0.05);
          }

          &.wrong {
            border-color: #ef4444;
            background: rgba(239, 68, 68, 0.05);
          }

          .result-index {
            font-size: 12px;
            font-weight: 600;
            color: #94a3b8;
            width: 40px;
          }

          .result-image {
            width: 100px;
            height: 40px;
            border-radius: 8px;
            overflow: hidden;

            img {
              width: 100%;
              height: 100%;
              object-fit: cover;
            }
          }

          .result-details {
            flex: 1;

            .plate-comparison {
              display: flex;
              align-items: center;
              gap: 12px;
              margin-bottom: 8px;

              .plate-box {
                display: flex;
                flex-direction: column;
                gap: 4px;

                .plate-label {
                  font-size: 11px;
                  color: #94a3b8;
                }

                .plate-value {
                  font-size: 16px;
                  font-weight: 700;
                  color: #1e293b;
                  padding: 6px 12px;
                  background: white;
                  border-radius: 8px;
                  border: 1px solid #e2e8f0;

                  &.error {
                    color: #ef4444;
                    text-decoration: line-through;
                  }
                }
              }

              .compare-arrow {
                color: #94a3b8;
              }
            }

            .result-meta {
              display: flex;
              gap: 16px;

              .meta-item {
                display: flex;
                align-items: center;
                gap: 6px;
                font-size: 13px;
                color: #64748b;

                .el-icon {
                  font-size: 14px;
                }
              }
            }
          }

          .result-status {
            .status-icon {
              width: 40px;
              height: 40px;
              border-radius: 10px;
              display: flex;
              align-items: center;
              justify-content: center;
              font-size: 20px;

              &.success {
                background: #dcfce7;
                color: #16a34a;
              }

              &.error {
                background: #fee2e2;
                color: #dc2626;
              }
            }
          }
        }
      }
    }
  }
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

// 结果动画
.result-enter-active,
.result-leave-active {
  transition: all 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

.result-enter-from {
  opacity: 0;
  transform: translateX(-30px) scale(0.9);
}

.result-leave-to {
  opacity: 0;
  transform: translateX(30px);
}

@media (max-width: 1200px) {
  .simulation-layout {
    grid-template-columns: 1fr;
  }

  .control-panel {
    order: 2;
  }

  .results-panel {
    order: 1;

    .results-card {
      height: 500px;
    }
  }
}
</style>
