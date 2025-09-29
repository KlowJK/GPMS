import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

// 👉 Import ảnh thật trong src/assets
import LoginBg from '../../../assets/tlu.png';

import LogoTLU from '../../../assets/login-bg.png';

export default function LoginPage() {
    const navigate = useNavigate();
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [showPw, setShowPw] = useState(false);
    const [loading, setLoading] = useState(false);

    async function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        setLoading(true);
        try {
            // TODO: gọi API login thực tế
            await new Promise(r => setTimeout(r, 400));
            navigate('/topics', { replace: true });
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-[#2F7CD3]">
            {/* Khung theo Figma: nền có ảnh + card trắng nổi lên */}
            <div className="relative w-[1100px] h-[700px] rounded-3xl overflow-hidden shadow-2xl">
                {/* Ảnh nền */}
                <img
                    src={LoginBg}
                    alt="Background"
                    className="absolute inset-0 w-full h-full object-cover opacity-90"
                />

                {/* Card trắng trung tâm */}
                <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2
                        w-[560px] bg-white rounded-[40px] p-10 shadow-xl">
                    <div className="flex justify-center mb-6">
                        <img src={LogoTLU} alt="TLU" className="h-24 object-contain" />
                    </div>

                    <h1 className="text-2xl md:text-3xl font-semibold text-center mb-8">Đăng nhập</h1>

                    <form onSubmit={handleSubmit} className="space-y-6">
                        <div>
                            <label className="block text-gray-500 mb-2">Tài khoản</label>
                            <input
                                value={username}
                                onChange={e => setUsername(e.target.value)}
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
                                    onChange={e => setPassword(e.target.value)}
                                    className="w-full h-12 rounded-md bg-[#F6F6F6] shadow px-4 pr-12 outline-none
                             focus:ring-2 focus:ring-sky-400"
                                    placeholder="Nhập mật khẩu"
                                    required
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPw(s => !s)}
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

                    <div className="text-center mt-5">
                        <Link to="#" className="text-[#457B9D] underline">Quên mật khẩu?</Link>
                    </div>
                </div>
            </div>
        </div>
    );
}
