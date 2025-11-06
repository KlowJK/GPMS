// src/features/assistants/pages/MajorsPage.tsx
import { useEffect, useMemo, useState } from 'react';
import { Pencil, Trash2 } from 'lucide-react';

import { useToast } from '@/features/admin/components/ToastProvider';
import MajorFormModal from '@/features/assistants/components/MajorFormModal';

import { toPage } from '@/features/assistants/services/base';
import {
  listDepartments,
  listMajors,
  createMajor,
  updateMajor,
  deleteMajor,
  type Department,
  type Major,
  type CreateMajorPayload,
  type UpdateMajorPayload,
} from '@/features/assistants/services/organization/orgApi';

/* ---------------- helpers ---------------- */
function useDebounce<T>(value: T, delay = 300) {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return v;
}
function norm(v?: string) {
  return (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');
}

/** Thanh phân trang có đầu/cuối, căn giữa */
function PageNav({
  page,            // 0-based
  totalPages,      // >= 1
  onChange,
}: {
  page: number;
  totalPages: number;
  onChange: (p: number) => void;
}) {
  const MAX_WINDOW = 5;
  const p1 = page + 1;
  const tp = totalPages;

  let start = Math.max(1, p1 - Math.floor(MAX_WINDOW / 2));
  let end   = Math.min(tp, start + MAX_WINDOW - 1);
  if (end - start + 1 < MAX_WINDOW) start = Math.max(1, end - MAX_WINDOW + 1);

  const pages: number[] = [];
  for (let i = start; i <= end; i++) pages.push(i);

  const go = (p: number) => onChange(Math.min(Math.max(0, p), tp - 1));

  const btn = (label: string | number, active = false, disabled = false, to?: number) => (
    <button
      key={`${label}-${to ?? label}`}
      className={`min-w-9 h-9 px-2 rounded border text-sm ${
        active ? 'bg-blue-600 text-white border-blue-600' : 'bg-white hover:bg-slate-50'
      } ${disabled ? 'opacity-40 cursor-not-allowed' : ''}`}
      onClick={() => (to != null && !disabled ? go(to) : undefined)}
      disabled={disabled}
    >
      {label}
    </button>
  );

  return (
    <div className="flex items-center gap-2">
      {btn('«', false, page === 0, 0)}
      {btn('‹', false, page === 0, page - 1)}
      {pages.map(n => btn(n, n === p1, false, n - 1))}
      {tp > end && <span className="px-2 select-none">…</span>}
      {btn('›', false, page >= tp - 1, page + 1)}
      {btn('»', false, page >= tp - 1, tp - 1)}
    </div>
  );
}

/* ---------------- page ---------------- */
const PAGE_SIZE = 12;

type ModalState  = { open: boolean; editing?: Major | null };
type ConfirmState = { open: boolean; row?: Major | null; busy?: boolean };

export default function MajorsPage() {
  const { success, error } = useToast();

  const [rows, setRows] = useState<Major[]>([]);
  const [deps, setDeps] = useState<Department[]>([]);
  const [page, setPage] = useState(0);            // 0-based
  const [size, setSize] = useState(PAGE_SIZE);    // dòng/trang
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const qDebounced = useDebounce(q, 300);
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });
  const [confirm, setConfirm] = useState<ConfirmState>({ open: false, row: null, busy: false });

  const totalPages = Math.max(1, Math.ceil(total / size));

  async function loadDeps() {
    try {
      const res = await listDepartments({ page: 0, size: 1000 });
      const pg = toPage<Department>(res, { page: 0, size: 1000 });
      setDeps(pg.content);
    } catch {
      setDeps([]);
    }
  }

  async function load() {
    setLoading(true);
    try {
      // vẫn gửi q lên BE nếu có hỗ trợ; FE sẽ lọc lại theo mã/tên để chắc chắn
      const res = await listMajors({ page, size, q: qDebounced.trim() || undefined });
      const pg = toPage<Major>(res, { page, size });
      setRows(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadDeps(); }, []);
  useEffect(() => { load(); }, [page, size, qDebounced]);

  // Lọc theo MÃ hoặc TÊN (client-side, không phụ thuộc BE)
  const filtered = useMemo(() => {
    const k = norm(qDebounced);
    if (!k) return rows;
    return rows.filter(r =>
      norm(r.tenNganh).includes(k) || norm(r.maNganh).includes(k)
    );
  }, [rows, qDebounced]);

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: Major) { setModal({ open: true, editing: row }); }

  function askDelete(row: Major) { setConfirm({ open: true, row, busy: false }); }
  async function doDelete() {
    if (!confirm.row) return;
    try {
      setConfirm(c => ({ ...c, busy: true }));
      await deleteMajor(confirm.row.id);
      success('Xóa ngành thành công.');
      setConfirm({ open: false, row: null, busy: false });
      await load();
    } catch {
      setConfirm(c => ({ ...c, busy: false }));
      error('Không thể xóa ngành.');
    }
  }

  const from = page * size + 1;
  const to   = Math.min(total, page * size + filtered.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách ngành</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          + Thêm ngành
        </button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo mã hoặc tên ngành…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">
          {total ? `${from}–${to}/${total}` : ''}
        </div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-36">Mã ngành</th>
              <th className="px-4">Tên ngành</th>
              <th className="px-4">Khoa</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Không có dữ liệu.</td></tr>
            ) : filtered.map((r) => (
              <tr key={`${r.id}`} className="border-t">
                <td className="px-4 py-3">{r.maNganh}</td>
                <td className="px-4 py-3">{r.tenNganh}</td>
                <td className="px-4 py-3">
                  {r.khoaTen ?? deps.find(d => `${d.id}` === `${r.khoaId}`)?.tenKhoa ?? '—'}
                </td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => openEdit(r)}
                    aria-label="Sửa"
                    title="Sửa"
                    className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                  >
                    <Pencil size={16} />
                    <span className="sr-only">Sửa</span>
                  </button>
                  <button
                    onClick={() => askDelete(r)}
                    aria-label="Xóa"
                    title="Xóa"
                    className="ml-1 inline-flex items-center justify-center h-9 w-9 rounded-md text-red-600 hover:bg-red-50"
                  >
                    <Trash2 size={16} />
                    <span className="sr-only">Xóa</span>
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Footer phân trang: căn giữa + đầu/cuối */}
        <div className="p-3">
          <div className="flex justify-center">
            <PageNav
              page={page}
              totalPages={totalPages}
              onChange={(p) => { if (p !== page) setPage(p); }}
            />
          </div>

          {/* (tuỳ chọn) chọn số dòng/trang */}
          <div className="mt-3 flex justify-center">
            <select
              className="h-9 border rounded px-2 bg-white"
              value={size}
              onChange={(e) => { setPage(0); setSize(Number(e.target.value) || PAGE_SIZE); }}
            >
              {[12, 20, 50, 100].map(s => (
                <option key={s} value={s}>{s}/trang</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Modal xác nhận xoá */}
      {confirm.open && confirm.row && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
          <div className="w-[460px] rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold mb-2">Xác nhận xóa</h3>
            <p className="text-sm text-slate-600">
              Bạn có chắc muốn xóa ngành <span className="font-medium">{confirm.row.tenNganh}</span>?
            </p>
            <div className="mt-5 flex justify-end gap-3">
              <button
                className="h-10 rounded bg-slate-200 px-4"
                onClick={() => setConfirm({ open: false, row: null, busy: false })}
                disabled={confirm.busy}
              >
                Hủy
              </button>
              <button
                className="inline-flex items-center gap-2 h-10 rounded bg-red-600 px-4 text-white disabled:opacity-50"
                onClick={doDelete}
                disabled={confirm.busy}
                title="Xóa ngành"
              >
                <Trash2 size={16} />
                {confirm.busy ? 'Đang xóa…' : 'Xóa'}
              </button>
            </div>
          </div>
        </div>
      )}

      {modal.open && (
        <MajorFormModal
          initial={modal.editing ?? undefined}
          departments={deps}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await updateMajor(modal.editing.id, payload as UpdateMajorPayload);
                success('Cập nhật ngành thành công.');
              } else {
                await createMajor(payload as CreateMajorPayload);
                success('Thêm ngành thành công.');
              }
              setModal({ open: false });
              await load();
            } catch {
              error('Lưu ngành thất bại.');
            }
          }}
        />
      )}
    </div>
  );
}
