<template>
  <div class="settings">
    <el-row :gutter="20">
      <el-col :span="12">
        <el-card>
          <template #header>
            <span>收费规则</span>
          </template>

          <el-form :model="feeForm" label-width="120px">
            <el-form-item label="免费时长(分)">
              <el-input-number v-model="feeForm.freeMinutes" :min="0" :max="60" />
            </el-form-item>

            <el-form-item label="首小时费用(元)">
              <el-input-number v-model="feeForm.firstHourFee" :min="0" :precision="2" />
            </el-form-item>

            <el-form-item label="超出费用(元/时)">
              <el-input-number v-model="feeForm.extraHourFee" :min="0" :precision="2" />
            </el-form-item>

            <el-form-item label="24小时封顶(元)">
              <el-input-number v-model="feeForm.dailyMaxFee" :min="0" :precision="2" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveFeeRule">保存</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>

      <el-col :span="12">
        <el-card>
          <template #header>
            <span>系统配置</span>
          </template>

          <el-form :model="systemForm" label-width="120px">
            <el-form-item label="系统名称">
              <el-input v-model="systemForm.systemName" />
            </el-form-item>

            <el-form-item label="总车位数">
              <el-input-number v-model="systemForm.totalSpaces" :min="1" />
            </el-form-item>

            <el-form-item label="检测阈值">
              <el-slider v-model="systemForm.detectConf" :min="0" :max="1" :step="0.1" />
            </el-form-item>

            <el-form-item label="识别阈值">
              <el-slider v-model="systemForm.recognizeConf" :min="0" :max="1" :step="0.1" />
            </el-form-item>

            <el-form-item>
              <el-button type="primary" @click="saveSystemConfig">保存</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { ElMessage } from 'element-plus'

const feeForm = reactive({
  freeMinutes: 15,
  firstHourFee: 5.00,
  extraHourFee: 3.00,
  dailyMaxFee: 50.00
})

const systemForm = reactive({
  systemName: '智能停车场管理系统',
  totalSpaces: 150,
  detectConf: 0.5,
  recognizeConf: 0.8
})

const saveFeeRule = () => {
  ElMessage.success('收费规则已保存')
}

const saveSystemConfig = () => {
  ElMessage.success('系统配置已保存')
}
</script>

<style scoped lang="scss">
.settings {
  .el-card {
    margin-bottom: 20px;
  }
}
</style>