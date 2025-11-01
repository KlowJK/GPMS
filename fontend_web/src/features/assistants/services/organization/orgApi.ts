import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@/features/assistants/services/base';

/* ===================== KHOA ===================== */
export type Department = { id: Id; tenKhoa: string };
export const listDepartments = (params?: PageParams) => axios.get('/api/khoa', { params });
export type UpsertDepartmentBody = { tenKhoa: string };
export const upsertDepartment = (khoaId: Id, body: UpsertDepartmentBody) =>
  axios.put(`/api/khoa/${khoaId}`, body);

/* ===================== NGÀNH ===================== */
export type Major = { id: Id; maNganh: string; tenNganh: string; khoaId?: Id; khoaTen?: string };
export type CreateMajorPayload = { maNganh: string; tenNganh: string; khoaId: Id };
export type UpdateMajorPayload = CreateMajorPayload;

function normalizeMajorReq(b: CreateMajorPayload | UpdateMajorPayload) {
  const onlyValid = (s: string) => (s || '').toUpperCase().replace(/[^A-Z0-9_-]/g, '');
  const _khoaId = Number((b as any).khoaId ?? (b as any).idKhoa);
  return { maNganh: onlyValid(b.maNganh), tenNganh: (b.tenNganh || '').trim(), khoaId: _khoaId, idKhoa: _khoaId };
}

export const listMajors  = (params?: PageParams) => axios.get('/api/nganh', { params });
export const createMajor = (body: CreateMajorPayload) => axios.post('/api/nganh', normalizeMajorReq(body));
export const updateMajor = (id: Id, body: UpdateMajorPayload) => axios.put(`/api/nganh/${id}`, normalizeMajorReq(body));
export const deleteMajor = (id: Id) => axios.delete(`/api/nganh/${id}`);

/* ===================== BỘ MÔN ===================== */
export type Subject = {
  id: Id; tenBoMon: string; khoaId: Id; khoaTen?: string; truongBoMonId?: Id; truongBoMonTen?: string;
};
export type CreateSubjectPayload = { tenBoMon: string; khoaId: Id; truongBoMonId?: Id };
export type UpdateSubjectPayload = CreateSubjectPayload;

export const listSubjects  = (params?: PageParams) => axios.get('/api/bo-mon', { params });
export const createSubject = (body: CreateSubjectPayload) => axios.post('/api/bo-mon', body);
export const updateSubject = (id: Id, body: UpdateSubjectPayload) => axios.put(`/api/bo-mon/${id}`, body);
export const deleteSubject = (id: Id) => axios.delete(`/api/bo-mon/${id}`);

export type SetSubjectHeadPayload = { idBoMon: Id; idGiangVien: Id | null };
export type SetSubjectHeadResponse = {
  result?: { maGV: string; hoTen: string; hocVi: string; hocHam: string; tenBoMon: string };
  message?: string; code?: number;
};
export const setSubjectHead = (body: SetSubjectHeadPayload) =>
  axios.post<SetSubjectHeadResponse>('/api/bo-mon/truong-bo-mon', body);

/* ===================== LỚP ===================== */
export type ClassRoom = { id: Id; tenLop: string };
export const listClasses = (params?: PageParams) => axios.get('/api/lop', { params });

export type OrgClass = { id: Id; tenLop: string; nganhId?: Id; nganhTen?: string; khoaTen?: string };
export type CreateClassPayload = { tenLop: string; nganhId: Id };
export type UpdateClassPayload = CreateClassPayload;

export const listOrgClasses  = (params?: PageParams) => axios.get('/api/lop', { params });
export const createOrgClass  = (body: CreateClassPayload) => axios.post('/api/lop', body);
export const updateOrgClass  = (id: Id, body: UpdateClassPayload) => axios.put(`/api/lop/${id}`, body);
export const deleteOrgClass  = (id: Id) => axios.delete(`/api/lop/${id}`);

export async function listOrgClassesNormalized(params?: PageParams): Promise<Page<OrgClass>> {
  const res = await listOrgClasses(params);
  const raw = unwrap<any>(res);
  const content: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  const totalElements = raw?.totalElements ?? content.length ?? 0;
  const map = (x: any): OrgClass => ({
    id: x.id ?? x.lopId ?? x._id,
    tenLop: x.tenLop ?? x.ten ?? '',
    nganhId: x.nganhId ?? x.idNganh ?? x.nganh?.id,
    nganhTen: x.nganhTen ?? x.tenNganh ?? x.nganh?.tenNganh,
    khoaTen: x.khoaTen ?? x.khoa?.tenKhoa,
  });
  return { content: content.map(map), totalElements, page: params?.page ?? 0, size: params?.size ?? 10 };
}
