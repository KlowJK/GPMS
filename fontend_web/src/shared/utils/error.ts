// src/shared/utils/error.ts
import { ErrorCode } from '@shared/constants/errorCode'
import { ERROR_MESSAGES } from '@shared/constants/errorMessages'

export class ApiError extends Error {
    constructor(
        message: string,
        public code: ErrorCode,
        public status?: number
    ) {
        super(message)
        this.name = 'ApiError'
    }
}

export const getErrorMessage = (error: any): string => {
    // Ưu tiên message có dấu từ frontend
    if (error?.code && ERROR_MESSAGES[error.code as ErrorCode]) {
        return ERROR_MESSAGES[error.code as ErrorCode]
    }

    // Fallback: message từ backend (không dấu)
    if (error?.message) return error.message

    // Cuối cùng
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.'
}

export const isAuthError = (error: any): boolean => {
    const authCodes = [
        ErrorCode.UNAUTHENTICATED,
        ErrorCode.TOKEN_EXPIRED,
        ErrorCode.INVALID_TOKEN,
    ]
    return authCodes.includes(error?.code)
}