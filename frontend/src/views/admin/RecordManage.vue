<template>
  <div class="record-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>停车记录</span>
          <div>
            <el-input
              v-model="searchForm.plateNumber"
              placeholder="车牌号"
              style="width: 200px; margin-right: 10px;"
            />
            <el-button type="primary" @click="fetchRecords">查询</el-button>
          </div>
        </div>
      </template>

      <el-table :data="records" v-loading="loading">
        <el-table-column prop="recordId" label="记录ID" width="80" />
        <el-table-column prop="plateNumber" label="车牌号" width="120" />
        <el-table-column prop="entryTime" label="入场时间" width="180" />
        <el-table-column prop="exitTime" label="出场时间" width="180" />
        <el-table-column prop="parkingDuration" label="停车时长(分)" width="120" />
        <el-table-column prop="payableAmount" label="应付金额" width="100">
          <template #default="{ row }">
            ¥{{ row.payableAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="paidAmount" label="实付金额" width="100">
          <template #default="{ row }">
            ¥{{ row.paidAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="payStatus" label="状态">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row)">
              {{ getStatusText(row) }}
            </el-tag>
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getRecords } from '@/api/parking'

const records = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)
const searchForm = ref({ plateNumber: '' })

const fetchRecords = async () => {
  loading.value = true
  try {
    const res = await getRecords({
      page: page.value,
      size: size.value,
      plateNumber: searchForm.value.plateNumber
    })
    records.value = res.records || []
    total.value = res.total || 0
  } catch (error) {
    console.error(error)
  } finally {
    loading.value = false
  }
}

const getStatusType = (row) => {
  if (row.payStatus === 1) return 'success'
  if (row.payStatus === 0) return 'danger'
  return 'info'
}

const getStatusText = (row) => {
  if (row.status === 0) return '进行中'
  if (row.payStatus === 1) return '已完成'
  return '未支付'
}

onMounted(fetchRecords)
</script>

<style scoped lang="scss">
.record-manage {
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
