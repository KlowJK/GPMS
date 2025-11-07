import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useRequestResetPassword } from '@features/auth/hooks'
import { ArrowLeft } from 'lucide-react'

import LoginBg from '@assets/tlu.png'
import LogoTLU from '@assets/logo_tlu.png'

export default function ForgotPasswordPage() {
    const navigate = useNavigate()
    const { mutate: requestReset, isPending } = useRequestResetPassword()
    const [email, setEmail] = useState('')
    const [emailError, setEmailError] = useState<string>('')

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault()
        setEmailError('')

        if (!email.trim()) {
            setEmailError('Vui lòng nhập email')
            return
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        if (!emailRegex.test(email)) {
            setEmailError('Email không hợp lệ')
            return
        }

        requestReset(
            { email },
            {
                onSuccess: () => {
                    // Tự động chuyển sang trang reset password
                    navigate('/reset-password')
                },
                onError: (error: any) => {
                    const message = error?.message || 'Có lỗi xảy ra'
                    setEmailError(message)
                },
            }
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

                    <h1 className="text-3xl font-semibold text-center mb-3">Quên mật khẩu?</h1>
                    <p className="text-gray-600 text-center mb-8">
                        Nhập email của bạn để nhận mã xác thực
                    </p>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        <div>
                            <label className="block text-gray-500 mb-2">Email</label>
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => {
                                    setEmail(e.target.value)
                                    setEmailError('')
                                }}
                                className={`
                                    w-full h-12 rounded-md bg-[#F6F6F6] px-4 outline-none transition-all
                                    ${emailError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                                `}
                                placeholder="example@tlu.edu.vn"
                                aria-invalid={!!emailError}
                            />
                            {emailError && (
                                <p className="mt-1 text-xs text-red-600">{emailError}</p>
                            )}
                        </div>

                        <button
                            type="submit"
                            disabled={isPending}
                            className="w-full h-11 bg-[#457B9D] text-white rounded-lg hover:opacity-95 transition disabled:opacity-70 disabled:cursor-not-allowed"
                        >
                            {isPending ? 'Đang gửi...' : 'Gửi mã xác thực'}
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