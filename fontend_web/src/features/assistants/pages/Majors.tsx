// src/features/assistants/pages/MajorsPage.tsx
import { useEffect, useState } from 'react';
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

type ModalState = { open: boolean; editing?: Major | null };
type ConfirmState = { open: boolean; row?: Major | null; busy?: boolean };

export default function MajorsPage() {
  const { success, error } = useToast();

  const [rows, setRows] = useState<Major[]>([]);
  const [deps, setDeps] = useState<Department[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(1000);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // ✅ modal xác nhận xoá
  const [confirm, setConfirm] = useState<ConfirmState>({ open: false, row: null, busy: false });

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
      const res = await listMajors({ page, size, q: q.trim() || undefined });
      const pg = toPage<Major>(res, { page, size });
      setRows(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadDeps(); }, []);
  useEffect(() => { load(); }, [page, size, q]);

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: Major) { setModal({ open: true, editing: row }); }

  // ✅ mở modal xác nhận xoá
  function askDelete(row: Major) {
    setConfirm({ open: true, row, busy: false });
  }

  // ✅ thực hiện xoá sau khi xác nhận
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
  const to = Math.min(total, page * size + rows.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách ngành</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          + Thêm ngành
        </button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo mã/tên ngành…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
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
            ) : rows.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Không có dữ liệu.</td></tr>
            ) : rows.map((r) => (
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

        <div className="flex items-center justify-end gap-3 p-3">
          <button
            className="px-3 py-1 border rounded disabled:opacity-40"
            onClick={() => setPage(p => Math.max(0, p - 1))}
            disabled={page === 0}
          >Trước</button>
          <span className="text-sm">{page + 1}</span>
          <button
            className="px-3 py-1 border rounded disabled:opacity-40"
            onClick={() => setPage(p => (from + size <= total ? p + 1 : p))}
            disabled={from + size > total}
          >Sau</button>
        </div>
      </div>

      {/* ✅ Modal xác nhận xoá */}
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
