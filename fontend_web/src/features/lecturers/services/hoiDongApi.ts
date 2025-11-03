import { axios } from '@shared/libs/axios'

export async function fetchHoiDongList(idGiangVien?: number) {
  const resp = await axios.get('/api/hoi-dong', {
    params: { idGiangVien, sort: 'thoiGianBatDau,DESC' },
    headers: { Accept: '*/*' },
    timeout: 10000,
  })
  return resp.data?.result
}

export async function fetchHoiDongDetail(id: number | null) {
  if (!id) return null
  const resp = await axios.get(`/api/hoi-dong/${id}`, { headers: { Accept: '*/*' }, timeout: 10000 })
  return resp.data?.result
}

/**
 * Fetch detailed info for a student's defense (committee member scores etc.)
 * GET /api/hoi-dong/sinh-vien/{deTaiId}/chi-tiet
 */
export async function fetchHoiDongStudentDetail(deTaiId: number | string | null) {
  if (!deTaiId) return null
  const url = `/api/hoi-dong/sinh-vien/${encodeURIComponent(String(deTaiId))}/chi-tiet`
  const resp = await axios.get(url, { headers: { Accept: '*/*' }, timeout: 10000 })
  return resp.data?.result ?? null
}
