// src/features/admin/components/DepartmentFormModal.tsx
import { useEffect, useState } from "react";
import ModalBase from "./ui/ModalBase";

export type DepartmentPayload = { tenKhoa: string };
type Props = {
  open: boolean;
  mode: "create" | "edit";
  initial?: DepartmentPayload;
  onClose: () => void;
  onSubmit: (payload: DepartmentPayload) => Promise<void> | void;
};

export default function DepartmentFormModal({
  open, mode, initial, onClose, onSubmit,
}: Props) {
  const [tenKhoa, setTenKhoa] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTenKhoa(initial?.tenKhoa ?? "");
  }, [initial, open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit({ tenKhoa });
      onClose();
    } finally {
      setLoading(false);
    }
  }

  return (
    <ModalBase open={open} onClose={loading ? () => {} : onClose}
      title={mode === "create" ? "Thêm khoa" : "Sửa khoa"}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm mb-2">Tên khoa</label>
          <input
            value={tenKhoa}
            onChange={(e) => setTenKhoa(e.target.value)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            placeholder="Ví dụ: Công nghệ thông tin"
            required
          />
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
