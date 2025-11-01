// src/features/assistants/components/StudentFormModal.tsx
import { useEffect, useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';

import type { Id } from '@features/assistants/services/base';
import { unwrap } from '@features/assistants/services/base';

// User APIs & types
import type {
  Student,
  CreateStudentBody,
  UpdateStudentBody,
} from '@features/assistants/services/user/userApi';
import { getStudentByMSV } from '@features/assistants/services/user/userApi';

// Org APIs & types (lấy danh sách lớp đã load sẵn từ page)
import type { OrgClass as ClassRoom } from '@features/assistants/services/organization/orgApi';

type Props = {
  initial?: Student;
  classes?: ClassRoom[];
  onClose: () => void;
  onSubmit: (data: CreateStudentBody | UpdateStudentBody) => Promise<any>;
};

export default function StudentFormModal({ initial, classes = [], onClose, onSubmit }: Props) {
  const isEdit = !!initial;

  const [maSinhVien, setMaSinhVien] = useState(initial?.maSinhVien ?? '');
  const [hoTen, setHoTen] = useState(initial?.hoTen ?? '');
  const [email, setEmail] = useState(initial?.email ?? '');
  const [soDienThoai, setSoDienThoai] = useState(initial?.soDienThoai ?? '');
  const [matKhau, setMatKhau] = useState('');
  const [idLop, setIdLop] = useState<Id | ''>('');
  const [lopHienTai, setLopHienTai] = useState<string>('');
  const [showPw, setShowPw] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  // Prefill khi sửa: lấy idLop hiện tại
  useEffect(() => {
    setMaSinhVien(initial?.maSinhVien ?? '');
    setHoTen(initial?.hoTen ?? '');
    setEmail(initial?.email ?? '');
    setSoDienThoai(initial?.soDienThoai ?? '');
    setMatKhau('');
    setIdLop('');
    setLopHienTai(initial?.lopTen ?? '');

    async function fetchDetail() {
      if (!initial?.maSinhVien) return;
      try {
        const res = await getStudentByMSV(initial.maSinhVien);
        const data = unwrap<any>(res);
        const id = data?.idLop ?? data?.lopId ?? data?.lop?.id;
        if (id != null) setIdLop(id);
        if (data?.tenLop && !lopHienTai) setLopHienTai(data.tenLop);
      } catch {
        /* ignore */
      }
    }
    if (isEdit) fetchDetail();
  }, [initial, isEdit]);

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

    if (!isEdit) {
      if (!maSinhVien || !hoTen || !email || !soDienThoai || !matKhau || !idLop) {
        setErr('Vui lòng nhập đủ thông tin bắt buộc.');
        return;
      }
    } else if (!hoTen || !email || !soDienThoai || !idLop) {
      setErr('Vui lòng nhập đủ thông tin bắt buộc.');
      return;
    }

    try {
      if (isEdit) {
        const payload: UpdateStudentBody = { hoTen, soDienThoai, email, idLop: idLop as Id };
        if (matKhau) payload.matKhau = matKhau;
        await onSubmit(payload);
      } else {
        const payload: CreateStudentBody = {
          maSinhVien, hoTen, soDienThoai, email, matKhau, idLop: idLop as Id,
        };
        await onSubmit(payload);
      }
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
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mã sinh viên</label>
            <input className="w-full h-11 rounded border px-3"
                   value={maSinhVien} onChange={(e) => setMaSinhVien(e.target.value)} disabled={isEdit} />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Họ và tên</label>
            <input className="w-full h-11 rounded border px-3"
                   value={hoTen} onChange={(e) => setHoTen(e.target.value)} />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Số điện thoại</label>
            <input className="w-full h-11 rounded border px-3"
                   value={soDienThoai} onChange={(e) => setSoDienThoai(e.target.value)} />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Email</label>
            <input type="email" className="w-full h-11 rounded border px-3"
                   value={email} onChange={(e) => setEmail(e.target.value)} />
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">
              {isEdit ? 'Mật khẩu (để trống nếu giữ nguyên)' : 'Mật khẩu'}
            </label>
            <div className="relative">
              <input type={showPw ? 'text' : 'password'} className="w-full h-11 rounded border px-3 pr-10"
                     value={matKhau} onChange={(e) => setMatKhau(e.target.value)} />
              <button type="button" onClick={() => setShowPw(s => !s)}
                      className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-500"
                      title={showPw ? 'Ẩn mật khẩu' : 'Hiện mật khẩu'}>
                {showPw ? <EyeOff size={18}/> : <Eye size={18}/>}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Lớp</label>
            <select className="w-full h-11 rounded border px-3 bg-white"
                    value={idLop === '' ? '' : String(idLop)}
                    onChange={(e) => setIdLop(e.target.value ? Number(e.target.value) : '')}>
              <option value="">{isEdit ? `— Giữ nguyên: ${lopHienTai || '—'} —` : '— Chọn lớp —'}</option>
              {classes.map((c) => (
                <option key={String(c.id)} value={String(c.id)}>
                  {c.tenLop}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white">
            {isEdit ? 'Cập nhật' : 'Lưu'}
          </button>
        </div>
      </div>
    </div>
  );
}
