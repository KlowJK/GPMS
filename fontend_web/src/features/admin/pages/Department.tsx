import { useEffect, useMemo, useState } from "react";
import { universityService } from "@features/admin/services/universityService";
import ConfirmDialog from "@features/admin/components/ConfirmDialog";
import { useToast } from "@features/admin/components/ToastProvider";

type Department = { id: number; tenKhoa: string };

function extractList<T = any>(res: any): T[] {
  const d = res?.data ?? res;
  const r = d?.result ?? d;
  if (Array.isArray(r)) return r as T[];
  if (Array.isArray(r?.content)) return r.content as T[];
  if (Array.isArray(d?.content)) return d.content as T[];
  return [];
}

export default function DepartmentPage() {
  const { success, error } = useToast();
  const [items, setItems] = useState<Department[]>([]);
  const [loading, setLoading] = useState(false);
  const [keyword, setKeyword] = useState("");
  const [modal, setModal] = useState<{ open: boolean; editing?: Department | null }>({ open: false });

  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  const openConfirm = (title: string, description: string, onConfirm: () => void | Promise<void>) =>
    setConfirm({ open: true, title, description, onConfirm });

  async function load() {
    setLoading(true);
    try {
      const res = await universityService.getDepartments();
      setItems(extractList<Department>(res));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const filtered = useMemo(() => {
    const k = keyword.trim().toLowerCase();
    if (!k) return items;
    return items.filter((x) => x.tenKhoa?.toLowerCase().includes(k));
  }, [items, keyword]);

  async function handleDelete(row: Department) {
    openConfirm(
      "Xóa khoa",
      `Xóa khoa "${row.tenKhoa}"?`,
      async () => {
        try {
          await universityService.deleteDepartment(row.id);
          success("Xóa khoa thành công");
          await load();
        } catch {
          error("Không thể xóa khoa");
        }
      }
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      <h1 className="text-3xl font-semibold text-center mb-8">Quản lý khoa</h1>

      <div className="flex items-center gap-3 mb-5">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg"
        >
          + Thêm khoa
        </button>
        <input
          className="h-10 px-3 rounded border w-72"
          placeholder="Tìm theo tên khoa…"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
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
            ) : (
              filtered.map((row, idx) => (
                <tr key={row.id} className="border-t">
                  <td className="px-4 py-3">{idx + 1}</td>
                  <td className="px-4 py-3">{row.tenKhoa}</td>
                  <td className="px-4 py-3">
                    <button
                      className="text-blue-600 mr-4"
                      onClick={() => setModal({ open: true, editing: row })}
                    >
                      Sửa
                    </button>
                    <button className="text-red-600" onClick={() => handleDelete(row)}>Xóa</button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {modal.open && (
        <DepartmentModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await universityService.updateDepartment(modal.editing.id, payload);
                success("Cập nhật khoa thành công");
              } else {
                await universityService.addDepartment(payload);
                success("Thêm khoa thành công");
              }
              setModal({ open: false });
              await load();
            } catch {
              error("Lưu khoa thất bại");
            }
          }}
        />
      )}

      <ConfirmDialog
        open={confirm.open}
        title={confirm.title}
        description={confirm.description}
        confirmText="OK"
        cancelText="Hủy"
        onConfirm={confirm.onConfirm}
        onClose={() => setConfirm(s => ({ ...s, open: false }))}
      />
    </div>
  );
}

function DepartmentModal({
  initial,
  onClose,
  onSubmit,
}: {
  initial?: Department;
  onClose: () => void;
  onSubmit: (data: { tenKhoa: string }) => Promise<any>;
}) {
  const [tenKhoa, setTenKhoa] = useState(initial?.tenKhoa ?? "");

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="w-[380px] bg-white rounded-2xl p-6">
        <h2 className="text-xl font-semibold mb-4">{initial ? "Sửa khoa" : "Thêm khoa"}</h2>
        <label className="block text-sm text-slate-600 mb-1">Tên khoa</label>
        <input
          className="w-full h-11 rounded border px-3 mb-6"
          value={tenKhoa}
          onChange={(e) => setTenKhoa(e.target.value)}
          placeholder="Nhập tên khoa"
        />
        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button
            onClick={() => onSubmit({ tenKhoa })}
            className="px-4 h-10 rounded bg-blue-600 text-white"
          >
            {initial ? "Cập nhật" : "Thêm"}
          </button>
        </div>
      </div>
    </div>
  );
}
