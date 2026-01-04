// src/features/assistants/pages/Students.tsx
import { useEffect, useMemo, useState } from 'react';
import { Plus, Search, CheckCircle2, AlertTriangle, Pencil } from 'lucide-react';
import {
  type Student,
  type CreateStudentBody,
  type UpdateStudentBody,
  listStudentsNormalized,
  updateStudentByCode,
  createStudent,
  importStudents as importStudentsApi,
  changeStudentStatusByCode,
} from '@/features/assistants/services/user/userApi';

import { type ClassRoom, listClasses } from '@/features/assistants/services/organization/orgApi';
import { type PageParams, unwrap } from '@/features/assistants/services/base';

import StudentFormModal from '@/features/assistants/components/StudentFormModal';
import ImportStudentsModal from '@/features/assistants/components/ImportStudentsModal';
import Pagination from '@/features/assistants/components/Pagination'; // ✅ dùng chung

/* ===================== Small helpers ===================== */
const norm = (v?: string) =>
  (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');

function EligibleTag({ value, onClick }: { value?: boolean; onClick?: () => void }) {
  const base =
    'inline-flex items-center gap-1 px-2 py-0.5 rounded text-sm cursor-pointer border';
  if (value)
    return (
      <span onClick={onClick} className={`${base} bg-green-50 text-green-700 border-green-200`}>
        <CheckCircle2 size={14} /> Đủ điều kiện
      </span>
    );
  return (
    <span onClick={onClick} className={`${base} bg-orange-50 text-orange-700 border-orange-200`}>
      <AlertTriangle size={14} /> Chưa đủ điều kiện
    </span>
  );
}

/* ===================== Page ===================== */
type ModalState = { open: boolean; editing?: Student | null };
type ImportState = { open: boolean };
type StatusState = { open: boolean; student?: Student | null };

export default function StudentsPage() {
  const [items, setItems] = useState<Student[]>([]);
  const [classes, setClasses] = useState<ClassRoom[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>({ open: false });
  const [imodal, setImodal] = useState<ImportState>({ open: false });
  const [statusModal, setStatusModal] = useState<StatusState>({ open: false });

  const keyword = useMemo(() => q.trim(), [q]);

  async function loadStudents() {
    setLoading(true);
    setError(null);
    try {
      const pg = await listStudentsNormalized({ page, size, q: keyword || undefined } as PageParams);
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch {
      setItems([]);
      setTotal(0);
      setError('Không tải được danh sách sinh viên.');
    } finally {
      setLoading(false);
    }
  }

  async function loadClasses() {
    try {
      const res = await listClasses();
      const data = unwrap<any>(res);
      const list: ClassRoom[] = Array.isArray(data?.content)
        ? data.content
        : Array.isArray(data)
        ? data
        : [];
      setClasses(list);
    } catch {
      setClasses([]);
    }
  }

  useEffect(() => {
    loadClasses();
  }, []);
  useEffect(() => {
    loadStudents();
  }, [page, size, keyword]);

  // Lọc mềm phía client theo TÊN hoặc MÃ SV (đảm bảo tìm đủ)
  const view = useMemo(() => {
    const k = norm(q);
    if (!k) return items;
    return items.filter(
      (s) => norm(s.hoTen).includes(k) || (s.maSinhVien || '').toLowerCase().includes(k)
    );
  }, [items, q]);

  const totalPages = Math.max(1, Math.ceil(total / size));
  const from = total ? page * size + 1 : 0;
  const to = Math.min(total, page * size + view.length); // ✅ đếm theo view ở trang hiện tại

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách tài khoản sinh viên</h1>

      <div className="flex items-center gap-3">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="px-4 py-2 rounded-lg bg-blue-600 text-white inline-flex items-center gap-2"
        >
          <Plus size={16} /> Thêm tài khoản
        </button>
        <button
          onClick={() => setImodal({ open: true })}
          className="px-3 py-2 rounded-lg border inline-flex items-center gap-2"
          title="Import danh sách từ Excel"
        >
          Import Excel
        </button>
        <div className="relative ml-2">
          <Search
            size={16}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400"
          />
          <input
            className="h-10 w-80 rounded border pl-9 pr-3"
            placeholder="Tìm theo mã hoặc tên sinh viên…"
            value={q}
            onChange={(e) => {
              setPage(0);
              setQ(e.target.value);
            }}
          />
        </div>
        <div className="ml-auto text-sm text-slate-600">{total ? `${from}–${to}/${total}` : ''}</div>
      </div>

      <div className="rounded border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4">Email</th>
              <th className="px-4">Mã sinh viên</th>
              <th className="px-4">Họ và tên</th>
              <th className="px-4">Lớp</th>
              <th className="px-4">SĐT</th>
              <th className="px-4">Điều kiện làm đồ án</th>
              <th className="px-4 w-24">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading && <tr><td className="px-4 py-6 text-center" colSpan={7}>Đang tải…</td></tr>}
            {!loading && error && (
              <tr><td className="px-4 py-6 text-center text-red-600" colSpan={7}>{error}</td></tr>
            )}
            {!loading && !error && view.length === 0 && (
              <tr><td className="px-4 py-6 text-center" colSpan={7}>Chưa có dữ liệu.</td></tr>
            )}
            {!loading && !error && view.map((s) => (
              <tr key={`${s.id}`} className="border-t">
                <td className="px-4 py-3">{s.email}</td>
                <td className="px-4 py-3">{s.maSinhVien}</td>
                <td className="px-4 py-3">{s.hoTen}</td>
                <td className="px-4 py-3">{s.lopTen ?? '—'}</td>
                <td className="px-4 py-3">{s.soDienThoai ?? '—'}</td>
                <td className="px-4 py-3">
                  <EligibleTag
                    value={s.duDieuKien}
                    onClick={() => setStatusModal({ open: true, student: s })}
                  />
                </td>
                <td className="px-4 py-3">
                  <button
                    className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                    onClick={() => setModal({ open: true, editing: s })}
                    title="Sửa"
                  >
                    <Pencil size={16} />
                    <span className="sr-only">Sửa</span>
                  </button>
                </td>
              </tr>
            ))}
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

      {modal.open && (
        <StudentFormModal
          initial={modal.editing ?? undefined}
          classes={classes}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: CreateStudentBody | UpdateStudentBody) => {
            if (modal.editing) {
              await updateStudentByCode(modal.editing.maSinhVien, payload as UpdateStudentBody);
            } else {
              await createStudent(payload as CreateStudentBody);
            }
            setModal({ open: false });
            await loadStudents();
          }}
        />
      )}

      {imodal.open && (
        <ImportStudentsModal
          onClose={() => setImodal({ open: false })}
          onSubmit={async (file: File) => {
            const fd = new FormData();
            fd.append('file', file);
            await importStudentsApi(fd);
            setImodal({ open: false });
            await loadStudents();
          }}
        />
      )}

      {statusModal.open && statusModal.student && (
        <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
          <div className="bg-white rounded-2xl p-6 w-[520px]">
            <h3 className="text-lg font-semibold mb-3">
              Đổi trạng thái điều kiện – {statusModal.student.hoTen} ({statusModal.student.maSinhVien})
            </h3>
            <p className="text-sm text-slate-600 mb-4">
              Chọn trạng thái mới cho sinh viên này.
            </p>
            <div className="flex gap-3">
              <button
                className="px-4 h-10 rounded border inline-flex items-center gap-2"
                onClick={async () => {
                  const s = statusModal.student;
                  if (s && !s.duDieuKien) {
                    await changeStudentStatusByCode(s.maSinhVien);
                    await loadStudents();
                  }
                  setStatusModal({ open: false, student: null });
                }}
              >
                <CheckCircle2 size={16} /> Đủ điều kiện
              </button>
              <button
                className="px-4 h-10 rounded border inline-flex items-center gap-2"
                onClick={async () => {
                  const s = statusModal.student;
                  if (s && s.duDieuKien) {
                    await changeStudentStatusByCode(s.maSinhVien);
                    await loadStudents();
                  }
                  setStatusModal({ open: false, student: null });
                }}
              >
                <AlertTriangle size={16} /> Chưa đủ điều kiện
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
