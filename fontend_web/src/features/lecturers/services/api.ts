import { axios } from '@shared/libs/axios'
import type { PageXetDuyet } from '../models/danh_sach_duyet'
import type { AxiosError } from 'axios'

export async function fetchReviewList(params: { status?: string; page?: number; size?: number; sort?: string[] }) {
  const searchParams = new URLSearchParams()
  if (params.status) searchParams.append('status', params.status)
  if (typeof params.page === 'number') searchParams.append('page', String(params.page))
  if (typeof params.size === 'number') searchParams.append('size', String(params.size))
  if (params.sort) params.sort.forEach(s => searchParams.append('sort', s))

  const url = `/api/giang-vien/do-an/xet-duyet-de-tai?${searchParams.toString()}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  // API returns JSON wrapped in `result`
  const result = resp.data.result as PageXetDuyet

  // Normalize status field variations from backend to always provide `trangThai`
  function normalizeStatus(raw: any): string | null {
    if (raw == null) return null
    const s = String(raw).toUpperCase().replace(/\s+|_|-|\./g, '')
    // Map common variants to canonical values the UI uses
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO' || s === 'CHODUYET') return 'CHO_XET_DUYET'
    if (s.includes('DADUYET') || s === 'DADUYET' || s === 'DA') return 'DA_DUYET'
    if (s.includes('TUCHOI') || s.includes('TUCHỐI') || s === 'TUCHOI' || s === 'TUCHOI' || s === 'TU_CHOI') return 'TU_CHOI'
    // fallback: return raw as-is (preserve value) or null
    return String(raw)
  }

  if (result && Array.isArray(result.content)) {
    result.content = result.content.map((c: any) => {
      const raw = c.trangThai ?? c.trangthai ?? c.status ?? c.trang_thai ?? null
      const trangThai = normalizeStatus(raw)
      return { ...c, trangThai }
    })
  }

  return result
}

export async function approveReview(idDeTai: string) {
  const url = `/api/giang-vien/do-an/${encodeURIComponent(idDeTai)}/approve`
  const resp = await axios.post(url)
  return resp.data
}

export async function rejectReview(idDeTai: string) {
  const url = `/api/giang-vien/do-an/${encodeURIComponent(idDeTai)}/reject`
  const resp = await axios.post(url)
  return resp.data
}

/**
 * Approve or reject a proposal (use approved=true to approve)
 * PUT /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/approve
 * Body: { approved: boolean, nhanXet: string }
 * Returns: resp.data.result (object)
 */
export async function approveDeTai(deTaiId: string | number, payload: { approved: boolean; nhanXet: string }) {
  const url = `/api/giang-vien/do-an/xet-duyet-de-tai/${encodeURIComponent(String(deTaiId))}/approve`
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*' }, timeout: 10000 })
    // return the `result` object from the API wrapper
    return resp.data?.result
  } catch (err) {
    const aerr = err as AxiosError | undefined
    if (aerr && aerr.response && aerr.response.status === 401) {
      const e = new Error('Unauthorized') as Error & { status?: number }
      e.status = 401
      throw e
    }
    // axios uses code === 'ECONNABORTED' for timeouts in many environments
    if (aerr && (aerr.code === 'ECONNABORTED' || /timeout/i.test(String(aerr.message)))) {
      const e = new Error('Request timeout') as Error & { code?: string }
      e.code = 'TIMEOUT'
      throw e
    }
    // rethrow other errors
    throw err
  }
}
