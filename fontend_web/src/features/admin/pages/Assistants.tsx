import { useEffect, useState } from 'react';
import { Pencil, Trash2 } from 'lucide-react';
import adminService, { KhoaAssistant } from '@features/admin/services/adminService';
import AssistantFormModal, {
  AssistantCreatePayload,
  AssistantUpdatePayload
} from '@features/admin/components/AssistantFormModal';
import { useToast } from '@features/admin/components/ToastProvider';
import ConfirmDialog from '@features/admin/components/ConfirmDialog';

// 👇 dùng chung pager của trợ lý
import Pagination from '@/features/assistants/components/Pagination';

type ModalState = { open: boolean; editing?: KhoaAssistant | null };

export default function AssistantsPage() {
  const { success, error } = useToast();
  const [rows, setRows] = useState<KhoaAssistant[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10); // cố định 10/trang
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // Confirm delete
  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  async function load() {
    setLoading(true);
    try {
      const res = await adminService.listKhoaAssistants({ page, size, q: q.trim() || undefined });
      const pg = adminService.toPage<KhoaAssistant>(res, { page, size });
      setRows(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, [page, size, q]);

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: KhoaAssistant) { setModal({ open: true, editing: row }); }

  function askDelete(row: KhoaAssistant) {
    setConfirm({
      open: true,
      title: 'Xóa trợ lý khoa',
      description: `Bạn có chắc chắn muốn xóa trợ lý "${row.hoTen}" không?`,
      onConfirm: async () => {
        try {
          await adminService.deleteKhoaAssistant(row.id);
          success('Xóa trợ lý khoa thành công.');
          setConfirm(s => ({ ...s, open: false }));
          await load();
        } catch {
          error('Không thể xóa trợ lý khoa.');
          setConfirm(s => ({ ...s, open: false }));
        }
      }
    });
  }

  const from = page * size + 1;
  const to = Math.min(total, page * size + rows.length);
  const totalPages = Math.max(1, Math.ceil(total / size)); // 👈 thêm để dùng Pagination

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Trợ lý khoa</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          + Thêm trợ lý
        </button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo tên/email…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Họ tên</th>
              <th className="px-4">Email</th>
              <th className="px-4">SĐT</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Đang tải…</td></tr>
            ) : rows.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Không có dữ liệu.</td></tr>
            ) : rows.map((r, idx) => (
              <tr key={`${r.id}`} className="border-t">
                <td className="px-4 py-3">{page * size + idx + 1}</td>
                <td className="px-4 py-3">{r.hoTen}</td>
                <td className="px-4 py-3">{r.email}</td>
                <td className="px-4 py-3">{r.soDienThoai ?? '—'}</td>
                <td className="px-4 py-3">
                  <button
                    onClick={() => openEdit(r)}
                    aria-label="Sửa trợ lý"
                    title="Sửa"
                    className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                  >
                    <Pencil size={16} />
                    <span className="sr-only">Sửa</span>
                  </button>

                  <button
                    onClick={() => askDelete(r)}
                    aria-label="Xóa trợ lý"
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

        {/* ✅ Pagination dùng chung */}
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
        <AssistantFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload, setEmailErr) => {
            try {
              if (modal.editing) {
                await adminService.updateKhoaAssistant(
                  modal.editing.id, payload as AssistantUpdatePayload
                );
                success('Cập nhật trợ lý khoa thành công.');
              } else {
                await adminService.createKhoaAssistant(
                  payload as AssistantCreatePayload
                );
                success('Thêm trợ lý khoa thành công.');
                setPage(0); // đưa record mới lên đầu
              }
              setModal({ open: false });
              await load();
            } catch (e: any) {
              const status = e?.response?.status;
              if (status === 409) { setEmailErr('Email đã tồn tại'); return; }
              if (status === 400) { setEmailErr('Email không hợp lệ'); return; }
              error('Lưu trợ lý khoa thất bại.');
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
