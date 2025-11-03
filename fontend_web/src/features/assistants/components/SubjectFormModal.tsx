// src/features/assistants/components/SubjectFormModal.tsx
import { useMemo, useState } from 'react';

// Org API types
import type {
  Department,
  Subject,
  CreateSubjectPayload,
  UpdateSubjectPayload,
} from '@features/assistants/services/organization/orgApi';

type Props = {
  initial?: Subject;
  departments: Department[];
  onClose: () => void;
  onSubmit: (data: CreateSubjectPayload | UpdateSubjectPayload) => Promise<any>;
};

function toId(v: string | number) {
  return typeof v === 'number' ? v : (/^\d+$/.test(v) ? Number(v) : v);
}

export default function SubjectFormModal({ initial, departments, onClose, onSubmit }: Props) {
  const isEdit = useMemo(() => Boolean(initial?.id), [initial]);

  const [tenBoMon, setTenBoMon] = useState<string>(initial?.tenBoMon ?? '');
  const [khoaId, setKhoaId] = useState<string>(() =>
    initial?.khoaId != null
      ? String(initial.khoaId)
      : departments[0]?.id != null
      ? String(departments[0].id)
      : ''
  );

  const [saving, setSaving] = useState(false);
  const [err, setErr] = useState<string | null>(null);

  async function handleSubmit() {
    if (saving) return;

    if (!tenBoMon.trim() || !khoaId) {
      setErr('Vui lòng nhập Tên bộ môn và chọn Khoa.');
      return;
    }

    setErr(null);
    setSaving(true);
    try {
      // chỉ gửi đúng 2 trường BE cần
      const payload: CreateSubjectPayload = {
        tenBoMon: tenBoMon.trim(),
        khoaId: toId(khoaId),
      };
      await onSubmit(payload as (CreateSubjectPayload | UpdateSubjectPayload));
      onClose();
    } catch {
      setErr('Không thể lưu bộ môn. Vui lòng thử lại.');
    } finally {
      setSaving(false);
    }
  }

  const hasDepartments = departments?.length > 0;

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[560px]">
        <h2 className="text-xl font-semibold mb-4">
          {isEdit ? 'Sửa bộ môn' : 'Thêm bộ môn'}
        </h2>

        {err && <div className="mb-3 text-sm text-red-600">{err}</div>}

        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Tên bộ môn</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={tenBoMon}
              onChange={(e) => setTenBoMon(e.target.value)}
              placeholder="VD: Khoa học máy tính"
            />
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Khoa</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={khoaId}
              onChange={(e) => setKhoaId(e.target.value)}
              disabled={!hasDepartments}
            >
              {hasDepartments ? (
                departments.map((d) => (
                  <option key={`${d.id}`} value={String(d.id)}>
                    {d.tenKhoa}
                  </option>
                ))
              ) : (
                <option value="">— Chưa có dữ liệu khoa —</option>
              )}
            </select>
          </div>
        </div>

        <div className="flex justify-end gap-3 mt-6">
          <button onClick={onClose} className="px-4 h-10 rounded bg-slate-200" disabled={saving}>
            Quay lại
          </button>
          <button
            onClick={handleSubmit}
            className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
            disabled={saving || !hasDepartments}
          >
            {isEdit ? (saving ? 'Đang cập nhật…' : 'Cập nhật') : (saving ? 'Đang lưu…' : 'Lưu')}
          </button>
        </div>
      </div>
    </div>
  );
}
