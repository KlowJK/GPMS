// src/features/assistants/services/organization/orgApi.ts
import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@/features/assistants/services/base';

/* ===================== KHOA ===================== */
export type Department = { id: Id; tenKhoa: string };
export const listDepartments = (params?: PageParams) => axios.get('/api/khoa', { params });
export type UpsertDepartmentBody = { tenKhoa: string };
export const upsertDepartment = (khoaId: Id, body: UpsertDepartmentBody) =>
  axios.put(`/api/khoa/${khoaId}`, body);

/** Luôn trả ra mảng [{ id: string, tenKhoa }] để không mất chính xác ID lớn */
export async function listDepartmentsNormalized(): Promise<Array<{ id: string; tenKhoa: string }>> {
  const res = await listDepartments();
  const raw = unwrap<any>(res);
  const arr: any[] =
    Array.isArray(raw?.content) ? raw.content :
    Array.isArray(raw?.data)    ? raw.data    :
    Array.isArray(raw)          ? raw         : [];

  return arr.map((x) => ({
    id: String(x.id ?? x.khoaId ?? x._id),
    tenKhoa: x.tenKhoa ?? x.ten ?? '',
  }));
}


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
  id: Id;
  tenBoMon: string;
  khoaId: Id;
  khoaTen?: string;
  truongBoMonId?: Id;
  truongBoMonTen?: string;
};

export type CreateSubjectPayload = { tenBoMon: string; khoaId: Id; truongBoMonId?: Id };
export type UpdateSubjectPayload = CreateSubjectPayload;

export const listSubjects  = (params?: PageParams) => axios.get('/api/bo-mon', { params });
export const createSubject = (body: CreateSubjectPayload) => axios.post('/api/bo-mon', body);
export const updateSubject = (id: Id, body: UpdateSubjectPayload) => axios.put(`/api/bo-mon/${id}`, body);
export const deleteSubject = (id: Id) => axios.delete(`/api/bo-mon/${id}`);

/** ---- GÁN TRƯỞNG BỘ MÔN (có fallback nhiều dạng BE hay dùng) ---- */
export type SetSubjectHeadPayload = { boMonId: Id; giangVienId: Id | null };
export type SetSubjectHeadResponse = {
  result?: { maGV: string; hoTen: string; hocVi: string; hocHam: string; tenBoMon: string };
  message?: string; code?: number;
};

/** Thử lần lượt các pattern phổ biến:
 * 1) POST /api/bo-mon/truong-bo-mon  { giangVienId, boMonId }
 * 2) POST /api/bo-mon/truong-bo-mon  { idGiangVien, idBoMon }
 * 3) PUT  /api/bo-mon/:boMonId/truong-bo-mon { giangVienId }
 * 4) PUT  /api/bo-mon/:boMonId/truong-bo-mon { idGiangVien }
 * 5) (bỏ gán) thử thêm giá trị 0 thay cho null nếu cần
 */
export async function setSubjectHead(body: SetSubjectHeadPayload) {
  const { boMonId, giangVienId } = body;
  const candidates: Array<{ m: 'post' | 'put'; url: string; data: any }> = [
    { m: 'post', url: '/api/bo-mon/truong-bo-mon', data: { giangVienId, boMonId } },
    { m: 'post', url: '/api/bo-mon/truong-bo-mon', data: { idGiangVien: giangVienId, idBoMon: boMonId } },
    { m: 'put',  url: `/api/bo-mon/${boMonId}/truong-bo-mon`, data: { giangVienId } },
    { m: 'put',  url: `/api/bo-mon/${boMonId}/truong-bo-mon`, data: { idGiangVien: giangVienId } },
  ];
  // Nếu bỏ gán (null) thì thử thêm biến thể 0:
  if (giangVienId == null) {
    candidates.push(
      { m: 'post', url: '/api/bo-mon/truong-bo-mon', data: { giangVienId: 0, boMonId } },
      { m: 'post', url: '/api/bo-mon/truong-bo-mon', data: { idGiangVien: 0, idBoMon: boMonId } },
      { m: 'put',  url: `/api/bo-mon/${boMonId}/truong-bo-mon`, data: { giangVienId: 0 } },
      { m: 'put',  url: `/api/bo-mon/${boMonId}/truong-bo-mon`, data: { idGiangVien: 0 } },
    );
  }

  let lastErr: any;
  for (const c of candidates) {
    try {
      const res = await axios[c.m]<SetSubjectHeadResponse>(c.url, c.data, {
        headers: { Accept: '*/*' },
      });
      return res;
    } catch (e: any) {
      lastErr = e;
      // thử pattern tiếp theo
    }
  }
  throw lastErr;
}

export const listSubjectsWithHead = (params?: PageParams) =>
  axios.get('/api/bo-mon/with-truong-bo-mon', { params });

function normalizeSubjectRow(x: any): Subject {
  const kv = x.khoa ?? {};
  const head = x.truongBoMon ?? {};
  return {
    id: x.id ?? x.boMonId ?? x._id,
    tenBoMon: x.tenBoMon ?? x.ten ?? '',
    khoaId:  x.khoaId ?? x.idKhoa ?? kv.id,
    khoaTen: x.khoaTen ?? x.tenKhoa ?? kv.tenKhoa ?? kv.ten ?? '',
    truongBoMonId:
      x.truongBoMonId ?? x.idTruongBoMon ?? head.id ?? x.headId ?? x.giangVienId,
    // Ưu tiên tên trường BE bạn cung cấp
    truongBoMonTen:
      x.truongBoMonHoTen ??
      x.truongBoMonTen ??
      x.tenTruongBoMon ??
      head.hoTen ??
      x.headName ??
      x.giangVienTen ??
      x.tenGiangVien ??
      '',
  };
}

export async function listSubjectsNormalized(params?: PageParams): Promise<Page<Subject>> {
  const res = await listSubjects(params);
  const raw = unwrap<any>(res);
  const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  return {
    content: arr.map(normalizeSubjectRow),
    totalElements: raw?.totalElements ?? arr.length ?? 0,
    page: params?.page ?? 0,
    size: params?.size ?? 10,
  };
}

export async function listSubjectsAnyNormalized(params?: PageParams): Promise<Page<Subject>> {
  try {
    const res = await listSubjectsWithHead(params);
    const raw = unwrap<any>(res);
    const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
    return {
      content: arr.map(normalizeSubjectRow),
      totalElements: raw?.totalElements ?? arr.length ?? 0,
      page: params?.page ?? 0,
      size: params?.size ?? 10,
    };
  } catch {
    return listSubjectsNormalized(params);
  }
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

// Helpers
const toNum = (v: any) => (typeof v === 'number' ? v : (/^\d+$/.test(String(v)) ? Number(v) : v));
const normStr = (s?: string) => (s ?? '').trim();

// ✅ Chuẩn hoá body gửi lên BE. Với update, nhét luôn id vào body (nhiều BE cần)
function normalizeClassReq(body: CreateClassPayload | UpdateClassPayload, id?: Id) {
  const nganhId = toNum((body as any).nganhId ?? (body as any).idNganh);
  const _id = id != null ? toNum(id) : undefined;
  return {
    tenLop: normStr(body.tenLop),
    nganhId,
    // alias để BE nào cũng “bắt” được:
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



