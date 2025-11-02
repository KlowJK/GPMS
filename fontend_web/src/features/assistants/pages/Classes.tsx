// src/features/assistants/pages/ClassesPage.tsx
import { useEffect, useMemo, useRef, useState } from 'react';
import assistantService, {
  OrgClass, PageParams, Id
} from '@features/assistants/services/assistantService';
import ClassFormModal from '@features/assistants/components/ClassFormModal';
import { Pencil, Search, Trash2, Plus } from 'lucide-react';

type MajorRow = { id: Id; tenNganh: string; khoaId: Id };
type DeptRow  = { id: Id; tenKhoa: string };

export default function ClassesPage() {
  const [items, setItems] = useState<OrgClass[]>([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // maps để join ngành → khoa
  const [majors, setMajors] = useState<Record<string, MajorRow>>({});
  const [depts,  setDepts]  = useState<Record<string, DeptRow>>({});

  // modal & ref chống race condition
  const [modal, setModal] = useState<{ open: boolean; editing?: OrgClass | null }>({ open: false });
  const editingIdRef = useRef<Id | null>(null);

  const keyword = useMemo(() => q.trim().toLowerCase(), [q]);

  async function loadClasses() {
    setLoading(true); setError(null);
    try {
      const pg = await assistantService.listOrgClassesNormalized({ page, size } as PageParams);
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]); setTotal(0);
      setError(e?.response?.data?.message || 'Không tải được danh sách lớp.');
    } finally {
      setLoading(false);
    }
  }

  // tải lớp theo trang
  useEffect(() => { loadClasses(); }, [page, size]);

  // tải ngành + khoa 1 lần
  useEffect(() => {
    (async () => {
      try {
        const [majRes, depRes] = await Promise.all([
          assistantService.listMajors({ page:0, size: 999 }),
          assistantService.listDepartments({ page:0, size: 999 }),
        ]);
        // majors
        const mraw = assistantService.unwrap<any>(majRes);
        const marr: any[] = Array.isArray(mraw?.content) ? mraw.content : (Array.isArray(mraw) ? mraw : []);
        const m: Record<string, MajorRow> = {};
        marr.forEach(x => {
          const id = String(x.id);
          m[id] = { id, tenNganh: x.tenNganh ?? x.ten ?? '', khoaId: x.khoaId ?? x.idKhoa };
        });
        setMajors(m);
        // departments
        const draw = assistantService.unwrap<any>(depRes);
        const darr: any[] = Array.isArray(draw?.content) ? draw.content : (Array.isArray(draw) ? draw : []);
        const d: Record<string, DeptRow> = {};
        darr.forEach(x => { d[String(x.id)] = { id: String(x.id), tenKhoa: x.tenKhoa ?? x.ten ?? '' };});
        setDepts(d);
      } catch {
        setMajors({}); setDepts({});
      }
    })();
  }, []);

  const view = items.filter(x =>
    !keyword ||
    x.tenLop?.toLowerCase().includes(keyword) ||
    (x.nganhTen ?? majors[String(x.nganhId)]?.tenNganh ?? '').toLowerCase().includes(keyword) ||
    (x.khoaTen ?? depts[String(majors[String(x.nganhId)]?.khoaId)]?.tenKhoa ?? '').toLowerCase().includes(keyword)
  );

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  async function handleDelete(x: OrgClass) {
    if (!confirm(`Xóa lớp "${x.tenLop}"?`)) return;
    await assistantService.deleteOrgClass(x.id);
    await loadClasses();
  }

  function openCreate() {
    editingIdRef.current = null;
    setModal({ open: true, editing: null });
  }
  function openEdit(x: OrgClass) {
    editingIdRef.current = x.id;          // ✨ giữ chắc id đang sửa
    setModal({ open: true, editing: x });
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
          <input className="h-10 w-80 rounded border pl-9 pr-3" placeholder="Tìm theo tên…"
                 value={q} onChange={e => setQ(e.target.value)} />
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
                      <button className="h-9 w-9 rounded border inline-grid place-items-center"
                              title="Sửa" onClick={() => openEdit(x)}><Pencil size={16}/></button>
                      <button className="h-9 w-9 rounded border inline-grid place-items-center"
                              title="Xóa" onClick={() => handleDelete(x)}><Trash2 size={16}/></button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        <div className="flex items-center justify-end gap-3 p-3">
          <button className="rounded border px-3 py-1 disabled:opacity-40"
                  onClick={() => setPage(p => Math.max(0, p - 1))} disabled={page === 0}>«</button>
          <span className="text-sm">{page + 1}</span>
          <button className="rounded border px-3 py-1 disabled:opacity-40"
                  onClick={() => setPage(p => (from + size <= total ? p + 1 : p))}
                  disabled={from + size > total}>»</button>
        </div>
      </div>

      {modal.open && (
        <ClassFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            const id = editingIdRef.current;        // ✨ quyết định PUT/POST bằng ref
            if (id != null) {
              await assistantService.updateOrgClass(id, payload);
            } else {
              await assistantService.createOrgClass(payload);
            }
            setModal({ open: false });
            await loadClasses();
          }}
        />
      )}
    </div>
  );
}
