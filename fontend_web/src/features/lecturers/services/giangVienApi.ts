import { axios } from '@shared/libs/axios'
import type { PhanTrang } from '../models/PhanTrang'
import type { XetDuyetItem } from '../models/DanhSachDuyetModels'
import type { SinhVien } from '../models/SinhVien'
import type { GiangVien } from '../models/GiangVien'
import type { AxiosError } from 'axios'

/**
 * Fetch lecturers for the current TBM's department
 * GET /api/giang-vien/by-truong-bo-mon
 */
export async function fetchLecturersByTruongBoMon() {
  const resp = await axios.get('/api/giang-vien/by-truong-bo-mon', { headers: { Accept: '*/*' }, timeout: 30000 })
  return resp.data?.result ?? resp.data
}

export type { GiangVienTb } from '../models/GiangVien'

export default fetchLecturersByTruongBoMon

export async function fetchReviewList(params: { status?: string; page?: number; size?: number; sort?: string[] }): Promise<PhanTrang<XetDuyetItem>> {
  const searchParams = new URLSearchParams()
  if (params.status) searchParams.append('status', params.status)
  if (typeof params.page === 'number') searchParams.append('page', String(params.page))
  if (typeof params.size === 'number') searchParams.append('size', String(params.size))
  if (params.sort) params.sort.forEach(s => searchParams.append('sort', s))

  const url = `/api/giang-vien/do-an/xet-duyet-de-tai?${searchParams.toString()}`
  // This endpoint may take longer for large pages; allow longer timeout here.
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 30000 })
  // API returns JSON wrapped in `result`
  const result = resp.data.result as PhanTrang<XetDuyetItem>

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

/**
 * Fetch students who don't have a supervisor yet
 * GET /api/giang-vien/sinh-vien-chua-co-gvhd
 */
export async function fetchStudentsWithoutSupervisor(params: { page?: number; size?: number; sort?: string[]; status?: string } = {}): Promise<PhanTrang<SinhVien>> {
  const searchParams = new URLSearchParams()
  if (typeof params.page === 'number') searchParams.append('page', String(params.page))
  if (typeof params.size === 'number') searchParams.append('size', String(params.size))
  if (params.sort) params.sort.forEach(s => searchParams.append('sort', s))
  if (params.status) searchParams.append('status', params.status)

  const url = `/api/giang-vien/sinh-vien-chua-co-gvhd?${searchParams.toString()}`
  // This endpoint may return a large result set when page/size are large; allow longer timeout
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 30000 })
  return resp.data?.result ?? { content: [] }
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
 * Fetch student's proposal submissions (đề cương) by student code
 * GET /api/giang-vien/sinh-vien/log?maSinhVien={maSinhVien}
 * Returns an array of proposals with normalized `trangThai` and some convenience fields
 */
export async function fetchStudentProposals(maSinhVien: string) {
  const search = new URLSearchParams()
  search.append('maSinhVien', maSinhVien)
  const url = `/api/giang-vien/sinh-vien/log?${search.toString()}`
  // Proposal history requests can take longer; increase timeout
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 30000 })
  const items = resp.data?.result ?? []

  function normalizeStatus(raw: any): string {
    if (raw == null) return ''
    const s = String(raw).toUpperCase().replace(/\s+|_|-|\./g, '')
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO' || s === 'CHODUYET') return 'CHO_XET_DUYET'
    if (s.includes('DADUYET') || s === 'DADUYET' || s === 'DA') return 'DA_DUYET'
    if (s.includes('TUCHOI') || s === 'TUCHOI' || s === 'TUCHOI' || s === 'TU_CHOI') return 'TU_CHOI'
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
 * Get lecturers by department id
 * GET /api/giang-vien/{boMonId}
 * Returns array (resp.data.result)
 */
export async function getLecturersByBoMon(boMonId: string | number): Promise<GiangVien[]> {
  if (!boMonId) return []
  const url = `/api/giang-vien/${encodeURIComponent(String(boMonId))}`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 50000 })
  return resp.data?.result ?? resp.data ?? []
}

/**
 * Update quota (soLuongChoPhepHuongDan) for a single lecturer
 * PUT /api/giang-vien/{id}/quota?quotaInstruct={number}
 */
export async function updateQuotaForLecturer(id: string | number, quotaInstruct: number) {
  if (id == null) throw new Error('Missing lecturer id')
  const url = `/api/giang-vien/${encodeURIComponent(String(id))}/quota`
  const resp = await axios.put(url, null, { params: { quotaInstruct }, headers: { Accept: '*/*' }, timeout: 20000 })
  return resp.data?.result ?? resp.data
}

/**
 * Bulk update quotas for multiple lecturers. Returns Promise.allSettled results.
 * Note: backend currently exposes per-lecturer endpoint; this helper runs them in parallel.
 */
export async function bulkUpdateQuotas(ids: Array<string | number>, quotaInstruct: number) {
  const tasks = ids.map(id => updateQuotaForLecturer(id, quotaInstruct).then(r => ({ id, ok: true, result: r })).catch(e => ({ id, ok: false, error: e })))
  return Promise.allSettled(tasks)
}
