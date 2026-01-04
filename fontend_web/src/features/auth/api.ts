import { axios } from '@shared/libs/axios'
import { ApiResponse, PageResponse } from '@shared/types/apiResponse'
import { setToken, setUser } from '@shared/libs/storage'
import { AuthResponse } from '@shared/hooks/useAuth'  // Import từ file chun

export type LoginPayload = {
	email: string
	matKhau: string
}

const unwrap = (r: any) => {
	if (!r) return r
	const data = r.data ?? r
	return data.result ?? data
}

export const login = async (payload: LoginPayload): Promise<AuthResponse> => {
	const res = await axios.post<ApiResponse<AuthResponse>>('/api/auth/login', payload)
	const data = res.data

	if (data.code !== 200) {
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
	const resp = await axios.post('/api/auth/logout', {}, { headers: { Accept: '*/*' } })
	return unwrap(resp)
}

export const changePassword = async (currentPassword: string, newPassword: string, confirmNewPassword: string) => {
	const resp = await axios.post<ApiResponse<any>>('/api/auth/change-password', {
		currentPassword,
		newPassword,
		confirmNewPassword
	})
	return unwrap(resp)
}

export async function uploadAvatar(file: File): Promise<{ imageUrl?: string; user?: AuthResponse['user'] }> {
	const form = new FormData();
	form.append('file', file);
	const res = await axios.post<ApiResponse<any>>('/api/auth/update-avt', form, {
		headers: { 'Content-Type': 'multipart/form-data' },
	});

	return unwrap(res);
}

export type RequestResetPasswordPayload = {
	email: string
}

export type ResetPasswordPayload = {
	token: string
	newPassword: string
}

export const requestResetPassword = async (payload: RequestResetPasswordPayload) => {
	const resp = await axios.post<ApiResponse<any>>('/api/auth/request-reset-password', payload)
	const data = resp.data

	if (data.code !== 200) {
		throw new Error(data.message || 'Yêu cầu đặt lại mật khẩu thất bại')
	}

	return unwrap(resp)
}

export const resetPassword = async (payload: ResetPasswordPayload) => {
	const resp = await axios.post<ApiResponse<any>>('/api/auth/reset-password', payload)
	const data = resp.data

	if (data.code !== 200) {
		throw new Error(data.message || 'Đặt lại mật khẩu thất bại')
	}

	return unwrap(resp)
}