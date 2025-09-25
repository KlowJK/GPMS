
import { jwtDecode } from 'jwt-decode'

import { useMemo } from 'react'

export function useAuth() {
    const token = localStorage.getItem('gpms_token')
    const payload = useMemo(() => {
        if (!token) return null
        try { return jwtDecode<{ roles?: string[] }>(token) } catch { return null }
    }, [token])

    return {
        isAuthenticated: !!token && !!payload,
        roles: payload?.roles ?? []
    }
}
