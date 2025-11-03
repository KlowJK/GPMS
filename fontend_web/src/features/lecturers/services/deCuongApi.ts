import { axios } from '@shared/libs/axios'
import type { AxiosError } from 'axios'

/**
 * Reject a proposal (đề cương) by id (and optional version/phienBan).
 * Endpoint: PUT /api/de-cuong/{id}/tu-choi?reason={reason}
 * Body: optionally { phienBan: number }
 * Returns: resp.data.result
 */
export async function rejectDeCuong(id: string | number, phienBan?: number | string, reason?: string) {
  const q = reason ? `?reason=${encodeURIComponent(String(reason))}` : ''
  const url = `/api/de-cuong/${encodeURIComponent(String(id))}/tu-choi${q}`
  const payload: any = {}
  if (phienBan !== undefined) payload.phienBan = phienBan
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    const aerr = err as AxiosError | undefined
    if (aerr && aerr.response && aerr.response.status === 401) {
      const e = new Error('Unauthorized') as Error & { status?: number }
      e.status = 401
      throw e
    }
    if (aerr && (aerr.code === 'ECONNABORTED' || /timeout/i.test(String(aerr.message)))) {
      const e = new Error('Request timeout') as Error & { code?: string }
      e.code = 'TIMEOUT'
      throw e
    }
    throw err
  }
}

/**
 * Approve a proposal (đề cương) by id and optional version/phienBan.
 * Endpoint: PUT /api/de-cuong/{id}/duyet?reason={reason}
 * Body: optionally { phienBan: number }
 * Returns: resp.data.result
 */
export async function approveDeCuong(id: string | number, phienBan?: number | string, reason?: string) {
  const q = reason ? `?reason=${encodeURIComponent(String(reason))}` : ''
  const url = `/api/de-cuong/${encodeURIComponent(String(id))}/duyet${q}`
  const payload: any = {}
  if (phienBan !== undefined) payload.phienBan = phienBan
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    const aerr = err as AxiosError | undefined
    if (aerr && aerr.response && aerr.response.status === 401) {
      const e = new Error('Unauthorized') as Error & { status?: number }
      e.status = 401
      throw e
    }
    if (aerr && (aerr.code === 'ECONNABORTED' || /timeout/i.test(String(aerr.message)))) {
      const e = new Error('Request timeout') as Error & { code?: string }
      e.code = 'TIMEOUT'
      throw e
    }
    throw err
  }
}

/**
 * Fetch proposals (đề cương) page filtered by status / roles
 * GET /api/de-cuong?page=0&size=10&sort=updatedAt,DESC&status=...
 * Returns resp.data.result (paged)
 */
export async function fetchDeCuongPage(params: { page?: number; size?: number; sort?: string[]; status?: string; } = {}) {
  const search = new URLSearchParams()
  if (typeof params.page === 'number') search.append('page', String(params.page))
  if (typeof params.size === 'number') search.append('size', String(params.size))
  if (params.sort) params.sort.forEach(s => search.append('sort', s))
  if (params.status) search.append('status', params.status)

  const url = `/api/de-cuong?${search.toString()}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  const result = resp.data?.result ?? { content: [] }

  // normalize items slightly for UI convenience
  if (result && Array.isArray(result.content)) {
    result.content = result.content.map((it: any) => ({
      id: it.id,
      deCuongUrl: it.deCuongUrl ?? it.fileUrl ?? null,
      trangThaiDeCuong: it.trangThaiDeCuong ?? it.trangThai ?? it.trangthai ?? '',
      phienBan: it.phienBan,
      tenDeTai: it.tenDeTai ?? it.title ?? '',
      maSinhVien: it.maSinhVien ?? it.maSV ?? it.maSV ?? '',
      hoTenSinhVien: it.hoTenSinhVien ?? it.hoTen ?? it.hoTenSV ?? '',
      giangVienHuongDan: it.giangVienHuongDan ?? it.gvhd ?? '',
      giangVienPhanBien: it.giangVienPhanBien ?? it.gvpb ?? '',
      gvPhanBienDuyet: it.gvPhanBienDuyet ?? it.gvPhanBienDuyet ?? null,
      truongBoMon: it.truongBoMon ?? it.tbm ?? '',
      tbmDuyet: it.tbmDuyet ?? it.tbmDuyet ?? null,
      nhanXets: Array.isArray(it.nhanXets) ? it.nhanXets : (it.nhanXet ? [{ nhanXet: it.nhanXet }] : []),
      raw: it,
    }))
  }

  return result
}
