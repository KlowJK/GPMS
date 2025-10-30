// src/shared/hooks/useApiError.ts
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate } from 'react-router-dom'
import { clearToken, clearUser } from '@shared/libs/storage'
import { getErrorMessage, isAuthError } from '@shared/utils/error'
import { toast } from 'sonner'

export function useApiError() {
    const queryClient = useQueryClient()
    const navigate = useNavigate()

    return (error: any) => {
        const message = getErrorMessage(error)

        // Xử lý lỗi xác thực → logout + redirect
        if (isAuthError(error)) {
            clearToken()
            clearUser()
            queryClient.clear()
            toast.error('Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.')
            navigate('/login', { replace: true })
            return
        }

        // Các lỗi khác → hiển thị toast
        toast.error(message)
    }
}