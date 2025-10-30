// @features/admin/services/adminService.ts
import { axios } from '@shared/libs/axios';

export type Id = string | number;

export type Department = {
  id: Id;
  tenKhoa: string;
  coSan?: boolean;
  system?: boolean;
  builtIn?: boolean;
  deletable?: boolean;
};

export type KhoaAssistant = {
  id: Id;
  hoTen: string;
  email: string;
  soDienThoai?: string;
  khoaId?: Id;
  khoaTen?: string;
};

export type AssistantCreatePayload = {
  hoTen: string;
  email: string;
  matKhau: string;
  soDienThoai?: string;
  diaChi?: string;
};
export type AssistantUpdatePayload = Omit<AssistantCreatePayload, 'matKhau'>;

export type PageParams = { page?: number; size?: number; q?: string };
export type Page<T> = { content: T[]; totalElements: number; page: number; size: number };

export function unwrap<T = any>(res: any): T {
  // hỗ trợ cả {result: {...}} và { ... } thuần
  return (res?.data?.result ?? res?.data) as T;
}

function isPageShape(x: any) {
  return x && Array.isArray(x.content) && typeof x.totalElements === 'number';
}

/** Trả đúng cấu trúc Page, không slice nếu BE đã phân trang */
function toPage<T = any>(res: any, fb: { page: number; size: number }): Page<T> {
  const raw = unwrap<any>(res);

  // BE phân trang chuẩn (Spring Page)
  if (isPageShape(raw)) {
    return { content: raw.content as T[], totalElements: raw.totalElements as number, page: fb.page, size: fb.size };
  }

  // BE trả full list -> FE mới slice
  const arr: T[] = Array.isArray(raw) ? raw : Array.isArray(raw?.data) ? raw.data : [];
  const start = fb.page * fb.size;
  const content = arr.slice(start, start + fb.size);
  return { content, totalElements: arr.length, page: fb.page, size: fb.size };
}

export function canDeleteDepartment(x: any) {
  if (typeof x?.deletable === 'boolean') return x.deletable;
  if (typeof x?.coSan === 'boolean') return !x.coSan;
  if (typeof x?.system === 'boolean') return !x.system;
  if (typeof x?.builtIn === 'boolean') return !x.builtIn;
  return true;
}

// KHOA
const listDepartments  = (params?: PageParams) => axios.get('/api/khoa', { params /* có thể thêm sort để ổn định thứ tự */ });
const createDepartment = (body: Pick<Department, 'tenKhoa'>) => axios.post('/api/khoa', body);
const updateDepartment = (id: Id, body: Pick<Department, 'tenKhoa'>) => axios.put(`/api/khoa/${id}`, body);
const deleteDepartment = (id: Id) => axios.delete(`/api/khoa/${id}`);

// TRỢ LÝ KHOA
const listKhoaAssistants  = (params?: PageParams) => axios.get('/api/khoa/tro-ly-khoa', { params });
const createKhoaAssistant = (body: AssistantCreatePayload) => axios.post('/api/khoa/tro-ly-khoa', body);
const updateKhoaAssistant = (id: Id, body: AssistantUpdatePayload) => axios.put(`/api/khoa/tro-ly-khoa/${id}`, body);
const deleteKhoaAssistant = (id: Id) => axios.delete(`/api/khoa/tro-ly-khoa/${id}`);

const adminService = {
  // Khoa
  listDepartments, createDepartment, updateDepartment, deleteDepartment,
  canDeleteDepartment, toPage, unwrap,
  // Trợ lý
  listKhoaAssistants, createKhoaAssistant, updateKhoaAssistant, deleteKhoaAssistant,
};

export default adminService;
