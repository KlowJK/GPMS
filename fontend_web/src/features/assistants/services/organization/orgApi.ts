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
export const listSubjectsWithHead = (params?: PageParams) =>
  axios.get('/api/bo-mon/with-truong-bo-mon', { params });

function normalizeSubjectRow(x: any): Subject {
  const kv = x.khoa ?? {};
  const head = x.truongBoMon ?? {};

  return {
    id: x.id ?? x.boMonId ?? x._id,

    tenBoMon: x.tenBoMon ?? x.ten ?? '',

    // ⬇️ BE có thể trả 'khoaTen' hoặc 'tenKhoa' (root) hoặc 'khoa.tenKhoa'
    khoaId:  x.khoaId ?? x.idKhoa ?? kv.id,
    khoaTen: x.khoaTen ?? x.tenKhoa ?? kv.tenKhoa ?? kv.ten ?? '',

    // ⬇️ Ưu tiên đủ loại alias, thêm 'truongBoMonHoTen'
    truongBoMonId:
      x.truongBoMonId ??
      x.idTruongBoMon ??
      head.id ??
      x.headId ??
      x.giangVienId,

    truongBoMonTen:
      x.truongBoMonTen ??
      x.truongBoMonHoTen ??   // <<< THÊM DÒNG NÀY
      x.tenTruongBoMon ??
      head.hoTen ??
      x.headName ??
      x.giangVienTen ??
      x.tenGiangVien ??
      '',
  };
}

/** Trả về Page<Subject> đã có sẵn truongBoMonId/ten nếu BE cung cấp */
export async function listSubjectsWithHeadNormalized(
  params?: PageParams
): Promise<Page<Subject>> {
  const res = await listSubjectsWithHead(params);
  const raw = unwrap<any>(res);
  const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  return {
    content: arr.map(normalizeSubjectRow),
    totalElements: raw?.totalElements ?? arr.length ?? 0,
    page: params?.page ?? 0,
    size: params?.size ?? 10,
  };
}
/* ===================== LỚP ===================== */
export type ClassRoom = { id: Id; tenLop: string };

export type OrgClass = {
  id: Id;
  tenLop: string;
  nganhId?: Id;
  nganhTen?: string;
  khoaTen?: string;
};

export type CreateClassPayload = { tenLop: string; nganhId: Id };
export type UpdateClassPayload = CreateClassPayload;

// Helper chung
const toNum = (v: any) => (typeof v === 'number' ? v : (/^\d+$/.test(String(v)) ? Number(v) : v));
const normStr = (s?: string) => (s ?? '').trim();

// ✅ Chuẩn hoá body gửi lên BE. Với update, nhét luôn id vào body (nhiều BE cần)
function normalizeClassReq(body: CreateClassPayload | UpdateClassPayload, id?: Id) {
  const nganhId = toNum((body as any).nganhId ?? (body as any).idNganh);
  const _id = id != null ? toNum(id) : undefined;
  return {
    tenLop: normStr(body.tenLop),
    nganhId,
    // các alias để BE nào cũng “bắt” được:
    id: _id,
    lopId: _id,
    idLop: _id,
  };
}

export const listClasses     = (params?: PageParams) => axios.get('/api/lop', { params });
export const listOrgClasses  = (params?: PageParams) => axios.get('/api/lop', { params });

// ✅ create: không truyền id trong body
export const createOrgClass  = (body: CreateClassPayload) =>
  axios.post('/api/lop', normalizeClassReq(body));

// ✅ update: truyền id cả ở path lẫn body
export const updateOrgClass  = (id: Id, body: UpdateClassPayload) =>
  axios.put(`/api/lop/${id}`, normalizeClassReq(body, id));

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
