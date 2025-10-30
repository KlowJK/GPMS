import { jwtDecode } from 'jwt-decode'
import { useEffect, useState } from 'react'
import { getToken, getUser } from '@shared/libs/storage'
import { Role } from '@shared/constants/roles'

type Payload = { roles?: string[] }

export type User = {
    id: number | string
    fullName: string
    role: Role | string
    email: string
    duongDanAvt?: string
    enabled?: boolean
    teacherId?: number | null
    studentId?: number | null
    aadminId?: number | null
    assistantId?: number | null
    [key: string]: any
}

export type AuthResponse = {
    accessToken: string
    tokenType: string
    expiresAt: number
    user: User
}

export function useAuth() {
    const [token, setToken] = useState<string | null>(() => getToken())
    const [user, setUser] = useState<any>(() => getUser())

    useEffect(() => {
        const onStorage = () => {
            setToken(getToken())
            setUser(getUser())
        }
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
