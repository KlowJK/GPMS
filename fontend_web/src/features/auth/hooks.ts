// src/app/features/auth/hooks.ts
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { login, me, logout } from './api'
import { clearToken, clearUser } from '@shared/libs/storage'
import { useApiError } from '@shared/hooks/useApiError'

export function useLogin() {
    const queryClient = useQueryClient()
    const handleError = useApiError()

    return useMutation({
        mutationFn: login,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['me'] })
        },
        onError: handleError, // Tự động toast + logout nếu cần
    })
}

export function useProfile() {
    return useQuery({
        queryKey: ['me'],
        queryFn: me,
        staleTime: 1000 * 60 * 5,
    })
}

export function useLogout() {
    const queryClient = useQueryClient()
    const handleError = useApiError()

    return async () => {
        try {
            await logout()
        } catch (err) {
            handleError(err)
        } finally {
            clearToken()
            clearUser()
            queryClient.clear()
            window.location.href = '/login'
        }
    }
}