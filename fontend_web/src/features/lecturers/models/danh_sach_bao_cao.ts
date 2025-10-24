// Shared models for the lecturers feature
// Keep fields optional where backend may omit them; expand as backend schema stabilizes.

export interface Student {
  maSV: string
  hoTen?: string
  email?: string
  soDienThoai?: string
  ngaySinh?: string
  tenNganh?: string
  gioiTinh?: string
  tenLop?: string
  // raw extra fields
  [key: string]: any
}

export interface ReportComment {
  nhanXet?: string
  hoTenGiangVien?: string
  // allow extra metadata
  [key: string]: any
}

export interface ReportVersion {
  id: string | number
  phienBan?: number
  tenDeTai?: string
  title?: string
  ngayNop?: string
  fileUrl?: string | null
  fileName?: string | null
  trangThai?: string
  diem?: number | string | null
  nhanXets?: ReportComment[] | string | null
  maSV?: string
  raw?: any
}

export interface PagedResult<T> {
  content: T[]
  page?: number
  size?: number
  totalElements?: number
  totalPages?: number
  [key: string]: any
}

export default {}
