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

/* ===================== NGÀNH ===================== */
export type Major = { id: Id; maNganh: string; tenNganh: string; khoaId?: Id; khoaTen?: string };
export type CreateMajorPayload = { maNganh: string; tenNganh: string; khoaId: Id };
export type UpdateMajorPayload = CreateMajorPayload;

const listMajors  = (params?: PageParams) => axios.get('/api/nganh', { params });
const createMajor = (body: CreateMajorPayload) => axios.post('/api/nganh', body);
const updateMajor = (id: Id, body: UpdateMajorPayload) => axios.put(`/api/nganh/${id}`, body);
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

const assistantService = {
  // utils
  unwrap, toPage,
  // departments
  listDepartments,
  // majors
  listMajors, createMajor, updateMajor, deleteMajor,
  // subjects
  listSubjects, createSubject, updateSubject, deleteSubject, setSubjectHead,
  // lecturers
  listLecturers, createLecturer, updateLecturer,
  // defense rounds
   listDefenseRounds, createDefenseRound, updateDefenseRound, deleteDefenseRound,
  getDefenseRoundDetail, addRoundTask, updateRoundTaskApi,
};
export default assistantService;
