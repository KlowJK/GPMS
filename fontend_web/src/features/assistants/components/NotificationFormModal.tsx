import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/features/admin/components/ToastProvider';
import { listDepartmentsNormalized } from '@/features/assistants/services/organization/orgApi';

type Props = {
  onClose: () => void;
  onSubmit: (p: {
    tieuDe: string;
    noiDung: string;
    kieuNguoiNhan?: string | null; // ID khoa hoặc undefined
    file?: File | null;
  }) => Promise<any>;
};

const norm = (s = '') => s.toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');

export default function NotificationFormModal({ onClose, onSubmit }: Props) {
  const { error } = useToast();

  const [tieuDe, setTieuDe] = useState('');
  const [noiDung, setNoiDung] = useState('');
  const [sendByDept, setSendByDept] = useState(false);
  const [deptFilter, setDeptFilter] = useState('');
  const [deptId, setDeptId] = useState<string>(''); // giữ string để không mất chính xác
  const [deps, setDeps] = useState<Array<{ id: string; tenKhoa: string }>>([]);
  const [file, setFile] = useState<File | null>(null);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const list = await listDepartmentsNormalized();
        setDeps(list);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được danh sách khoa.');
      }
    })();
  }, [error]);

  const filteredDeps = useMemo(() => {
    const k = deptFilter.trim();
    if (!k) return deps;
    const kNorm = norm(k);
    return deps.filter(d => norm(d.tenKhoa).includes(kNorm) || d.id.includes(k));
  }, [deps, deptFilter]);

  const canSave = tieuDe.trim() && noiDung.trim() && (!sendByDept || (sendByDept && deptId));

  async function save() {
    if (!canSave || busy) return;
    setBusy(true);
    try {
      await onSubmit({
        tieuDe: tieuDe.trim(),
        noiDung: noiDung.trim(),
        kieuNguoiNhan: sendByDept ? (deptId || null) : undefined,
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
            <label className="inline-flex items-center gap-2">
              <input
                type="checkbox"
                checked={sendByDept}
                onChange={(e) => { setSendByDept(e.target.checked); if (!e.target.checked) setDeptId(''); }}
              />
              <span>Gửi theo khoa</span>
            </label>

            {sendByDept && (
              <div className="mt-3 grid grid-cols-5 gap-3">
                <input
                  className="col-span-2 h-11 rounded border px-3"
                  placeholder="Tìm theo tên/ID khoa…"
                  value={deptFilter}
                  onChange={(e) => setDeptFilter(e.target.value)}
                />
                <select
                  className="col-span-3 h-11 rounded border px-3 bg-white"
                  value={deptId}
                  onChange={(e) => setDeptId(e.target.value)}
                >
                  <option value="">— Chọn khoa —</option>
                  {filteredDeps.length === 0 ? (
                    <option disabled value="">(Không có khoa)</option>
                  ) : filteredDeps.map(d => (
                    <option key={d.id} value={d.id}>
                      {d.tenKhoa} (ID: {d.id})
                    </option>
                  ))}
                </select>
              </div>
            )}

            <p className="mt-1 text-xs text-slate-500">
              Bỏ tick ⇒ không gửi <code>kieuNguoiNhan</code> (toàn trường). Tick & chọn khoa ⇒ gửi <code>kieuNguoiNhan = ID khoa</code>.
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
