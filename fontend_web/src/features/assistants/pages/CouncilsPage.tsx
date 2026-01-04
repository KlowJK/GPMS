import { useEffect, useMemo, useRef, useState } from 'react';
import { Eye, Plus, FileUp } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';
import { useNavigate } from 'react-router-dom';
import {
  type Council,
  type CreateCouncilPayload,
  listCouncilsNormalized,
  createCouncil,
  importCouncilStudents,
} from '@/features/assistants/services/council/councilApi';
import CouncilFormModal from '@/features/assistants/components/CouncilFormModal';
// ✅ Pagination dùng chung
import Pagination from '@/features/assistants/components/Pagination';

function fmt(d?: string) {
  if (!d) return '—';
  const [y, m, dd] = d.split('-');
  return `${dd}/${m}/${y}`;
}

export default function CouncilsPage() {
  const { success, error } = useToast();
  const navigate = useNavigate();

  const [rows, setRows] = useState<Council[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);

  const fileRef = useRef<HTMLInputElement | null>(null);
  const [importTargetId, setImportTargetId] = useState<number | string | null>(null);
  const [uploading, setUploading] = useState<Record<string, boolean>>({});
  const [modalOpen, setModalOpen] = useState(false);

  async function load() {
    setLoading(true);
    try {
      const pg = await listCouncilsNormalized({ page, size, q: q.trim() || undefined });
      setRows(pg.content);
      setTotal(pg.totalElements ?? pg.content.length ?? 0);
    } catch (e: any) {
      error(e?.response?.data?.message || 'Không tải được danh sách hội đồng.');
      setRows([]); setTotal(0);
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [page, size, q]);

  const filtered = useMemo(() => {
    const k = q.trim().toLowerCase();
    if (!k) return rows;
    return rows.filter(r => r.tenHoiDong?.toLowerCase().includes(k) || String(r.id).includes(k));
  }, [rows, q]);

  const from = page * size + 1;
  const to = Math.min(total, page * size + filtered.length);
  const totalPages = Math.max(1, Math.ceil(total / size));

  async function handleImportFileChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file || !importTargetId) return;

    const key = String(importTargetId);
    try {
      setUploading(prev => ({ ...prev, [key]: true }));
      await importCouncilStudents(importTargetId, file);
      success('Import danh sách sinh viên thành công.');
      navigate(`/assistant/councils/${importTargetId}`);
    } catch (err: any) {
      const msg = err?.response?.data?.message ?? err?.message ?? 'Import thất bại';
      error(String(msg));
    } finally {
      setUploading(prev => ({ ...prev, [key]: false }));
      setImportTargetId(null);
    }
  }

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách hội đồng</h1>

      <div className="flex items-center gap-3">
        <button
          onClick={() => setModalOpen(true)}
          className="px-4 py-2 bg-blue-600 text-white rounded-lg inline-flex items-center gap-2"
        >
          <Plus size={16}/> Thêm hội đồng
        </button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo mã/tên…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">
          {total ? `${from}–${to}/${total}` : ''}
        </div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Tên hội đồng</th>
              <th className="px-4">Bắt đầu</th>
              <th className="px-4">Kết thúc</th>
              <th className="px-4">Địa điểm</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Không có dữ liệu.</td></tr>
            ) : filtered.map((r, idx) => {
              const key = String(r.id);
              const busy = !!uploading[key];
              return (
                <tr key={`${r.id}`} className="border-t">
                  <td className="px-4 py-3">{page * size + idx + 1}</td>
                  <td className="px-4 py-3">{r.tenHoiDong}</td>
                  <td className="px-4 py-3">{fmt(r.thoiGianBatDau)}</td>
                  <td className="px-4 py-3">{fmt(r.thoiGianKetThuc)}</td>
                  <td className="px-4 py-3">{r.diaDiem || '—'}</td>
                  <td className="px-4 py-3">
                    <button
                      className="inline-flex items-center justify-center h-9 w-9 rounded-md hover:bg-slate-100 mr-1"
                      title="Xem chi tiết hội đồng"
                      aria-label="Xem chi tiết hội đồng"
                      onClick={() => navigate(`/assistant/councils/${r.id}`)}
                    >
                      <Eye size={16}/>
                    </button>
                    <button
                      className="inline-flex items-center justify-center h-9 px-2 rounded-md hover:bg-slate-100 disabled:opacity-50"
                      title="Import sinh viên từ Excel"
                      aria-label="Import sinh viên từ Excel"
                      disabled={busy}
                      onClick={() => {
                        setImportTargetId(r.id);
                        fileRef.current?.click();
                      }}
                    >
                      <FileUp size={16}/>
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {/* ✅ Pagination dùng chung */}
        <Pagination
          page={page}
          totalPages={totalPages}
          onChange={setPage}
          disabled={loading}
        />
      </div>

      {/* input file ẩn dùng chung */}
      <input
        type="file"
        ref={fileRef}
        className="hidden"
        accept=".xlsx,.xls"
        onChange={handleImportFileChange}
      />

      {modalOpen && (
        <CouncilFormModal
          onClose={() => setModalOpen(false)}
          onSubmit={async (payload) => {
            await createCouncil(payload as CreateCouncilPayload);
            success('Tạo hội đồng thành công.');
            setModalOpen(false);
            await load();
          }}
        />
      )}
    </div>
  );
}
