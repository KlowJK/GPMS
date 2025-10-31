import { useEffect, useState } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import assistantService, {
  Department, Major,
  CreateMajorPayload, UpdateMajorPayload,
} from '@features/assistants/services/assistantService';
import { useToast } from '@features/admin/components/ToastProvider';
import MajorFormModal from '@features/assistants/components/MajorFormModal';

type ModalState = { open: boolean; editing?: Major | null };

export default function MajorsPage() {
  const { success, error } = useToast();
  const [rows, setRows] = useState<Major[]>([]);
  const [deps, setDeps] = useState<Department[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  async function loadDeps() {
    const res = await assistantService.listDepartments({ page: 0, size: 1000 });
    const pg = assistantService.toPage<Department>(res, { page: 0, size: 1000 });
    setDeps(pg.content);
  }

  async function load() {
    setLoading(true);
    try {
      const res = await assistantService.listMajors({ page, size, q: q.trim() || undefined });
      const pg = assistantService.toPage<Major>(res, { page, size });
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

  async function onDelete(row: Major) {
    if (!confirm(`Xóa ngành "${row.tenNganh}"?`)) return;
    try {
      await assistantService.deleteMajor(row.id);
      success('Xóa ngành thành công.');
      await load();
    } catch {
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
                    onClick={() => onDelete(r)}
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

      {modal.open && (
        <MajorFormModal
          initial={modal.editing ?? undefined}
          departments={deps}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await assistantService.updateMajor(modal.editing.id, payload as UpdateMajorPayload);
                success('Cập nhật ngành thành công.');
              } else {
                await assistantService.createMajor(payload as CreateMajorPayload);
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
