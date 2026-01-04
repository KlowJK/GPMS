// src/features/auth/hooks.ts
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { login, me, logout , changePassword, uploadAvatar, requestResetPassword, resetPassword } from './api'
import { clearToken, clearUser } from '@shared/libs/storage'
import { useApiError } from '@shared/hooks/useApiError'
import { useState } from 'react'
import { getUser } from '@shared/libs/storage'

export function useLogin() {
    const queryClient = useQueryClient()
    const handleError = useApiError()

    return useMutation({
        mutationFn: login,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['me'] })
        },
       // onError: handleError, // Tự động toast + logout nếu cần
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
        }
    }
}

export function useChangePassword() {
    const handleError = useApiError()
    const [message, setMessage] = useState<string | null>(null)

    const mutation = useMutation({
        mutationFn: ({ currentPassword, newPassword, confirmNewPassword }: { currentPassword: string; newPassword: string; confirmNewPassword: string }) =>
            changePassword(currentPassword, newPassword, confirmNewPassword),
        onSuccess: () => setMessage('Đổi mật khẩu thành công'),
        onError: handleError,
    })

    const mutate = (currentPassword: string, newPassword: string, confirmNewPassword: string) => {
        setMessage(null)
        return mutation.mutateAsync({ currentPassword, newPassword, confirmNewPassword })
    }

    return {
        mutate,
        loading: mutation.status === 'pending',
        error: (mutation.error as any)?.message ?? null,
        message,
        reset: (mutation as any).reset,
    }
}

export function useUploadAvatar() {
    const queryClient = useQueryClient()
    const handleError = useApiError()
    const extractImageUrl = (data: any) => {
        if (!data) return undefined
        if (typeof data === 'string') return data
        return data?.imageUrl ?? data?.result ?? data?.user?.duongDanAvt ?? data?.duongDanAvt
    }

    const mutation = useMutation({
        mutationFn: (file: File) => uploadAvatar(file),
        onSuccess: (data: any) => {
            const imageUrl = extractImageUrl(data)
            if (!imageUrl) return
            try {
                const stored = getUser() as any | null
                if (stored) {
                    let updated: any
                    if (stored.user) {
                        updated = { ...stored, user: { ...stored.user, duongDanAvt: imageUrl } }
                        try { localStorage.setItem('authResponse', JSON.stringify(updated)) } catch {}
                        try { localStorage.setItem('user', JSON.stringify(updated.user)) } catch {}
                    } else {
                        updated = { ...stored, duongDanAvt: imageUrl }
                        try { localStorage.setItem('user', JSON.stringify(updated)) } catch {}
                    }
                }
            } catch {

            }

            try { queryClient.invalidateQueries({ queryKey: ['me'] }) } catch {}
        },
        onError: handleError,
    })

    const upload = async (file: File, { maxWait = 10000, interval = 1000 } = {}): Promise<string> => {
        // initial upload attempt
        const data = await mutation.mutateAsync(file)
        let imageUrl = extractImageUrl(data)
        if (imageUrl) return imageUrl

        // poll `me` until server provides the image URL or timeout
        const start = Date.now()
        while (Date.now() - start < maxWait) {
            await new Promise((r) => setTimeout(r, interval))
            try {
                const profile = await queryClient.fetchQuery({ queryKey: ['me'], queryFn: me })
                imageUrl = extractImageUrl(profile as any)
                if (imageUrl) return imageUrl
            } catch {
                // ignore fetch errors and keep polling until timeout
            }
        }

        throw new Error('Invalid server response')
    }

    return {
        upload,
        loading: (mutation as any).status === 'pending',
        error: (mutation.error as any)?.message ?? null,
        reset: (mutation as any).reset,
    }
}

export function useRequestResetPassword() {
    const handleError = useApiError()

    return useMutation({
        mutationFn: requestResetPassword,
        onError: handleError,
    })
}

export function useResetPassword() {
    const handleError = useApiError()

    return useMutation({
        mutationFn: resetPassword,
        onError: handleError,
    })
}