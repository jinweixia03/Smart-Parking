<template>
  <div class="parking-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>停车管理</span>
          <div>
            <el-button type="primary" @click="showEntryDialog">车辆入场</el-button>
            <el-button type="success" @click="showExitDialog">车辆出场</el-button>
          </div>
        </div>
      </template>

      <el-table :data="records" v-loading="loading">
        <el-table-column prop="plateNumber" label="车牌号" width="120" />
        <el-table-column prop="entryTime" label="入场时间" width="180" />
        <el-table-column prop="entryGate" label="入口" width="100" />
        <el-table-column prop="spaceCode" label="车位" width="100" />
        <el-table-column prop="parkingDuration" label="停车时长(分)" width="120" />
        <el-table-column prop="payableAmount" label="应付金额" width="100">
          <template #default="{ row }">
            ¥{{ row.payableAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="payStatus" label="支付状态">
          <template #default="{ row }">
            <el-tag :type="getPayStatusType(row.payStatus)">
              {{ getPayStatusText(row.payStatus) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150">
          <template #default="{ row }">
            <el-button
              v-if="row.payStatus === 0"
              type="primary"
              size="small"
              @click="handlePay(row)"
            >
              支付
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-pagination
        class="pagination"
        v-model:current-page="page"
        v-model:page-size="size"
        :total="total"
        @current-change="fetchRecords"
      />
    </el-card>

    <!-- 入场/出场对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="400px">
      <el-form :model="form" label-width="80px">
        <el-form-item label="车牌号">
          <el-input v-model="form.plateNumber" placeholder="请输入车牌号" />
        </el-form-item>
        <el-form-item label="通道">
          <el-select v-model="form.gate">
            <el-option label="A1" value="A1" />
            <el-option label="B1" value="B1" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit">确认</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getRecords, entry, exit, pay } from '@/api/parking'

const records = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)

const dialogVisible = ref(false)
const dialogTitle = ref('')
const dialogType = ref('') // entry or exit
const form = ref({ plateNumber: '', gate: 'A1' })

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await getRecords({ page: page.value, size: size.value, status: 0 })
    records.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const showEntryDialog = () => {
  dialogType.value = 'entry'
  dialogTitle.value = '车辆入场'
  form.value = { plateNumber: '', gate: 'A1' }
  dialogVisible.value = true
}

const showExitDialog = () => {
  dialogType.value = 'exit'
  dialogTitle.value = '车辆出场'
  form.value = { plateNumber: '', gate: 'A1' }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!form.value.plateNumber) {
    ElMessage.warning('请输入车牌号')
    return
  }
  try {
    if (dialogType.value === 'entry') {
      await entry(form.value.plateNumber, form.value.gate)
      ElMessage.success('入场成功')
    } else {
      await exit(form.value.plateNumber, form.value.gate)
      ElMessage.success('出场成功')
    }
    dialogVisible.value = false
    fetchRecords()
  } catch (error) {
    console.error(error)
  }
}

const handlePay = async (row) => {
  try {
    await pay(row.recordId)
    ElMessage.success('支付成功')
    fetchRecords()
  } catch (error) {
    console.error(error)
  }
}

const getPayStatusType = (status) => {
  const map = { 0: 'danger', 1: 'success', 2: 'info', 3: 'warning' }
  return map[status] || 'info'
}

const getPayStatusText = (status) => {
  const map = { 0: '未支付', 1: '已支付', 2: '免费', 3: '欠费' }
  return map[status] || '未知'
}

onMounted(fetchRecords)
</script>

<style scoped lang="scss">
.parking-manage {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .pagination {
    margin-top: 20px;
    justify-content: flex-end;
  }
}
</style>
