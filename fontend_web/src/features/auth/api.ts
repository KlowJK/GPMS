import { axios } from '@shared/libs/axios'

// The backend may wrap the actual payload inside a `result` field.
// Normalize responses so callers always get the inner object when present.
export type LoginReq = { email: string; password: string }
export type LoginRes = { accessToken: string; tokenType?: 'Bearer'; [k: string]: any }

const unwrap = (r: any) => {
	if (!r) return r
	const data = r.data ?? r
	// prefer result if backend wraps payload
	return data.result ?? data
}

export const login = (payload: LoginReq) => axios.post('/api/auth/login', payload).then(r => unwrap(r))
export const me = () => axios.get('/api/auth/me').then(r => unwrap(r))
