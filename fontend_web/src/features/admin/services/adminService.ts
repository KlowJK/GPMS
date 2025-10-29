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
  return (res?.data?.result ?? res?.data) as T;
}
function toPage<T = any>(res: any, fb: { page: number; size: number }): Page<T> {
  const raw = unwrap<any>(res);
  const content = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  const totalElements = raw?.totalElements ?? content.length ?? 0;
  return { content, totalElements, page: fb.page, size: fb.size };
}

export function canDeleteDepartment(x: any) {
  if (typeof x?.deletable === 'boolean') return x.deletable;
  if (typeof x?.coSan === 'boolean') return !x.coSan;
  if (typeof x?.system === 'boolean') return !x.system;
  if (typeof x?.builtIn === 'boolean') return !x.builtIn;
  return true;
}

// KHOA
const listDepartments  = (params?: PageParams) => axios.get('/api/khoa', { params });
const createDepartment = (body: Pick<Department, 'tenKhoa'>) => axios.post('/api/khoa', body);
const updateDepartment = (id: Id, body: Pick<Department, 'tenKhoa'>) => axios.put(`/api/khoa/${id}`, body);
const deleteDepartment = (id: Id) => axios.delete(`/api/khoa/${id}`);

// TRỢ LÝ KHOA
const listKhoaAssistants  = (params?: PageParams) => axios.get('/api/khoa/tro-ly-khoa', { params });
const createKhoaAssistant = (body: AssistantCreatePayload) =>
  axios.post('/api/khoa/tro-ly-khoa', body);
const updateKhoaAssistant = (id: Id, body: AssistantUpdatePayload) =>
  axios.put(`/api/khoa/tro-ly-khoa/${id}`, body);
const deleteKhoaAssistant = (id: Id) => axios.delete(`/api/khoa/tro-ly-khoa/${id}`);

const adminService = {
  // Khoa
  listDepartments, createDepartment, updateDepartment, deleteDepartment,
  canDeleteDepartment, toPage, unwrap,
  // Trợ lý
  listKhoaAssistants, createKhoaAssistant, updateKhoaAssistant, deleteKhoaAssistant,
};
export default adminService;
