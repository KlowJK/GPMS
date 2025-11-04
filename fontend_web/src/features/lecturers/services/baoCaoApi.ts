import { axios } from '@shared/libs/axios'
import type { AxiosError } from 'axios'
import type { PhanTrang } from '../models/PhanTrang'
import type { ReportVersion } from '../models/DanhSachBaoCaoModels'

/**
 * Fetch paged reports for the lecturer
 * GET /api/bao-cao/page-bao-cao-giang-vien?page=0&size=10&sort=createdAt,DESC
 * Returns the API wrapper response `result` (paged) and normalizes each item into a stable shape
 */
export async function fetchReportsPage(params: { page?: number; size?: number; sort?: string[]; status?: string; maSinhVien?: string } = {}): Promise<PhanTrang<ReportVersion>> {
  const search = new URLSearchParams()
  if (typeof params.page === 'number') search.append('page', String(params.page))
  if (typeof params.size === 'number') search.append('size', String(params.size))
  if (params.sort) params.sort.forEach(s => search.append('sort', s))
  if (params.status) search.append('status', params.status)
  if (params.maSinhVien) search.append('maSinhVien', params.maSinhVien)

  const url = `/api/bao-cao/page-bao-cao-giang-vien?${search.toString()}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  const result = resp.data?.result ?? { content: [] }

  // normalize content items into a stable shape
  if (result && Array.isArray(result.content)) {
    result.content = result.content.map((it: any) => ({
      id: it.id,
      idDeTai: it.idDeTai ?? it.idDeTai,
      tenDeTai: it.tenDeTai ?? it.title ?? '',
      maSinhVien: it.maSinhVien ?? it.maSV ?? it.maSV,
      trangThai: it.trangThai ?? it.trangthai ?? it.status ?? '',
      phienBan: it.phienBan,
      ngayNop: it.ngayNop,
      fileUrl: it.duongDanFile ?? it.fileUrl ?? it.deCuongUrl ?? null,
      diemBaoCao: it.diemBaoCao ?? it.diem ?? null,
      tenGiangVienHuongDan: it.tenGiangVienHuongDan ?? it.tenGiangVienHuongDan,
      nhanXet: it.nhanXet ?? null,
      raw: it,
    }))
  }

  return result
}

/**
 * Reject a report (báo cáo) by id
 * PUT /api/bao-cao/tu-choi?idBaoCao={id}&nhanXet={nhanXet}
 * Returns: resp.data.result
 */
export async function rejectBaoCao(idBaoCao: string | number, nhanXet?: string) {
  const params: any = { idBaoCao }
  if (nhanXet !== undefined) params.nhanXet = nhanXet
  try {
    const resp = await axios.put('/api/bao-cao/tu-choi', null, { params, headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
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
 * Approve a report (báo cáo) by id
 * PUT /api/bao-cao/duyet?idBaoCao={id}&diemHuongDan={number}&nhanXet={nhanXet}
 * Returns: resp.data.result
 */
export async function approveBaoCao(idBaoCao: string | number, diemHuongDan?: number | string, nhanXet?: string) {
  const params: any = { idBaoCao }
  if (diemHuongDan !== undefined) params.diemHuongDan = diemHuongDan
  if (nhanXet !== undefined) params.nhanXet = nhanXet
  try {
    const resp = await axios.put('/api/bao-cao/duyet', null, { params, headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
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
