import { useEffect, useState } from 'react';
import assistantService, {
  DefenseRoundDetail, RoundTask, CreateRoundTask, UpdateRoundTask, Id,
} from '@features/assistants/services/assistantService';

type Props = { roundId: Id; onClose: () => void };

const WORKS = [
  'DANG_KY_DE_TAI',
  'NOP_DE_CUONG',
  'THAM_DINH_DE_CUONG',
  'NOP_BAO_CAO_TIENDO',
  'CHAM_BAO_CAO',
  'BAO_VE',
];

const toDate = (v?: string) => (v ? String(v).slice(0, 10) : '');

export default function RoundScheduleModal({ roundId, onClose }: Props) {
  const [detail, setDetail] = useState<DefenseRoundDetail | null>(null);
  const [rows, setRows] = useState<(RoundTask | (CreateRoundTask & { _tmpId: string }))[]>([]);
  const [saving, setSaving] = useState<number | string | null>(null);

  async function load() {
    const res = await assistantService.getDefenseRoundDetail(roundId);
    const data = assistantService.unwrap<DefenseRoundDetail>(res);
    setDetail(data);
    setRows(data.thoiGianThucHiens ?? []);
  }
  useEffect(() => { load(); }, [roundId]);

  function addRow() {
    const tmp = { _tmpId: crypto.randomUUID(), congViec: WORKS[0], thoiGianBatDau: toDate(), thoiGianKetThuc: toDate() };
    setRows(r => [...r, tmp]);
  }

  async function saveRow(r: any) {
    try {
      setSaving((r.id ?? r._tmpId) as any);
      if (r.id) {
        const body: UpdateRoundTask = {
          congViec: r.congViec,
          thoiGianBatDau: r.thoiGianBatDau,
          thoiGianKetThuc: r.thoiGianKetThuc,
        };
        await assistantService.updateRoundTaskApi(r.id, body);
      } else {
        const body: CreateRoundTask = {
          congViec: r.congViec,
          thoiGianBatDau: r.thoiGianBatDau,
          thoiGianKetThuc: r.thoiGianKetThuc,
        };
        await assistantService.addRoundTask(roundId, body);
      }
      await load();
    } finally {
      setSaving(null);
    }
  }

  if (!detail) return null;

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[900px] rounded-2xl bg-white p-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-xl font-semibold">
            Thời gian thực hiện — {detail.tenDotBaoVe} ({detail.hocKi}, {detail.namHoc})
          </h2>
          <button onClick={onClose} className="rounded bg-slate-200 px-3 py-2">Đóng</button>
        </div>

        <div className="mb-3">
          <button onClick={addRow} className="rounded bg-blue-600 px-3 py-2 text-white">+ Thêm mốc</button>
        </div>

        <div className="overflow-auto rounded border">
          <table className="w-full text-left">
            <thead className="bg-slate-50">
              <tr className="h-11">
                <th className="px-3">Công việc</th>
                <th className="px-3">Bắt đầu</th>
                <th className="px-3">Kết thúc</th>
                <th className="px-3 w-28">Lưu</th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r, i) => {
                const key = (r as any).id ?? (r as any)._tmpId ?? i;
                return (
                  <tr key={key} className="border-t">
                    <td className="px-3 py-2">
                      <select
                        className="h-10 rounded border px-2 bg-white"
                        value={(r as any).congViec}
                        onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, congViec: e.target.value } : x))}
                      >
                        {WORKS.map(w => <option key={w} value={w}>{w}</option>)}
                      </select>
                    </td>
                    <td className="px-3 py-2">
                      <input type="date" className="h-10 rounded border px-2"
                             value={toDate((r as any).thoiGianBatDau)}
                             onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, thoiGianBatDau: e.target.value } : x))}
                      />
                    </td>
                    <td className="px-3 py-2">
                      <input type="date" className="h-10 rounded border px-2"
                             value={toDate((r as any).thoiGianKetThuc)}
                             onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, thoiGianKetThuc: e.target.value } : x))}
                      />
                    </td>
                    <td className="px-3 py-2">
                      <button
                        disabled={saving === key}
                        onClick={() => saveRow(r)}
                        className="rounded border px-3 py-2 disabled:opacity-50"
                      >
                        {saving === key ? 'Đang lưu…' : 'Lưu'}
                      </button>
                    </td>
                  </tr>
                );
              })}
              {rows.length === 0 && (
                <tr><td colSpan={4} className="px-3 py-6 text-center text-slate-500">Chưa có mốc thời gian.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
