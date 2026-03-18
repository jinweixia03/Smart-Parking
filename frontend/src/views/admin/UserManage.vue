<template>
  <div class="user-manage">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <el-input
            v-model="searchKeyword"
            placeholder="搜索用户名/手机号"
            style="width: 250px;"
            clearable
            @keyup.enter="fetchUsers"
          >
            <template #append>
              <el-button @click="fetchUsers">
                <el-icon><Search /></el-icon>
              </el-button>
            </template>
          </el-input>
        </div>
      </template>

      <el-table :data="users" v-loading="loading">
        <el-table-column prop="userId" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="userType" label="用户类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.userType === 1 ? 'danger' : 'info'">
              {{ row.userType === 1 ? '管理员' : '普通用户' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="手机号" width="150" />
        <el-table-column prop="email" label="邮箱" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-switch
              v-model="row.status"
              :active-value="1"
              :inactive-value="0"
              @change="handleStatusChange(row)"
            />
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="注册时间" width="180" />
      </el-table>

      <el-pagination
        class="pagination"
        v-model:current-page="page"
        v-model:page-size="size"
        :total="total"
        @current-change="fetchUsers"
      />
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

const users = ref([])
const loading = ref(false)
const page = ref(1)
const size = ref(10)
const total = ref(0)
const searchKeyword = ref('')

const fetchUsers = async () => {
  loading.value = true
  // 模拟数据
  users.value = [
    { userId: 1, username: 'user1', userType: 1, phone: '13800138000', email: 'user1@test.com', status: 1, createTime: '2024-01-01 10:00:00' },
    { userId: 2, username: 'user2', userType: 2, phone: '13800138001', email: 'user2@test.com', status: 1, createTime: '2024-01-02 11:00:00' }
  ]
  total.value = 2
  loading.value = false
}

const handleStatusChange = (row) => {
  ElMessage.success(`用户 ${row.username} 状态已更新`)
}

onMounted(fetchUsers)
</script>

<style scoped lang="scss">
.user-manage {
  padding: 24px;
  height: 100%;
  box-sizing: border-box;

  :deep(.el-card) {
    height: 100%;
    display: flex;
    flex-direction: column;

    .el-card__body {
      flex: 1;
      display: flex;
      flex-direction: column;
      overflow: hidden;
    }
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 12px;

    span {
      font-size: 18px;
      font-weight: 600;
      color: #1e293b;
    }
  }

  .el-table {
    flex: 1;
    overflow: auto;
  }

  .pagination {
    margin-top: 20px;
    justify-content: flex-end;
    flex-shrink: 0;
  }

  // 响应式
  @media (max-width: 768px) {
    padding: 16px;

    .card-header {
      flex-direction: column;
      align-items: flex-start;

      .el-input {
        width: 100% !important;
      }
    }

    .pagination {
      justify-content: center;
    }
  }
}
</style>
