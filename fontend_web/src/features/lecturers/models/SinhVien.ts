export interface SinhVien {
  maSV: string
  hoTen?: string
  email?: string
  soDienThoai?: string
  ngaySinh?: string
  tenNganh?: string
  tenLop?: string
  duongDanCv?: string | null
  [key: string]: any
}

export default SinhVien
