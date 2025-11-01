// src/features/assistants/components/ClassFormModal.tsx
import { useEffect, useState } from 'react';
import type { Id, OrgClass } from '@features/assistants/services/assistantService';
import assistantService from '@features/assistants/services/assistantService';

type Major = { id: Id; tenNganh: string };
type Props = {
  initial?: OrgClass;
  onClose: () => void;
  onSubmit: (data: { tenLop: string; nganhId: Id }) => Promise<any>;
};

export default function ClassFormModal({ initial, onClose, onSubmit }: Props) {
  const isEdit = !!initial;
  const [tenLop, setTenLop] = useState(initial?.tenLop ?? '');
  const [nganhId, setNganhId] = useState<string>(initial?.nganhId != null ? String(initial.nganhId) : '');
  const [majors, setMajors] = useState<Major[]>([]);
  const [err, setErr] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await assistantService.listMajors({ page: 0, size: 999 });
        const raw = assistantService.unwrap<any>(res);
        const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
        setMajors(arr.map(x => ({ id: x.id, tenNganh: x.tenNganh ?? x.ten ?? '' })));
      } catch {
        setMajors([]);
      }
    })();
  }, []);

  async function handleSubmit() {
  if (loading) return;           // ✨ chống double-click
  setErr(null);
  if (!tenLop.trim() || !nganhId) {
    setErr('Vui lòng nhập tên lớp và chọn ngành.'); return;
  }
  try {
    setLoading(true);
    await onSubmit({ tenLop: tenLop.trim(), nganhId: /^\d+$/.test(nganhId) ? Number(nganhId) : nganhId });
    onClose();
  } catch (e: any) {
    setErr(e?.response?.data?.message || 'Không thể lưu dữ liệu. Vui lòng thử lại.');
  } finally {
    setLoading(false);
  }
}

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[560px]">
        <h2 className="text-xl font-semibold mb-4">{isEdit ? 'Sửa lớp' : 'Thêm lớp'}</h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Tên lớp</label>
            <input className="w-full h-11 rounded border px-3" value={tenLop} onChange={e => setTenLop(e.target.value)} />
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Ngành</label>
            <select className="w-full h-11 rounded border px-3 bg-white" value={nganhId} onChange={e => setNganhId(e.target.value)}>
              <option value="">— Chọn ngành —</option>
              {/* Nếu đang sửa và ngành hiện tại không nằm trong danh sách đã load, vẫn hiển thị giữ chỗ */}
              {isEdit && !!nganhId && !majors.some(m => String(m.id) === String(nganhId)) && (
                <option value={nganhId}>
                  {initial?.nganhTen ? `Hiện tại: ${initial.nganhTen}` : `Hiện tại (ID: ${nganhId})`}
                </option>
              )}
              {majors.map(m => (
                <option key={String(m.id)} value={String(m.id)}>{m.tenNganh}</option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200" disabled={loading}>Quay lại</button>
          <button onClick={handleSubmit} className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50" disabled={loading}>
            {isEdit ? (loading ? 'Đang cập nhật…' : 'Cập nhật') : (loading ? 'Đang lưu…' : 'Lưu')}
          </button>
        </div>
      </div>
    </div>
  );
}
