import { axios } from '@shared/libs/axios';

export { axios }; // dùng lại trong các module

export type Id = string | number;

export type PageParams = { page?: number; size?: number; q?: string };
export type Page<T> = { content: T[]; totalElements: number; page: number; size: number };

export function unwrap<T = any>(res: any): T {
  return (res?.data?.result ?? res?.data) as T;
}

export function toPage<T = any>(res: any, fb: { page: number; size: number }): Page<T> {
  const raw = unwrap<any>(res);
  const content: T[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  const totalElements = raw?.totalElements ?? content.length ?? 0;
  return { content, totalElements, page: fb.page, size: fb.size };
}
