import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { axios } from '@shared/libs/axios'
import { setToken, setUser } from '@shared/libs/storage'
import type { AxiosError } from 'axios'

// Ảnh: nền = TLU.png (hình minh hoạ), logo = logo_tlu.png
import LoginBg from '../../../assets/TLU.png';
import LogoTLU from '../../../assets/logo_tlu.png';

export default function LoginPage() {
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showPw, setShowPw] = useState(false);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        setLoading(true);
        try {
            const payload = { email: username, matKhau: password }
            const res = await axios.post('/api/auth/login', payload, {
                headers: { 'Content-Type': 'application/json' },
            })
            setError(null)
            const accessToken = res.data?.accessToken
            const user = res.data?.user
            if (!accessToken) throw new Error('Token not returned from server')

            // store token and user
            setToken(accessToken)
            if (user) setUser(user)

            // navigate based on role
            const role = (user?.role ?? '').toString()
            if (role === 'GIANG_VIEN' || role === 'TRUONG_BO_MON') {
                navigate('/lecturers', { replace: true })
            } else {
                navigate('/topics', { replace: true })
            }
        } catch (err) {
            const axiosErr = err as AxiosError
            const serverMsg =
                (axiosErr?.response as any)?.data?.message ??
                (axiosErr?.response as any)?.data ??
                (err as Error)?.message ??
                'Đăng nhập thất bại'
            // show error in UI and log details for debugging
            setError(typeof serverMsg === 'string' ? serverMsg : JSON.stringify(serverMsg))
            console.error('Login error response:', axiosErr?.response?.status, axiosErr?.response?.data, err)
        } finally {
            setLoading(false)
        }
    }

    return (

        <div className="min-h-screen flex items-center justify-center bg-[#2F7CD3]">
            {/* Khung nền */}
            <div
                className="
          relative mx-auto rounded-3xl overflow-hidden shadow-2xl
          w-full max-w-5xl md:max-w-4xl sm:max-w-[94vw]
          h-[560px] md:h-[600px] lg:h-[640px] xl:h-[700px]
          bg-cover bg-center
        "
                style={{ backgroundImage: `url(${LoginBg})` }}
            >
                {/* Lớp phủ để đúng tông màu */}
                <div className="absolute inset-0 bg-[#2F7CD3]/40" />

                {/* Card trắng căn giữa */}
                <div className="absolute inset-0 flex items-center justify-center p-4 sm:p-6">
                    <div className="w-full max-w-lg bg-white rounded-[40px] p-10 sm:p-8 shadow-xl">
                        <div className="flex justify-center mb-6">
                            <img
                                src={LogoTLU}
                                alt="TLU"
                                className="h-16 sm:h-14 mx-auto object-contain"
                            />
                        </div>

                        <h1 className="text-3xl sm:text-2xl font-semibold text-center mb-8">
                            Đăng nhập
                        </h1>

                        <form onSubmit={handleSubmit} className="space-y-6">
                            <div>
                                <label className="block text-gray-500 mb-2">Tài khoản</label>
                                <input
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    className="w-full h-12 rounded-md bg-[#F6F6F6] shadow px-4 outline-none
                             focus:ring-2 focus:ring-sky-400"
                                    placeholder="Nhập tài khoản"
                                    required
                                />
                            </div>

                            <div>
                                <label className="block text-gray-500 mb-2">Mật khẩu</label>
                                <div className="relative">
                                    <input
                                        type={showPw ? 'text' : 'password'}
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        className="w-full h-12 rounded-md bg-[#F6F6F6] shadow px-4 pr-12 outline-none
                               focus:ring-2 focus:ring-sky-400"
                                        placeholder="Nhập mật khẩu"
                                        required
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPw((s) => !s)}
                                        className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500"
                                        aria-label="toggle password"
                                    >
                                        {showPw ? '🙈' : '👁️'}
                                    </button>
                                </div>
                            </div>

                            <button
                                type="submit"
                                disabled={loading}
                                className="w-full h-11 bg-[#457B9D] text-white rounded-lg hover:opacity-95 transition"
                            >
                                {loading ? 'Đang đăng nhập…' : 'Đăng nhập'}
                            </button>
                        </form>
                        {error && (
                            <div className="mt-4 text-center text-sm text-red-600">{error}</div>
                        )}

                        <div className="text-center mt-5">
                            <Link to="#" className="text-[#457B9D] underline">
                                Quên mật khẩu?
                            </Link>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

