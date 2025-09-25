import { axios } from '@shared/libs/axios'
export type LoginReq = { email: string; password: string }
export type LoginRes = { accessToken: string; tokenType: 'Bearer' }
export const login = (payload: LoginReq) => axios.post<LoginRes>('/api/auth/login', payload).then(r => r.data)
export const me = () => axios.get('/api/auth/me').then(r => r.data)
