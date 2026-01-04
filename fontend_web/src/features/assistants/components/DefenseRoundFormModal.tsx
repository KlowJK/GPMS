// src/features/assistants/components/DefenseRoundFormModal.tsx
import { useMemo, useState } from 'react';
import type {
  CreateUpdateDefenseRound,
  DefenseRound,
} from '@/features/assistants/services/topic/topicApi';

type Props = {
  initial?: DefenseRound;
  onClose: () => void;
  onSubmit: (data: CreateUpdateDefenseRound) => Promise<void>;
};

const toDate = (v?: string) => (v ? String(v).slice(0, 10) : '');

export default function DefenseRoundFormModal({ initial, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [tenDotBaoVe, setTen] = useState(initial?.tenDotBaoVe ?? '');
  const [hocKi, setHocKi] = useState(initial?.hocKi ?? '');
  const [namHoc, setNamHoc] = useState(initial?.namHoc ?? '');
  const [batDau, setBatDau] = useState(toDate(initial?.thoiGianBatDau));
  const [ketThuc, setKetThuc] = useState(toDate(initial?.thoiGianKetThuc));

  const [err, setErr] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function handleSubmit() {
    if (saving) return;

    // ✅ Validate để tránh BE NullPointerException
    if (!tenDotBaoVe.trim() || !hocKi.trim() || !namHoc.trim()) {
      setErr('Vui lòng nhập đầy đủ Tên đợt, Học kì và Năm học.');
      return;
    }
    if (!batDau || !ketThuc) {
      setErr('Vui lòng chọn Ngày bắt đầu và Ngày kết thúc.');
      return;
    }
    if (batDau > ketThuc) {
      setErr('Ngày bắt đầu phải trước hoặc bằng ngày kết thúc.');
      return;
    }

    setErr(null);
    setSaving(true);
    try {
      await onSubmit({
        tenDotBaoVe: tenDotBaoVe.trim(),
        hocKi: hocKi.trim(),
        namHoc: namHoc.trim(),
        thoiGianBatDau: batDau,
        thoiGianKetThuc: ketThuc,
      });
      onClose();
    } catch {
      setErr('Không thể lưu dữ liệu. Vui lòng thử lại.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[680px] rounded-2xl bg-white p-6">
        <h2 className="mb-4 text-xl font-semibold">
          {isEdit ? 'Sửa đợt bảo vệ' : 'Thêm đợt bảo vệ'}
        </h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="mb-1 block text-sm text-slate-600">Tên đợt</label>
            <input
              className="h-11 w-full rounded border px-3"
              value={tenDotBaoVe}
              onChange={(e) => setTen(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-1 block text-sm text-slate-600">Học kì</label>
            <input
              className="h-11 w-full rounded border px-3"
              value={hocKi}
              onChange={(e) => setHocKi(e.target.value)}
              placeholder="I / II / Hè..."
            />
          </div>
          <div>
            <label className="mb-1 block text-sm text-slate-600">Năm học</label>
            <input
              className="h-11 w-full rounded border px-3"
              value={namHoc}
              onChange={(e) => setNamHoc(e.target.value)}
              placeholder="2025-2026"
            />
          </div>
          <div />
          <div>
            <label className="mb-1 block text-sm text-slate-600">Ngày bắt đầu</label>
            <input
              type="date"
              className="h-11 w-full rounded border px-3"
              value={batDau}
              onChange={(e) => setBatDau(e.target.value)}
            />
          </div>
          <div>
            <label className="mb-1 block text-sm text-slate-600">Ngày kết thúc</label>
            <input
              type="date"
              className="h-11 w-full rounded border px-3"
              value={ketThuc}
              onChange={(e) => setKetThuc(e.target.value)}
            />
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-3">
          <button onClick={onClose} className="h-10 rounded bg-slate-200 px-4" disabled={saving}>
            Quay lại
          </button>
          <button
            onClick={handleSubmit}
            className="h-10 rounded bg-blue-600 px-4 text-white disabled:opacity-50"
            disabled={saving}
          >
            {isEdit ? (saving ? 'Đang cập nhật…' : 'Cập nhật') : (saving ? 'Đang lưu…' : 'Lưu')}
          </button>
        </div>
      </div>
    </div>
  );
}
