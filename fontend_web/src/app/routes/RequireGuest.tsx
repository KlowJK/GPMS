import React, { useEffect, useState } from 'react'
import { Navigate, useLocation } from 'react-router-dom'
import { useQueryClient } from '@tanstack/react-query'
import { getUser } from '@shared/libs/storage'
import { me } from '@features/auth/api'

type Props = { children: React.ReactNode; maxWait?: number; interval?: number }

const getRedirectPath = (role?: string) => {
    const roleMap: Record<string, string> = {
        GIANG_VIEN: '/lecturers',
        TRUONG_BO_MON: '/lecturers',
        QUAN_TRI_VIEN: '/admin',
        TRO_LY_KHOA: '/assistant',
    }
    return (role && roleMap[role]) || '/topics'
}

export default function RequireGuest({ children, maxWait = 10000, interval = 500 }: Props) {
    const location = useLocation()
    const queryClient = useQueryClient()
    const [redirectTo, setRedirectTo] = useState<string | null>(null)
    const [checked, setChecked] = useState(false)

    // If navigation came from an explicit logout, skip checking and show guest UI immediately.
    if ((location.state as any)?.fromLogout) return <>{children}</>

    // Quick local check: if there's no stored user/token, render guest UI immediately to avoid white screen.
    const stored = getUser()
    if (!stored) return <>{children}</>

    useEffect(() => {
        let mounted = true

        const extractRole = (storedOrProfile: any): string | undefined => {
            if (!storedOrProfile) return undefined
            if (storedOrProfile.user && storedOrProfile.user.role) return storedOrProfile.user.role
            if (storedOrProfile.role) return storedOrProfile.role
            return undefined
        }

        const checkAuth = async () => {
            try {
                const roleFromStorage = extractRole(stored)
                if (roleFromStorage) {
                    if (mounted) { setRedirectTo(getRedirectPath(roleFromStorage)); setChecked(true) }
                    return
                }
            } catch {}

            const start = Date.now()
            while (Date.now() - start < maxWait) {
                try {
                    const profile = await queryClient.fetchQuery({ queryKey: ['me'], queryFn: me })
                    const role = extractRole(profile as any)
                    if (role && mounted) { setRedirectTo(getRedirectPath(role)); setChecked(true); return }
                } catch {}
                await new Promise((r) => setTimeout(r, interval))
            }

            if (mounted) setChecked(true)
        }

        checkAuth()
        return () => { mounted = false }
    }, [queryClient, maxWait, interval, stored])

    if (redirectTo) {
        if (location.pathname === redirectTo) return <>{children}</>
        return <Navigate to={redirectTo} replace />
    }

    if (!checked) return null
    return <>{children}</>
}