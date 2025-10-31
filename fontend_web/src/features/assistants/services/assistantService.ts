import { axios } from '@shared/libs/axios';

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

/* ===================== KHOA ===================== */
export type Department = { id: Id; tenKhoa: string };
const listDepartments = (params?: PageParams) => axios.get('/api/khoa', { params });
export type UpsertDepartmentBody = { tenKhoa: string };
const upsertDepartment = (khoaId: Id, body: UpsertDepartmentBody) =>
  axios.put(`/api/khoa/${khoaId}`, body);
// --- NGÀNH ---
export type Major = { id: Id; maNganh: string; tenNganh: string; khoaId?: Id; khoaTen?: string };
export type CreateMajorPayload = { maNganh: string; tenNganh: string; khoaId: Id };
export type UpdateMajorPayload = CreateMajorPayload;

// helper: chuẩn hóa & tương thích field name
function normalizeMajorReq(b: CreateMajorPayload | UpdateMajorPayload) {
  const onlyValid = (s: string) => (s || '').toUpperCase().replace(/[^A-Z0-9_-]/g, '');
  const _khoaId = Number((b as any).khoaId ?? (b as any).idKhoa);
  return {
    maNganh: onlyValid(b.maNganh),
    tenNganh: (b.tenNganh || '').trim(),
    // gửi cả 2 để BE nào cũng ăn
    khoaId: _khoaId,
    idKhoa: _khoaId,
  };
}

const listMajors  = (params?: PageParams) => axios.get('/api/nganh', { params });
const createMajor = (body: CreateMajorPayload) =>
  axios.post('/api/nganh', normalizeMajorReq(body));
const updateMajor = (id: Id, body: UpdateMajorPayload) =>
  axios.put(`/api/nganh/${id}`, normalizeMajorReq(body));
const deleteMajor = (id: Id) => axios.delete(`/api/nganh/${id}`);

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

const listSubjects  = (params?: PageParams) => axios.get('/api/bo-mon', { params });
const createSubject = (body: CreateSubjectPayload) => axios.post('/api/bo-mon', body);
const updateSubject = (id: Id, body: UpdateSubjectPayload) => axios.put(`/api/bo-mon/${id}`, body);
const deleteSubject = (id: Id) => axios.delete(`/api/bo-mon/${id}`);

// 👉 Chỉ còn API gán/huỷ Trưởng bộ môn
export type SetSubjectHeadPayload = { idBoMon: Id; idGiangVien: Id | null };
export type SetSubjectHeadResponse = {
  result?: { maGV: string; hoTen: string; hocVi: string; hocHam: string; tenBoMon: string };
  message?: string;
  code?: number;
};
const setSubjectHead = (body: SetSubjectHeadPayload) =>
  axios.post<SetSubjectHeadResponse>('/api/bo-mon/truong-bo-mon', body);

/* ===================== GIẢNG VIÊN ===================== */
export type Lecturer = {
  id: Id;
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  idBoMon?: Id;
  boMonTen?: string;
  laTruongBoMon?: boolean;
};

export type CreateLecturerPayload = {
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  matKhau: string;
  idBoMon: Id;
};
export type UpdateLecturerPayload =
  Omit<CreateLecturerPayload, 'matKhau'> & { laTruongBoMon?: boolean };

const listLecturers  = (params?: PageParams) => axios.get('/api/giang-vien/list', { params });
const createLecturer = (body: CreateLecturerPayload) => axios.post('/api/giang-vien', body);
const updateLecturer = (id: Id, body: UpdateLecturerPayload) => axios.put(`/api/giang-vien/${id}`, body);

/* ========= ĐỢT BẢO VỆ ========= */
export type DefenseRound = {
  id: Id;
  tenDotBaoVe: string;
  hocKi: string;            // vd: 'I' | 'II' | 'Hè'
  namHoc: string;           // vd: '2025-2026'
  thoiGianBatDau: string;   // 'YYYY-MM-DD'
  thoiGianKetThuc: string;  // 'YYYY-MM-DD'
};
export type CreateUpdateDefenseRound = Omit<DefenseRound, 'id'>;

const listDefenseRounds = (params?: PageParams) => axios.get('/api/dot-bao-ve', { params });
const createDefenseRound = (body: CreateUpdateDefenseRound) => axios.post('/api/dot-bao-ve', body);
const updateDefenseRound = (id: Id, body: CreateUpdateDefenseRound) => axios.put(`/api/dot-bao-ve/${id}`, body);
const deleteDefenseRound = (id: Id) => axios.delete(`/api/dot-bao-ve/${id}`);

/* ========= THỜI GIAN THỰC HIỆN CỦA MỘT ĐỢT ========= */
export type RoundTask = {
  id: Id;
  congViec: string;           // enum text BE trả
  thoiGianBatDau: string;     // 'YYYY-MM-DD'
  thoiGianKetThuc: string;    // 'YYYY-MM-DD'
};
export type CreateRoundTask = Omit<RoundTask, 'id'>;
export type UpdateRoundTask = Omit<RoundTask, 'id'>;

export type DefenseRoundDetail = DefenseRound & { thoiGianThucHiens: RoundTask[] };

const getDefenseRoundDetail = (dotBaoVeId: Id) => axios.get(`/api/dot-bao-ve/${dotBaoVeId}`);
const addRoundTask       = (dotBaoVeId: Id, body: CreateRoundTask) => axios.post(`/api/dot-bao-ve/${dotBaoVeId}`, body);
const updateRoundTaskApi = (thoiGianThucHienId: Id, body: UpdateRoundTask) =>
  axios.put(`/api/thoi-gian-thuc-hien/${thoiGianThucHienId}`, body);

/* ===================== LỚP (để chọn idLop) ===================== */
export type ClassRoom = { id: Id; tenLop: string };
const listClasses = (params?: PageParams) => axios.get('/api/lop', { params });

/* ===================== SINH VIÊN ===================== */
export type Student = {
  id: Id;
  email: string;
  maSinhVien: string;
  hoTen: string;
  soDienThoai?: string;
  lopTen?: string;
  duDieuKien?: boolean; // map từ 'kichHoat'
};

export type CreateStudentBody = {
  maSinhVien: string;
  hoTen: string;
  soDienThoai: string;
  email: string;
  matKhau: string;
  idLop: Id;
};
export type UpdateStudentBody = {
  hoTen: string;
  soDienThoai: string;
  email: string;
  idLop: Id;
  matKhau?: string;
};

// API gốc
const listStudents = (params?: PageParams) => axios.get('/api/sinh-vien', { params });
const searchStudents = (info: string, params?: PageParams) =>
  axios.get('/api/sinh-vien/search', { params: { ...params, info } });
const getStudentByMSV = (maSV: string) => axios.get(`/api/sinh-vien/${maSV}`);
const getStudentById  = (id: Id) => axios.get(`/api/sinh-vien/by-id/${id}`);
const createStudent   = (body: CreateStudentBody) => axios.post('/api/sinh-vien', body);
const updateStudentByCode = (maSV: string, body: UpdateStudentBody) =>
  axios.put(`/api/sinh-vien/${maSV}`, body);
const changeStudentStatusByCode = (maSV: string) =>
  axios.put(`/api/sinh-vien/change-status/${maSV}`);
const importStudents  = (formData: FormData) =>
  axios.post('/api/sinh-vien/import', formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });

// Chuẩn hóa record BE → FE
export function normalizeStudent(x: any): Student {
  const acc = x.taiKhoan ?? x.user ?? {};
  const lop = x.lop ?? {};
  return {
    id: x.id ?? x.idSV ?? x.sinhVienId ?? x._id,
    email: x.email ?? acc.email ?? '',
    maSinhVien: x.maSinhVien ?? x.maSV ?? x.msv ?? '',
    hoTen: x.hoTen ?? x.hoVaTen ?? x.ten ?? '',
    soDienThoai: x.soDienThoai ?? x.sdt ?? '',
    lopTen: x.tenLop ?? x.lopTen ?? lop.tenLop ?? lop.ten ?? '',
    duDieuKien: typeof x.kichHoat === 'boolean' ? x.kichHoat : (x.duDieuKien ?? false),
  };
}

// Wrapper trả Page<Student> đã normalize
async function listStudentsNormalized(params?: PageParams): Promise<Page<Student>> {
  const res = await listStudents(params);
  const pg = toPage<any>(res, { page: params?.page ?? 0, size: params?.size ?? 10 });
  return { ...pg, content: (pg.content ?? []).map(normalizeStudent) };
}

/** ====== LỚP (Quản lý tổ chức) ====== */
export type OrgClass = {
  id: Id;
  tenLop: string;
  nganhId?: Id;
  nganhTen?: string;
  khoaTen?: string;   // nếu BE trả kèm
};

export type CreateClassPayload = { tenLop: string; nganhId: Id };
export type UpdateClassPayload = CreateClassPayload;

const listOrgClasses  = (params?: PageParams) => axios.get('/api/lop', { params });
const createOrgClass  = (body: CreateClassPayload) => axios.post('/api/lop', body);
const updateOrgClass  = (id: Id, body: UpdateClassPayload) => axios.put(`/api/lop/${id}`, body);
const deleteOrgClass  = (id: Id) => axios.delete(`/api/lop/${id}`);

// Ưu tiên trang hóa nếu BE trả Page; nếu không, vẫn dùng được với mảng
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


const assistantService = {
  // utils
  unwrap, toPage,
  // departments
  listDepartments,
   upsertDepartment, 
  // majors
  listMajors, createMajor, updateMajor, deleteMajor,
  // subjects
  listSubjects, createSubject, updateSubject, deleteSubject, setSubjectHead,
  // lecturers
  listLecturers, createLecturer, updateLecturer,
  // defense rounds
   listDefenseRounds, createDefenseRound, updateDefenseRound, deleteDefenseRound,
  getDefenseRoundDetail, addRoundTask, updateRoundTaskApi,
  // classes
  listClasses,

  // students
  listStudents, listStudentsNormalized, searchStudents,
  getStudentByMSV, getStudentById,
  createStudent, updateStudentByCode,
  changeStudentStatusByCode, importStudents,
  // lớp (quản lý tổ chức)
  listOrgClasses, listOrgClassesNormalized,
  createOrgClass, updateOrgClass, deleteOrgClass,
};
export default assistantService;
