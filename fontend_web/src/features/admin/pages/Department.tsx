import { useEffect, useMemo, useState } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import adminService, { Department } from '@features/admin/services/adminService';
import DepartmentFormModal from '@features/admin/components/DepartmentFormModal';
import ConfirmDialog from '@features/admin/components/ConfirmDialog';
import { useToast } from '@features/admin/components/ToastProvider';

// dùng pager dùng chung
import Pagination from '@/features/assistants/components/Pagination';

/* helpers */
function useDebounce<T>(value: T, delay = 300) {
  const [v, setV] = useState(value);
  useEffect(() => { const t = setTimeout(() => setV(value), delay); return () => clearTimeout(t); }, [value, delay]);
  return v;
}
const norm = (s = '') => s.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');

type ModalState = { open: boolean; editing?: Department | null };

export default function DepartmentPage() {
  const { success, error } = useToast();
  const [items, setItems] = useState<Department[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const qx = useDebounce(q, 250);
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  async function load() {
    setLoading(true);
    try {
      // vẫn truyền q lên BE nếu có hỗ trợ tìm kiếm server-side
      const res = await adminService.listDepartments({ page, size, q: qx.trim() || undefined });
      const pg = adminService.toPage<Department>(res, { page, size });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [page, size, qx]); // eslint-disable-line

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: Department) { setModal({ open: true, editing: row }); }

  function askDelete(row: Department) {
    if (!adminService.canDeleteDepartment(row)) { error('Khoa có sẵn không thể xóa.'); return; }
    setConfirm({
      open: true,
      title: 'Xóa khoa',
      description: `Bạn có chắc chắn muốn xóa khoa "${row.tenKhoa}" không?`,
      onConfirm: async () => {
        try {
          await adminService.deleteDepartment(row.id);
          success('Xóa khoa thành công.');
          setConfirm(s => ({ ...s, open: false }));
          await load();
        } catch {
          error('Không thể xóa khoa.');
          setConfirm(s => ({ ...s, open: false }));
        }
      },
    });
  }

  // lọc mềm phía client theo tên hoặc ID
  const filtered = useMemo(() => {
    const k = qx.trim();
    if (!k) return items;
    const nk = norm(k);
    return items.filter(r => norm(r.tenKhoa).includes(nk) || String(r.id).includes(k));
  }, [items, qx]);

  const totalPages = Math.max(1, Math.ceil(total / size));
  const from = total ? page * size + 1 : 0;
  const to = Math.min(total, page * size + filtered.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Quản lý khoa</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">+ Thêm khoa</button>
        <input
          className="h-10 px-3 rounded border w-72"
          placeholder="Tìm theo tên hoặc ID khoa…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-20">STT</th>
              <th className="px-4">Tên khoa</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={3}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={3}>Không có dữ liệu khoa.</td></tr>
            ) : filtered.map((row, idx) => {
              const stt = page * size + idx + 1;
              const canDel = adminService.canDeleteDepartment(row);
              return (
                <tr key={row.id as any} className="border-t">
                  <td className="px-4 py-3">{stt}</td>
                  <td className="px-4 py-3">{row.tenKhoa}</td>
                  <td className="px-4 py-3">
                    <button
                      onClick={() => openEdit(row)}
                      aria-label="Sửa khoa"
                      title="Sửa"
                      className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                    >
                      <Pencil size={16} />
                      <span className="sr-only">Sửa</span>
                    </button>

                    <button
                      onClick={() => canDel && askDelete(row)}
                      disabled={!canDel}
                      aria-label="Xóa khoa"
                      title={!canDel ? 'Khoa có sẵn – không thể xóa' : 'Xóa'}
                      className={`ml-1 inline-flex items-center justify-center h-9 w-9 rounded-md text-red-600 hover:bg-red-50 ${
                        !canDel ? 'opacity-40 pointer-events-none' : ''
                      }`}
                    >
                      <Trash2 size={16} />
                      <span className="sr-only">Xóa</span>
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {/* ✅ Pagination dùng chung, căn giữa */}
        <div className="p-3 flex justify-center">
          <Pagination
            page={page}
            totalPages={totalPages}
            onChange={setPage}
            showCounter={false}
            disabled={loading}
          />
        </div>
      </div>

      {modal.open && (
        <DepartmentFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await adminService.updateDepartment(modal.editing.id, payload);
                success('Cập nhật khoa thành công.');
              } else {
                await adminService.createDepartment(payload);
                success('Thêm khoa thành công.');
                setPage(0);
              }
              setModal({ open: false });
              await load();
            } catch {
              error('Lưu khoa thất bại.');
            }
          }}
        />
      )}

      <ConfirmDialog
        open={confirm.open}
        title={confirm.title ?? ''}
        description={confirm.description}
        confirmText="Xóa"
        cancelText="Hủy"
        onConfirm={confirm.onConfirm}
        onClose={() => setConfirm(s => ({ ...s, open: false }))}
      />
    </div>
  );
}
