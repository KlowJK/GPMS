// Shared models for the lecturers feature
// Keep fields optional where backend may omit them; expand as backend schema stabilizes.
import type { SinhVien } from './SinhVien'
import type { PhanTrang } from './PhanTrang'

// Re-export SinhVien under the older name `Student` for compatibility
export type Student = SinhVien

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

export type PagedResult<T> = PhanTrang<T>
