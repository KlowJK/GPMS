// src/features/admin/services/universityService.ts
import { axios } from "@shared/libs/axios";

export type Id = string | number;
export type LecturerRole = 'GIANG_VIEN' | 'TRO_LY_KHOA' | 'TRUONG_BO_MON';

export interface Lecturer {
  id: number;
  email: string;
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocHam?: string;
  hocVi?: string;
  vaiTro: LecturerRole;
  boMonId?: number;
  boMonTen?: string;
  trangThai?: string;
}

export interface LecturerPayload {
  email: string;
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  matKhau?: string; 
  hocHam?: string;
  hocVi?: string;
  vaiTro: LecturerRole;
  boMonId?: number;
}

export type Department = { id: Id; tenKhoa: string };
export type Major      = { id: Id; tenNganh: string; khoaId: Id };
export type Subject    = { id: Id; tenBoMon: string;  khoaId: Id };
export type ClassEnt   = { id: Id; tenLop: string;    nganhId: Id };

export function unwrap<T = any>(res: any): T {
  // chấp nhận cả {result: {...}} lẫn trả thẳng payload
  return (res?.data?.result ?? res?.data) as T;
}

/* ====================== KHOA ====================== */
const getDepartments   = () => axios.get("/api/public/khoa");
const createDepartment = (body: Partial<Department>) =>
  axios.post("/api/public/khoa", body);
const updateDepartment = (id: Id, body: Partial<Department>) =>
  axios.put(`/api/public/khoa/${id}`, body);
const deleteDepartment = (id: Id) =>
  axios.delete(`/api/public/khoa/${id}`);

/* ====================== NGÀNH ====================== */
const getMajors   = () => axios.get("/api/public/nganh");
const createMajor = (body: Partial<Major>) =>
  axios.post("/api/public/nganh", body);
const updateMajor = (id: Id, body: Partial<Major>) =>
  axios.put(`/api/public/nganh/${id}`, body);
const deleteMajor = (id: Id) =>
  axios.delete(`/api/public/nganh/${id}`);

/* ====================== LỚP ====================== */
const getClasses   = () => axios.get("/api/public/lop");
const createClass  = (body: Partial<ClassEnt>) =>
  axios.post("/api/public/lop", body);
const updateClass  = (id: Id, body: Partial<ClassEnt>) =>
  axios.put(`/api/public/lop/${id}`, body);
const deleteClass  = (id: Id) =>
  axios.delete(`/api/public/lop/${id}`);

/* ====================== BỘ MÔN ====================== */
const getSubjects = (params?: { page?: number; size?: number; q?: string; khoaId?: Id }) =>
  axios.get("/api/public/bo-mon", { params });

const createSubject = (body: Partial<Subject>) =>
  axios.post("/api/public/bo-mon", body);
const updateSubject = (id: Id, body: Partial<Subject>) =>
  axios.put(`/api/public/bo-mon/${id}`, body);
const deleteSubject = (id: Id) =>
  axios.delete(`/api/public/bo-mon/${id}`);

/* ====================== GIẢNG VIÊN ====================== */
// GET /api/giang-vien/list?page=&size=&q=&boMonId=
const getLecturers = (params?: { page?: number; size?: number; q?: string; boMonId?: Id }) =>
  axios.get("/api/giang-vien/list", { params });

// POST /api/giang-vien  (map maGiangVien -> maGV)
const createLecturer = (body: LecturerPayload) => {
  const wire: any = { ...body, maGV: body.maGiangVien };
  delete wire.maGiangVien;
  return axios.post("/api/giang-vien", wire);
};

// PUT /api/giang-vien/{id}  (nếu có maGiangVien thì map -> maGV)
const updateLecturer = (id: Id, body: Partial<LecturerPayload>) => {
  const wire: any = { ...body };
  if (wire.maGiangVien != null) {
    wire.maGV = wire.maGiangVien;
    delete wire.maGiangVien;
  }
  return axios.put(`/api/giang-vien/${id}`, wire);
};

// (tuỳ nhu cầu) DELETE /api/giang-vien/{id}
const deleteLecturer = (id: Id) =>
  axios.delete(`/api/giang-vien/${id}`);

/* Chuẩn hoá dữ liệu giảng viên từ BE về UI */
export const mapLecturer = (x: any): Lecturer => ({
  id: x.id,
  email: x.email ?? '',
  maGiangVien: x.maGiangVien ?? x.maGV ?? '',
  hoTen: x.hoTen ?? x.ten ?? '',
  soDienThoai: x.soDienThoai ?? x.sdt ?? '',
  hocHam: x.hocHam ?? '',
  hocVi: x.hocVi ?? '',
  vaiTro: (x.vaiTro ?? 'GIANG_VIEN') as LecturerRole,
  boMonId: x.boMonId ?? x.idBoMon,
  boMonTen: x.boMonTen ?? x.tenBoMon,
  trangThai: x.trangThai ?? x.status ?? '',
});

export const universityService = {
  // Khoa / Ngành / Lớp / Bộ môn
  getDepartments, createDepartment, updateDepartment, deleteDepartment,
  getMajors, createMajor, updateMajor, deleteMajor,
  getClasses, createClass, updateClass, deleteClass,
  getSubjects, createSubject, updateSubject, deleteSubject,

  // Giảng viên
  getLecturers, createLecturer, updateLecturer, deleteLecturer,

 
  addDepartment:   createDepartment,
  addMajor:        createMajor,
  addClass:        createClass,
  addSubject:      createSubject,

  editDepartment:  updateDepartment,
  editMajor:       updateMajor,
  editClass:       updateClass,
  editSubject:     updateSubject,

  removeDepartment: deleteDepartment,
  removeMajor:      deleteMajor,
  removeClass:      deleteClass,
  removeSubject:    deleteSubject,

  // helpers
  mapLecturer,
  unwrap,
};

export default universityService;
