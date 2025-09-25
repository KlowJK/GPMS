import { useMutation, useQuery } from '@tanstack/react-query'
import { login, me } from './api'
import { setToken, clearToken } from '@shared/libs/storage'

export function useLogin() {
    return useMutation({
        mutationFn: login,
        onSuccess: (data) => setToken(data.accessToken)
    })
}
export function useProfile() {
    return useQuery({ queryKey: ['me'], queryFn: me })
}
export function useLogout() {
    return () => { clearToken(); window.location.href = '/login' }
}
