// src/features/assistants/components/RoundTimeFormModal.tsx
import { useState } from 'react';
import type { Id } from '@features/assistants/services/base';
import type { DefenseRound, RoundTime } from '@features/assistants/services/topic/topicApi';

type Props = {
  rounds: DefenseRound[];                 // mảng đợt bảo vệ
  initial?: Partial<RoundTime>;           // dữ liệu khi sửa
  onClose: () => void;
  onSubmit: (payload: {
    congViec: string;
    thoiGianBatDau: string;
    thoiGianKetThuc: string;
    dotBaoVeId: Id;
  }) => Promise<any>;
};

const CV_OPTIONS = ['DANG_KY_DE_TAI', 'NOP_DE_CUONG', 'NOP_BAO_CAO'] as const;
const toId = (v: string): Id => (/^\d+$/.test(v) ? Number(v) : v);

export default function RoundTimeFormModal({ rounds, initial, onClose, onSubmit }: Props) {
  const isEdit = Boolean(initial?.id);

  const [dotBaoVeId, setDotBaoVeId] = useState<string>(
    initial?.dotBaoVeId != null ? String(initial.dotBaoVeId) : ''
  );
  const [congViec, setCongViec] = useState<string>(initial?.congViec ?? CV_OPTIONS[0]);
  const [start, setStart] = useState<string>(initial?.thoiGianBatDau ?? '');
  const [end, setEnd] = useState<string>(initial?.thoiGianKetThuc ?? '');
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const roundLabel = (r: DefenseRound) => `${r.tenDotBaoVe} (${r.hocKi} - ${r.namHoc})`;

  async function handleSave() {
    setErr(null);
    if (!dotBaoVeId) { setErr('Vui lòng chọn đợt bảo vệ'); return; }
    if (!congViec) { setErr('Vui lòng chọn công việc'); return; }
    if (!start || !end) { setErr('Vui lòng nhập đầy đủ thời gian'); return; }
    if (start > end) { setErr('Thời gian bắt đầu không được sau thời gian kết thúc'); return; }

    try {
      setLoading(true);
      await onSubmit({
        congViec,
        thoiGianBatDau: start,
        thoiGianKetThuc: end,
        dotBaoVeId: toId(dotBaoVeId),
      });
      onClose();
    } catch (e: any) {
      setErr(e?.response?.data?.message || e?.response?.data?.error || 'Không thể lưu dữ liệu.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[720px]">
        <h2 className="text-xl font-semibold mb-4">
          {isEdit ? 'Sửa thời gian thực hiện' : 'Thêm thời gian thực hiện'}
        </h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          {/* Đợt bảo vệ */}
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Đợt bảo vệ</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={dotBaoVeId}
              onChange={(e) => setDotBaoVeId(e.target.value)}
            >
              <option value="">Chọn đợt bảo vệ</option>
              {rounds.map((r: DefenseRound) => (
                <option key={String(r.id)} value={String(r.id)}>
                  {roundLabel(r)}
                </option>
              ))}
            </select>
          </div>

          {/* Công việc */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Công việc</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={congViec}
              onChange={(e) => setCongViec(e.target.value)}
            >
              {CV_OPTIONS.map((k) => (
                <option key={k} value={k}>{k}</option>
              ))}
            </select>
          </div>

          {/* Thời gian bắt đầu */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Thời gian bắt đầu</label>
            <input
              type="date"
              className="w-full h-11 rounded border px-3"
              value={start}
              onChange={(e) => setStart(e.target.value)}
            />
          </div>

          {/* Thời gian kết thúc */}
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Thời gian kết thúc</label>
            <input
              type="date"
              className="w-full h-11 rounded border px-3"
              value={end}
              onChange={(e) => setEnd(e.target.value)}
            />
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200" disabled={loading}>
            Quay lại
          </button>
          <button
            onClick={handleSave}
            className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
            disabled={loading}
          >
            {isEdit ? (loading ? 'Đang cập nhật…' : 'Cập nhật') : (loading ? 'Đang lưu…' : 'Lưu')}
          </button>
        </div>
      </div>
    </div>
  );
}
