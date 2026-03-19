<template>
  <div class="settings-page">
    <div class="page-header">
      <div class="header-title">
        <el-icon class="title-icon"><Setting /></el-icon>
        <div class="title-content">
          <h1>系统设置</h1>
          <p>管理停车场收费规则</p>
        </div>
      </div>
    </div>

    <div class="main-content">
      <!-- 规则列表 -->
      <div class="rules-panel">
        <el-card v-loading="loading" class="rules-card">
          <template #header>
            <div class="card-header">
              <span>收费规则列表</span>
              <el-tag type="info" size="small">共 {{ rules.length }} 条</el-tag>
            </div>
          </template>

          <div class="rules-list">
            <div
              v-for="rule in rules"
              :key="rule.ruleId"
              class="rule-item"
              :class="{ active: selectedRule?.ruleId === rule.ruleId }"
              @click="selectRule(rule)"
            >
              <div class="rule-main">
                <div class="rule-name">
                  {{ rule.ruleName }}
                  <el-tag v-if="rule.isDefault === 1" type="success" size="small" effect="dark">默认</el-tag>
                  <el-tag v-if="rule.status === 0" type="danger" size="small">已禁用</el-tag>
                </div>
                <div class="rule-summary">
                  免费 {{ rule.freeMinutes }}分 · 首时 ¥{{ rule.firstHourFee }} · 超出 ¥{{ rule.extraHourFee }}/时 · 封顶 ¥{{ rule.dailyMaxFee }}
                </div>
              </div>
              <div class="rule-actions" @click.stop>
                <el-button
                  v-if="rule.isDefault !== 1"
                  size="small"
                  type="success"
                  link
                  @click="handleSetDefault(rule)"
                >设为默认</el-button>
                <el-button size="small" type="primary" link @click="openEditDialog(rule)">编辑</el-button>
                <el-button
                  v-if="rule.isDefault !== 1"
                  size="small"
                  type="danger"
                  link
                  @click="handleDelete(rule)"
                >删除</el-button>
              </div>
            </div>

            <el-empty v-if="rules.length === 0" description="暂无收费规则" :image-size="60" />
          </div>
        </el-card>
      </div>

      <!-- 右侧：规则详情 + 费用模拟器 -->
      <div class="detail-panel">
        <!-- 规则详情 -->
        <el-card class="detail-card">
          <template #header>
            <div class="card-header">
              <span>{{ selectedRule ? selectedRule.ruleName : '规则详情' }}</span>
              <el-tag v-if="selectedRule?.isDefault === 1" type="success" size="small" effect="dark">当前默认</el-tag>
            </div>
          </template>

          <div v-if="selectedRule" class="detail-content">
            <div class="detail-grid">
              <div class="detail-item">
                <div class="detail-label">免费时长</div>
                <div class="detail-value">{{ selectedRule.freeMinutes }} <span class="unit">分钟</span></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">首小时费用</div>
                <div class="detail-value">¥{{ selectedRule.firstHourFee }}</div>
              </div>
              <div class="detail-item">
                <div class="detail-label">超出费用</div>
                <div class="detail-value">¥{{ selectedRule.extraHourFee }} <span class="unit">/时</span></div>
              </div>
              <div class="detail-item">
                <div class="detail-label">24小时封顶</div>
                <div class="detail-value">¥{{ selectedRule.dailyMaxFee }}</div>
              </div>
            </div>

            <div class="fee-desc">
              <el-icon><InfoFilled /></el-icon>
              停车 {{ selectedRule.freeMinutes }} 分钟内免费；超出后首小时收 ¥{{ selectedRule.firstHourFee }}，
              之后每小时 ¥{{ selectedRule.extraHourFee }}，24小时最高收 ¥{{ selectedRule.dailyMaxFee }}。
            </div>
          </div>

          <el-empty v-else description="点击左侧规则查看详情" :image-size="60" />
        </el-card>

        <!-- 费用模拟器 -->
        <el-card class="simulator-card">
          <template #header>
            <div class="card-header">
              <el-icon><Cpu /></el-icon>
              <span>费用模拟计算</span>
            </div>
          </template>

          <div class="simulator-body">
            <div class="sim-rule-select">
              <span class="sim-label">选择规则</span>
              <el-select v-model="simRuleId" placeholder="选择规则" size="small" style="width:160px">
                <el-option
                  v-for="r in rules"
                  :key="r.ruleId"
                  :label="r.ruleName"
                  :value="r.ruleId"
                />
              </el-select>
            </div>

            <div class="sim-inputs">
              <div class="sim-input-group">
                <span class="sim-label">停车时长</span>
                <el-input-number
                  v-model="simHours"
                  :min="0"
                  :max="72"
                  size="small"
                  style="width:90px"
                  @change="calcFee"
                />
                <span class="sim-unit">小时</span>
                <el-input-number
                  v-model="simMinutes"
                  :min="0"
                  :max="59"
                  size="small"
                  style="width:90px"
                  @change="calcFee"
                />
                <span class="sim-unit">分钟</span>
              </div>
            </div>

            <div class="sim-result">
              <div class="sim-total-minutes">共 {{ simHours * 60 + simMinutes }} 分钟</div>
              <div class="sim-fee-box">
                <span class="sim-fee-label">预计费用</span>
                <span class="sim-fee-value" :class="{ free: simFee === 0 }">
                  {{ simFee === null ? '-' : simFee === 0 ? '免费' : '¥' + simFee }}
                </span>
              </div>
              <el-button
                type="primary"
                size="small"
                :loading="simLoading"
                :disabled="!simRuleId"
                @click="calcFee"
              >
                计算
              </el-button>
            </div>
          </div>
        </el-card>
      </div>
    </div>

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="editingRule ? '编辑收费规则' : '新增收费规则'"
      width="480px"
      :close-on-click-modal="false"
    >
      <el-form :model="form" :rules="formRules" ref="formRef" label-width="130px">
        <el-form-item label="规则名称" prop="ruleName">
          <el-input v-model="form.ruleName" placeholder="如：标准收费-日间" maxlength="50" />
        </el-form-item>
        <el-form-item label="免费时长(分钟)" prop="freeMinutes">
          <el-input-number v-model="form.freeMinutes" :min="0" :max="120" style="width:100%" />
          <div class="form-tip">停车不超过此时长免费</div>
        </el-form-item>
        <el-form-item label="首小时费用(元)" prop="firstHourFee">
          <el-input-number v-model="form.firstHourFee" :min="0" :precision="2" :step="0.5" style="width:100%" />
        </el-form-item>
        <el-form-item label="超出费用(元/时)" prop="extraHourFee">
          <el-input-number v-model="form.extraHourFee" :min="0" :precision="2" :step="0.5" style="width:100%" />
          <div class="form-tip">超出首小时后每小时收费</div>
        </el-form-item>
        <el-form-item label="24小时封顶(元)" prop="dailyMaxFee">
          <el-input-number v-model="form.dailyMaxFee" :min="0" :precision="2" :step="5" style="width:100%" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch v-model="form.statusBool" active-text="启用" inactive-text="禁用" />
        </el-form-item>
        <el-form-item label="设为默认规则">
          <el-switch v-model="form.isDefaultBool" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="saveLoading" @click="handleSave">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Setting, Plus, InfoFilled, Cpu } from '@element-plus/icons-vue'
import {
  listFeeRules, createFeeRule, updateFeeRule,
  deleteFeeRule, setDefaultFeeRule, calculateFee
} from '@/api/feeRule'

const loading = ref(false)
const rules = ref([])
const selectedRule = ref(null)

// 模拟器
const simRuleId = ref(null)
const simHours = ref(1)
const simMinutes = ref(0)
const simFee = ref(null)
const simLoading = ref(false)

// 对话框
const dialogVisible = ref(false)
const editingRule = ref(null)
const saveLoading = ref(false)
const formRef = ref(null)

const form = reactive({
  ruleName: '',
  freeMinutes: 15,
  firstHourFee: 5.00,
  extraHourFee: 3.00,
  dailyMaxFee: 50.00,
  statusBool: true,
  isDefaultBool: false,
})

const formRules = {
  ruleName: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
  freeMinutes: [{ required: true, message: '请填写免费时长', trigger: 'change' }],
  firstHourFee: [{ required: true, message: '请填写首小时费用', trigger: 'change' }],
  extraHourFee: [{ required: true, message: '请填写超出费用', trigger: 'change' }],
  dailyMaxFee: [{ required: true, message: '请填写封顶金额', trigger: 'change' }],
}

onMounted(loadRules)

async function loadRules() {
  loading.value = true
  try {
    const res = await listFeeRules()
    rules.value = res || []
    // 默认选中默认规则
    const def = rules.value.find(r => r.isDefault === 1)
    if (def) { selectedRule.value = def; simRuleId.value = def.ruleId }
    else if (rules.value.length) { selectedRule.value = rules.value[0]; simRuleId.value = rules.value[0].ruleId }
  } catch (e) {
    ElMessage.error('加载失败：' + (e.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const selectRule = (rule) => {
  selectedRule.value = rule
  simRuleId.value = rule.ruleId
  simFee.value = null
}

const openAddDialog = () => {
  editingRule.value = null
  Object.assign(form, { ruleName: '', freeMinutes: 15, firstHourFee: 5, extraHourFee: 3, dailyMaxFee: 50, statusBool: true, isDefaultBool: false })
  dialogVisible.value = true
}

const openEditDialog = (rule) => {
  editingRule.value = rule
  Object.assign(form, {
    ruleName: rule.ruleName,
    freeMinutes: rule.freeMinutes,
    firstHourFee: Number(rule.firstHourFee),
    extraHourFee: Number(rule.extraHourFee),
    dailyMaxFee: Number(rule.dailyMaxFee),
    statusBool: rule.status === 1,
    isDefaultBool: rule.isDefault === 1,
  })
  dialogVisible.value = true
}

const handleSave = async () => {
  await formRef.value.validate()
  saveLoading.value = true
  try {
    const data = {
      ruleName: form.ruleName,
      freeMinutes: form.freeMinutes,
      firstHourFee: form.firstHourFee,
      extraHourFee: form.extraHourFee,
      dailyMaxFee: form.dailyMaxFee,
      status: form.statusBool ? 1 : 0,
      isDefault: form.isDefaultBool ? 1 : 0,
    }
    if (editingRule.value) {
      await updateFeeRule(editingRule.value.ruleId, data)
      ElMessage.success('更新成功')
    } else {
      await createFeeRule(data)
      ElMessage.success('新增成功')
    }
    dialogVisible.value = false
    await loadRules()
  } catch (e) {
    ElMessage.error('保存失败：' + (e.message || '未知错误'))
  } finally {
    saveLoading.value = false
  }
}

const handleSetDefault = async (rule) => {
  try {
    await setDefaultFeeRule(rule.ruleId)
    ElMessage.success(`已将「${rule.ruleName}」设为默认规则`)
    await loadRules()
  } catch (e) {
    ElMessage.error('操作失败：' + (e.message || '未知错误'))
  }
}

const handleDelete = (rule) => {
  ElMessageBox.confirm(`确定删除规则「${rule.ruleName}」吗？`, '提示', {
    confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning'
  }).then(async () => {
    await deleteFeeRule(rule.ruleId)
    ElMessage.success('已删除')
    if (selectedRule.value?.ruleId === rule.ruleId) selectedRule.value = null
    await loadRules()
  }).catch(() => {})
}

const calcFee = async () => {
  if (!simRuleId.value) return
  const totalMinutes = simHours.value * 60 + simMinutes.value
  simLoading.value = true
  try {
    const res = await calculateFee(simRuleId.value, totalMinutes)
    simFee.value = Number(res)
  } catch (e) {
    ElMessage.error('计算失败')
  } finally {
    simLoading.value = false
  }
}
</script>

<style scoped lang="scss">
.settings-page {
  height: 100%;
  padding: 20px;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: #f5f7fa;
}

.page-header {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;

  .header-title {
    display: flex;
    align-items: center;
    gap: 14px;

    .title-icon {
      width: 42px;
      height: 42px;
      background: linear-gradient(135deg, #6366f1, #8b5cf6);
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: white;
      font-size: 20px;
      flex-shrink: 0;
    }

    .title-content {
      h1 { font-size: 20px; font-weight: 600; color: #1e293b; margin: 0 0 2px 0; }
      p  { font-size: 13px; color: #64748b; margin: 0; }
    }
  }
}

.main-content {
  flex: 1;
  min-height: 0;
  display: flex;
  gap: 16px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}

// 左侧规则列表
.rules-panel {
  width: 360px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
}

.rules-card {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;

  :deep(.el-card__body) {
    flex: 1;
    min-height: 0;
    overflow-y: auto;
    padding: 12px;
  }
}

.rules-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rule-item {
  padding: 12px 14px;
  border: 2px solid #e5e7eb;
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s;

  &:hover { border-color: #c7d2fe; background: #fafafa; }
  &.active { border-color: #6366f1; background: #eef2ff; }

  .rule-main {
    margin-bottom: 8px;

    .rule-name {
      font-size: 14px;
      font-weight: 600;
      color: #1e293b;
      display: flex;
      align-items: center;
      gap: 6px;
      margin-bottom: 4px;
    }

    .rule-summary {
      font-size: 12px;
      color: #94a3b8;
    }
  }

  .rule-actions {
    display: flex;
    gap: 4px;
    border-top: 1px solid #f1f5f9;
    padding-top: 8px;
  }
}

// 右侧
.detail-panel {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.detail-card {
  flex-shrink: 0;

  .detail-content {
    .detail-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
      margin-bottom: 16px;

      .detail-item {
        padding: 14px 16px;
        background: #f8fafc;
        border-radius: 8px;

        .detail-label { font-size: 12px; color: #94a3b8; margin-bottom: 6px; }
        .detail-value {
          font-size: 22px;
          font-weight: 700;
          color: #6366f1;
          .unit { font-size: 13px; font-weight: 400; color: #94a3b8; }
        }
      }
    }

    .fee-desc {
      display: flex;
      align-items: flex-start;
      gap: 8px;
      padding: 12px;
      background: #eff6ff;
      border-radius: 8px;
      font-size: 13px;
      color: #3b82f6;
      line-height: 1.6;
    }
  }
}

.simulator-card {
  flex: 1;
  min-height: 0;

  :deep(.el-card__body) { padding: 16px; }

  .simulator-body {
    display: flex;
    flex-direction: column;
    gap: 16px;

    .sim-label { font-size: 13px; color: #64748b; white-space: nowrap; }
    .sim-unit  { font-size: 13px; color: #94a3b8; }

    .sim-rule-select {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .sim-inputs {
      .sim-input-group {
        display: flex;
        align-items: center;
        gap: 8px;
        flex-wrap: wrap;
      }
    }

    .sim-result {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 14px 16px;
      background: #f8fafc;
      border-radius: 10px;

      .sim-total-minutes { font-size: 13px; color: #94a3b8; flex-shrink: 0; }

      .sim-fee-box {
        flex: 1;
        display: flex;
        align-items: center;
        gap: 10px;

        .sim-fee-label { font-size: 13px; color: #64748b; }
        .sim-fee-value {
          font-size: 26px;
          font-weight: 700;
          color: #f59e0b;
          &.free { color: #10b981; }
        }
      }
    }
  }
}

// 表单
.form-tip {
  font-size: 12px;
  color: #94a3b8;
  margin-top: 4px;
}
</style>
