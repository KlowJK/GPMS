import Axios from 'axios'
import { getToken } from './storage'
import { ApiError } from '@shared/utils/error'
import { ErrorCode } from '@shared/constants/errorCode'

const RAW_BASE = (import.meta.env.VITE_API_BASE_URL as string) ?? 'http://localhost:8080'
const BASE_URL = RAW_BASE.replace(/\/+$/g, '').replace(/\/$/, '')

export const axios = Axios.create({
    baseURL: BASE_URL,
    withCredentials: false,
})

axios.interceptors.request.use((config) => {
    const token = getToken()
    const isLoginRequest = typeof config.url === 'string' && /\/auth\/login/i.test(config.url)

    if (token && !isLoginRequest) {
        ;(config.headers as any) = {
            ...(config.headers || {}),
            Authorization: `Bearer ${token}`,
        }
    }

    // Tránh double /api/api
    try {
        if (typeof config.url === 'string') {
            const baseLower = String(BASE_URL).toLowerCase()
            const url = config.url
            if (baseLower.endsWith('/api') && url.startsWith('/api/')) {
                config.url = url.replace(/^\/api/, '')
            }
        }
    } catch (e) {}

    // Dev logging
    if (import.meta.env.DEV) {
        try {
            const safeData = typeof config.data === 'string' ? config.data : JSON.stringify(config.data)
            console.debug('[axios request]', config.method?.toUpperCase(), config.url, {
                headers: config.headers,
                data: safeData,
            })
        } catch (e) {}
    }

    return config
})

axios.interceptors.response.use(
    (resp) => {
        if (import.meta.env.DEV) {
            console.debug('[axios response]', resp.config?.url, resp.status, resp.data)
        }
        return resp
    },
    (err) => {
        const status = err.response?.status
        const data = err.response?.data

        if (import.meta.env.DEV) {
            console.error('[axios error]', err.config?.url, status, data)
        }

        // Nếu backend trả về { code, message } → chuẩn hóa thành ApiError
        if (data?.code && data?.message) {
            const apiError = new ApiError(data.message, data.code as ErrorCode, status)
            return Promise.reject(apiError)
        }

        // Lỗi mạng, 5xx, v.v.
        return Promise.reject(err)
    }
)