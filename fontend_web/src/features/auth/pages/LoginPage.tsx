import React, { useState, useEffect } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useLogin } from '@features/auth/hooks'
import { Role } from '@shared/constants/roles'
import { getErrorMessage } from '@shared/utils/error'
import { Eye, EyeOff } from 'lucide-react';

import LoginBg from '@assets/tlu.png'
import LogoTLU from '@assets/logo_tlu.png'

const getRedirectPath = (role: string): string => {
    const roleMap: Record<string, string> = {
        GIANG_VIEN: '/lecturers',
        TRUONG_BO_MON: '/lecturers',
        QUAN_TRI_VIEN: '/admin',
        TRO_LY_KHOA: '/assistant',
    }
    return roleMap[role] || '/topics'
}

export default function LoginPage() {
    const navigate = useNavigate()
    const { mutate: login, isPending, error } = useLogin()

    const [email, setEmail] = useState('')
    const [matKhau, setMatKhau] = useState('')
    const [showPw, setShowPw] = useState(false)

    // State lỗi riêng biệt
    const [emailError, setEmailError] = useState<string>('')
    const [matKhauError, setMatKhauError] = useState<string>('')

    // Xử lý lỗi từ backend
    useEffect(() => {
        if (error) {
            const message = getErrorMessage(error)

            // Xác định lỗi thuộc email hay mật khẩu
            if (message.includes('email') || message.includes('Email')) {
                setEmailError(message)
                setMatKhauError('')
            } else if (message.includes('mật khẩu') || message.includes('Mật khẩu') || message.includes('không đúng')) {
                setMatKhauError(message)
                setEmailError('')
            } else {
                // Lỗi chung (ví dụ: token, server)
                setEmailError('')
                setMatKhauError(message)
            }
        } else {
            setEmailError('')
            setMatKhauError('')
        }
    }, [error])

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault()

        setEmailError('')
        setMatKhauError('')

        const emailEmpty = !email.trim()
        const pwEmpty = !matKhau.trim()

        if (emailEmpty || pwEmpty) {
            if (emailEmpty) setEmailError('Vui lòng nhập email')
            if (pwEmpty) setMatKhauError('Vui lòng nhập mật khẩu')
            return
        }

        login(
            { email, matKhau },
            {
                onSuccess: (data) => {
                    const role = data.user.role as Role
                    navigate(getRedirectPath(role), { replace: true })
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

            {/* Form */}
            <div className="relative z-10 w-full max-w-lg p-4">
                <div className="bg-white rounded-[40px] p-10 shadow-xl">
                    <div className="flex justify-center mb-6">
                        <img src={LogoTLU} alt="TLU" className="h-16 object-contain" />
                    </div>

                    <h1 className="text-3xl font-semibold text-center mb-8">Đăng nhập</h1>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        {/* Email Field */}
                        <div>
                            <label className="block text-gray-500 mb-2">Tài khoản</label>
                            <input
                                type="text"
                                value={email}
                                onChange={(e) => {
                                    setEmail(e.target.value)
                                    setEmailError('')
                                }}
                                className={`
                  w-full h-12 rounded-md bg-[#F6F6F6] px-4 outline-none transition-all
                  ${emailError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                `}
                                placeholder="Email"
                                aria-invalid={!!emailError}
                            />
                            {emailError && (
                                <p className="mt-1 text-xs text-red-600">{emailError}</p>
                            )}
                        </div>

                        {/* Password Field */}
                        <div>
                            <label className="block text-gray-500 mb-2">Mật khẩu</label>
                            <div className="relative">
                                <input
                                    type={showPw ? 'text' : 'password'}
                                    value={matKhau}
                                    onChange={(e) => {
                                        setMatKhau(e.target.value)
                                        setMatKhauError('')
                                    }}
                                    className={`
                    w-full h-12 rounded-md bg-[#F6F6F6] px-4 pr-12 outline-none transition-all
                    ${matKhauError ? 'ring-1 ring-red-500 border border-red-500' : 'focus:ring-1 focus:ring-sky-400 border border-transparent'}
                  `}
                                    placeholder="Nhập mật khẩu"
                                    aria-invalid={!!matKhauError}
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPw(!showPw)}
                                    className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 text-sm"
                                >
                                    {showPw ? <EyeOff size={20} /> : <Eye size={20} />}
                                </button>
                            </div>
                            {matKhauError && (
                                <p className="mt-1 text-xs text-red-600">{matKhauError}</p>
                            )}
                        </div>

                        {/* Submit Button */}
                        <button
                            type="submit"
                            disabled={isPending}
                            className="w-full h-11 bg-[#457B9D] text-white rounded-lg hover:opacity-95 transition disabled:opacity-70 disabled:cursor-not-allowed"
                        >
                            {isPending ? 'Đang đăng nhập…' : 'Đăng nhập'}
                        </button>
                    </form>

                    {/* Quên mật khẩu */}
                    <div className="text-center mt-5">
                        <Link to="#" className="text-[#457B9D] underline text-sm">
                            Quên mật khẩu?
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    )
}