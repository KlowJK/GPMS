// src/features/assistants/components/LecturerFormModal.tsx
import { useMemo, useState } from 'react';

// Types
import type { Lecturer } from '@features/assistants/services/user/userApi';
import type { Subject } from '@features/assistants/services/organization/orgApi';

export type LecturerCreatePayload = {
  maGiangVien: string;
  hoTen: string;
  soDienThoai?: string;
  hocVi?: string;
  hocHam?: string;
  email: string;
  matKhau: string;
  idBoMon: string | number;
};
export type LecturerUpdatePayload = Omit<LecturerCreatePayload, 'matKhau'>; // ❌ bỏ laTruongBoMon

type Props = {
  initial?: Lecturer;
  subjects: Subject[];
  onClose: () => void;
  onSubmit: (data: LecturerCreatePayload | LecturerUpdatePayload) => Promise<Lecturer | undefined>;
};

function toId(v: string | number) {
  return typeof v === 'number' ? v : (/^\d+$/.test(v) ? Number(v) : v);
}

export default function LecturerFormModal({ initial, subjects, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [maGiangVien, setMaGiangVien] = useState(initial?.maGiangVien ?? '');
  const [hoTen, setHoTen] = useState(initial?.hoTen ?? '');
  const [soDienThoai, setSoDienThoai] = useState(initial?.soDienThoai ?? '');
  const [hocVi, setHocVi] = useState(initial?.hocVi ?? '');
  const [hocHam, setHocHam] = useState(initial?.hocHam ?? '');
  const [email, setEmail] = useState(initial?.email ?? '');
  const [matKhau, setMatKhau] = useState('');
  const [showPw, setShowPw] = useState(false);
  const [idBoMon, setIdBoMon] = useState<string>(String(initial?.idBoMon ?? subjects[0]?.id ?? ''));

  const [err, setErr] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function handleSubmit() {
    if (saving) return;

    if (!hoTen.trim() || !email.trim() || !idBoMon) {
      setErr('Vui lòng nhập đầy đủ Họ tên, Email và chọn Bộ môn.');
      return;
    }
    if (!isEdit && (!maGiangVien.trim() || !matKhau)) {
      setErr('Vui lòng nhập Mã GV và Mật khẩu cho tài khoản mới.');
      return;
    }

    setErr(null);
    setSaving(true);

    try {
      if (isEdit) {
        const payload: any = {
          hoTen,
          soDienThoai,
          hocVi,
          hocHam,
          email,
          idBoMon: toId(idBoMon),
        };
        if (maGiangVien.trim() !== (initial?.maGiangVien ?? '')) {
          payload.maGiangVien = maGiangVien.trim();
        }
        await onSubmit(payload as LecturerUpdatePayload);
      } else {
        const payload: LecturerCreatePayload = {
          maGiangVien: maGiangVien.trim(),
          hoTen,
          soDienThoai,
          hocVi,
          hocHam,
          email,
          matKhau,
          idBoMon: toId(idBoMon),
        };
        await onSubmit(payload);
      }

      // ✅ Không còn gán/huỷ Trưởng bộ môn tại đây
      onClose();
    } catch {
      setErr('Không thể lưu dữ liệu. Vui lòng thử lại.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[760px]">
        <h2 className="text-xl font-semibold mb-4">
          {isEdit ? 'Sửa tài khoản' : 'Thêm tài khoản'}
        </h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mã giảng viên</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={maGiangVien}
              onChange={(e) => setMaGiangVien(e.target.value)}
              placeholder="VD: gv001"
            />
          </div>
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
                className="w-full h-11 rounded border px-3 pr-24"
                value={matKhau}
                onChange={(e) => setMatKhau(e.target.value)}
                placeholder={isEdit ? 'Để trống nếu không đổi mật khẩu' : 'Tối thiểu 6 ký tự'}
              />
              <button
                type="button"
                className="absolute right-2 top-1/2 -translate-y-1/2 text-slate-600 text-sm px-3 py-1 border rounded"
                onClick={() => setShowPw((s) => !s)}
              >
                {showPw ? 'Ẩn' : 'Hiện'}
              </button>
            </div>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Bộ môn</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={String(idBoMon)}
              onChange={(e) => setIdBoMon(e.target.value)}
            >
              {subjects.map((s) => (
                <option key={`${s.id}`} value={String(s.id)}>
                  {s.tenBoMon}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Học vị</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={hocVi}
              onChange={(e) => setHocVi(e.target.value)}
            />
          </div>
          <div>
            <label className="block text-sm text-slate-600 mb-1">Học hàm</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={hocHam}
              onChange={(e) => setHocHam(e.target.value)}
            />
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200" disabled={saving}>
            Quay lại
          </button>
          <button
            onClick={handleSubmit}
            className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
            disabled={saving}
          >
            {isEdit ? (saving ? 'Đang cập nhật…' : 'Cập nhật') : (saving ? 'Đang lưu…' : 'Lưu')}
          </button>
        </div>
      </div>
    </div>
  );
}
