// src/features/assistants/components/StudentFormModal.tsx
import { useEffect, useMemo, useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import { useToast } from '@features/admin/components/ToastProvider';

import type { Id } from '@features/assistants/services/base';
import { unwrap } from '@features/assistants/services/base';

import type {
  Student,
  CreateStudentBody,
  UpdateStudentBody,
} from '@features/assistants/services/user/userApi';
import { getStudentByMSV } from '@features/assistants/services/user/userApi';

import type { OrgClass as ClassRoom } from '@features/assistants/services/organization/orgApi';

type Props = {
  initial?: Student;
  classes?: ClassRoom[];
  onClose: () => void;
  onSubmit: (data: CreateStudentBody | UpdateStudentBody) => Promise<any>;
};

export default function StudentFormModal({ initial, classes = [], onClose, onSubmit }: Props) {
  const isEdit = !!initial;
  const { success } = useToast(); // ✅ dùng toast

  const [maSinhVien, setMaSinhVien] = useState(initial?.maSinhVien ?? '');
  const [hoTen, setHoTen] = useState(initial?.hoTen ?? '');
  const [email, setEmail] = useState(initial?.email ?? '');
  const [soDienThoai, setSoDienThoai] = useState(initial?.soDienThoai ?? '');
  const [matKhau, setMatKhau] = useState('');
  const [idLop, setIdLop] = useState<Id | ''>(''); // chọn mới; '' = giữ nguyên
  const [lopHienTai, setLopHienTai] = useState<string>(initial?.lopTen ?? '');
  const [showPw, setShowPw] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  const initialClassId = useMemo<number | undefined>(() => {
    const v =
      (initial as any)?.idLop ??
      (initial as any)?.lopId ??
      (initial as any)?.lop?.id;
    return v != null ? Number(v) : undefined;
  }, [initial]);

  const [currentClassId, setCurrentClassId] = useState<number | undefined>(initialClassId);

  useEffect(() => {
    setMaSinhVien(initial?.maSinhVien ?? '');
    setHoTen(initial?.hoTen ?? '');
    setEmail(initial?.email ?? '');
    setSoDienThoai(initial?.soDienThoai ?? '');
    setMatKhau('');
    setIdLop('');
    setCurrentClassId(initialClassId);

    const initTenLop =
      initial?.lopTen ?? (initial as any)?.tenLop ?? (initial as any)?.lop?.tenLop ?? '';
    if (initTenLop) setLopHienTai(initTenLop);

    async function ensureCurrentClass() {
      if (!isEdit || initialClassId || !initial?.maSinhVien) return;
      try {
        const res = await getStudentByMSV(initial.maSinhVien);
        const data = unwrap<any>(res);
        const gotId = data?.idLop ?? data?.lopId ?? data?.lop?.id;
        const gotTen = data?.tenLop ?? data?.lop?.tenLop;
        if (gotId != null) setCurrentClassId(Number(gotId));
        if (gotTen && !initTenLop) setLopHienTai(gotTen);
      } catch { /* ignore */ }
    }
    ensureCurrentClass();
  }, [initial, isEdit, initialClassId]); // eslint-disable-line

  function pickMessageFromBE(e: any): string {
    const raw = e?.response?.data;
    const msg = raw?.message || raw?.error || '';
    if (msg?.includes('LOP_EMPTY')) return 'Vui lòng chọn lớp.';
    if (msg?.includes('SO_DIEN_THOAI_INVALID')) return 'Số điện thoại không hợp lệ.';
    if (msg?.includes('MA_INVALID')) return 'Mã sinh viên phải gồm 10 chữ số.';
    if (msg?.includes('EMAIL_INVALID')) return 'Email không hợp lệ.';
    if (msg?.includes('MAT_KHAU_INVALID')) return 'Mật khẩu tối thiểu 6 ký tự.';
    return msg || 'Không thể lưu dữ liệu. Vui lòng thử lại.';
  }

  async function handleSubmit() {
    setErr(null);

    const hasBasic = hoTen.trim() && email.trim() && soDienThoai.trim();

    if (!isEdit) {
      // THÊM MỚI – bắt buộc chọn lớp
      if (!maSinhVien.trim() || !hasBasic || idLop === '' || !matKhau.trim()) {
        setErr('Vui lòng nhập đủ thông tin bắt buộc.');
        return;
      }
      try {
        const payload: CreateStudentBody = {
          maSinhVien: maSinhVien.trim(),
          hoTen: hoTen.trim(),
          soDienThoai: soDienThoai.trim(),
          email: email.trim(),
          matKhau: matKhau.trim(),
          idLop: Number(idLop as Id),
        };
        await onSubmit(payload);
        success('Thêm sinh viên thành công.'); // ✅ toast thành công
      } catch (e: any) {
        setErr(pickMessageFromBE(e));
      }
      return;
    }

    // SỬA – không bắt buộc chọn lại lớp
    if (!hasBasic) {
      setErr('Vui lòng nhập đủ thông tin bắt buộc.');
      return;
    }

    let resolvedIdLop: number | undefined = idLop !== '' ? Number(idLop) : undefined;
    if (!resolvedIdLop && currentClassId) resolvedIdLop = currentClassId;

    if (!resolvedIdLop && lopHienTai) {
      const found = classes.find(c => String(c.tenLop).trim() === String(lopHienTai).trim());
      if (found?.id != null) resolvedIdLop = Number(found.id);
    }

    if (!resolvedIdLop && initial?.maSinhVien) {
      try {
        const res = await getStudentByMSV(initial.maSinhVien);
        const data = unwrap<any>(res);
        const gotId = data?.idLop ?? data?.lopId ?? data?.lop?.id;
        if (gotId != null) resolvedIdLop = Number(gotId);
      } catch { /* ignore */ }
    }

    if (!resolvedIdLop) {
      setErr('Không xác định được lớp hiện tại. Vui lòng chọn lớp.');
      return;
    }

    try {
      const payload: UpdateStudentBody = {
        hoTen: hoTen.trim(),
        soDienThoai: soDienThoai.trim(),
        email: email.trim(),
        idLop: resolvedIdLop,
      };
      if (matKhau.trim()) payload.matKhau = matKhau.trim();
      await onSubmit(payload);
      success('Cập nhật sinh viên thành công.'); // ✅ toast thành công
    } catch (e: any) {
      setErr(pickMessageFromBE(e));
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[720px]">
        <h2 className="text-xl font-semibold mb-4">{isEdit ? 'Sửa tài khoản' : 'Thêm tài khoản'}</h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          {!isEdit && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Mã sinh viên</label>
              <input
                className="w-full h-11 rounded border px-3"
                value={maSinhVien}
                onChange={(e) => setMaSinhVien(e.target.value)}
              />
            </div>
          )}

          <div>
            <label className="block text-sm text-slate-600 mb-1">Họ và tên</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={hoTen}
              onChange={(e) => setHoTen(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Số điện thoại</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={soDienThoai}
              onChange={(e) => setSoDienThoai(e.target.value)}
            />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Email</label>
            <input
              type="email"
              className="w-full h-11 rounded border px-3"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">
              {isEdit ? 'Mật khẩu (để trống nếu giữ nguyên)' : 'Mật khẩu'}
            </label>
            <div className="relative">
              <input
                type={showPw ? 'text' : 'password'}
                className="w-full h-11 rounded border px-3 pr-10"
                value={matKhau}
                onChange={(e) => setMatKhau(e.target.value)}
                placeholder={isEdit ? 'Để trống nếu không muốn đổi' : ''}
              />
              <button
                type="button"
                onClick={() => setShowPw((s) => !s)}
                className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-500"
                title={showPw ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}
              >
                {showPw ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Lớp</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={idLop === '' ? '' : String(idLop)}
              onChange={(e) => setIdLop(e.target.value ? Number(e.target.value) as Id : '')}
            >
              <option value="">
                {isEdit ? (lopHienTai ? `Giữ nguyên: ${lopHienTai}` : '— Chọn lớp —') : '— Chọn lớp —'}
              </option>
              {classes.map((c) => (
                <option key={String(c.id)} value={String(c.id)}>
                  {c.tenLop}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">
            Quay lại
          </button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white">
            {isEdit ? 'Cập nhật' : 'Lưu'}
          </button>
        </div>
      </div>
    </div>
  );
}
