import { useEffect, useMemo, useState } from 'react';
import { Search, Plus, Paperclip } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';
import {
  listNotificationsNormalized,
  createNotification,
  type NotificationRow,
} from '@/features/assistants/services/notification/notificationApi';
import NotificationFormModal from '@/features/assistants/components/NotificationFormModal';

function useDebounce<T>(v: T, ms = 300) {
  const [val, setVal] = useState(v);
  useEffect(() => { const t = setTimeout(() => setVal(v), ms); return () => clearTimeout(t); }, [v, ms]);
  return val;
}

export default function NotificationsPage() {
  const { error } = useToast();
  const [items, setItems] = useState<NotificationRow[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const qx = useDebounce(q, 250);
  const [loading, setLoading] = useState(false);
  const [open, setOpen] = useState(false);

  async function load() {
    setLoading(true);
    try {
      const pg = await listNotificationsNormalized({ page, size, sort: ['updatedAt,DESC'] });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]); setTotal(0);
      error(e?.response?.data?.message || 'Không tải được danh sách thông báo.');
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); /* eslint-disable-next-line */ }, [page, size]);

  const filtered = useMemo(() => {
    const k = qx.trim().toLowerCase();
    if (!k) return items;
    return items.filter(x => (x.tieuDe || '').toLowerCase().includes(k));
  }, [items, qx]);

  const from = page * size + 1;
  const to   = Math.min(total, page * size + items.length);

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-3xl font-semibold text-center">Quản lý thông báo</h1>

      <div className="flex items-center gap-3">
        <button onClick={() => setOpen(true)} className="px-4 py-2 rounded-lg bg-blue-600 text-white inline-flex items-center gap-2">
          <Plus size={16}/> Thêm thông báo
        </button>

        <div className="relative ml-2">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"/>
          <input
            className="h-10 w-80 rounded border pl-9 pr-3"
            placeholder="Tìm theo tiêu đề…"
            value={q}
            onChange={e => setQ(e.target.value)}
          />
        </div>

        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">#</th>
              <th className="px-4">Tiêu đề</th>
              <th className="px-4">Nội dung</th>
              <th className="px-4">Tệp</th>
              <th className="px-4">Ngày tạo</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Không có dữ liệu.</td></tr>
            ) : filtered.map((r, idx) => (
              <tr key={`${r.id ?? r.createdAt ?? idx}`} className="border-t">
                <td className="px-4 py-3">{page*size + idx + 1}</td>
                <td className="px-4 py-3">{r.tieuDe}</td>
                <td className="px-4 py-3 max-w-[520px]"><div className="line-clamp-2">{r.noiDung}</div></td>
                <td className="px-4 py-3">
                  {r.fileUrl ? (
                    <a href={r.fileUrl} target="_blank" rel="noreferrer" className="inline-flex items-center gap-1 text-blue-600 hover:underline">
                      <Paperclip size={14}/> Tệp
                    </a>
                  ) : '—'}
                </td>
                <td className="px-4 py-3">{r.createdAt ? new Date(r.createdAt).toLocaleString() : '—'}</td>
              </tr>
            ))}
          </tbody>
        </table>

        <div className="flex items-center justify-center gap-3 p-3">
          <button className="rounded border px-3 py-1 disabled:opacity-40" onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}>
            « Trước
          </button>
          <span className="text-sm">Trang {page + 1}</span>
          <button className="rounded border px-3 py-1 disabled:opacity-40"
                  onClick={() => setPage(p => (page * size + size < total ? p + 1 : p))}
                  disabled={page * size + size >= total}>
            Sau »
          </button>
        </div>
      </div>

      {open && (
        <NotificationFormModal
          onClose={() => setOpen(false)}
          onSubmit={async ({ tieuDe, noiDung, khoaId, file }) => {
            await createNotification({ tieuDe, noiDung, khoaId: (khoaId ?? null), file });
            await load();
          }}
        />
      )}
    </div>
  );
}
