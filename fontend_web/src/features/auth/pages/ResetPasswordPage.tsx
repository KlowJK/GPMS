import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useResetPassword } from '@features/auth/hooks'
import { Eye, EyeOff, ArrowLeft } from 'lucide-react'

import LoginBg from '@assets/tlu.png'
import LogoTLU from '@assets/logo_tlu.png'

export default function ResetPasswordPage() {
    const navigate = useNavigate()
    const { mutate: resetPassword, isPending } = useResetPassword()

    const [token, setToken] = useState('')
    const [newPassword, setNewPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const [showPassword, setShowPassword] = useState(false)
    const [showConfirmPassword, setShowConfirmPassword] = useState(false)

    const [tokenError, setTokenError] = useState<string>('')
    const [passwordError, setPasswordError] = useState<string>('')
    const [confirmPasswordError, setConfirmPasswordError] = useState<string>('')
    const [generalError, setGeneralError] = useState<string>('')
    const [success, setSuccess] = useState(false)

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault()

        setTokenError('')
        setPasswordError('')
        setConfirmPasswordError('')
        setGeneralError('')

        if (!token.trim()) {
            setTokenError('Vui lòng nhập mã xác thực')
            return
        }

        if (!newPassword.trim()) {
            setPasswordError('Vui lòng nhập mật khẩu mới')
            return
        }

        if (newPassword.length < 6) {
            setPasswordError('Mật khẩu phải có ít nhất 6 ký tự')
            return
        }

        if (!confirmPassword.trim()) {
            setConfirmPasswordError('Vui lòng xác nhận mật khẩu')
            return
        }

        if (newPassword !== confirmPassword) {
            setConfirmPasswordError('Mật khẩu xác nhận không khớp')
            return
        }

        resetPassword(
            { token: token.trim(), newPassword },
            {
                onSuccess: () => {
                    setSuccess(true)
                    setTimeout(() => {
                        navigate('/login', { replace: true })
                    }, 3000)
                },
                onError: (error: any) => {
                    const message = error?.message || 'Có lỗi xảy ra'
                    if (message.includes('token') || message.includes('Token') || message.includes('mã')) {
                        setTokenError('Mã xác thực không hợp lệ hoặc đã hết hạn')
                    } else if (message.includes('mật khẩu') || message.includes('password')) {
                        setPasswordError(message)
                    } else {
                        setGeneralError(message)
                    }
                },
            }
        )
    }

    if (success) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-[#2F7CD3] relative overflow-hidden">
                <div
                    className="absolute inset-0 bg-cover bg-center"
                    style={{ backgroundImage: `url(${LoginBg})` }}
                >
                    <div className="absolute inset-0 bg-[#2F7CD3]/40" />
                </div>

                <div className="relative z-10 w-full max-w-lg p-4">
                    <div className="bg-white rounded-[40px] p-10 shadow-xl">
                        <div className="flex justify-center mb-6">
                            <img src={LogoTLU} alt="TLU" className="h-16 object-contain" />
                        </div>

                        <div className="text-center">
                            <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                                <svg
                                    className="w-8 h-8 text-green-600"
                                    fill="none"
                                    stroke="currentColor"
                                    viewBox="0 0 24 24"
                                >
                                    <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth={2}
                                        d="M5 13l4 4L19 7"
                                    />
                                </svg>
                            </div>

                            <h2 className="text-2xl font-semibold mb-3">Đặt lại mật khẩu thành công!</h2>
                            <p className="text-gray-600 mb-6">
                                Mật khẩu của bạn đã được cập nhật. <br />
                                Bạn sẽ được chuyển đến trang đăng nhập...
                            </p>

                            <Link
                                to="/login"
                                className="inline-flex items-center justify-center gap-2 text-[#457B9D] hover:underline"
                            >
                                Đăng nhập ngay
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        )
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#2F7CD3] relative overflow-hidden">
            <div
                className="absolute inset-0 bg-cover bg-center"
                style={{ backgroundImage: `url(${LoginBg})` }}
            >
                <div className="absolute inset-0 bg-[#2F7CD3]/40" />
            </div>

            <div className="relative z-10 w-full max-w-lg p-4">
                <div className="bg-white rounded-[40px] p-10 shadow-xl">
                    <div className="flex justify-center mb-6">
                        <img src={LogoTLU} alt="TLU" className="h-16 object-contain" />
                    </div>

                    <h1 className="text-3xl font-semibold text-center mb-3">Đặt lại mật khẩu</h1>
                    <p className="text-gray-600 text-center mb-8">
                        Nhập mã xác thực từ email và mật khẩu mới
                    </p>

                    {generalError && (
                        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
                            <p className="text-sm text-red-600 text-center">{generalError}</p>
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* Token Field */}
                        <div>
                            <label className="block text-gray-500 mb-2">Mã xác thực</label>
                            <input
                                type="text"
                                value={token}
                                onChange={(e) => {
                                    setToken(e.target.value)
                                    setTokenError('')
                                }}
                                className={`
                                    w-full h-12 rounded-md bg-[#F6F6F6] px-4 outline-none transition-all
                                    ${tokenError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                                `}
                                placeholder="Nhập mã xác thực từ email"
                                aria-invalid={!!tokenError}
                            />
                            {tokenError && (
                                <p className="mt-1 text-xs text-red-600">{tokenError}</p>
                            )}
                        </div>

                        {/* New Password Field */}
                        <div>
                            <label className="block text-gray-500 mb-2">Mật khẩu mới</label>
                            <div className="relative">
                                <input
                                    type={showPassword ? 'text' : 'password'}
                                    value={newPassword}
                                    onChange={(e) => {
                                        setNewPassword(e.target.value)
                                        setPasswordError('')
                                    }}
                                    className={`
                                        w-full h-12 rounded-md bg-[#F6F6F6] px-4 pr-12 outline-none transition-all
                                        ${passwordError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                                    `}
                                    placeholder="Nhập mật khẩu mới"
                                    aria-invalid={!!passwordError}
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
                                >
                                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>
                            {passwordError && (
                                <p className="mt-1 text-xs text-red-600">{passwordError}</p>
                            )}
                        </div>

                        {/* Confirm Password Field */}
                        <div>
                            <label className="block text-gray-500 mb-2">Xác nhận mật khẩu</label>
                            <div className="relative">
                                <input
                                    type={showConfirmPassword ? 'text' : 'password'}
                                    value={confirmPassword}
                                    onChange={(e) => {
                                        setConfirmPassword(e.target.value)
                                        setConfirmPasswordError('')
                                    }}
                                    className={`
                                        w-full h-12 rounded-md bg-[#F6F6F6] px-4 pr-12 outline-none transition-all
                                        ${confirmPasswordError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                                    `}
                                    placeholder="Nhập lại mật khẩu mới"
                                    aria-invalid={!!confirmPasswordError}
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
                                >
                                    {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>
                            {confirmPasswordError && (
                                <p className="mt-1 text-xs text-red-600">{confirmPasswordError}</p>
                            )}
                        </div>

                        <button
                            type="submit"
                            disabled={isPending}
                            className="w-full h-11 bg-[#457B9D] text-white rounded-lg hover:opacity-95 transition disabled:opacity-70 disabled:cursor-not-allowed"
                        >
                            {isPending ? 'Đang xử lý...' : 'Đặt lại mật khẩu'}
                        </button>
                    </form>

                    <div className="text-center mt-6">
                        <Link
                            to="/login"
                            className="inline-flex items-center gap-2 text-[#457B9D] hover:underline text-sm"
                        >
                            <ArrowLeft size={16} />
                            Quay lại đăng nhập
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    )
}