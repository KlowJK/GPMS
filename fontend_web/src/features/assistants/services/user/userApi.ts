import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@/features/assistants/services/base';

/* ===================== GIẢNG VIÊN ===================== */
export type Lecturer = {
  id: Id;
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  idBoMon?: Id;        // ✅ bảo đảm luôn có idBoMon nếu BE trả về
  boMonTen?: string;
  laTruongBoMon?: boolean;
};

export type LecturerCreatePayload = {
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  matKhau: string;
  idBoMon: Id;         // FE dùng idBoMon; BE có thể nhận boMonId cũng ok
};

export type LecturerUpdatePayload = Omit<LecturerCreatePayload, 'matKhau'> & {
  laTruongBoMon?: boolean;
};

export const listLecturers  = (params?: PageParams) => axios.get('/api/giang-vien/list', { params });
export const createLecturer = (body: LecturerCreatePayload) => axios.post('/api/giang-vien', body);
export const updateLecturer = (id: Id, body: LecturerUpdatePayload) => axios.put(`/api/giang-vien/${id}`, body);

// ✅ NEW: import Excel
export const importLecturers = (file: File) => {
  const fd = new FormData();
  fd.append('file', file);
  return axios.post('/api/giang-vien/import', fd, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });
};

// ✅ Chuẩn hoá bản ghi để chắc chắn có idBoMon & boMonTen
function normalizeLecturer(x: any): Lecturer {
  const boMon = x.boMon ?? {};
  const idBoMon =
    x.idBoMon ?? x.boMonId ?? boMon.id ?? x.id_bo_mon ?? x.id_bm;

  return {
    id: x.id ?? x.giangVienId ?? x._id,
    maGiangVien: x.maGiangVien ?? x.maGV ?? x.code ?? '',
    hoTen: x.hoTen ?? x.ten ?? '',
    soDienThoai: x.soDienThoai ?? x.sdt,
    hocVi: x.hocVi,
    hocHam: x.hocHam,
    email: x.email ?? '',
    idBoMon: idBoMon,
    boMonTen: x.boMonTen ?? boMon.tenBoMon ?? boMon.ten ?? '',
    laTruongBoMon: x.laTruongBoMon ?? x.isHead ?? false,
  };
}

// ✅ Dùng khi cần page có content đã normalize
export async function listLecturersNormalized(params?: PageParams): Promise<Page<Lecturer>> {
  const res = await listLecturers(params);
  const pg = toPage<any>(res, { page: params?.page ?? 0, size: params?.size ?? 10 });
  return { ...pg, content: (pg.content ?? []).map(normalizeLecturer) };
}
/* ===================== SINH VIÊN ===================== */
export type Student = {
  id: Id; email: string; maSinhVien: string; hoTen: string; soDienThoai?: string; lopTen?: string; duDieuKien?: boolean;
};
export type CreateStudentBody = {
  maSinhVien: string; hoTen: string; soDienThoai: string; email: string; matKhau: string; idLop: Id;
};
export type UpdateStudentBody = { hoTen: string; soDienThoai: string; email: string; idLop: Id; matKhau?: string };

export const listStudents = (params?: PageParams) => axios.get('/api/sinh-vien', { params });
export const searchStudents = (info: string, params?: PageParams) =>
  axios.get('/api/sinh-vien/search', { params: { ...params, info } });
export const getStudentByMSV = (maSV: string) => axios.get(`/api/sinh-vien/${maSV}`);
export const getStudentById  = (id: Id) => axios.get(`/api/sinh-vien/by-id/${id}`);
export const createStudent   = (body: CreateStudentBody) => axios.post('/api/sinh-vien', body);
export const updateStudentByCode = (maSV: string, body: UpdateStudentBody) => axios.put(`/api/sinh-vien/${maSV}`, body);
export const changeStudentStatusByCode = (maSV: string) => axios.put(`/api/sinh-vien/change-status/${maSV}`);
export const importStudents  = (formData: FormData) =>
  axios.post('/api/sinh-vien/import', formData, { headers: { 'Content-Type': 'multipart/form-data' } });

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

export async function listStudentsNormalized(params?: PageParams): Promise<Page<Student>> {
  const res = await listStudents(params);
  const pg = toPage<any>(res, { page: params?.page ?? 0, size: params?.size ?? 10 });
  return { ...pg, content: (pg.content ?? []).map(normalizeStudent) };
}
