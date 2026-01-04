// src/features/assistants/components/CouncilFormModal.tsx
import { useEffect, useMemo, useState } from 'react';
import { useToast } from '@/features/admin/components/ToastProvider';

import type { Id } from '@features/assistants/services/base';

import type { Lecturer } from '@features/assistants/services/user/userApi';
import { listLecturersAny } from '@features/assistants/services/user/userApi';

import type { DefenseRoundUI } from '@features/assistants/services/topic/topicApi';
import { listDefenseRoundsNormalized } from '@features/assistants/services/topic/topicApi';

type Props = {
  onClose: () => void;
  onSubmit: (payload: {
    tenHoiDong: string;
    thoiGianBatDau: string;
    thoiGianKetThuc: string;
    chuTichId: Id;
    thuKyId: Id;
    dotBaoVeId: Id;
    diaDiem?: string;
    lecturers: { giangVienId: Id }[];
  }) => Promise<any>;
};

export default function CouncilFormModal({ onClose, onSubmit }: Props) {
  const { error } = useToast();

  // form state
  const [ten, setTen] = useState('');
  const [start, setStart] = useState('');
  const [end, setEnd] = useState('');
  const [diaDiem, setDiaDiem] = useState('');
  const [chuTichId, setChuTichId] = useState<Id | ''>('');
  const [thuKyId, setThuKyId] = useState<Id | ''>('');
  const [dotBaoVeId, setDotBaoVeId] = useState<Id | ''>('');

  // options
  const [gvAll, setGvAll] = useState<Lecturer[]>([]);
  const [rounds, setRounds] = useState<DefenseRoundUI[]>([]);
  const [loading, setLoading] = useState(true);

  // tìm kiếm
  const [qGV, setQGV] = useState('');
  const [qChair, setQChair] = useState('');
  const [qSec, setQSec] = useState('');

  // multi-select thành viên hội đồng
  const [members, setMembers] = useState<Set<string>>(new Set());
  const toggleMember = (id: Id) =>
    setMembers(prev => {
      const s = new Set(prev);
      const k = String(id);
      s.has(k) ? s.delete(k) : s.add(k);
      return s;
    });

  // helper: bỏ dấu + lowercase để tìm kiếm VN tốt hơn
  const norm = (v?: string) =>
    (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');

  // lọc danh sách hiển thị theo tên/email
  const filterByNameEmail = (arr: Lecturer[], q: string) => {
    const k = norm(q.trim());
    if (!k) return arr;
    return arr.filter(x => {
      const email = x.email || (x as any).taiKhoan || '';
      return (norm(x.hoTen) + ' ' + norm(email)).includes(k);
    });
  };

  const gvMembers = useMemo(() => filterByNameEmail(gvAll, qGV), [gvAll, qGV]);
  const gvChair   = useMemo(() => filterByNameEmail(gvAll, qChair), [gvAll, qChair]);
  const gvSecOpt  = useMemo(() => filterByNameEmail(gvAll, qSec), [gvAll, qSec]);

  // load options (đợt + toàn bộ giảng viên)
  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        setLoading(true);
        const [pgRound, lecturers] = await Promise.all([
          listDefenseRoundsNormalized({ page: 0, size: 999 }),
          listLecturersAny(),
        ]);
        if (!alive) return;
        setRounds(pgRound.content);
        setGvAll(lecturers);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được dữ liệu lựa chọn.');
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => { alive = false; };
  }, [error]);

  // mặc định auto chọn đợt đầu tiên
  useEffect(() => {
    if (!dotBaoVeId && rounds.length) setDotBaoVeId(rounds[0].id);
  }, [rounds, dotBaoVeId]);

  const canSave = useMemo(
    () => !!(ten.trim() && start && end && dotBaoVeId && chuTichId && thuKyId),
    [ten, start, end, dotBaoVeId, chuTichId, thuKyId]
  );

  async function handleSave() {
    if (!canSave) return;
    const lecturers = Array.from(members).map(id => ({ giangVienId: Number(id) }));
    await onSubmit({
      tenHoiDong: ten.trim(),
      thoiGianBatDau: start,
      thoiGianKetThuc: end,
      chuTichId: chuTichId as Id,
      thuKyId: thuKyId as Id,
      dotBaoVeId: dotBaoVeId as Id,
      diaDiem: diaDiem.trim() || undefined,
      lecturers,
    });
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/40">
      <div className="h-full w-full overflow-y-auto">
        <div className="mx-auto my-6 md:my-10 w-[760px] max-w-[95vw] md:translate-x-6">
          <div className="rounded-2xl bg-white shadow-xl">
            <div className="px-6 pt-6">
              <h2 className="text-xl font-semibold">Thêm hội đồng</h2>
            </div>

            <div className="px-6 pb-4 mt-4 max-h-[70vh] overflow-y-auto pr-1">
              <div className="grid grid-cols-2 gap-4">
                <div className="col-span-2">
                  <label className="block text-sm text-slate-600 mb-1">Tên hội đồng</label>
                  <input
                    className="w-full h-11 rounded border px-3"
                    value={ten}
                    onChange={(e) => setTen(e.target.value)}
                  />
                </div>

                <div>
                  <label className="block text-sm text-slate-600 mb-1">Bắt đầu</label>
                  <input
                    type="date"
                    className="w-full h-11 rounded border px-3"
                    value={start}
                    onChange={(e) => setStart(e.target.value)}
                  />
                </div>
                <div>
                  <label className="block text-sm text-slate-600 mb-1">Kết thúc</label>
                  <input
                    type="date"
                    className="w-full h-11 rounded border px-3"
                    value={end}
                    onChange={(e) => setEnd(e.target.value)}
                  />
                </div>

                <div>
                  <label className="block text-sm text-slate-600 mb-1">Đợt bảo vệ</label>
                  <select
                    className="w-full h-11 rounded border px-3 bg-white"
                    value={dotBaoVeId === '' ? '' : String(dotBaoVeId)}
                    onChange={(e) => setDotBaoVeId(e.target.value ? Number(e.target.value) : '')}
                    disabled={loading}
                  >
                    {rounds.map(r => (
                      <option key={`${r.id}`} value={String(r.id)}>
                        {r.tenDotBaoVe} — {r.hocKi}/{r.namHoc}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="col-span-2">
                  <label className="block text-sm text-slate-600 mb-1">Địa điểm (tuỳ chọn)</label>
                  <input
                    className="w-full h-11 rounded border px-3"
                    value={diaDiem}
                    onChange={(e) => setDiaDiem(e.target.value)}
                    placeholder="VD: P.302 - Nhà C2"
                  />
                </div>

                {/* Giảng viên tham gia (lọc theo tên/email) */}
                <div className="col-span-2">
                  <label className="block text-sm text-slate-600 mb-1">Giảng viên tham gia</label>
                  <input
                    className="w-full h-10 rounded border px-3 mb-2"
                    placeholder="Tìm theo tên hoặc email…"
                    value={qGV}
                    onChange={(e) => setQGV(e.target.value)}
                  />
                  <div className="max-h-64 overflow-y-auto overscroll-contain rounded border p-2">
                    {loading ? (
                      <div className="text-sm text-slate-500 px-1">Đang tải…</div>
                    ) : gvMembers.length === 0 ? (
                      <div className="text-sm text-slate-500 px-1">Không có dữ liệu.</div>
                    ) : (
                      gvMembers.map(x => {
                        const checked = members.has(String(x.id));
                        return (
                          <label key={`${x.id}`} className="flex items-center gap-2 py-1 px-1">
                            <input
                              type="checkbox"
                              className="h-4 w-4"
                              checked={checked}
                              onChange={() => toggleMember(x.id)}
                            />
                            <span className="text-sm">
                              {x.hoTen}
                              {x.boMonTen ? ` — ${x.boMonTen}` : ''}
                              {x.email ? ` — ${x.email}` : ''}
                            </span>
                          </label>
                        );
                      })
                    )}
                  </div>
                </div>

                {/* Chủ tịch */}
                <div>
                  <label className="block text-sm text-slate-600 mb-1">Chủ tịch hội đồng</label>
                  <input
                    className="w-full h-10 rounded border px-3 mb-2"
                    placeholder="Tìm theo tên hoặc email…"
                    value={qChair}
                    onChange={(e) => setQChair(e.target.value)}
                  />
                  <select
                    className="w-full h-11 rounded border px-3 bg-white"
                    value={chuTichId === '' ? '' : String(chuTichId)}
                    onChange={(e) => setChuTichId(e.target.value ? Number(e.target.value) : '')}
                    disabled={loading}
                  >
                    <option value="">— Chọn —</option>
                    {gvChair.map(x => (
                      <option key={`${x.id}`} value={String(x.id)}>
                        {x.hoTen}{x.email ? ` — ${x.email}` : ''}
                      </option>
                    ))}
                  </select>
                </div>

                {/* Thư ký */}
                <div>
                  <label className="block text-sm text-slate-600 mb-1">Thư ký</label>
                  <input
                    className="w-full h-10 rounded border px-3 mb-2"
                    placeholder="Tìm theo tên hoặc email…"
                    value={qSec}
                    onChange={(e) => setQSec(e.target.value)}
                  />
                  <select
                    className="w-full h-11 rounded border px-3 bg-white"
                    value={thuKyId === '' ? '' : String(thuKyId)}
                    onChange={(e) => setThuKyId(e.target.value ? Number(e.target.value) : '')}
                    disabled={loading}
                  >
                    <option value="">— Chọn —</option>
                    {gvSecOpt.map(x => (
                      <option key={`${x.id}`} value={String(x.id)}>
                        {x.hoTen}{x.email ? ` — ${x.email}` : ''}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            <div className="sticky bottom-0 bg-white border-t px-6 py-4 flex justify-end gap-3 rounded-b-2xl">
              <button className="px-4 h-10 rounded border" onClick={onClose}>Quay lại</button>
              <button
                className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
                onClick={handleSave}
                disabled={!canSave}
              >
                Lưu
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
