import { axios } from '@shared/libs/axios'

// The backend may wrap the actual payload inside a `result` field.
// Normalize responses so callers always get the inner object when present.
export type LoginReq = { username: string; password: string }

export type LoginNormalized = {
	accessToken?: string
	tokenType?: string
	expiresAt?: number
	user?: any
	message?: string
	code?: number
	raw?: any
}

const unwrap = (r: any) => {
	if (!r) return r
	const data = r.data ?? r
	// prefer result if backend wraps payload
	return data.result ?? data
}

/**
 * Robust login helper.
 * Sends common aliases for username/email and password so the same function
 * works against different server shapes (swagger shows `matKhau` while others
 * use `password`). Returns a normalized object containing accessToken and user.
 */
export const login = async ({ username, password }: LoginReq): Promise<LoginNormalized> => {
	// Try a sequence of payload shapes. Swagger shows `{ email, matKhau }` works,
	// so try that first, then fall back to other common variants.
	const variants: any[] = [
		{ email: username, matKhau: password }, // swagger example
		{ email: username, password },
		{ username, password },
		{ taiKhoan: username, matKhau: password },
		{ email: username, token: password },
	]

	let lastErr: any = null
	for (const payload of variants) {
		try {
			// include Accept header like Swagger UI
			const resp = await axios.post('/api/auth/login', payload, { headers: { 'Content-Type': 'application/json', Accept: '*/*' } })
			const data = unwrap(resp)

			const accessToken = data?.accessToken ?? data?.token ?? data?.access_token
			const tokenType = data?.tokenType ?? data?.token_type ?? 'Bearer'
			const expiresAt = data?.expiresAt ?? data?.expires_at
			const user = data?.user ?? data

			return {
				accessToken,
				tokenType,
				expiresAt,
				user,
				message: data?.message,
				code: data?.code,
				raw: data,
			}
		} catch (e) {
			lastErr = e
			// continue to next variant
		}
	}

	// If we reach here, all variants failed — throw the last error so caller can show message
	throw lastErr
}

export const me = () => axios.get('/api/auth/me').then(r => unwrap(r))

export const logout = async () => {
	// call server logout to invalidate token/session if backend supports it
	const resp = await axios.post('/api/auth/logout', {}, { headers: { Accept: '*/*' } })
	return unwrap(resp)
}
