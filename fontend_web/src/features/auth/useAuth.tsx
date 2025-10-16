import { useCallback } from 'react'
import { getUser, clearUser, clearToken } from '@shared/libs/storage'
import { useNavigate } from 'react-router-dom'

export function useAuth() {
  const navigate = useNavigate()

  const user = getUser()

  const logout = useCallback(async () => {
    try {
      const { logout: apiLogout } = await import('./api')
      try { await apiLogout() } catch {}
    } catch {}
    try { clearToken(); clearUser() } catch {}
    navigate('/login', { replace: true })
  }, [navigate])

  return { user, logout }
}
