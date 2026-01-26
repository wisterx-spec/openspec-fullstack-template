/**
 * 通用类型定义
 */

// 标准响应
export interface StandardResp<T = any> {
  status: 'ok' | 'error';
  data?: T;
  message?: string;
}

// 分页数据
export interface PaginatedData<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

// 分页请求参数
export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  search?: string;
}

// ID 类型
export type ID = number | string;
