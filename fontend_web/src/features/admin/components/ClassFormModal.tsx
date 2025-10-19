// src/features/admin/components/ClassFormModal.tsx
import { useEffect, useState } from "react";
import ModalBase from "./ui/ModalBase";

export type ClassPayload = { tenLop: string; nganhId?: number };
type MajorOption = { id: number; tenNganh: string };

type Props = {
  open: boolean;
  mode: "create" | "edit";
  majors: MajorOption[];
  initial?: ClassPayload;
  onClose: () => void;
  onSubmit: (payload: ClassPayload) => Promise<void> | void;
};

export default function ClassFormModal({
  open, mode, majors, initial, onClose, onSubmit,
}: Props) {
  const [tenLop, setTenLop] = useState("");
  const [nganhId, setNganhId] = useState<number | undefined>();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setTenLop(initial?.tenLop ?? "");
    setNganhId(initial?.nganhId);
  }, [initial, open]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      await onSubmit({ tenLop, nganhId });
      onClose();
    } finally {
      setLoading(false);
    }
  }

  return (
    <ModalBase open={open} onClose={loading ? () => {} : onClose}
      title={mode === "create" ? "Thêm lớp" : "Sửa lớp"}
    >
      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <label className="block text-sm mb-2">Tên lớp</label>
          <input
            value={tenLop}
            onChange={(e) => setTenLop(e.target.value)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            placeholder="Ví dụ: 65HTTT1"
            required
          />
        </div>

        <div>
          <label className="block text-sm mb-2">Ngành</label>
          <select
            value={nganhId ?? ""}
            onChange={(e) => setNganhId(Number(e.target.value) || undefined)}
            className="w-full h-11 rounded-md bg-[#F6F6F6] shadow px-4 outline-none focus:ring-2 focus:ring-sky-400"
            required
          >
            <option value="">— Chọn ngành —</option>
            {majors.map((m) => (
              <option key={m.id} value={m.id}>{m.tenNganh}</option>
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
