// src/features/admin/components/MajorFormModal.tsx
import { useEffect, useState } from "react";
import ModalBase from "./ui/ModalBase";

export type MajorPayload = { tenNganh: string; khoaId?: number };
type DepartmentOption = { id: number; tenKhoa: string };

type Props = {
  open: boolean;
  mode: "create" | "edit";
  departments: DepartmentOption[]; // để render select Khoa
  initial?: MajorPayload;
  onClose: () => void;
  onSubmit: (payload: MajorPayload) => Promise<void> | void;
};

export default function MajorFormModal({
  open, mode, departments, initial, onClose, onSubmit,
}: Props) {
  const [tenNganh, setTenNganh] = useState("");
  const [khoaId, setKhoaId] = useState<number | undefined>();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTenNganh(initial?.tenNganh ?? "");
    setKhoaId(initial?.khoaId);
  }, [initial, open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit({ tenNganh, khoaId });
      onClose();
    } finally {
      setLoading(false);
    }
  }

  return (
    <ModalBase open={open} onClose={loading ? () => {} : onClose}
      title={mode === "create" ? "Thêm ngành" : "Sửa ngành"}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm mb-2">Tên ngành</label>
          <input
            value={tenNganh}
            onChange={(e) => setTenNganh(e.target.value)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            placeholder="Ví dụ: Hệ thống thông tin"
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
