import { Navigate, Outlet } from 'react-router-dom'
import { useAuth } from '@shared/hooks/useAuth'
import type { Role } from '@shared/constants/roles'

export default function RoleGuard({ allow }: { allow: Role[] }) {
    const { roles } = useAuth()
    const ok = roles.some(r => allow.includes(r as Role))
    return ok ? <Outlet /> : <Navigate to="/403" replace />
}
