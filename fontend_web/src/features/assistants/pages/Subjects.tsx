// src/features/assistants/pages/Subjects.tsx
import { useEffect, useState } from 'react';
import {
  type Subject,
  type Department,
  type CreateSubjectPayload,
  type UpdateSubjectPayload,
  listSubjects,
  createSubject,
  updateSubject,
  deleteSubject,
  listDepartments,
} from '@/features/assistants/services/organization/orgApi';

import { toPage } from '@/features/assistants/services/base';
import SubjectFormModal from '@/features/assistants/components/SubjectFormModal';
import { useToast } from '@/features/admin/components/ToastProvider';

type ModalState = { open: boolean; editing?: Subject | null };

export default function SubjectsPage() {
  const { success, error } = useToast();

  const [rows, setRows] = useState<Subject[]>([]);
  const [deps, setDeps] = useState<Department[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(1000);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [modal, setModal] = useState<ModalState>({ open: false });

  async function loadOptions() {
    const res = await listDepartments({ page: 0, size: 999 });
    const pg = toPage<Department>(res, { page: 0, size: 999 });
    setDeps(pg.content);
  }

  async function load() {
    setLoading(true);
    try {
      const res = await listSubjects({ page, size, q: q.trim() || undefined });
      const pg = toPage<Subject>(res, { page, size });
      setRows(pg.content);
      setTotal(pg.totalElements);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadOptions(); }, []);
  useEffect(() => { load(); }, [page, size, q]);

  const openCreate = () => setModal({ open: true, editing: null });
  const openEdit = (row: Subject) => setModal({ open: true, editing: row });

  async function onDelete(row: Subject) {
    if (!confirm(`Xóa bộ môn "${row.tenBoMon}"?`)) return;
    try {
      await deleteSubject(row.id);
      success('Xóa bộ môn thành công.');
      await load();
    } catch {
      error('Không thể xóa bộ môn.');
    }
  }

  const from = page * size + 1;
  const to = Math.min(total, page * size + rows.length);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách bộ môn</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">+ Thêm bộ môn</button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo tên…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Tên bộ môn</th>
              <th className="px-4">Khoa</th>
              <th className="px-4 w-40">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Đang tải…</td></tr>
            ) : rows.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={4}>Không có dữ liệu.</td></tr>
            ) : rows.map((r, idx) => (
              <tr key={`${r.id}`} className="border-t">
                <td className="px-4 py-3">{page * size + idx + 1}</td>
                <td className="px-4 py-3">{r.tenBoMon}</td>
                <td className="px-4 py-3">
                  {r.khoaTen ?? deps.find(d => `${d.id}` === `${r.khoaId}`)?.tenKhoa ?? '—'}
                </td>
                <td className="px-4 py-3">
                  <button className="text-blue-600 mr-4" onClick={() => openEdit(r)}>Sửa</button>
                  <button className="text-red-600" onClick={() => onDelete(r)}>Xóa</button>
                </td>
              </tr>
            ))}
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
        <SubjectFormModal
          initial={modal.editing ?? undefined}
          departments={deps}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload) => {
            try {
              if (modal.editing) {
                await updateSubject(modal.editing.id, payload as UpdateSubjectPayload);
                success('Cập nhật bộ môn thành công.');
              } else {
                await createSubject(payload as CreateSubjectPayload);
                success('Thêm bộ môn thành công.');
              }
              setModal({ open: false });
              await load();
            } catch {
              error('Lưu bộ môn thất bại.');
            }
          }}
        />
      )}
    </div>
  );
}
