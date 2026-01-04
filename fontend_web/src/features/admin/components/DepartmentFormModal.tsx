import { useState } from 'react';
import type { Department } from '@features/admin/services/adminService';

type Props = {
  initial?: Department;
  onClose: () => void;
  onSubmit: (data: { tenKhoa: string }) => Promise<any>;
};

export default function DepartmentFormModal({ initial, onClose, onSubmit }: Props) {
  const [tenKhoa, setTenKhoa] = useState(initial?.tenKhoa ?? '');

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[420px]">
        <h2 className="text-xl font-semibold mb-4">
          {initial ? 'Sửa khoa' : 'Thêm khoa'}
        </h2>

        <label className="block text-sm text-slate-600 mb-1">Tên khoa</label>
        <input
          className="w-full h-11 rounded border px-3 mb-6"
          value={tenKhoa}
          onChange={(e) => setTenKhoa(e.target.value)}
          placeholder="Nhập tên khoa"
        />

        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">
            Quay lại
          </button>
          <button
            onClick={() => onSubmit({ tenKhoa })}
            className="px-4 h-10 rounded bg-blue-600 text-white"
          >
            {initial ? 'Cập nhật' : 'Thêm'}
          </button>
        </div>
      </div>
    </div>
  );
}
