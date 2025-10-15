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

/**
 * Reject a proposal
 * PUT /api/giang-vien/do-an/xet-duyet-de-tai/{deTaiId}/reject
 * Body: { approved: false, nhanXet: string }
 * Returns: resp.data.result
 */
export async function rejectDeTai(deTaiId: string | number, nhanXet: string) {
  const url = `/api/giang-vien/do-an/xet-duyet-de-tai/${encodeURIComponent(String(deTaiId))}/reject`
  const payload = { approved: false, nhanXet }
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result
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
 * Approve a student's proposal submission (đề cương) by id
 * PUT /api/giang-vien/sinh-vien/log/{id}/approve
 */
export async function approveProposal(proposalId: string | number, payload?: { nhanXet?: string }) {
  const url = `/api/giang-vien/sinh-vien/log/${encodeURIComponent(String(proposalId))}/approve`
  try {
    const resp = await axios.put(url, payload ?? {}, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    throw err
  }
}

/**
 * Reject a student's proposal submission (đề cương) by id
 * PUT /api/giang-vien/sinh-vien/log/{id}/reject
 */
export async function rejectProposal(proposalId: string | number, nhanXet?: string) {
  const url = `/api/giang-vien/sinh-vien/log/${encodeURIComponent(String(proposalId))}/reject`
  const payload = { nhanXet: nhanXet ?? '' }
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    throw err
  }
}

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
 * Fetch student's proposal submissions (đề cương) by student code
 * GET /api/giang-vien/sinh-vien/log?maSinhVien={maSinhVien}
 * Returns an array of proposals with normalized `trangThai` and some convenience fields
 */
export async function fetchStudentProposals(maSinhVien: string) {
  const search = new URLSearchParams()
  search.append('maSinhVien', maSinhVien)
  const url = `/api/giang-vien/sinh-vien/log?${search.toString()}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  const items = resp.data?.result ?? []

  function normalizeStatus(raw: any): string {
    if (raw == null) return ''
    const s = String(raw).toUpperCase().replace(/\s+|_|-|\./g, '')
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO' || s === 'CHODUYET') return 'CHO_XET_DUYET'
    if (s.includes('DADUYET') || s === 'DADUYET' || s === 'DA') return 'DA_DUYET'
    if (s.includes('TUCHOI') || s.includes('TUCHOI') || s === 'TUCHOI' || s === 'TU_CHOI') return 'TU_CHOI'
    return String(raw)
  }

  return (Array.isArray(items) ? items : []).map((it: any) => {
    const raw = it.trangThai ?? it.trangthai ?? it.status ?? null
    const trangThai = normalizeStatus(raw)
    const fileUrl = it.deCuongUrl ?? it.fileUrl ?? ''
    const fileName = fileUrl ? String(fileUrl).split('/').pop() ?? '' : (it.fileName ?? '')
    return {
      id: it.id,
      tenDeTai: it.tenDeTai ?? it.title ?? '',
      phienBan: it.phienBan,
      fileUrl,
      fileName,
      trangThai,
      maSV: it.maSV ?? it.maSinhVien ?? '',
      hoTenSinhVien: it.hoTenSinhVien ?? it.hoTen ?? '',
      nhanXets: Array.isArray(it.nhanXets) ? it.nhanXets : [],
      createdAt: it.createdAt,
      raw: it,
    }
  })
}

/*
Usage example (in a component):

import { useQuery } from '@tanstack/react-query'
import { fetchStudentProposals, approveProposal, rejectProposal } from './services/api'

const { data: proposals } = useQuery(['sinh-vien-proposals', maSV], () => fetchStudentProposals(maSV), { enabled: !!maSV })

function isPending(trangThai: string) {
  return String(trangThai).toUpperCase().includes('CHO') || String(trangThai).toUpperCase().includes('CHOXET') || String(trangThai).toUpperCase().includes('CHODUYET')
}

// In render: proposals.map(p => isPending(p.trangThai) ? show approve/reject buttons : show status)
*/
