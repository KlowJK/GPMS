// src/features/assistants/components/SubjectFormModal.tsx
import { useEffect, useMemo, useState } from 'react';

import { unwrap, toPage } from '@features/assistants/services/base';

// Org API (bộ môn/khoa)
import type {
  Department,
  Subject,
  CreateSubjectPayload,
  UpdateSubjectPayload,
} from '@features/assistants/services/organization/orgApi';
import { setSubjectHead } from '@features/assistants/services/organization/orgApi';

// User API (giảng viên)
import type { Lecturer } from '@features/assistants/services/user/userApi';
import { listLecturers } from '@features/assistants/services/user/userApi';

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

  const [tenBoMon, setTenBoMon] = useState(initial?.tenBoMon ?? '');
  const [khoaId, setKhoaId] = useState<string>(String(initial?.khoaId ?? departments[0]?.id ?? ''));

  // --- Trưởng bộ môn: searchable dropdown ---
  const [gvSearch, setGvSearch] = useState('');
  const [gvOptions, setGvOptions] = useState<Lecturer[]>([]);
  const [loadingGV, setLoadingGV] = useState(false);
  const [truongBoMonId, setTruongBoMonId] = useState<string>(
    initial?.truongBoMonId ? String(initial.truongBoMonId) : ''
  );

  useEffect(() => {
    let alive = true;
    const q = gvSearch.trim();

    setLoadingGV(true);
    const t = setTimeout(async () => {
      try {
        const res = await listLecturers({ page: 0, size: 10, q: q || undefined });
        const pg = toPage<Lecturer>(res, { page: 0, size: 10 });
        if (alive) setGvOptions(pg.content);
      } finally {
        if (alive) setLoadingGV(false);
      }
    }, 250); // debounce 250ms

    return () => { alive = false; clearTimeout(t); };
  }, [gvSearch]);

  async function handleSubmit() {
    // Lưu bộ môn (create/update)
    const saved = await onSubmit({ tenBoMon, khoaId: toId(khoaId) });

    // Gán/huỷ Trưởng bộ môn theo lựa chọn (có thể để trống)
    const subjectId = saved?.id ?? initial?.id;
    if (subjectId != null) {
      await setSubjectHead({
        idBoMon: subjectId,
        idGiangVien: truongBoMonId ? toId(truongBoMonId) : null,
      });
    }

    onClose();
  }

  return (
    <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
      <div className="bg-white rounded-2xl p-6 w-[560px]">
        <h2 className="text-xl font-semibold mb-4">{isEdit ? 'Sửa bộ môn' : 'Thêm bộ môn'}</h2>

        <div className="grid grid-cols-2 gap-4">
          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Tên bộ môn</label>
            <input
              className="w-full h-11 rounded border px-3"
              value={tenBoMon}
              onChange={(e) => setTenBoMon(e.target.value)}
            />
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Khoa</label>
            <select
              className="w-full h-11 rounded border px-3 bg-white"
              value={khoaId}
              onChange={(e) => setKhoaId(e.target.value)}
            >
              {departments.map((d) => (
                <option key={`${d.id}`} value={String(d.id)}>
                  {d.tenKhoa}
                </option>
              ))}
            </select>
          </div>

          <div className="col-span-2">
            <label className="block text-sm text-slate-600 mb-1">Trưởng bộ môn (tuỳ chọn)</label>

            {/* Ô tìm kiếm giảng viên */}
            <input
              className="w-full h-11 rounded border px-3"
              placeholder="Tìm theo tên/email/mã GV…"
              value={gvSearch}
              onChange={(e) => setGvSearch(e.target.value)}
            />

            {/* Dropdown kết quả */}
            <div className="relative">
              <select
                className="mt-2 w-full h-11 rounded border px-3 bg-white"
                value={truongBoMonId}
                onChange={(e) => setTruongBoMonId(e.target.value)}
              >
                <option value="">{loadingGV ? 'Đang tải…' : '— Không chọn —'}</option>
                {gvOptions.map((gv) => (
                  <option key={`${gv.id}`} value={String(gv.id)}>
                    {gv.hoTen} {gv.boMonTen ? `(${gv.boMonTen})` : ''}
                  </option>
                ))}
              </select>
            </div>
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
