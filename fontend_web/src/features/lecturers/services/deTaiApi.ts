import { axios } from '@shared/libs/axios'

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
    // rethrow to let callers handle
    throw err
  }
}

export async function rejectDeTai(deTaiId: string | number, nhanXet: string) {
  const url = `/api/giang-vien/do-an/xet-duyet-de-tai/${encodeURIComponent(String(deTaiId))}/reject`
  const payload = { approved: false, nhanXet }
  try {
    const resp = await axios.put(url, payload, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result
  } catch (err) {
    throw err
  }
}

/**
 * Assign a supervisor (giảng viên) to a student's topic
 * POST /api/de-tai/gan-de-tai
 * Body: { maSV: string, maGV: string }
 */
export async function assignDeTai(payload: { maSV: string; maGV: string }) {
  const url = '/api/de-tai/gan-de-tai'
  try {
    const resp = await axios.post(url, payload, { headers: { Accept: '*/*' }, timeout: 10000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    throw err
  }
}

/**
 * Fetch list of student requests to postpone thesis for department heads
 * GET /api/de-tai/danh-sach-sinh-vien/hoan-do-an-by-cn-khoa
 * Accepts pageable params: page, size, sort
 */
export async function fetchHoanDoAnByCnKhoa(params: { page?: number; size?: number; sort?: string[] } = {}) {
  const sp = new URLSearchParams()
  if (params.page != null) sp.set('page', String(params.page))
  if (params.size != null) sp.set('size', String(params.size))
  if (Array.isArray(params.sort)) params.sort.forEach(s => sp.append('sort', s))
  const url = `/api/de-tai/danh-sach-sinh-vien/hoan-do-an-by-cn-khoa?${sp.toString()}`
  try {
    const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 15000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    throw err
  }
}

/**
 * Approve a thesis postponement request (Chủ nhiệm khoa)
 * PUT /api/de-tai/duyet-don-hoan-do-an/duyet
 * Body: multipart/form-data { donHoanDoAnId, bienbanHopPheDuyetFile (file) }
 */
export async function duyetDonHoanDoAn(payload: { donHoanDoAnId: number | string; bienbanHopPheDuyetFile?: File | null }) {
  const url = '/api/de-tai/duyet-don-hoan-do-an/duyet'
  try {
    const form = new FormData()
    form.append('donHoanDoAnId', String(payload.donHoanDoAnId))
    if (payload.bienbanHopPheDuyetFile) {
      form.append('bienbanHopPheDuyetFile', payload.bienbanHopPheDuyetFile)
    }
    const resp = await axios.put(url, form, { headers: { Accept: '*/*' }, timeout: 20000 })
    return resp.data?.result ?? resp.data
  } catch (err) {
    throw err
  }
}
