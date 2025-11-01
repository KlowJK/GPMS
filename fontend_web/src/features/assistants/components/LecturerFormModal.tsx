// src/features/assistants/components/LecturerFormModal.tsx
import { useMemo, useState } from 'react';

// 👉 Lấy type Lecturer từ userApi
import type { Lecturer } from '@features/assistants/services/user/userApi';
// 👉 Lấy type Subject và API gán/huỷ Trưởng bộ môn từ orgApi
import type { Subject } from '@features/assistants/services/organization/orgApi';
import { setSubjectHead } from '@features/assistants/services/organization/orgApi';

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
export type LecturerUpdatePayload = Omit<LecturerCreatePayload, 'matKhau'> & {
  laTruongBoMon?: boolean;
};

type Props = {
  initial?: Lecturer;
  subjects: Subject[];
  onClose: () => void;
  // Nên trả về Lecturer đã lưu để xử lý setSubjectHead chính xác
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
  const [idBoMon, setIdBoMon] = useState<string>(
    String(initial?.idBoMon ?? subjects[0]?.id ?? '')
  );
  const [laTruongBoMon, setLaTruongBoMon] = useState<boolean>(Boolean(initial?.laTruongBoMon));

  const [err, setErr] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function handleSubmit() {
    if (saving) return;

    // ✅ Validate nhanh
    if (!maGiangVien.trim() || !hoTen.trim() || !email.trim() || !idBoMon) {
      setErr('Vui lòng nhập đầy đủ Mã GV, Họ tên, Email và chọn Bộ môn.');
      return;
    }
    if (!isEdit && !matKhau) {
      setErr('Vui lòng nhập mật khẩu cho tài khoản mới.');
      return;
    }

    setErr(null);
    setSaving(true);

    try {
      let saved: Lecturer | undefined;
      if (isEdit) {
        const payload: LecturerUpdatePayload = {
          maGiangVien,
          hoTen,
          soDienThoai,
          hocVi,
          hocHam,
          email,
          idBoMon: toId(idBoMon),
          laTruongBoMon,
        };
        saved = await onSubmit(payload);
        // fallback nếu API không trả body
        if (!saved && initial) {
          saved = { ...initial, ...payload, idBoMon: toId(idBoMon) } as unknown as Lecturer;
        }
      } else {
        const payload: LecturerCreatePayload = {
          maGiangVien,
          hoTen,
          soDienThoai,
          hocVi,
          hocHam,
          email,
          matKhau,
          idBoMon: toId(idBoMon),
        };
        saved = await onSubmit(payload);
      }

      // 👉 Gán/huỷ Trưởng bộ môn theo checkbox
      try {
        await setSubjectHead({
          idBoMon: toId(idBoMon),
          idGiangVien: laTruongBoMon ? (saved?.id as number | string) : null,
        });
      } catch {
        /* ignore lỗi gán trưởng bộ môn để không chặn luồng lưu chính */
      }

      onClose();
    } catch (e) {
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

          {!isEdit && (
            <div>
              <label className="block text-sm text-slate-600 mb-1">Mật khẩu</label>
              <input
                type="password"
                className="w-full h-11 rounded border px-3"
                value={matKhau}
                onChange={(e) => setMatKhau(e.target.value)}
              />
            </div>
          )}

          <div>
            <label className="block text-sm text-slate-600 mb-1">Bộ môn</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={idBoMon}
              onChange={(e) => setIdBoMon(e.target.value)}
            >
              {subjects.map((s) => (
                <option key={`${s.id}`} value={String(s.id)}>
                  {s.tenBoMon}
                </option>
              ))}
            </select>

            <label className="mt-2 inline-flex items-center gap-2 select-none">
              <input
                type="checkbox"
                className="h-4 w-4"
                checked={laTruongBoMon}
                onChange={(e) => setLaTruongBoMon(e.target.checked)}
              />
              <span className="text-sm">Đặt làm Trưởng bộ môn</span>
            </label>
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
