// src/features/assistants/pages/ClassesPage.tsx
import { useEffect, useMemo, useRef, useState } from 'react';
import type { ReactNode } from 'react';
import { type Id, type PageParams, unwrap } from '@/features/assistants/services/base';
import {
  type OrgClass,
  listOrgClassesNormalized,
  createOrgClass,
  updateOrgClass,
  deleteOrgClass,
  listMajors,
  listDepartments,
} from '@/features/assistants/services/organization/orgApi';
import ClassFormModal from '@/features/assistants/components/ClassFormModal';
import { Pencil, Search, Trash2, Plus } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';

type MajorRow = { id: Id; tenNganh: string; khoaId: Id };
type DeptRow  = { id: Id; tenKhoa: string };
type ConfirmState = { open: boolean; row?: OrgClass | null; busy?: boolean };

/* ---------- helpers ---------- */
function norm(v?: string) {
  return (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');
}
function PageNav({
  page, totalPages, onChange,
}: { page: number; totalPages: number; onChange: (p: number) => void }) {
  const MAX_WINDOW = 5;
  const p1 = page + 1;
  const tp = Math.max(1, totalPages);

  let start = Math.max(1, p1 - Math.floor(MAX_WINDOW / 2));
  let end   = Math.min(tp, start + MAX_WINDOW - 1);
  if (end - start + 1 < MAX_WINDOW) start = Math.max(1, end - MAX_WINDOW + 1);

  const go = (p: number) => onChange(Math.min(Math.max(0, p), tp - 1));
    const btn = (label: string | number, active = false, disabled = false, to?: number): ReactNode => (
    <button
      key={`${label}-${to ?? label}`}
      className={`min-w-9 h-9 px-2 rounded border text-sm ${
        active ? 'bg-blue-600 text-white border-blue-600' : 'bg-white hover:bg-slate-50'
      } ${disabled ? 'opacity-40 cursor-not-allowed' : ''}`}
      onClick={() => (to != null && !disabled ? go(to) : undefined)}
      disabled={disabled}
    >
      {label}
    </button>
  );

    const buttons: ReactNode[] = [];
  buttons.push(btn('«', false, page === 0, 0));
  buttons.push(btn('‹', false, page === 0, page - 1));
  for (let i = start; i <= end; i++) buttons.push(btn(i, i === p1, false, i - 1));
  if (tp > end) buttons.push(<span key="ellipsis" className="px-2 select-none">…</span>);
  buttons.push(btn('›', false, page >= tp - 1, page + 1));
  buttons.push(btn('»', false, page >= tp - 1, tp - 1));

  return <div className="flex items-center gap-2">{buttons}</div>;
}
/* -------------------------------- */

export default function ClassesPage() {
  const { success, error: toastError } = useToast();

  const [items, setItems] = useState<OrgClass[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);            // 0-based
  const [size] = useState(10);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [majors, setMajors] = useState<Record<string, MajorRow>>({});
  const [depts,  setDepts]  = useState<Record<string, DeptRow>>({});

  const [modal, setModal] = useState<{ open: boolean; editing?: OrgClass | null }>({ open: false });
  const editingIdRef = useRef<Id | null>(null);

  const [confirm, setConfirm] = useState<ConfirmState>({ open: false });

  const keyword = useMemo(() => norm(q), [q]);

  async function loadClasses() {
    setLoading(true); setError(null);
    try {
      const pg = await listOrgClassesNormalized({ page, size } as PageParams);
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]); setTotal(0);
      setError(e?.response?.data?.message || 'Không tải được danh sách lớp.');
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { loadClasses(); }, [page, size]);

  // load ngành + khoa 1 lần
  useEffect(() => {
    (async () => {
      try {
        const [majRes, depRes] = await Promise.all([
          listMajors({ page:0, size: 999 }),
          listDepartments({ page:0, size: 999 }),
        ]);
        const mraw = unwrap<any>(majRes);
        const marr: any[] = Array.isArray(mraw?.content) ? mraw.content : (Array.isArray(mraw) ? mraw : []);
        const m: Record<string, MajorRow> = {};
        marr.forEach(x => {
          const id = String(x.id);
          m[id] = { id, tenNganh: x.tenNganh ?? x.ten ?? '', khoaId: x.khoaId ?? x.idKhoa };
        });
        setMajors(m);

        const draw = unwrap<any>(depRes);
        const darr: any[] = Array.isArray(draw?.content) ? draw.content : (Array.isArray(draw) ? draw : []);
        const d: Record<string, DeptRow> = {};
        darr.forEach(x => { d[String(x.id)] = { id: String(x.id), tenKhoa: x.tenKhoa ?? x.ten ?? '' };});
        setDepts(d);
      } catch {
        setMajors({}); setDepts({});
      }
    })();
  }, []);

  // 🔎 chỉ tìm theo TÊN LỚP (client-side trong trang hiện tại)
  const view = items.filter(x => !keyword || norm(x.tenLop).includes(keyword));

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);
  const totalPages = Math.max(1, Math.ceil(total / size));

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(x: OrgClass) { setModal({ open: true, editing: x }); }

  function askDelete(row: OrgClass) { setConfirm({ open: true, row, busy: false }); }
  async function doDelete() {
    if (!confirm.row) return;
    try {
      setConfirm(c => ({ ...c, busy: true }));
      await deleteOrgClass(confirm.row.id);
      success('Xóa lớp thành công.');
      setConfirm({ open: false, row: null, busy: false });
      await loadClasses();
    } catch (e: any) {
      setConfirm(c => ({ ...c, busy: false }));
      toastError(e?.response?.data?.message || 'Không thể xóa lớp.');
    }
  }

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách lớp</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 rounded-lg bg-blue-600 text-white inline-flex items-center gap-2">
          <Plus size={16}/> Thêm lớp
        </button>
        <div className="relative ml-2">
          <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"/>
          <input
            className="h-10 w-80 rounded border pl-9 pr-3"
            placeholder="Tìm theo tên lớp…"
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
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Tên lớp</th>
              <th className="px-4">Ngành</th>
              <th className="px-4">Tên khoa</th>
              <th className="px-4 w-32">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td colSpan={5} className="px-4 py-6 text-center">Đang tải…</td></tr>}
            {!loading && error && <tr><td colSpan={5} className="px-4 py-6 text-center text-red-600">{error}</td></tr>}
            {!loading && !error && view.length === 0 && <tr><td colSpan={5} className="px-4 py-6 text-center">Chưa có dữ liệu.</td></tr>}
            {!loading && !error && view.map((x, idx) => {
              const major = majors[String(x.nganhId)];
              const nganhTen = x.nganhTen ?? major?.tenNganh ?? '—';
              const khoaTen  = x.khoaTen  ?? (major?.khoaId != null ? depts[String(major.khoaId)]?.tenKhoa : undefined) ?? '—';
              return (
                <tr key={String(x.id)} className="border-t">
                  <td className="px-4 py-3">{page*size + idx + 1}</td>
                  <td className="px-4 py-3">{x.tenLop}</td>
                  <td className="px-4 py-3">{nganhTen}</td>
                  <td className="px-4 py-3">{khoaTen}</td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      <button className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                              title="Sửa" onClick={() => openEdit(x)}><Pencil size={16}/></button>
                      <button className="ml-1 inline-flex items-center justify-center h-9 w-9 rounded-md text-red-600 hover:bg-red-50"
                              title="Xóa" onClick={() => askDelete(x)}><Trash2 size={16}/></button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {/* Phân trang: căn giữa + có đầu/cuối */}
        <div className="p-3 flex justify-center">
          <PageNav
            page={page}
            totalPages={totalPages}
            onChange={(p) => { if (p !== page) setPage(p); }}
          />
        </div>
      </div>

      {/* Modal xác nhận xoá */}
      {confirm.open && confirm.row && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
          <div className="w-[460px] rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold mb-2">Xác nhận xóa</h3>
            <p className="text-sm text-slate-600">
              Bạn có chắc muốn xóa lớp <span className="font-medium">{confirm.row.tenLop}</span>?
            </p>
            <div className="mt-5 flex justify-end gap-3">
              <button
                className="h-10 rounded bg-slate-200 px-4"
                onClick={() => setConfirm({ open: false, row: null, busy: false })}
                disabled={confirm.busy}
              >
                Hủy
              </button>
              <button
                className="inline-flex items-center gap-2 h-10 rounded bg-red-600 px-4 text-white disabled:opacity-50"
                onClick={doDelete}
                disabled={confirm.busy}
                title="Xóa lớp"
              >
                <Trash2 size={16} />
                {confirm.busy ? 'Đang xóa…' : 'Xóa'}
              </button>
            </div>
          </div>
        </div>
      )}

      {modal.open && (
        <ClassFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            const editId = modal.editing?.id ?? null;
            try {
              if (editId != null) {
                await updateOrgClass(editId, payload);
                success('Cập nhật lớp thành công.');
              } else {
                await createOrgClass(payload);
                success('Thêm lớp thành công.');
              }
              setModal({ open: false });
              await loadClasses();
            } catch (e: any) {
              toastError(e?.response?.data?.message || 'Không thể lưu lớp.');
            }
          }}
        />
      )}
    </div>
  );
}
