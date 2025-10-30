import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import assistantService, { DefenseRound, CreateUpdateDefenseRound } from '@features/assistants/services/assistantService';
import DefenseRoundFormModal from '@features/assistants/components/DefenseRoundFormModal';

type ModalState = { open: boolean; editing?: DefenseRound | null };
const today = () => new Date().toISOString().slice(0,10);

function statusOf(r: DefenseRound) {
  const now = today();
  if (now < r.thoiGianBatDau) return 'Sắp diễn ra';
  if (now > r.thoiGianKetThuc) return 'Kết thúc';
  return 'Đang diễn ra';
}

export default function DefenseRoundsPage() {
  const nav = useNavigate();
  const [items, setItems] = useState<DefenseRound[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });
  const keyword = useMemo(() => q.trim(), [q]);

  async function load() {
    setLoading(true);
    try {
      const res = await assistantService.listDefenseRounds({ page, size, q: keyword || undefined });
      const pg = assistantService.toPage<DefenseRound>(res, { page, size });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [page, size, keyword]);

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-center text-3xl font-semibold">Danh sách các đợt bảo vệ</h1>

      <div className="flex items-center gap-3">
        <button onClick={() => setModal({ open: true, editing: null })} className="rounded-lg bg-blue-600 px-4 py-2 text-white">+ Thêm đợt</button>
        <input className="h-10 w-72 rounded border px-3" placeholder="Tìm theo tên…"
               value={q} onChange={e => { setPage(0); setQ(e.target.value); }} />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4">Tên đợt</th>
              <th className="px-4">Học kì</th>
              <th className="px-4">Năm học</th>
              <th className="px-4">Thời gian</th>
              <th className="px-4">Trạng thái</th>
              <th className="px-4 w-[260px]">Hành động</th>
            </tr>
          </thead>
          <tbody>
          {loading ? (
            <tr><td className="px-4 py-6 text-center" colSpan={6}>Đang tải…</td></tr>
          ) : items.length === 0 ? (
            <tr><td className="px-4 py-6 text-center" colSpan={6}>Chưa có đợt bảo vệ.</td></tr>
          ) : items.map(r => (
            <tr key={`${r.id}`} className="border-t">
              <td className="px-4 py-3">{r.tenDotBaoVe}</td>
              <td className="px-4 py-3">{r.hocKi}</td>
              <td className="px-4 py-3">{r.namHoc}</td>
              <td className="px-4 py-3">{r.thoiGianBatDau} → {r.thoiGianKetThuc}</td>
              <td className="px-4 py-3">
                {statusOf(r) === 'Đang diễn ra' ? <span className="text-green-600">Đang diễn ra</span>
                  : statusOf(r) === 'Kết thúc' ? <span className="text-red-600">Kết thúc</span>
                  : <span className="text-slate-600">Sắp diễn ra</span>}
              </td>
              <td className="px-4 py-3">
                <button onClick={() => nav(`/assistant/round-schedule?round=${r.id}`)} className="mr-2 rounded border px-3 py-1">Thời gian thực hiện</button>
                <button onClick={() => setModal({ open: true, editing: r })} className="mr-2 rounded border px-3 py-1">Sửa</button>
                <button onClick={async () => { await assistantService.deleteDefenseRound(r.id); await load(); }}
                        className="rounded border px-3 py-1 text-red-600">Xóa</button>
              </td>
            </tr>
          ))}
          </tbody>
        </table>

        <div className="flex items-center justify-end gap-3 p-3">
          <button className="rounded border px-3 py-1 disabled:opacity-40" onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}>Trước</button>
          <span className="text-sm">{page + 1}</span>
          <button className="rounded border px-3 py-1 disabled:opacity-40" onClick={() => setPage(p => (from + size <= total ? p + 1 : p))} disabled={from + size > total}>Sau</button>
        </div>
      </div>

      {modal.open && (
        <DefenseRoundFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: CreateUpdateDefenseRound) => {
            if (modal.editing) await assistantService.updateDefenseRound(modal.editing.id, payload);
            else await assistantService.createDefenseRound(payload);
            setModal({ open: false });
            await load();
          }}
        />
      )}
    </div>
  );
}
