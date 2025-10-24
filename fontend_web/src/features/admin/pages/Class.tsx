import { useEffect, useMemo, useState } from "react";
import { universityService } from "@features/admin/services/universityService";
import ConfirmDialog from "@features/admin/components/ConfirmDialog";
import { useToast } from "@features/admin/components/ToastProvider";

type Major = { id: number; tenNganh: string; khoaId: number };
type ClassItem = { id: number; tenLop: string; nganhId: number };

function extractList<T = any>(res: any): T[] {
  const d = res?.data ?? res;
  const r = d?.result ?? d;
  if (Array.isArray(r)) return r as T[];
  if (Array.isArray(r?.content)) return r.content as T[];
  if (Array.isArray(d?.content)) return d.content as T[];
  return [];
}

export default function ClassPage() {
  const { success, error } = useToast();
  const [items, setItems] = useState<ClassItem[]>([]);
  const [majors, setMajors] = useState<Major[]>([]);
  const [loading, setLoading] = useState(false);
  const [keyword, setKeyword] = useState("");
  const [modal, setModal] = useState<{ open: boolean; editing?: ClassItem | null }>({ open: false });

  const [confirm, setConfirm] = useState<{
    open: boolean; title?: string; description?: string; onConfirm?: () => void | Promise<void>;
  }>({ open: false });

  const openConfirm = (title: string, description: string, onConfirm: () => void | Promise<void>) =>
    setConfirm({ open: true, title, description, onConfirm });

  const majorMap = useMemo(
    () => new Map<number, string>(majors.map((m) => [m.id, m.tenNganh])),
    [majors]
  );

  async function load() {
    setLoading(true);
    try {
      const [c, m] = await Promise.all([
        universityService.getClasses(),
        universityService.getMajors(),
      ]);
      setItems(extractList<ClassItem>(c));
      setMajors(extractList<Major>(m));
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  const filtered = useMemo(() => {
    const k = keyword.trim().toLowerCase();
    if (!k) return items;
    return items.filter((x) => x.tenLop?.toLowerCase().includes(k));
  }, [items, keyword]);

  async function handleDelete(row: ClassItem) {
    openConfirm(
      "Xóa lớp",
      `Xóa lớp "${row.tenLop}"?`,
      async () => {
        try {
          await universityService.deleteClass(row.id);
          success("Xóa lớp thành công");
          await load();
        } catch {
          error("Không thể xóa lớp");
        }
      }
    );
  }

  return (
    <div className="max-w-6xl mx-auto">
      <h1 className="text-3xl font-semibold text-center mb-8">Quản lý lớp</h1>

      <div className="flex items-center gap-3 mb-5">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg"
        >
          + Thêm lớp
        </button>
        <input
          className="h-10 px-3 rounded border w-72"
          placeholder="Tìm theo tên lớp…"
          value={keyword}
          onChange={(e) => setKeyword(e.target.value)}
        />
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-20">STT</th>
              <th className="px-4">Tên lớp</th>
              <th className="px-4">Ngành</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Không có dữ liệu lớp.</td></tr>
            ) : (
              filtered.map((row, idx) => (
                <tr key={row.id} className="border-t">
                  <td className="px-4 py-3">{idx + 1}</td>
                  <td className="px-4 py-3">{row.tenLop}</td>
                  <td className="px-4 py-3">{majorMap.get(row.nganhId) || row.nganhId}</td>
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
        <ClassModal
          initial={modal.editing ?? undefined}
          majors={majors}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await universityService.updateClass(modal.editing.id, payload);
                success("Cập nhật lớp thành công");
              } else {
                await universityService.addClass(payload);
                success("Thêm lớp thành công");
              }
              setModal({ open: false });
              await load();
            } catch {
              error("Lưu lớp thất bại");
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

function ClassModal({
  initial,
  onClose,
  onSubmit,
  majors,
}: {
  initial?: ClassItem;
  majors: Major[];
  onClose: () => void;
  onSubmit: (data: { tenLop: string; nganhId: number }) => Promise<any>;
}) {
  const [tenLop, setTenLop] = useState(initial?.tenLop ?? "");
  const [nganhId, setNganhId] = useState<number>(initial?.nganhId ?? majors[0]?.id ?? 0);

  return (
    <div className="fixed inset-0 bg-black/40 flex items-center justify-center z-50">
      <div className="w-[420px] bg-white rounded-2xl p-6">
        <h2 className="text-xl font-semibold mb-4">{initial ? "Sửa lớp" : "Thêm lớp"}</h2>

        <label className="block text-sm text-slate-600 mb-1">Tên lớp</label>
        <input
          className="w-full h-11 rounded border px-3 mb-4"
          value={tenLop}
          onChange={(e) => setTenLop(e.target.value)}
          placeholder="Nhập tên lớp"
        />

        <label className="block text-sm text-slate-600 mb-1">Ngành</label>
        <select
          className="w-full h-11 rounded border px-3 mb-6"
          value={nganhId}
          onChange={(e) => setNganhId(Number(e.target.value))}
        >
          {majors.map((m) => (
            <option key={m.id} value={m.id}>{m.tenNganh}</option>
          ))}
        </select>

        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button
            onClick={() => onSubmit({ tenLop, nganhId })}
            className="px-4 h-10 rounded bg-blue-600 text-white"
          >
            {initial ? "Cập nhật" : "Thêm"}
          </button>
        </div>
      </div>
    </div>
  );
}
