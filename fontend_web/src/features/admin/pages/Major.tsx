import { useEffect, useMemo, useState } from "react";
import { universityService } from "@features/admin/services/universityService";
import ConfirmDialog from "@features/admin/components/ConfirmDialog";
import { useToast } from "@features/admin/components/ToastProvider";

type Department = { id: number; tenKhoa: string };
type Major = { id: number; tenNganh: string; khoaId: number };

function extractList<T = any>(res: any): T[] {
  const d = res?.data ?? res;
  const r = d?.result ?? d;
  if (Array.isArray(r)) return r as T[];
  if (Array.isArray(r?.content)) return r.content as T[];
  if (Array.isArray(d?.content)) return d.content as T[];
  return [];
}

export default function MajorPage() {
  const { success, error } = useToast();
  const [items, setItems] = useState<Major[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(false);
  const [keyword, setKeyword] = useState("");
  const [modal, setModal] = useState<{ open: boolean; editing?: Major | null }>({ open: false });

  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  const openConfirm = (title: string, description: string, onConfirm: () => void | Promise<void>) =>
    setConfirm({ open: true, title, description, onConfirm });

  const depMap = useMemo(
    () => new Map<number, string>(departments.map((d) => [d.id, d.tenKhoa])),
    [departments]
  );

  async function load() {
    setLoading(true);
    try {
      const [m, d] = await Promise.all([
        universityService.getMajors(),
        universityService.getDepartments(),
      ]);
      setItems(extractList<Major>(m));
      setDepartments(extractList<Department>(d));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const filtered = useMemo(() => {
    const k = keyword.trim().toLowerCase();
    if (!k) return items;
    return items.filter((x) => x.tenNganh?.toLowerCase().includes(k));
  }, [items, keyword]);

  async function handleDelete(row: Major) {
    openConfirm(
      "Xóa ngành",
      `Xóa ngành "${row.tenNganh}"?`,
      async () => {
        try {
          await universityService.deleteMajor(row.id);
          success("Xóa ngành thành công");
          await load();
        } catch {
          error("Không thể xóa ngành");
        }
      }
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      <h1 className="text-3xl font-semibold text-center mb-8">Quản lý ngành</h1>

      <div className="flex items-center gap-3 mb-5">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg"
        >
          + Thêm ngành
        </button>
        <input
          className="h-10 px-3 rounded border w-72"
          placeholder="Tìm theo tên ngành…"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-20">STT</th>
              <th className="px-4">Tên ngành</th>
              <th className="px-4">Khoa</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Không có dữ liệu ngành.</td></tr>
            ) : (
              filtered.map((row, idx) => (
                <tr key={row.id} className="border-t">
                  <td className="px-4 py-3">{idx + 1}</td>
                  <td className="px-4 py-3">{row.tenNganh}</td>
                  <td className="px-4 py-3">{depMap.get(row.khoaId) || row.khoaId}</td>
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
        <MajorModal
          initial={modal.editing ?? undefined}
          departments={departments}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await universityService.updateMajor(modal.editing.id, payload);
                success("Cập nhật ngành thành công");
              } else {
                await universityService.addMajor(payload);
                success("Thêm ngành thành công");
              }
              setModal({ open: false });
              await load();
            } catch {
              error("Lưu ngành thất bại");
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

function MajorModal({
  initial,
  onClose,
  onSubmit,
  departments,
}: {
  initial?: Major;
  departments: Department[];
  onClose: () => void;
  onSubmit: (data: { tenNganh: string; khoaId: number }) => Promise<any>;
}) {
  const [tenNganh, setTenNganh] = useState(initial?.tenNganh ?? "");
  const [khoaId, setKhoaId] = useState<number>(initial?.khoaId ?? departments[0]?.id ?? 0);

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="w-[420px] bg-white rounded-2xl p-6">
        <h2 className="text-xl font-semibold mb-4">{initial ? "Sửa ngành" : "Thêm ngành"}</h2>

        <label className="block text-sm text-slate-600 mb-1">Tên ngành</label>
        <input
          className="w-full h-11 rounded border px-3 mb-4"
          value={tenNganh}
          onChange={(e) => setTenNganh(e.target.value)}
          placeholder="Nhập tên ngành"
        />

        <label className="block text-sm text-slate-600 mb-1">Khoa</label>
        <select
          className="w-full h-11 rounded border px-3 mb-6"
          value={khoaId}
          onChange={(e) => setKhoaId(Number(e.target.value))}
        >
          {departments.map((d) => (
            <option key={d.id} value={d.id}>{d.tenKhoa}</option>
          ))}
        </select>

        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button
            onClick={() => onSubmit({ tenNganh, khoaId })}
            className="px-4 h-10 rounded bg-blue-600 text-white"
          >
            {initial ? "Cập nhật" : "Thêm"}
          </button>
        </div>
      </div>
    </div>
  );
}
