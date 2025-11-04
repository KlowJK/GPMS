import { axios } from '@shared/libs/axios'

/**
 * Fetch weeks (tuần) for diary by lecturer
 * GET /api/nhat-ky-tien-trinh/tuans-by-lecturer?includeAll={boolean}
 * Returns: resp.data.result (array of { tuan, ngayBatDau, ngayKetThuc })
 */
export async function fetchTuansByLecturer(includeAll = false) {
  const search = new URLSearchParams()
  search.append('includeAll', String(includeAll))
  const url = `/api/nhat-ky-tien-trinh/tuans-by-lecturer?${search.toString()}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  // API returns { result: [...] }
  return resp.data?.result ?? []
}

/**
 * Fetch diary entries (nhật ký) for a given week
 * GET /api/nhat-ky-tien-trinh/all-nhat-ky/list?tuan={tuan}
 * Returns: resp.data.result (array of entries)
 */
export async function fetchDiaryListByWeek(tuan?: number) {
  const params: any = {}
  if (typeof tuan === 'number') params.tuan = tuan

  const resp = await axios.get('/api/nhat-ky-tien-trinh/all-nhat-ky/list', {
    params,
    headers: { Accept: '*/*' },
    timeout: 10000,
  })

  const items = resp.data?.result ?? []

  // Normalize to a stable shape for UI
  return (Array.isArray(items) ? items : []).map((it: any) => ({
    id: it.id,
    tuan: it.tuan,
    tenDeTai: it.deTai ?? it.tenDeTai ?? '',
    maSV: it.maSinhVien ?? it.maSv ?? it.maSV ?? '',
    lop: it.lop ?? it.class ?? '',
    idDeTai: it.idDeTai ?? it.idDeTai,
    hoTen: it.hoTen ?? it.hoTenSinhVien ?? it.hoTenSV ?? '',
    ngayBatDau: it.ngayBatDau,
    ngayKetThuc: it.ngayKetThuc,
    trangThaiNhatKy: it.trangThaiNhatKy ?? it.trangThai ?? it.trangthai ?? '',
    noiDung: it.noiDung ?? it.content ?? null,
    fileUrl: it.duongDanFile ?? it.fileUrl ?? null,
    nhanXet: it.nhanXet ?? null,
    raw: it,
  }))
}

/**
 * Fetch diary progress for a proposal (by proposal id)
 * GET /api/nhat-ky-tien-trinh/proposal/{proposalId}/progress
 * Returns: resp.data.result (array of week entries)
 * If backend path differs, adapt accordingly.
 */
export async function fetchDiaryProgressByProposal(proposalId: string | number) {
  const url = `/api/nhat-ky-tien-trinh/proposal/${encodeURIComponent(String(proposalId))}/progress`
  try {
    const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result ?? []
  } catch (err) {
    // fallback: return empty array
    return []
  }
}

/**
 * Fetch diary entries for a proposal (đề tài).
 * Endpoint: GET /api/nhat-ky-tien-trinh/{id}
 */
export async function fetchStudentDiaryByProposal(idDeTai: string | number, studentCode?: string | number) {
  const params: any = {}
  if (studentCode !== undefined && studentCode !== null) params.maSinhVien = studentCode

  const url = `/api/nhat-ky-tien-trinh/${encodeURIComponent(String(idDeTai))}`

  const resp = await axios.get(url, { params, headers: { Accept: '*/*' }, timeout: 10000 })
  const items = resp.data?.result ?? []

  return (Array.isArray(items) ? items : []).map((it: any) => ({
    id: it.id,
    tuan: it.tuan,
    tenDeTai: it.deTai ?? it.tenDeTai ?? '',
    maSV: it.maSinhVien ?? it.maSv ?? it.maSV ?? '',
    lop: it.lop ?? it.class ?? '',
    idDeTai: it.idDeTai ?? it.idDeTai,
    hoTen: it.hoTen ?? it.hoTenSinhVien ?? it.hoTenSV ?? '',
    ngayBatDau: it.ngayBatDau,
    ngayKetThuc: it.ngayKetThuc,
    trangThaiNhatKy: it.trangThaiNhatKy ?? it.trangThai ?? it.trangthai ?? '',
    noiDung: it.noiDung ?? it.noiDung ?? null,
    fileUrl: it.duongDanFile ?? it.fileUrl ?? null,
    nhanXet: it.nhanXet ?? null,
    raw: it,
  }))
}

/**
 * Review (approve) a diary entry by id with a comment (nhanXet)
 * PUT /api/nhat-ky-tien-trinh/{id}/duyet
 */
export async function reviewDiaryEntry(entryId: string | number, payload: { id: number | string; nhanXet: string }) {
  const url = `/api/nhat-ky-tien-trinh/${encodeURIComponent(String(entryId))}/duyet`
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    // rethrow
    throw err
  }
}
