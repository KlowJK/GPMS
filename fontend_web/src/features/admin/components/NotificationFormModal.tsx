// src/features/admin/components/NotificationFormModal.tsx
import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/features/admin/components/ToastProvider';
import { type Department, listDepartments } from '@/features/assistants/services/organization/orgApi';

type Props = {
  onClose: () => void;
  onSubmit: (p: { tieuDe: string; noiDung: string; khoaId?: number | null; file?: File | null }) => Promise<any>;
};

type Mode = 'all' | 'dept';

function normalizeVN(s?: string) {
  return (s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '');
}

export default function NotificationFormModal({ onClose, onSubmit }: Props) {
  const { error } = useToast();

  const [mode, setMode] = useState<Mode>('all'); // 'all' = Toàn trường | 'dept' = Theo khoa
  const [tieuDe, setTieuDe] = useState('');
  const [noiDung, setNoiDung] = useState('');
  const [file, setFile] = useState<File | null>(null);

  // khoa
  const [deps, setDeps] = useState<Department[]>([]);
  const [khoaId, setKhoaId] = useState<string>(''); // id khoa được chọn khi mode='dept'
  const [qDept, setQDept] = useState('');

  useEffect(() => {
    (async () => {
      try {
        const res = await listDepartments({ page: 0, size: 999 });
        const raw: any = (res as any).data;
        const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
        setDeps(arr);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được danh sách khoa.');
      }
    })();
  }, [error]);

  const filteredDeps = useMemo(() => {
    const k = normalizeVN(qDept.trim());
    if (!k) return deps;
    return deps.filter(d => normalizeVN(d.tenKhoa).includes(k));
  }, [deps, qDept]);

  const canSave = useMemo(() => {
    if (!tieuDe.trim() || !noiDung.trim()) return false;
    if (mode === 'dept' && !khoaId) return false;
    return true;
  }, [tieuDe, noiDung, mode, khoaId]);

  async function save() {
    if (!canSave) return;
    try {
      const parsed = Number(khoaId);
      await onSubmit({
        tieuDe: tieuDe.trim(),
        noiDung: noiDung.trim(),
        khoaId: mode === 'dept' && Number.isFinite(parsed) && parsed > 0 ? parsed : null,
        file,
      });
      onClose();
    } finally {
      // giữ nguyên
    }
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="w-[660px] max-w-[95vw] rounded-2xl bg-white p-6 shadow-xl">
        <h3 className="text-lg font-semibold">Tạo thông báo</h3>

        <div className="mt-4 grid gap-4">
          <div className="grid gap-1">
            <label className="block text-sm text-slate-600">Tiêu đề *</label>
            <input className="w-full h-11 rounded border px-3" value={tieuDe} onChange={(e) => setTieuDe(e.target.value)} />
          </div>

          <div className="grid gap-1">
            <label className="block text-sm text-slate-600">Nội dung *</label>
            <textarea className="w-full min-h-[140px] rounded border px-3 py-2" value={noiDung} onChange={(e) => setNoiDung(e.target.value)} />
          </div>

          {/* Kiểu gửi */}
          <div className="grid gap-2">
            <span className="block text-sm text-slate-600">Gửi đến</span>
            <div className="flex items-center gap-6">
              <label className="inline-flex items-center gap-2">
                <input
                  type="radio"
                  name="send_mode"
                  value="all"
                  checked={mode === 'all'}
                  onChange={() => setMode('all')}
                />
                <span>Toàn trường</span>
              </label>
              <label className="inline-flex items-center gap-2">
                <input
                  type="radio"
                  name="send_mode"
                  value="dept"
                  checked={mode === 'dept'}
                  onChange={() => setMode('dept')}
                />
                <span>Theo khoa</span>
              </label>
            </div>

            {mode === 'dept' && (
              <div className="mt-2 grid gap-2">
                <input
                  className="h-10 rounded border px-3"
                  placeholder="Tìm theo tên khoa…"
                  value={qDept}
                  onChange={(e) => setQDept(e.target.value)}
                />
                <select
                  className="w-full h-11 rounded border px-3 bg-white"
                  value={khoaId}
                  onChange={(e) => setKhoaId(e.target.value)}
                >
                  <option value="">— Chọn khoa —</option>
                  {filteredDeps.map((d) => (
                    <option key={String(d.id)} value={String(d.id)}>
                      {d.tenKhoa}
                    </option>
                  ))}
                </select>
                <p className="text-xs text-slate-500">Chọn khoa để gửi thông báo cho sinh viên thuộc khoa đó.</p>
              </div>
            )}
          </div>

          <div className="grid gap-1">
            <label className="block text-sm text-slate-600">Tệp đính kèm (tuỳ chọn)</label>
            <input
              type="file"
              onChange={(e) => setFile(e.target.files?.[0] ?? null)}
              className="block w-full text-sm file:mr-3 file:rounded file:border file:px-3 file:py-2 file:bg-slate-50"
              accept="*/*"
            />
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 h-10 rounded border">Hủy</button>
          <button
            onClick={save}
            className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
            disabled={!canSave}
          >
            Tạo thông báo
          </button>
        </div>
      </div>
    </div>
  );
}
