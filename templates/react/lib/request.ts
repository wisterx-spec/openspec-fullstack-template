/**
 * HTTP 请求封装
 *
 * 统一处理：
 * - 请求/响应拦截
 * - 错误处理
 * - 开发环境日志
 */

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '';

// 响应格式
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

// 错误类型
export type ApiErrorType = 'network' | 'timeout' | 'business' | 'unknown';

export interface ApiError extends Error {
  type: ApiErrorType;
  statusCode?: number;
  detail?: any;
}

// 创建 API 错误
function createApiError(
  type: ApiErrorType,
  message: string,
  statusCode?: number,
  detail?: any
): ApiError {
  const error = new Error(message) as ApiError;
  error.type = type;
  error.statusCode = statusCode;
  error.detail = detail;

  // 开发环境打印完整错误
  if (import.meta.env.DEV) {
    console.error('[API Error]', { type, message, statusCode, detail });
  }

  return error;
}

// 核心请求函数
async function fetchApi<T>(endpoint: string, options?: RequestInit): Promise<T> {
  const url = `${API_BASE_URL}${endpoint}`;

  // 开发环境打印请求
  if (import.meta.env.DEV) {
    console.log('[API Request]', options?.method || 'GET', endpoint);
  }

  try {
    const response = await fetch(url, {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        ...options?.headers,
      },
    });

    // HTTP 错误
    if (!response.ok) {
      let errorMessage = `HTTP ${response.status}: ${response.statusText}`;
      let errorDetail: any = null;

      try {
        const error = await response.json();
        errorDetail = error;
        errorMessage = error.message || error.detail || errorMessage;
      } catch {
        // JSON 解析失败
      }

      throw createApiError('business', errorMessage, response.status, errorDetail);
    }

    const result: StandardResp<T> = await response.json();

    // 开发环境打印响应
    if (import.meta.env.DEV) {
      console.log('[API Response]', endpoint, result);
    }

    // 业务错误
    if (result.status === 'error') {
      throw createApiError('business', result.message || '请求失败');
    }

    return result.data as T;
  } catch (error) {
    // 网络错误
    if (error instanceof TypeError && error.message.includes('fetch')) {
      throw createApiError('network', '网络连接失败，请检查网络');
    }

    // 超时错误
    if (error instanceof DOMException && error.name === 'AbortError') {
      throw createApiError('timeout', '请求超时，请稍后重试');
    }

    // 已经是 ApiError
    if ((error as ApiError).type) {
      throw error;
    }

    // 其他错误
    throw createApiError(
      'unknown',
      error instanceof Error ? error.message : '操作失败，请稍后重试'
    );
  }
}

// 导出 API 方法
export const api = {
  get: <T>(endpoint: string): Promise<T> => {
    return fetchApi<T>(endpoint);
  },

  post: <T>(endpoint: string, data?: any): Promise<T> => {
    return fetchApi<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
    });
  },

  put: <T>(endpoint: string, data?: any): Promise<T> => {
    return fetchApi<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
    });
  },

  patch: <T>(endpoint: string, data?: any): Promise<T> => {
    return fetchApi<T>(endpoint, {
      method: 'PATCH',
      body: data ? JSON.stringify(data) : undefined,
    });
  },

  delete: <T>(endpoint: string): Promise<T> => {
    return fetchApi<T>(endpoint, {
      method: 'DELETE',
    });
  },
};
