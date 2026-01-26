/**
 * 枚举定义
 *
 * 前后端枚举值必须一致，用字符串不用数字。
 */

// 任务状态
export const TaskStatus = {
  PENDING: 'pending',
  RUNNING: 'running',
  COMPLETED: 'completed',
  FAILED: 'failed',
  PAUSED: 'paused',
} as const;

export type TaskStatusType = (typeof TaskStatus)[keyof typeof TaskStatus];

// 任务状态标签
export const TaskStatusLabel: Record<TaskStatusType, string> = {
  pending: '待执行',
  running: '执行中',
  completed: '已完成',
  failed: '失败',
  paused: '已暂停',
};

// 用户角色
export const UserRole = {
  ADMIN: 'admin',
  USER: 'user',
  GUEST: 'guest',
} as const;

export type UserRoleType = (typeof UserRole)[keyof typeof UserRole];

export const UserRoleLabel: Record<UserRoleType, string> = {
  admin: '管理员',
  user: '用户',
  guest: '访客',
};
