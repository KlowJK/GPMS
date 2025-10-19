import Axios from 'axios'
import { getToken } from './storage'

// Use VITE_API_BASE_URL (recommended) and fall back to localhost
const RAW_BASE = (import.meta.env.VITE_API_BASE_URL as string) ?? 'http://localhost:8080'
// normalize base URL (remove trailing slashes)
const BASE_URL = RAW_BASE.replace(/\/+$|\/+$/g, '').replace(/\/$/, '')

export const axios = Axios.create({
    baseURL: BASE_URL,
    withCredentials: false,
})

axios.interceptors.request.use((config) => {
    const token = getToken()
    // avoid sending Authorization for the login endpoint
    const isLoginRequest = typeof config.url === 'string' && /\/auth\/login/i.test(config.url)
    if (token && !isLoginRequest) {
        // cast to any to avoid AxiosHeaders type incompatibilities in various Axios versions
        ;(config.headers as any) = {
            ...(config.headers || {}),
            Authorization: `Bearer ${token}`,
        }
    }

    // Prevent double '/api/api' when baseURL already contains '/api' and request url also starts with '/api'
    try {
        if (typeof config.url === 'string') {
            const baseLower = String(BASE_URL).toLowerCase()
            const url = config.url
            if (baseLower.endsWith('/api') && url.startsWith('/api/')) {
                // remove the duplicate '/api' from request url
                config.url = url.replace(/^\/api/, '')
            }
        }
    } catch (e) {
        // ignore
    }
    // dev logging
    try {
        if (import.meta.env.DEV) {
            // avoid logging large binary data
            const safeData = typeof config.data === 'string' ? config.data : JSON.stringify(config.data)
            // eslint-disable-next-line no-console
            console.debug('[axios request]', config.method, config.url, { headers: config.headers, data: safeData })
        }
    } catch (e) {
        // ignore
    }
    return config
})

axios.interceptors.response.use(
    (resp) => {
        try {
            if (import.meta.env.DEV) {
                // eslint-disable-next-line no-console
                console.debug('[axios response]', resp.config?.url, resp.status, resp.data)
            }
        } catch (e) {}
        return resp
    },
    (err) => {
        try {
            if (import.meta.env.DEV) {
                // eslint-disable-next-line no-console
                console.error('[axios error]', err?.config?.url, err?.response?.status, err?.response?.data)
            }
        } catch (e) {}
        return Promise.reject(err)
    }
)
