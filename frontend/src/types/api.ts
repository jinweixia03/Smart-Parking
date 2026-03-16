// API 响应类型
export interface ApiResponse<T = any> {
  code: number
  message: string
  data: T
  timestamp: number
}

// 用户类型
export interface User {
  userId: number
  username: string
  phone?: string
  email?: string
  realName?: string
  avatar?: string
  status: number
  totalAmount?: number
  lastLoginTime?: string
  createTime: string
}

// 登录请求
export interface LoginForm {
  username: string
  password: string
}

// 登录响应
export interface LoginResponse {
  token: string
  user: User
}

// 注册请求
export interface RegisterForm {
  username: string
  password: string
  phone?: string
  realName?: string
}

// 停车记录
export interface ParkingRecord {
  recordId: number
  plateNumber: string
  entryTime: string
  exitTime?: string
  feeAmount: number
  payStatus: number
  status: number
}

// 分页请求
export interface PageParams {
  page: number
  size: number
}

// 分页响应
export interface PageResult<T> {
  records: T[]
  total: number
  size: number
  current: number
  pages: number
}
