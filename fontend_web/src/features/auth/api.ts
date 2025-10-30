import { axios } from '@shared/libs/axios'
import { ApiResponse, PageResponse } from '@shared/types/apiResponse'
import { setToken, setUser } from '@shared/libs/storage'

export type LoginPayload = {
	email: string
	matKhau: string
}

export type LoginResponse = {
	accessToken: string
	tokenType: string
	expiresAt: number
	user: {
		id: number | string
		fullName: string
		email: string
		role: string
		duongDanAvt?: string
		enabled?: boolean
		teacherId?: number | null
		studentId?: number | null
	}
}
const unwrap = (r: any) => {
	if (!r) return r
	const data = r.data ?? r
	// prefer result if backend wraps payload
	return data.result ?? data
}

export const login = async (payload: LoginPayload): Promise<LoginResponse> => {
	const res = await axios.post<ApiResponse<LoginResponse>>('/api/auth/login', payload)
	const data = res.data

	if (data.code !== 200 && data.code !== 1073741824) {
		throw new Error(data.message || 'Đăng nhập thất bại')
	}

	const result = data.result
	if (!result?.accessToken) {
		throw new Error('Token không được trả về từ server')
	}

	setToken(result.accessToken)
	setUser(result.user)

	return result
}
export const me = () => axios.get<ApiResponse<any>>('/api/auth/me').then(r => r.data.result)

export const logout = async () => {
	// call server logout to invalidate token/session if backend supports it
	const resp = await axios.post('/api/auth/logout', {}, { headers: { Accept: '*/*' } })
	return unwrap(resp)
}
