import { useEffect, useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import assistantService, {
  DefenseRound, DefenseRoundDetail, RoundTask, CreateRoundTask, UpdateRoundTask,
} from '@features/assistants/services/assistantService';

const WORKS = [
  'DANG_KY_DE_TAI',
  'NOP_DE_CUONG',
  'THAM_DINH_DE_CUONG',
  'NOP_BAO_CAO_TIENDO',
  'CHAM_BAO_CAO',
  'BAO_VE',
];
const toDate = (v?: string) => (v ? String(v).slice(0, 10) : '');

export default function RoundSchedulePage() {
  const [params, setParams] = useSearchParams();
  const roundIdParam = params.get('round') ?? '';

  const [rounds, setRounds] = useState<DefenseRound[]>([]);
  const [selectedId, setSelectedId] = useState(roundIdParam);
  const [detail, setDetail] = useState<DefenseRoundDetail | null>(null);
  const [rows, setRows] = useState<(RoundTask | (CreateRoundTask & { _tmpId: string }))[]>([]);
  const [saving, setSaving] = useState<number | string | null>(null);

  async function loadRounds() {
    const res = await assistantService.listDefenseRounds({ page: 0, size: 1000 });
    const pg = assistantService.toPage<DefenseRound>(res, { page: 0, size: 1000 });
    setRounds(pg.content);
    if (!selectedId && pg.content[0]) setSelectedId(String(pg.content[0].id));
  }

  async function loadDetail(id: string | number) {
    const res = await assistantService.getDefenseRoundDetail(id);
    const d = assistantService.unwrap<DefenseRoundDetail>(res);
    setDetail(d);
    setRows(d.thoiGianThucHiens ?? []);
  }

  useEffect(() => { loadRounds(); }, []);
  useEffect(() => {
    if (selectedId) {
      setParams(p => { p.set('round', String(selectedId)); return p; });
      loadDetail(selectedId);
    } else {
      setDetail(null); setRows([]);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedId]);

  function addRow() {
    setRows(r => [...r, { _tmpId: crypto.randomUUID(), congViec: WORKS[0], thoiGianBatDau: toDate(), thoiGianKetThuc: toDate() }]);
  }

  async function saveRow(r: any) {
    try {
      setSaving((r.id ?? r._tmpId) as any);
      if (r.id) {
        const body: UpdateRoundTask = { congViec: r.congViec, thoiGianBatDau: r.thoiGianBatDau, thoiGianKetThuc: r.thoiGianKetThuc };
        await assistantService.updateRoundTaskApi(r.id, body);
      } else {
        const body: CreateRoundTask = { congViec: r.congViec, thoiGianBatDau: r.thoiGianBatDau, thoiGianKetThuc: r.thoiGianKetThuc };
        await assistantService.addRoundTask(selectedId!, body);
      }
      await loadDetail(selectedId!);
    } finally {
      setSaving(null);
    }
  }

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-center text-3xl font-semibold">Thời gian thực hiện</h1>

      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2">
          <span className="text-sm text-slate-600">Chọn đợt:</span>
          <select className="h-10 rounded border bg-white px-2"
                  value={selectedId}
                  onChange={(e) => setSelectedId(e.target.value)}>
            {!selectedId && <option value="">— Chọn đợt —</option>}
            {rounds.map(r => <option key={`${r.id}`} value={String(r.id)}>{r.tenDotBaoVe} ({r.hocKi} - {r.namHoc})</option>)}
          </select>
        </div>
        <div className="ml-auto text-sm text-slate-600">
          {detail ? `${detail.thoiGianBatDau} → ${detail.thoiGianKetThuc}` : ''}
        </div>
      </div>

      <div className="rounded border bg-white">
        {!detail ? (
          <div className="p-6 text-center text-slate-500">Hãy chọn một đợt bảo vệ để quản lý thời gian thực hiện.</div>
        ) : (
          <>
            <div className="p-3">
              <button onClick={addRow} className="rounded bg-blue-600 px-3 py-2 text-white">+ Thêm mốc</button>
            </div>

            <div className="overflow-auto">
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
                          <select className="h-10 rounded border bg-white px-2"
                                  value={(r as any).congViec}
                                  onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, congViec: e.target.value } : x))}>
                            {WORKS.map(w => <option key={w} value={w}>{w}</option>)}
                          </select>
                        </td>
                        <td className="px-3 py-2">
                          <input type="date" className="h-10 rounded border px-2"
                                 value={toDate((r as any).thoiGianBatDau)}
                                 onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, thoiGianBatDau: e.target.value } : x))}/>
                        </td>
                        <td className="px-3 py-2">
                          <input type="date" className="h-10 rounded border px-2"
                                 value={toDate((r as any).thoiGianKetThuc)}
                                 onChange={e => setRows(rs => rs.map((x, idx) => idx === i ? { ...x, thoiGianKetThuc: e.target.value } : x))}/>
                        </td>
                        <td className="px-3 py-2">
                          <button disabled={saving === key} onClick={() => saveRow(r)}
                                  className="rounded border px-3 py-2 disabled:opacity-50">
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
          </>
        )}
      </div>
    </div>
  );
}
