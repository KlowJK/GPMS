export interface DeCuong {
  id: string | number
  tenDeTai?: string
  phienBan?: number
  fileUrl?: string | null
  fileName?: string | null
  trangThai?: string
  maSV?: string
  hoTenSinhVien?: string
  nhanXets?: any[] | null
  tongQuanDeTaiUrl?: string | null
  raw?: any
  [key: string]: any
}

export default DeCuong
