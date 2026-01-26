/**
 * 错误类型定义
 */

export type ApiErrorType = 'network' | 'timeout' | 'business' | 'unknown';

export interface ApiError extends Error {
  type: ApiErrorType;
  statusCode?: number;
  detail?: any;
}

export class BusinessError extends Error {
  constructor(message: string, public code?: number) {
    super(message);
    this.name = 'BusinessError';
  }
}

export class NetworkError extends Error {
  constructor(message: string = '网络连接失败') {
    super(message);
    this.name = 'NetworkError';
  }
}

export class TimeoutError extends Error {
  constructor(message: string = '请求超时') {
    super(message);
    this.name = 'TimeoutError';
  }
}
