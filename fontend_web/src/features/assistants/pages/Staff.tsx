// src/features/assistants/pages/Staff.tsx
import { useEffect, useMemo, useState } from 'react';
import { type Lecturer, listLecturers, createLecturer, updateLecturer } from '@/features/assistants/services/user/userApi';
import { type Subject, listSubjects } from '@/features/assistants/services/organization/orgApi';
import { toPage, unwrap } from '@/features/assistants/services/base';

import LecturerFormModal, {
  LecturerCreatePayload,
  LecturerUpdatePayload,
} from '@/features/assistants/components/LecturerFormModal';

type ModalState = { open: boolean; editing?: Lecturer | null };

export default function StaffPage() {
  const [items, setItems] = useState<Lecturer[]>([]);
  const [subjects, setSubjects] = useState<Subject[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(1000);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  const keyword = useMemo(() => q.trim(), [q]);

  async function loadLecturers() {
    setLoading(true);
    try {
      const res = await listLecturers({ page, size, q: keyword || undefined });
      const pg = toPage<Lecturer>(res, { page, size });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  async function loadSubjects() {
    const res = await listSubjects({ page: 0, size: 1000 });
    const pg = toPage<Subject>(res, { page: 0, size: 1000 });
    setSubjects(pg.content);
  }

  useEffect(() => { loadSubjects(); }, []);
  useEffect(() => { loadLecturers(); }, [page, size, keyword]);

  function openCreate() { setModal({ open: true, editing: null }); }
  function openEdit(row: Lecturer) { setModal({ open: true, editing: row }); }

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Giảng viên</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">+ Thêm giảng viên</button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo tên/email…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
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
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Đang tải…</td></tr>
            ) : items.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Không có dữ liệu.</td></tr>
            ) : items.map((row, idx) => {
              const stt = page * size + idx + 1;
              return (
                <tr key={`${row.id}`} className="border-t">
                  <td className="px-4 py-3">{stt}</td>
                  <td className="px-4 py-3">{row.hoTen}</td>
                  <td className="px-4 py-3">{row.email}</td>
                  <td className="px-4 py-3">{row.soDienThoai ?? '—'}</td>
                  <td className="px-4 py-3">{row.boMonTen ?? '—'}</td>
                  <td className="px-4 py-3">
                    <button onClick={() => openEdit(row)} className="px-3 py-1 border rounded">Sửa</button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        <div className="flex items-center justify-end gap-3 p-3">
          <button className="px-3 py-1 border rounded disabled:opacity-40"
                  onClick={() => setPage(p => Math.max(0, p - 1))}
                  disabled={page === 0}>Trước</button>
          <span className="text-sm">{page + 1}</span>
          <button className="px-3 py-1 border rounded disabled:opacity-40"
                  onClick={() => setPage(p => (from + size <= total ? p + 1 : p))}
                  disabled={from + size > total}>Sau</button>
        </div>
      </div>

      {modal.open && (
        <LecturerFormModal
          initial={modal.editing ?? undefined}
          subjects={subjects}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: LecturerCreatePayload | LecturerUpdatePayload) => {
            // Trả về lecturer đã lưu để modal gán Trưởng bộ môn
            let saved: Lecturer | undefined;

            if ((payload as any).matKhau !== undefined) {
              const res = await createLecturer(payload as LecturerCreatePayload);
              saved = unwrap<Lecturer>(res);
            } else {
              const id = modal.editing?.id as string | number;
              const res = await updateLecturer(id, payload as LecturerUpdatePayload);
              saved = unwrap<Lecturer>(res);
              if (!saved) saved = { ...(modal.editing as Lecturer), ...(payload as any) };
            }

            await loadLecturers();
            return saved;
          }}
        />
      )}
    </div>
  );
}
