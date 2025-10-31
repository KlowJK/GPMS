import { getUser } from '@shared/libs/storage'
import { useNavigate } from 'react-router-dom'
import { useLogout } from '@features/auth/hooks'

export function useAuth() {
  const navigate = useNavigate()
  const user = getUser()
  const logoutFn = useLogout()

  const logout = async () => {
    await logoutFn()
    navigate('/login', { replace: true, state: { fromLogout: true } })
  }

  return { user, logout }
}