import Axios from 'axios'
import { getToken } from './storage'

export const axios = Axios.create({
    baseURL: import.meta.env.VITE_API_URL ?? 'http://localhost:8080',
    withCredentials: false
})

axios.interceptors.request.use((config) => {
    const token = getToken()
    if (token) config.headers.Authorization = `Bearer ${token}`
    return config
})
