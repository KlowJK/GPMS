import { axios } from '@shared/libs/axios'
import type { SinhVien } from '../models/SinhVien'

/**
 * Fetch student basic info by student code
 * GET /api/sinh-vien/{maSV}
 */
export async function fetchStudentByCode(maSV: string): Promise<SinhVien | null> {
  if (!maSV) return null
  const url = `/api/sinh-vien/${encodeURIComponent(String(maSV))}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  const raw = resp.data?.result ?? null
  if (!raw) return null

  // normalize commonly used fields so UI components can rely on stable keys
  const normalized = {
    // keep original raw fields available
    ...raw,
    maSV: raw.maSV ?? raw.maSinhVien ?? raw.ma ?? raw.msv,
    hoTen: raw.hoTen ?? raw.hoVaTen ?? raw.ten ?? raw.name,
    email: raw.email ?? raw.taiKhoan?.email ?? raw.user?.email,
    soDienThoai: raw.soDienThoai ?? raw.sdt ?? raw.phone,
    ngaySinh: raw.ngaySinh ?? raw.birthDate ?? raw.dateOfBirth,
    tenNganh: raw.tenNganh ?? raw.nganhTen ?? raw.nganh?.tenNganh,
    // CV url aliases consolidated to `duongDanCv`
    duongDanCv: raw.duongDanCv ?? raw.duongDanFile ?? raw.fileUrl ?? raw.cvUrl ?? (raw.cv && raw.cv.url) ?? raw.linkCv ?? null,
  }

  return normalized
}
