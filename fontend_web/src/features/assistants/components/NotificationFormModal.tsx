import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/features/admin/components/ToastProvider';
import { type Department, listDepartments } from '@/features/assistants/services/organization/orgApi';

type Props = {
  onClose: () => void;
  onSubmit: (p: { tieuDe: string; noiDung: string; khoaId?: number | null; file?: File | null }) => Promise<any>;
};

function norm(s = '') {
  return s.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');
}

export default function NotificationFormModal({ onClose, onSubmit }: Props) {
  const { error } = useToast();
  const [tieuDe, setTieuDe] = useState('');
  const [noiDung, setNoiDung] = useState('');
  const [scope, setScope]   = useState<'all'|'dept'>('all'); // Toàn trường / Theo khoa
  const [deptQ, setDeptQ]   = useState('');
  const [deptId, setDeptId] = useState<number | null>(null); // ⇐ Lưu ID khoa
  const [file, setFile]     = useState<File | null>(null);
  const [deps, setDeps]     = useState<Department[]>([]);
  const [busy, setBusy]     = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res: any = await listDepartments({ page: 0, size: 999 });
        const raw = res?.data;
        const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
        setDeps(arr);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được danh sách khoa.');
      }
    })();
  }, [error]);

  const filteredDeps = useMemo(() => {
    const k = norm(deptQ.trim());
    if (!k) return deps;
    return deps.filter(d => norm(d.tenKhoa || '').includes(k));
  }, [deps, deptQ]);

  const canSave = tieuDe.trim() && noiDung.trim() && (scope === 'all' || (scope === 'dept' && deptId != null));

  async function save() {
    if (!canSave || busy) return;
    setBusy(true);
    try {
      await onSubmit({
        tieuDe: tieuDe.trim(),
        noiDung: noiDung.trim(),
        khoaId: scope === 'dept' ? (deptId ?? null) : null,  // ⇐ truyền ID khoa hoặc null
        file,
      });
      onClose();
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[640px] max-w-[95vw] rounded-2xl bg-white p-6 shadow-xl">
        <h3 className="text-lg font-semibold">Tạo thông báo</h3>

        <div className="mt-4 space-y-3">
          <div>
            <label className="block text-sm text-slate-600 mb-1">Tiêu đề *</label>
            <input className="w-full h-11 rounded border px-3" value={tieuDe} onChange={(e) => setTieuDe(e.target.value)} />
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Nội dung *</label>
            <textarea className="w-full min-h-[120px] rounded border px-3 py-2" value={noiDung} onChange={(e) => setNoiDung(e.target.value)} />
          </div>

          {/* Gửi đến */}
          <div>
            <label className="block text-sm text-slate-600 mb-1">Gửi đến</label>
            <div className="flex items-center gap-6">
              <label className="inline-flex items-center gap-2">
                <input type="radio" name="scope" checked={scope === 'all'} onChange={() => setScope('all')} />
                <span>Toàn trường</span>
              </label>
              <label className="inline-flex items-center gap-2">
                <input type="radio" name="scope" checked={scope === 'dept'} onChange={() => setScope('dept')} />
                <span>Theo khoa</span>
              </label>
            </div>

            {scope === 'dept' && (
              <div className="mt-3 grid grid-cols-5 gap-3">
                <input
                  className="col-span-2 h-11 rounded border px-3"
                  placeholder="Lọc theo tên khoa…"
                  value={deptQ}
                  onChange={(e) => setDeptQ(e.target.value)}
                />
                <select
                  className="col-span-3 h-11 rounded border px-3 bg-white"
                  value={deptId ?? ''}
                  onChange={(e) => setDeptId(e.target.value ? Number(e.target.value) : null)} // ⇐ value là ID khoa
                >
                  <option value="">— Chọn khoa —</option>
                  {filteredDeps.map((d) => (
                    <option key={String(d.id)} value={String(d.id)}>
                      {d.tenKhoa}
                    </option>
                  ))}
                </select>
              </div>
            )}
            <p className="mt-1 text-xs text-slate-500">
              * Toàn trường: không gửi kèm khoaId. — Theo khoa: dropdown trả về <b>khoaId</b>.
            </p>
          </div>

          <div>
            <label className="block text-sm text-slate-600 mb-1">Tệp đính kèm (tuỳ chọn)</label>
            <input
              type="file"
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="block w-full text-sm file:mr-3 file:rounded file:border file:px-3 file:py-2 file:bg-slate-50"
            />
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 h-10 rounded border" disabled={busy}>Hủy</button>
          <button onClick={save} className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50" disabled={!canSave || busy}>
            {busy ? 'Đang tạo…' : 'Tạo thông báo'}
          </button>
        </div>
      </div>
    </div>
  );
}
