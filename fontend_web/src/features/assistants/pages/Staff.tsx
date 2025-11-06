// src/features/assistants/pages/Staff.tsx
import { useEffect, useMemo, useRef, useState, type ReactNode } from 'react';
import { Pencil } from 'lucide-react';
import {
  type Lecturer,
  listLecturersNormalized,
  createLecturer,
  updateLecturer,
  importLecturers,
} from '@/features/assistants/services/user/userApi';
import { type Subject, listSubjects } from '@/features/assistants/services/organization/orgApi';
import { toPage, unwrap } from '@/features/assistants/services/base';
import LecturerFormModal, {
  LecturerCreatePayload,
  LecturerUpdatePayload,
} from '@/features/assistants/components/LecturerFormModal';

type ModalState = { open: boolean; editing?: Lecturer | null };

// helper bỏ dấu để tìm kiếm VN
const norm = (v?: string) =>
  (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');

// Pagination (centered) giống các trang khác
function PageNav({
  page,
  total,
  size,
  onChange,
}: {
  page: number;
  total: number;
  size: number;
  onChange: (p: number) => void;
}) {
  const totalPages = Math.max(1, Math.ceil(total / size));
  const p1 = page + 1;
  const MAX_WINDOW = 5;

  let start = Math.max(1, p1 - Math.floor(MAX_WINDOW / 2));
  let end = Math.min(totalPages, start + MAX_WINDOW - 1);
  if (end - start + 1 < MAX_WINDOW) start = Math.max(1, end - MAX_WINDOW + 1);

  const go = (p: number) => onChange(Math.min(Math.max(0, p), totalPages - 1));
  const btn = (label: string | number, active = false, disabled = false, to?: number): ReactNode => (
    <button
      key={`p-${label}`}
      className={
        'min-w-8 h-9 px-3 rounded border text-sm ' +
        (active ? 'bg-blue-600 text-white border-blue-600' : 'bg-white hover:bg-slate-50') +
        (disabled ? ' opacity-40 cursor-not-allowed' : '')
      }
      onClick={() => (to != null ? go(to) : undefined)}
      disabled={disabled}
      aria-current={active ? 'page' : undefined}
    >
      {label}
    </button>
  );

  const nodes: ReactNode[] = [];
  nodes.push(btn('«', false, page === 0, 0));
  nodes.push(btn('‹', false, page === 0, page - 1));
  for (let i = start; i <= end; i++) nodes.push(btn(i, i === p1, false, i - 1));
  if (totalPages > end) nodes.push(<span key="ellipsis" className="px-1 select-none">…</span>);
  nodes.push(btn('›', false, page >= totalPages - 1, page + 1));
  nodes.push(btn('»', false, page >= totalPages - 1, totalPages - 1));

  return <div className="flex items-center justify-center gap-2">{nodes}</div>;
}

export default function StaffPage() {
  const [items, setItems] = useState<Lecturer[]>([]);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [subjectsMap, setSubjectsMap] = useState<Record<string, Subject>>({});
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // import
  const fileRef = useRef<HTMLInputElement | null>(null);
  const [importBusy, setImportBusy] = useState(false);

  const keyword = useMemo(() => q.trim(), [q]);

  async function loadLecturers() {
    setLoading(true);
    setError(null);
    try {
      const pg = await listLecturersNormalized({ page, size, q: keyword || undefined });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]);
      setTotal(0);
      setError(e?.response?.data?.message || 'Không tải được danh sách giảng viên.');
    } finally {
      setLoading(false);
    }
  }

  async function loadSubjects() {
    try {
      const res = await listSubjects({ page: 0, size: 1000 });
      const pg = toPage<Subject>(res, { page: 0, size: 1000 });
      setSubjects(pg.content);
      const map: Record<string, Subject> = {};
      pg.content.forEach((s) => {
        map[String(s.id)] = s;
      });
      setSubjectsMap(map);
    } catch {
      setSubjects([]);
      setSubjectsMap({});
    }
  }

  useEffect(() => {
    loadSubjects();
  }, []);
  useEffect(() => {
    loadLecturers();
  }, [page, size, keyword]);

  function openCreate() {
    setModal({ open: true, editing: null });
  }
  function openEdit(row: Lecturer) {
    setModal({ open: true, editing: row });
  }

  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file) return;
    try {
      setImportBusy(true);
      await importLecturers(file);
      alert('Import giảng viên thành công.');
      await loadLecturers();
    } catch (err: any) {
      alert(err?.response?.data?.message || 'Import thất bại.');
    } finally {
      setImportBusy(false);
    }
  }

  // lọc mềm theo tên hoặc email (đảm bảo tìm đúng kể cả khi BE chỉ lọc 1 trường)
  const view = useMemo(() => {
    const k = norm(q);
    if (!k) return items;
    return items.filter((r) => norm(r.hoTen).includes(k) || (r.email || '').toLowerCase().includes(k));
  }, [items, q]);

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Giảng viên</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          + Thêm giảng viên
        </button>

        <button
          onClick={() => fileRef.current?.click()}
          className="px-4 py-2 border rounded-lg"
          disabled={importBusy}
          title="Import giảng viên từ Excel"
        >
          {importBusy ? 'Đang import…' : 'Import Excel'}
        </button>
        <input ref={fileRef} type="file" accept=".xlsx,.xls,.csv" style={{ display: 'none' }} onChange={onPickFile} />

        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo tên hoặc email…"
          value={q}
          onChange={(e) => {
            setPage(0);
            setQ(e.target.value);
          }}
        />
        <div className="ml-auto text-sm text-slate-600">
          {error ? <span className="text-red-600">{error}</span> : total ? `${from}–${to}/${total}` : ''}
        </div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-20">STT</th>
              <th className="px-4">Họ tên</th>
              <th className="px-4">Email</th>
              <th className="px-4">SĐT</th>
              <th className="px-4">Bộ môn</th>
              <th className="px-4 w-36">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td className="px-4 py-6 text-center" colSpan={6}>
                  Đang tải…
                </td>
              </tr>
            ) : error ? (
              <tr>
                <td className="px-4 py-6 text-center text-red-600" colSpan={6}>
                  {error}
                </td>
              </tr>
            ) : view.length === 0 ? (
              <tr>
                <td className="px-4 py-6 text-center" colSpan={6}>
                  Không có dữ liệu.
                </td>
              </tr>
            ) : (
              view.map((row, idx) => {
                const stt = page * size + idx + 1;
                const bmTen =
                  row.boMonTen || (row.idBoMon != null ? subjectsMap[String(row.idBoMon)]?.tenBoMon : '') || '—';
                return (
                  <tr key={`${row.id}`} className="border-t">
                    <td className="px-4 py-3">{stt}</td>
                    <td className="px-4 py-3">{row.hoTen}</td>
                    <td className="px-4 py-3">{row.email}</td>
                    <td className="px-4 py-3">{row.soDienThoai ?? '—'}</td>
                    <td className="px-4 py-3">{bmTen}</td>
                    <td className="px-4 py-3">
                      <button
                        onClick={() => openEdit(row)}
                        className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                        title="Sửa"
                      >
                        <Pencil size={16} />
                        <span className="sr-only">Sửa</span>
                      </button>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>

        {/* Pagination centered */}
        <div className="p-3 flex justify-center">
          <PageNav page={page} total={total} size={size} onChange={(p) => setPage(p)} />
        </div>
      </div>

      {modal.open && (
        <LecturerFormModal
          initial={modal.editing ?? undefined}
          subjects={subjects}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: LecturerCreatePayload | LecturerUpdatePayload) => {
            let saved: Lecturer | undefined;
            if ((payload as any).matKhau !== undefined) {
              const res = await createLecturer(payload as LecturerCreatePayload);
              saved = unwrap<Lecturer>(res);
            } else {
              const id = modal.editing!.id as string | number;
              const res = await updateLecturer(id, payload as LecturerUpdatePayload);
              saved = unwrap<Lecturer>(res) || { ...(modal.editing as Lecturer), ...(payload as any) };
            }
            await loadLecturers();
            return saved;
          }}
        />
      )}
    </div>
  );
}
