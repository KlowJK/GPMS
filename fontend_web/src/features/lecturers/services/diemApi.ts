import { axios } from '@shared/libs/axios'
import type { AxiosError } from 'axios'

/**
 * Save a common score for a deTai (POST /api/diem/nhap-diem-chung)
 * Body: { idDeTai, diem, nhanXet }
 */
export async function saveCommonScore(payload: { idDeTai: number | string; diem: number; nhanXet?: string }) {
  const url = '/api/diem/nhap-diem-chung'
  try {
    const resp = await axios.post(url, payload, { headers: { Accept: '*/*', 'Content-Type': 'application/json' }, timeout: 10000 })
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
 * Approve common scores for a deTai (POST /api/diem/{idDeTai}/phe-duyet-diem-chung)
 */
export async function approveCommonScore(idDeTai: number | string) {
  const url = `/api/diem/${encodeURIComponent(String(idDeTai))}/phe-duyet-diem-chung`
  try {
    const resp = await axios.post(url, null, { headers: { Accept: '*/*' }, timeout: 10000 })
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
