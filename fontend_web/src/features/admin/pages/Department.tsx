import { useEffect, useState } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import adminService, { Department } from '@features/admin/services/adminService';
import DepartmentFormModal from '@features/admin/components/DepartmentFormModal';
import ConfirmDialog from '@features/admin/components/ConfirmDialog';
import { useToast } from '@features/admin/components/ToastProvider';

type ModalState = { open: boolean; editing?: Department | null };

export default function DepartmentPage() {
  const { success, error } = useToast();
  const [items, setItems] = useState<Department[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  const keyword = q.trim();

  async function load() {
    setLoading(true);
    try {
      const res = await adminService.listDepartments({ page, size, q: keyword || undefined });
      const pg = adminService.toPage<Department>(res, { page, size });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [page, size, keyword]);

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: Department) { setModal({ open: true, editing: row }); }

  function askDelete(row: Department) {
    if (!adminService.canDeleteDepartment(row)) {
      error('Khoa có sẵn không thể xóa.');
      return;
    }
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

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Quản lý khoa</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">+ Thêm khoa</button>
        <input
          className="h-10 px-3 rounded border w-72"
          placeholder="Tìm theo tên khoa…"
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
            ) : items.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={3}>Không có dữ liệu khoa.</td></tr>
            ) : items.map((row, idx) => {
              const stt = page * size + idx + 1;
              const canDel = adminService.canDeleteDepartment(row);
              return (
                <tr key={`${row.id}`} className="border-t">
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
                      onClick={() => canDel && askDelete(row)}  // ✅ dùng askDelete
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

        <div className="flex items-center justify-end gap-3 p-3">
          <button className="px-3 py-1 border rounded disabled:opacity-40"
                  onClick={() => setPage(p => Math.max(0, p - 1))}
                  disabled={page === 0}>Trước</button>
          <span className="text-sm">{page + 1}</span>
          <button className="px-3 py-1 border rounded disabled:opacity-40"
                  onClick={() => setPage(p => (from + size <= total ? p + 1 : p))}
                  disabled={from + size > total}>Sau</button>
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
                setPage(0); // record mới lên đầu
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
        title={confirm.title ?? ''}   // ✅ ép string
        description={confirm.description}
        confirmText="Xóa"
        cancelText="Hủy"
        onConfirm={confirm.onConfirm}
        onClose={() => setConfirm(s => ({ ...s, open: false }))}
      />
    </div>
  );
}
