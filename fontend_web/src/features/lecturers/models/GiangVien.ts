// Types for lecturers used across the lecturers feature
export type GiangVienTb = {
  id?: number
  maGV?: string
  hoTen?: string
  hocVi?: string
  hocHam?: string
  email?: string
  soDienThoai?: string
  soLuongDeTai?: number
  soLuongChoPhepHuongDan?: number
  raw?: any
}

export interface GiangVien {
  id?: number | string
  maGiangVien?: string
  hoTen?: string
  email?: string
  boMonId?: number | string
  chucVu?: string
  raw?: any
  [key: string]: any
}

// Named exports only (no default export) — import with `import type { GiangVienTb } from './models/giangVien'`
