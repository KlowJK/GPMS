const TOKEN_KEY = 'gpms_token'
const USER_KEY = 'gpms_user'

export const getToken = () => localStorage.getItem(TOKEN_KEY)
export const setToken = (t: string) => localStorage.setItem(TOKEN_KEY, t)
export const clearToken = () => localStorage.removeItem(TOKEN_KEY)

export const getUser = () => {
	const s = localStorage.getItem(USER_KEY)
	return s ? JSON.parse(s) : null
}

export const setUser = (u: unknown) => {
	try {
		localStorage.setItem(USER_KEY, JSON.stringify(u))
	} catch {}
}

export const clearUser = () => localStorage.removeItem(USER_KEY)
