// src/features/assistants/pages/DefenseRoundsPage.tsx
import { useEffect, useMemo, useRef, useState } from 'react';


import { toPage } from '@/features/assistants/services/base';
import {
  type DefenseRound,
  type CreateUpdateDefenseRound,
  listDefenseRounds,
  createDefenseRound,
  updateDefenseRound,
  deleteDefenseRound,
  // ✅ thêm API import
  importStudentsToRound,
} from '@/features/assistants/services/topic/topicApi';

import DefenseRoundFormModal from '@/features/assistants/components/DefenseRoundFormModal';

type ModalState = { open: boolean; editing?: DefenseRound | null };
const today = () => new Date().toISOString().slice(0, 10);

function fallbackByDate(r: DefenseRound) {
  const now = today();
  if (now < r.thoiGianBatDau) return 'Sắp diễn ra';
  if (now > r.thoiGianKetThuc) return 'Kết thúc';
  return 'Đang diễn ra';
}
function statusOf(r: DefenseRound) {
  if (r.trangThai === true) return 'Đang diễn ra';
  if (r.trangThai === false) return 'Kết thúc';
  return fallbackByDate(r);
}

export default function DefenseRoundsPage() {
  // const nav = useNavigate(); // ❌ bỏ
  const [items, setItems] = useState<DefenseRound[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // ✅ state cho import file
  const fileRef = useRef<HTMLInputElement | null>(null);
  const [importingFor, setImportingFor] = useState<number | string | null>(null);
  const [importBusy, setImportBusy] = useState(false);

  const keyword = useMemo(() => q.trim(), [q]);

  async function load() {
    setLoading(true); setError(null);
    try {
      const res = await listDefenseRounds({ page, size, q: keyword || undefined });
      const pg = toPage<DefenseRound>(res, { page, size });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]); setTotal(0);
      setError(e?.response?.data?.message || 'Không tải được danh sách đợt bảo vệ.');
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [page, size, keyword]); // eslint-disable-line

  // ✅ handler chọn file
  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    // reset input để lần sau chọn cùng tên file vẫn nhận change
    e.target.value = '';
    if (!file || importingFor == null) return;

    try {
      setImportBusy(true);
      await importStudentsToRound(importingFor, file);
      alert('Import sinh viên thành công.');
      await load();
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Import thất bại.');
    } finally {
      setImportBusy(false);
      setImportingFor(null);
    }
  }

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-center text-3xl font-semibold">Danh sách các đợt bảo vệ</h1>

      <div className="flex items-center gap-3">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="rounded-lg bg-blue-600 px-4 py-2 text-white"
        >
          + Thêm đợt
        </button>

        <input
          className="h-10 w-72 rounded border px-3"
          placeholder="Tìm theo tên…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />

        <div className="ml-auto text-sm text-slate-600">
          {error ? <span className="text-red-600">{error}</span> : total ? `${from}–${to}/${total}` : ''}
        </div>
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
              <th className="px-4 w-[240px]">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Đang tải…</td></tr>
            ) : items.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Chưa có đợt bảo vệ.</td></tr>
            ) : (
              items.map((r) => (
                <tr key={`${r.id}`} className="border-t">
                  <td className="px-4 py-3">{r.tenDotBaoVe}</td>
                  <td className="px-4 py-3">{r.hocKi}</td>
                  <td className="px-4 py-3">{r.namHoc}</td>
                  <td className="px-4 py-3">{r.thoiGianBatDau || '—'} → {r.thoiGianKetThuc || '—'}</td>
                  <td className="px-4 py-3">
                    {(() => {
                      const s = statusOf(r);
                      if (s === 'Đang diễn ra') return <span className="text-green-600">{s}</span>;
                      if (s === 'Kết thúc') return <span className="text-red-600">{s}</span>;
                      if (s === 'Sắp diễn ra') return <span className="text-slate-600">{s}</span>;
                      return <span className="text-slate-400">—</span>;
                    })()}
                  </td>
                  <td className="px-4 py-3">
                    {/* ❌ bỏ nút Thời gian thực hiện */}
                    {/* ✅ nút Import SV */}
                    <button
                      onClick={() => { setImportingFor(r.id); fileRef.current?.click(); }}
                      className="mr-2 rounded border px-3 py-1"
                      disabled={importBusy}
                      title="Import sinh viên vào đợt từ file Excel"
                    >
                      {importBusy && importingFor === r.id ? 'Đang import…' : 'Import SV'}
                    </button>
                    <button
                      onClick={() => setModal({ open: true, editing: r })}
                      className="mr-2 rounded border px-3 py-1"
                    >
                      Sửa
                    </button>
                    <button
                      onClick={async () => {
                        if (!confirm(`Xóa đợt "${r.tenDotBaoVe}"?`)) return;
                        try { await deleteDefenseRound(r.id); await load(); }
                        catch (e: any) { alert(e?.response?.data?.message || 'Không thể xóa đợt.'); }
                      }}
                      className="rounded border px-3 py-1 text-red-600"
                    >
                      Xóa
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>

        <div className="flex items-center justify-end gap-3 p-3">
          <button className="rounded border px-3 py-1 disabled:opacity-40"
                  onClick={() => setPage(p => Math.max(0, p - 1))}
                  disabled={page === 0}>Trước</button>
          <span className="text-sm">{page + 1}</span>
          <button className="rounded border px-3 py-1 disabled:opacity-40"
                  onClick={() => setPage(p => (page * size + size < total ? p + 1 : p))}
                  disabled={page * size + size >= total}>Sau</button>
        </div>
      </div>

      {/* input file ẩn dùng chung cho tất cả các hàng */}
      <input
        ref={fileRef}
        type="file"
        accept=".xlsx,.xls,.csv"
        style={{ display: 'none' }}
        onChange={onPickFile}
      />

      {modal.open && (
        <DefenseRoundFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: CreateUpdateDefenseRound) => {
            if (modal.editing) await updateDefenseRound(modal.editing.id, payload);
            else await createDefenseRound(payload);
            setModal({ open: false }); await load();
          }}
        />
      )}
    </div>
  );
}
