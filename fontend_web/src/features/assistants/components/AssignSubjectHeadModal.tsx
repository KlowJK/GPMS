import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/features/admin/components/ToastProvider';
import { toPage } from '@/features/assistants/services/base';

import type { Subject } from '@/features/assistants/services/organization/orgApi';
import { setSubjectHead } from '@/features/assistants/services/organization/orgApi';

import type { Lecturer } from '@/features/assistants/services/user/userApi';
import { listLecturers } from '@/features/assistants/services/user/userApi';

// remove accents (bản tương thích cao)
function norm(v?: string) {
  return (v || '').toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '');
}

type Props = {
  subject: Subject;
  onClose: () => void;
  onSaved?: () => void;
};

export default function AssignSubjectHeadModal({ subject, onClose, onSaved }: Props) {
  const { success, error } = useToast();

  const [q, setQ] = useState('');
  const [all, setAll] = useState<Lecturer[]>([]);
  const [loadingGV, setLoadingGV] = useState(false);
  const [selectedId, setSelectedId] = useState<string>(() => {
    const anySub = subject as any;
    return anySub.truongBoMonId != null ? String(anySub.truongBoMonId) : '';
  });
  const [busy, setBusy] = useState(false);

  // tải đủ danh sách GV một lần
  useEffect(() => {
    let alive = true;
    (async () => {
      setLoadingGV(true);
      try {
        const res = await listLecturers({ page: 0, size: 5000 });
        const pg  = toPage<Lecturer>(res, { page: 0, size: 5000 });
        if (alive) setAll(pg.content);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được danh sách giảng viên.');
      } finally {
        if (alive) setLoadingGV(false);
      }
    })();
    return () => { alive = false; };
  }, [error]);

  // lọc client theo tên/email/mã
  const options = useMemo(() => {
    const k = norm(q.trim());
    if (!k) return all;
    return all.filter(gv => {
      const bag = `${norm(gv.hoTen)} ${norm((gv as any).email || '')} ${norm((gv as any).maGiangVien || '')}`;
      return bag.includes(k);
    });
  }, [all, q]);

  async function handleSave(selected: string) {
    try {
      setBusy(true);
      await setSubjectHead({
        boMonId: subject.id,
        giangVienId: selected ? Number(selected) : null,
      });
      success(selected ? 'Gán Trưởng bộ môn thành công.' : 'Bỏ gán Trưởng bộ môn thành công.');
      onSaved?.();
      onClose();
    } catch (e: any) {
      error(e?.response?.data?.message || `Thao tác thất bại.`);
      // để dev tiện theo dõi log lỗi
      // eslint-disable-next-line no-console
      console.error('setSubjectHead error:', e?.response || e);
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[560px] rounded-2xl bg-white p-6 shadow-xl">
        <h3 className="text-lg font-semibold">Gán Trưởng bộ môn</h3>
        <p className="mt-1 text-sm text-slate-600">
          Bộ môn: <span className="font-medium">{subject.tenBoMon}</span>
        </p>

        <div className="mt-4 space-y-2">
          <input
            className="w-full h-10 rounded border px-3"
            placeholder="Tìm giảng viên theo tên/email/mã GV…"
            value={q}
            onChange={(e) => setQ(e.target.value)}
          />
          <select
            className="w-full h-10 rounded border px-3 bg-white"
            value={selectedId}
            onChange={(e) => setSelectedId(e.target.value)}
          >
            <option value="">{loadingGV ? 'Đang tải…' : '— Không chọn —'}</option>
            {options.map(gv => (
              <option key={`${gv.id}`} value={String(gv.id)}>
                {gv.hoTen}{gv.boMonTen ? ` (${gv.boMonTen})` : ''}{(gv as any).email ? ` — ${(gv as any).email}` : ''}
              </option>
            ))}
          </select>
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button className="px-4 h-10 rounded border" onClick={onClose} disabled={busy}>
            Đóng
          </button>
          <button
            className="px-4 h-10 rounded bg-slate-500 text-white disabled:opacity-50"
            onClick={() => handleSave('')}
            disabled={busy}
          >
            Bỏ gán
          </button>
          <button
            className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
            onClick={() => handleSave(selectedId)}
            disabled={busy}
          >
            {busy ? 'Đang lưu…' : 'Gán'}
          </button>
        </div>
      </div>
    </div>
  );
}
