// src/features/assistants/pages/RoundTimesPage.tsx
import { useEffect, useMemo, useState } from 'react';
import { Pencil, Plus } from 'lucide-react';

import RoundTimeFormModal from '@/features/assistants/components/RoundTimeFormModal';
import { type Id, unwrap } from '@/features/assistants/services/base';
import {
  listDefenseRounds,
  listRoundTimes,
  createRoundTime,
  updateRoundTime,
  normalizeRoundTime,
  type DefenseRound,
  type RoundTimeUI,
  type CreateRoundTime,
  type UpdateRoundTime,
} from '@/features/assistants/services/topic/topicApi';
import { useToast } from '@/features/admin/components/ToastProvider';

const CV_LABELS: Record<string, string> = {
  DANG_KY_DE_TAI: 'Đăng ký đề tài',
  NOP_DE_CUONG: 'Nộp đề cương',
  NOP_BAO_CAO: 'Nộp báo cáo',
  NULL: '—',
};
const cvText = (code?: string) => (code ? (CV_LABELS[code] ?? code) : '—');
const fmt = (d?: string) => (!d ? '—' : d.split('-').reverse().join('/'));

export default function RoundTimesPage() {
  const { success, error } = useToast();

  const [rounds, setRounds] = useState<DefenseRound[]>([]);
  const [times, setTimes] = useState<RoundTimeUI[]>([]);
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [modal, setModal] = useState<{ open: boolean; editing?: RoundTimeUI | null }>({ open: false });

  const roundNameById = useMemo(() => {
    const m = new Map<string, string>();
    rounds.forEach((r) => m.set(String(r.id), r.tenDotBaoVe));
    return (id?: Id) => (id != null ? m.get(String(id)) ?? '—' : '—');
  }, [rounds]);

  useEffect(() => {
    (async () => {
      try {
        const resR = await listDefenseRounds({ page: 0, size: 999 });
        const rawR = unwrap<any>(resR);
        const listR: DefenseRound[] = Array.isArray(rawR?.content)
          ? rawR.content
          : Array.isArray(rawR)
          ? rawR
          : [];
        setRounds(listR);
      } catch {
        setRounds([]);
      }
      await loadAllTimes();
    })();
  }, []); // eslint-disable-line

  async function loadAllTimes() {
    setLoading(true);
    setErr(null);
    try {
      const res = await listRoundTimes();
      const raw = unwrap<any>(res);
      const arr: any[] = Array.isArray(raw?.content) ? raw.content : (Array.isArray(raw) ? raw : []);
      const mapped: RoundTimeUI[] = arr
        .map((x) => normalizeRoundTime(x))
        .map((rt) => ({ ...rt, tenDotBaoVe: rt.tenDotBaoVe ?? roundNameById(rt.dotBaoVeId) }));
      setTimes(mapped);
    } catch (e: any) {
      setTimes([]);
      setErr(e?.response?.data?.message || 'Không tải được dữ liệu.');
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <div className="flex items-center">
        <h1 className="text-3xl font-semibold mx-auto">Thời gian thực hiện</h1>
      </div>

      {/* ✅ Nút nằm bên phải nhờ ml-auto */}
      <div className="flex items-center">
        <button
          className=" px-4 h-10 rounded bg-blue-600 text-white inline-flex items-center gap-2"
          onClick={() => setModal({ open: true, editing: null })}
        >
          <Plus size={16} /> Thêm thời gian
        </button>
      </div>

      <div className="rounded border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Đợt bảo vệ</th>
              <th className="px-4">Công việc</th>
              <th className="px-4">Thời gian bắt đầu</th>
              <th className="px-4">Thời gian kết thúc</th>
              <th className="px-4 w-24">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading && (
              <tr>
                <td colSpan={6} className="px-4 py-6 text-center">Đang tải…</td>
              </tr>
            )}
            {!loading && err && (
              <tr>
                <td colSpan={6} className="px-4 py-6 text-center text-red-600">{err}</td>
              </tr>
            )}
            {!loading && !err && times.length === 0 && (
              <tr>
                <td colSpan={6} className="px-4 py-6 text-center">Chưa có mốc thời gian.</td>
              </tr>
            )}
            {!loading && !err && times.map((t, idx) => (
              <tr key={String(t.id)} className="border-t">
                <td className="px-4 py-3">{idx + 1}</td>
                <td className="px-4 py-3">{t.tenDotBaoVe ?? roundNameById(t.dotBaoVeId)}</td>
                <td className="px-4 py-3">{cvText(t.congViec)}</td>
                <td className="px-4 py-3">{fmt(t.thoiGianBatDau)}</td>
                <td className="px-4 py-3">{fmt(t.thoiGianKetThuc)}</td>
                <td className="px-4 py-3">
                  <button
                    className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                    title="Sửa"
                    onClick={() => setModal({ open: true, editing: t })}
                  >
                    <Pencil size={16} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {modal.open && (
        <RoundTimeFormModal
          rounds={rounds}
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (p) => {
            try {
              if (modal.editing) {
                const body: UpdateRoundTime = {
                  congViec: p.congViec,
                  thoiGianBatDau: p.thoiGianBatDau,
                  thoiGianKetThuc: p.thoiGianKetThuc,
                  dotBaoVeId: p.dotBaoVeId,
                };
                await updateRoundTime(modal.editing.id, body);
                success('Cập nhật mốc thời gian thành công.');
              } else {
                const body: CreateRoundTime = {
                  congViec: p.congViec,
                  thoiGianBatDau: p.thoiGianBatDau,
                  thoiGianKetThuc: p.thoiGianKetThuc,
                  dotBaoVeId: p.dotBaoVeId,
                };
                await createRoundTime(body);
                success('Thêm mốc thời gian thành công.');
              }
              await loadAllTimes();
              setModal({ open: false });
            } catch (e: any) {
              error(e?.response?.data?.message || 'Lưu mốc thời gian thất bại.');
            }
          }}
        />
      )}
    </div>
  );
}
