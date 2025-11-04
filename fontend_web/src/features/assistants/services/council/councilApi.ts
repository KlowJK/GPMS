import { axios, unwrap, toPage, type Id, type Page, type PageParams }
  from '@features/assistants/services/base';

/* ===== Types cơ bản ===== */
export type Council = {
  id: Id;
  tenHoiDong: string;
  thoiGianBatDau: string;  // yyyy-MM-dd
  thoiGianKetThuc: string; // yyyy-MM-dd
  diaDiem?: string;
};

export type CreateCouncilPayload = {
  tenHoiDong: string;
  thoiGianBatDau: string;   // yyyy-MM-dd
  thoiGianKetThuc: string;  // yyyy-MM-dd
  chuTichId: Id;
  thuKyId: Id;
  dotBaoVeId: Id;
  diaDiem?: string;
  lecturers: { giangVienId: Id }[];
};

/* ===== Chi tiết hội đồng (GET /api/hoi-dong/{id}) ===== */
export type CouncilDetail = {
  id: Id;
  tenHoiDong: string;
  thoiGianBatDau: string;
  thoiGianKetThuc: string;
  diaDiem?: string;
  chuTich?: string;
  thuKy?: string;
  giangVienPhanBien?: string[];
  sinhVienList: Array<{
    hoTen: string; maSV: string; lop: string;
    idDeTai: string; tenDeTai: string; gvhd: string;
    idBoMon?: string; boMon?: string;
  }>;
  /** Nếu BE trả kèm danh sách thành viên đã chọn khi tạo hội đồng (id + tên) */
  members?: Array<{ id: Id; hoTen: string; email?: string }>;
};

export const listCouncils = (params?: PageParams) =>
  axios.get('/api/hoi-dong', { params });

export async function listCouncilsNormalized(params?: PageParams): Promise<Page<Council>> {
  const res = await listCouncils(params);
  const raw = unwrap<any>(res);
  const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
  const map = (x: any): Council => ({
    id: x.id ?? x.hoiDongId ?? x._id,
    tenHoiDong: x.tenHoiDong ?? x.ten ?? '',
    thoiGianBatDau: (x.thoiGianBatDau ?? x.startDate ?? '').slice(0, 10),
    thoiGianKetThuc: (x.thoiGianKetThuc ?? x.endDate ?? '').slice(0, 10),
    diaDiem: x.diaDiem ?? x.diaChi ?? '',
  });
  return {
    content: arr.map(map),
    totalElements: raw?.totalElements ?? arr.length ?? 0,
    page: params?.page ?? 0,
    size: params?.size ?? 10,
  };
}

export const createCouncil = (body: CreateCouncilPayload) =>
  axios.post('/api/hoi-dong/them-hoi-dong', body);

/* ===== GET chi tiết /api/hoi-dong/{id} (result wrapper) ===== */
export async function getCouncilDetail(id: Id | string): Promise<CouncilDetail> {
  const res = await axios.get(`/api/hoi-dong/${id}`);
  const raw = unwrap<any>(res)?.result ?? {};
  // cố gắng chuẩn hoá members nếu BE trả các key khác nhau
  const rawMembers: any[] =
    raw.members ?? raw.thanhVienList ?? raw.giangVienThamGia ?? [];
  const members = Array.isArray(rawMembers)
    ? rawMembers.map((m: any) => ({
        id: m?.id ?? m?.giangVienId ?? m?.uid ?? m,
        hoTen: m?.hoTen ?? m?.ten ?? (typeof m === 'string' ? m : ''),
        email: m?.email,
      })).filter((m: any) => m.id != null && m.hoTen)
    : [];

  return {
    id: raw.id,
    tenHoiDong: raw.tenHoiDong ?? '',
    thoiGianBatDau: raw.thoiGianBatDau,
    thoiGianKetThuc: raw.thoiGianKetThuc,
    diaDiem: raw.diaDiem ?? raw.diaChi,
    chuTich: raw.chuTich,
    thuKy: raw.thuKy,
    giangVienPhanBien: Array.isArray(raw.giangVienPhanBien) ? raw.giangVienPhanBien : [],
    sinhVienList: Array.isArray(raw.sinhVienList) ? raw.sinhVienList : [],
    members,
  };
}

/* ===== Gán giảng viên phản biện đề tài =====*/
export const addTopicReviewLecturers = (payload: {
  idDeTai: string;
  lecturers: { giangVienId: Id }[];
}) => axios.post('/api/hoi-dong/them-giang-vien-pb-de-tai', payload);
/* ===== Chi tiết SV/Đề tài trong hội đồng (GET /api/hoi-dong/sinh-vien/{deTaiId}/chi-tiet) ===== */
export type CouncilStudentDetail = {
  id: Id;
  tenHoiDong: string;
  thoiGianBatDau: string;     // yyyy-MM-dd
  thoiGianKetThuc: string;    // yyyy-MM-dd
  maSinhVien: string;
  hoTen: string;
  lop: string;
  idDeTai: string;
  tenDeTai: string;
  duongDanBaoCao?: string;
  gvhd: string;
  idBoMon?: string;
  boMon?: string;
  diemBaoCao?: number;
  diemPhanBien?: number;
  diemHoiDong?: number;
  giangVien: Array<{
    idGiangVien: Id;
    hoTen: string;
    maGiangVien?: string;
    vaiTro?: string;
    idBoMon?: string;
    boMon?: string;
    diem?: number;
    nhanXet?: string;
    trangThai?: string;
    hopLe?: string;
  }>;
};

export async function getCouncilStudentDetail(deTaiId: Id | string): Promise<CouncilStudentDetail> {
  const res = await axios.get(`/api/hoi-dong/sinh-vien/${deTaiId}/chi-tiet`);
  const raw = unwrap<any>(res)?.result ?? {};

  return {
    id: raw.id ?? raw.hoiDongId ?? raw._id,
    tenHoiDong: raw.tenHoiDong ?? raw.ten ?? '',
    thoiGianBatDau: raw.ngayBatDau ?? raw.thoiGianBatDau ?? '',
    thoiGianKetThuc: raw.ngayKetThuc ?? raw.thoiGianKetThuc ?? '',
    maSinhVien: raw.maSinhVien ?? raw.maSV ?? '',
    hoTen: raw.hoTen ?? '',
    lop: raw.lop ?? '',
    idDeTai: raw.idDeTai ?? String(deTaiId),
    tenDeTai: raw.tenDeTai ?? '',
    duongDanBaoCao: raw.duongDanBaoCao ?? raw.baoCaoUrl,
    gvhd: raw.gvhd ?? raw.giangVienHuongDan ?? '',
    idBoMon: raw.idBoMon,
    boMon: raw.boMon,
    diemBaoCao: raw.diemBaoCao,
    diemPhanBien: raw.diemPhanBien,
    diemHoiDong: raw.diemHoiDong,
    giangVien: Array.isArray(raw.giangVien)
      ? raw.giangVien.map((g: any) => ({
          idGiangVien: g.idGiangVien ?? g.id ?? g.giangVienId,
          hoTen: g.hoTen ?? g.ten ?? '',
          maGiangVien: g.maGiangVien ?? g.maGV,
          vaiTro: g.vaiTro,
          idBoMon: g.idBoMon,
          boMon: g.boMon,
          diem: g.diem,
          nhanXet: g.nhanXet,
          trangThai: g.trangThai,
          hopLe: g.hopLe,
        }))
      : [],
  };
}
