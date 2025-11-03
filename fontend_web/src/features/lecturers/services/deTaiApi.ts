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
