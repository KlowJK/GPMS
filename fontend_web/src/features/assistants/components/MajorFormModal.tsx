// src/features/assistants/components/MajorFormModal.tsx
import { useMemo, useState } from 'react';
import type {
  Department,
  Major,
  CreateMajorPayload,
  UpdateMajorPayload,
} from '@features/assistants/services/organization/orgApi';

type Props = {
  initial?: Major;
  departments: Department[];
  onClose: () => void;
  onSubmit: (data: CreateMajorPayload | UpdateMajorPayload) => Promise<any>;
};

export default function MajorFormModal({ initial, departments, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [maNganh, setMaNganh]   = useState(initial?.maNganh ?? '');
  const [tenNganh, setTenNganh] = useState(initial?.tenNganh ?? '');
  const [khoaId, setKhoaId]     = useState<string>(initial?.khoaId ? String(initial.khoaId) : '');
  const [err, setErr] = useState<{ maNganh?: string; tenNganh?: string; khoaId?: string }>({});

  async function handleSubmit() {
    const e: typeof err = {};
    if (!maNganh.trim()) e.maNganh = 'Vui lòng nhập mã ngành';
    if (!tenNganh.trim()) e.tenNganh = 'Vui lòng nhập tên ngành';
    if (!khoaId) e.khoaId = 'Vui lòng chọn khoa';
    setErr(e);
    if (Object.keys(e).length) return;

    await onSubmit({
      maNganh: maNganh.trim(),
      tenNganh: tenNganh.trim(),
      // gửi dạng number nếu là số
      khoaId: /^\d+$/.test(khoaId) ? Number(khoaId) : (khoaId as unknown as number),
    });
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[560px]">
        <h2 className="text-xl font-semibold mb-4">{isEdit ? 'Sửa ngành' : 'Thêm ngành'}</h2>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Mã ngành</label>
            <input
              className={`w-full h-11 rounded border px-3 ${err.maNganh ? 'border-red-500' : ''}`}
              value={maNganh}
              onChange={(e) => setMaNganh(e.target.value)}
              placeholder="VD: TLA0"
            />
            {err.maNganh && <p className="text-xs text-red-600 mt-1">{err.maNganh}</p>}
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Khoa</label>
            <select
              className={`w-full h-11 rounded border px-3 ${err.khoaId ? 'border-red-500' : ''}`}
              value={khoaId}
              onChange={(e) => setKhoaId(e.target.value)}
            >
              <option value="">Chọn khoa</option>
              {departments.map(d => (
                <option key={String(d.id)} value={String(d.id)}>{d.tenKhoa}</option>
              ))}
            </select>
            {err.khoaId && <p className="text-xs text-red-600 mt-1">{err.khoaId}</p>}
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Tên ngành</label>
            <input
              className={`w-full h-11 rounded border px-3 ${err.tenNganh ? 'border-red-500' : ''}`}
              value={tenNganh}
              onChange={(e) => setTenNganh(e.target.value)}
              placeholder="VD: Công nghệ thông tin"
            />
            {err.tenNganh && <p className="text-xs text-red-600 mt-1">{err.tenNganh}</p>}
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200">Quay lại</button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white">
            {isEdit ? 'Cập nhật' : 'Lưu'}
          </button>
        </div>
      </div>
    </div>
  );
}
