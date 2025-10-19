// src/features/admin/components/SubjectFormModal.tsx
import { useEffect, useState } from "react";
import ModalBase from "./ui/ModalBase";

export type SubjectPayload = { tenBoMon: string; khoaId?: number };
type DepartmentOption = { id: number; tenKhoa: string };

type Props = {
  open: boolean;
  mode: "create" | "edit";
  departments: DepartmentOption[];
  initial?: SubjectPayload;
  onClose: () => void;
  onSubmit: (payload: SubjectPayload) => Promise<void> | void;
};

export default function SubjectFormModal({
  open, mode, departments, initial, onClose, onSubmit,
}: Props) {
  const [tenBoMon, setTenBoMon] = useState("");
  const [khoaId, setKhoaId] = useState<number | undefined>();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTenBoMon(initial?.tenBoMon ?? "");
    setKhoaId(initial?.khoaId);
  }, [initial, open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit({ tenBoMon, khoaId });
      onClose();
    } finally {
      setLoading(false);
    }
  }

  return (
    <ModalBase open={open} onClose={loading ? () => {} : onClose}
      title={mode === "create" ? "Thêm bộ môn" : "Sửa bộ môn"}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm mb-2">Tên bộ môn</label>
          <input
            value={tenBoMon}
            onChange={(e) => setTenBoMon(e.target.value)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            placeholder="Ví dụ: Trí tuệ nhân tạo"
            required
          />
        </div>

        <div>
          <label className="block text-sm mb-2">Khoa</label>
          <select
            value={khoaId ?? ""}
            onChange={(e) => setKhoaId(Number(e.target.value) || undefined)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            required
          >
            <option value="">— Chọn khoa —</option>
            {departments.map((d) => (
              <option key={d.id} value={d.id}>{d.tenKhoa}</option>
            ))}
          </select>
        </div>

        <div className="mt-6 flex items-center justify-center gap-4">
          <button type="button" onClick={onClose}
            disabled={loading}
            className="px-6 h-11 rounded-lg bg-gray-200 text-gray-600 disabled:opacity-60"
          >
            Quay lại
          </button>
          <button type="submit" disabled={loading}
            className="px-6 h-11 rounded-lg bg-[#2F7CD3] text-white disabled:opacity-60"
          >
            {mode === "create" ? "Thêm mới" : "Cập nhật"}
          </button>
        </div>
      </form>
    </ModalBase>
  );
}
