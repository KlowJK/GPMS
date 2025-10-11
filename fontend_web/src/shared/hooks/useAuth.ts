
import { jwtDecode } from 'jwt-decode'
import { useEffect, useState } from 'react'
import { getToken, getUser } from '@shared/libs/storage'

type Payload = { roles?: string[] }

export function useAuth() {
    const [token, setToken] = useState<string | null>(() => getToken())
    const [user, setUser] = useState<any>(() => getUser())

    useEffect(() => {
        const onStorage = () => {
            setToken(getToken())
            setUser(getUser())
        }
        // listen for changes in other tabs
        window.addEventListener('storage', onStorage)
        return () => window.removeEventListener('storage', onStorage)
    }, [])

    let roles: string[] = []
    if (user?.role) roles = [user.role]
    else if (token) {
        try {
            const p = jwtDecode<Payload>(token)
            roles = p?.roles ?? []
        } catch {}
    }

    return {
        isAuthenticated: !!token,
        roles,
        user,
    }
}
