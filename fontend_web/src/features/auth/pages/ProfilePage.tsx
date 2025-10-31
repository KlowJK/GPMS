import React, { useEffect, useRef, useState } from 'react';
import { getUser } from '@shared/libs/storage';
import type { AuthResponse, User } from '@shared/hooks/useAuth';
import { useChangePassword, useUploadAvatar } from '../hooks';
import { Pencil, UploadCloud, X,Eye, EyeOff } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const validateEmail = (email: string) =>
    /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim());

export default function ProfilePage() {
  const navigate = useNavigate();

  const stored = getUser() as unknown | null;

  function isAuthResponse(value: any): value is AuthResponse {
    return !!value && typeof value === 'object' && 'user' in value;
  }

  function isUser(value: any): value is User {
    return !!value && typeof value === 'object' && ('fullName' in value || 'email' in value || 'id' in value);
  }
  const [showCurrent, setShowCurrent] = useState(false);
  const [showNew, setShowNew] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);

  function formatRole(role?: string) {
    switch (role) {
      case 'GIANG_VIEN':
        return 'Giảng viên';
      case 'TRO_LY_KHOA':
        return 'Trợ lý khoa';
      case 'QUAN_TRI_VIEN':
        return 'Quản trị viên';
      case 'TRUONG_BO_MON':
        return 'Trưởng bộ môn';
      default:
        return role ?? '';
    }
  }
  const initialUser: User =
      stored && isAuthResponse(stored)
          ? stored.user
          : (stored as User) ?? {
        id: 0,
        fullName: 'No name',
        role: 'UNKNOWN',
        email: '',
        duongDanAvt: '',
      };

  // Avatar state
  const [avatarUrl, setAvatarUrl] = useState<string>(initialUser.duongDanAvt || '');
  const [avatarFile, setAvatarFile] = useState<File | null>(null);
  const [avatarPreview, setAvatarPreview] = useState<string | null>(null);
  const [avatarLoading, setAvatarLoading] = useState(false);
  const [avatarError, setAvatarError] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  // Password form state
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [pwdErrors, setPwdErrors] = useState<Record<string, string>>({});
  const [pwdLoading, setPwdLoading] = useState(false);
  const [pwdMessage, setPwdMessage] = useState<string | null>(null);

  // hooks
  const { upload } = useUploadAvatar();
  const { mutate: changePasswordHook } = useChangePassword();

  useEffect(() => {
    return () => {
      if (avatarPreview) URL.revokeObjectURL(avatarPreview);
    };
  }, [avatarPreview]);

  const handleSelectFile = () => fileInputRef.current?.click();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setAvatarError(null);
    const file = e.target.files?.[0] ?? null;
    if (!file) {
      setAvatarFile(null);
      setAvatarPreview(null);
      return;
    }

    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    const maxSize = 2 * 1024 * 1024;
    if (!allowed.includes(file.type)) {
      setAvatarError('Chỉ cho phép ảnh JPEG/PNG/WEBP');
      setAvatarFile(null);
      setAvatarPreview(null);
      return;
    }
    if (file.size > maxSize) {
      setAvatarError('Kích thước ảnh tối đa 2MB');
      setAvatarFile(null);
      setAvatarPreview(null);
      return;
    }

    const preview = URL.createObjectURL(file);
    setAvatarFile(file);
    setAvatarPreview(preview);
  };

  const handleUploadAvatar = async () => {
    if (!avatarFile) {
      setAvatarError('Vui lòng chọn ảnh');
      return;
    }
    setAvatarError(null);
    setAvatarLoading(true);
    try {
      const newUrl = await upload(avatarFile);
      setAvatarUrl(newUrl);
      setAvatarFile(null);
      if (avatarPreview) {
        URL.revokeObjectURL(avatarPreview);
        setAvatarPreview(null);
      }

      // best-effort persist to localStorage (update stored auth/user)
      try {
        if (stored) {
          if (isAuthResponse(stored)) {
            const updated: AuthResponse = { ...stored, user: { ...stored.user, duongDanAvt: newUrl } };
            try { localStorage.setItem('authResponse', JSON.stringify(updated)); } catch {}
            try { localStorage.setItem('user', JSON.stringify(updated.user)); } catch {}
          } else if (isUser(stored)) {
            const updatedUser: User = { ...stored, duongDanAvt: newUrl };
            try { localStorage.setItem('user', JSON.stringify(updatedUser)); } catch {}
          } else {
            // unknown shape: only persist the user object we can construct
            try { localStorage.setItem('user', JSON.stringify({ duongDanAvt: newUrl })); } catch {}
          }
        }
      } catch {
        // ignore persistence errors
      }
    } catch (err: any) {
      setAvatarError(err?.message || 'Đã có lỗi xảy ra khi upload');
    } finally {
      setAvatarLoading(false);
    }
  };

  const handleChangePassword = async (e?: React.FormEvent) => {
    e?.preventDefault();
    const errors: Record<string, string> = {};
    if (!currentPassword) errors.currentPassword = 'Vui lòng nhập mật khẩu hiện tại';
    if (!newPassword) errors.newPassword = 'Vui lòng nhập mật khẩu mới';
    else if (newPassword.length < 6) errors.newPassword = 'Mật khẩu mới tối thiểu 6 ký tự';
    if (!confirmPassword) errors.confirmPassword = 'Vui lòng xác nhận mật khẩu';
    else if (newPassword !== confirmPassword) errors.confirmPassword = 'Mật khẩu xác nhận không khớp';

    setPwdErrors(errors);
    setPwdMessage(null);
    if (Object.keys(errors).length) return;

    setPwdLoading(true);
    try {
      await changePasswordHook(currentPassword, newPassword, confirmPassword);
      setPwdMessage('Đổi mật khẩu thành công');
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
    } catch (err: any) {
      setPwdMessage(err?.message || 'Đã có lỗi xảy ra');
      throw err;
    } finally {
      setPwdLoading(false);
    }
  };

  const inputClass = (hasError?: boolean) =>
      `w-full border px-3 py-2 rounded-md focus:outline-none ${
          hasError ? 'border-red-500 ring-1 ring-red-200' : 'border-slate-200 focus:ring-2 focus:ring-slate-200'
      }`;

  return (
      <div className="max-w-2xl mx-auto mt-8 p-6 bg-white rounded-lg shadow">
   <h1 className="text-2xl font-semibold mb-4 text-center">Hồ sơ</h1>

        <div className="mb-6">
          <div className="flex items-center gap-4">
            <div className="relative">
              <img
                  src={avatarPreview || avatarUrl || 'https://placehold.co/80x80'}
                  alt="avatar"
                  className="h-20 w-20 rounded-full object-cover"
              />
              <button
                  type="button"
                  onClick={handleSelectFile}
                  className="absolute bottom-0 right-0 bg-white border rounded-full p-1 shadow text-sm"
                  title="Thay đổi ảnh đại diện"
              >
                <Pencil size={16} />
              </button>
            </div>

            <div>
              <div className="text-lg font-medium">{initialUser.fullName}</div>

              <div className="text-sm text-slate-600">{formatRole(initialUser.role)}</div>
              <div className="text-sm text-slate-600 mt-1">{initialUser.email}</div>
            </div>
          </div>

          <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={handleFileChange}
          />

          {avatarPreview && (
              <div className="mt-3 flex items-center gap-2">
                <button
                    type="button"
                    onClick={handleUploadAvatar}
                    disabled={avatarLoading}
                    className="px-3 py-1 bg-blue-600 text-white rounded disabled:opacity-60"
                >
                  {avatarLoading ? 'Đang tải...' : <UploadCloud size={16} className="mr-2" />}
                </button>
                <button
                    type="button"
                    onClick={() => {
                      if (avatarPreview) URL.revokeObjectURL(avatarPreview);
                      setAvatarFile(null);
                      setAvatarPreview(null);
                      setAvatarError(null);
                    }}
                    className="px-3 py-1 border rounded"
                >
                  <X size={16} className="mr-2" />
                </button>
                {avatarError && <div className="text-red-600 text-sm">{avatarError}</div>}
              </div>
          )}
        </div>

        <div className="border-t pt-6">
          <h2 className="text-lg font-medium mb-4">Đổi mật khẩu</h2>

          <form onSubmit={handleChangePassword} className="space-y-4">
            <div>
              <label className="block text-sm font-medium">Mật khẩu hiện tại</label>
              <div className="relative">
                <input
                    type={showCurrent ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    className={`${inputClass(Boolean(pwdErrors.currentPassword))} pr-10`}
                />
                <button
                    type="button"
                    onClick={() => setShowCurrent((s) => !s)}
                    className="absolute inset-y-0 right-0 flex items-center pr-2 text-slate-500"
                    aria-label={showCurrent ? 'Hide current password' : 'Show current password'}
                >
                  {showCurrent ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
              {pwdErrors.currentPassword && <div className="text-red-600 text-sm mt-1">{pwdErrors.currentPassword}</div>}
            </div>

            <div>
              <label className="block text-sm font-medium">Mật khẩu mới</label>
              <div className="relative">
                <input
                    type={showNew ? 'text' : 'password'}
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    className={`${inputClass(Boolean(pwdErrors.newPassword))} pr-10`}
                />
                <button
                    type="button"
                    onClick={() => setShowNew((s) => !s)}
                    className="absolute inset-y-0 right-0 flex items-center pr-2 text-slate-500"
                    aria-label={showNew ? 'Hide new password' : 'Show new password'}
                >
                  {showNew ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
              {pwdErrors.newPassword && <div className="text-red-600 text-sm mt-1">{pwdErrors.newPassword}</div>}
            </div>


            <div>
              <label className="block text-sm font-medium">Xác nhận mật khẩu mới</label>
              <div className="relative">
                <input
                    type={showConfirm ? 'text' : 'password'}
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    className={`${inputClass(Boolean(pwdErrors.confirmPassword))} pr-10`}
                />
                <button
                    type="button"
                    onClick={() => setShowConfirm((s) => !s)}
                    className="absolute inset-y-0 right-0 flex items-center pr-2 text-slate-500"
                    aria-label={showConfirm ? 'Hide confirm password' : 'Show confirm password'}
                >
                  {showConfirm ? <EyeOff size={16} /> : <Eye size={16} />}
                </button>
              </div>
              {pwdErrors.confirmPassword && <div className="text-red-600 text-sm mt-1">{pwdErrors.confirmPassword}</div>}
            </div>
           <div className="flex gap-2 justify-end items-center">
             <button
               type="submit"
               disabled={pwdLoading}
               className="px-4 py-2 bg-blue-600 text-white rounded disabled:opacity-60"
             >
               {pwdLoading ? 'Đang xử lý...' : 'Đổi mật khẩu'}
             </button>
             <button
               type="button"
               onClick={() => navigate(-1)}
               className="px-4 py-2 border rounded"
             >
               Quay lại
             </button>
           </div>
          </form>
        </div>
      </div>
  );
}