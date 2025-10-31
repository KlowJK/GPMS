import { useMemo, useState } from 'react';
import type { CreateUpdateDefenseRound, DefenseRound } from '@features/assistants/services/assistantService';

type Props = { initial?: DefenseRound; onClose: () => void; onSubmit: (data: CreateUpdateDefenseRound) => Promise<void>; };
const toDate = (v?: string) => (v ? String(v).slice(0, 10) : '');

export default function DefenseRoundFormModal({ initial, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);
  const [tenDotBaoVe, setTen] = useState(initial?.tenDotBaoVe ?? '');
  const [hocKi, setHocKi] = useState(initial?.hocKi ?? '');
  const [namHoc, setNamHoc] = useState(initial?.namHoc ?? '');
  const [batDau, setBatDau] = useState(toDate(initial?.thoiGianBatDau));
  const [ketThuc, setKetThuc] = useState(toDate(initial?.thoiGianKetThuc));

  async function handleSubmit() {
    await onSubmit({ tenDotBaoVe, hocKi, namHoc, thoiGianBatDau: batDau, thoiGianKetThuc: ketThuc });
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[680px] rounded-2xl bg-white p-6">
        <h2 className="mb-4 text-xl font-semibold">{isEdit ? 'Sửa đợt bảo vệ' : 'Thêm đợt bảo vệ'}</h2>

        <div className="grid grid-cols-2 gap-4">
          <div><label className="mb-1 block text-sm text-slate-600">Tên đợt</label>
            <input className="h-11 w-full rounded border px-3" value={tenDotBaoVe} onChange={e => setTen(e.target.value)} />
          </div>
          <div><label className="mb-1 block text-sm text-slate-600">Học kì</label>
            <input className="h-11 w-full rounded border px-3" value={hocKi} onChange={e => setHocKi(e.target.value)} placeholder="I / II / Hè..." />
          </div>
          <div><label className="mb-1 block text-sm text-slate-600">Năm học</label>
            <input className="h-11 w-full rounded border px-3" value={namHoc} onChange={e => setNamHoc(e.target.value)} placeholder="2025-2026" />
          </div>
          <div />
          <div><label className="mb-1 block text-sm text-slate-600">Ngày bắt đầu</label>
            <input type="date" className="h-11 w-full rounded border px-3" value={batDau} onChange={e => setBatDau(e.target.value)} />
          </div>
          <div><label className="mb-1 block text-sm text-slate-600">Ngày kết thúc</label>
            <input type="date" className="h-11 w-full rounded border px-3" value={ketThuc} onChange={e => setKetThuc(e.target.value)} />
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-3">
          <button onClick={onClose} className="h-10 rounded bg-slate-200 px-4">Quay lại</button>
          <button onClick={handleSubmit} className="h-10 rounded bg-blue-600 px-4 text-white">{isEdit ? 'Cập nhật' : 'Lưu'}</button>
        </div>
      </div>
    </div>
  );
}
