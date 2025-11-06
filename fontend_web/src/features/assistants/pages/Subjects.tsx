// src/features/assistants/pages/Subjects.tsx
import { useEffect, useMemo, useState } from 'react';
import { Pencil, Trash2, IdCardLanyard } from 'lucide-react';
import {
  type Subject,
  type Department,
  type CreateSubjectPayload,
  type UpdateSubjectPayload,
  listDepartments,
  createSubject,
  updateSubject,
  deleteSubject,
  // Nếu bạn chưa có hàm này trong orgApi,
  // hãy đổi sang listSubjectsWithHeadNormalized hoặc thêm theo hướng dẫn trước đó.
  listSubjectsAnyNormalized,
} from '@/features/assistants/services/organization/orgApi';

import { toPage } from '@/features/assistants/services/base';
import SubjectFormModal from '@/features/assistants/components/SubjectFormModal';
import AssignSubjectHeadModal from '@/features/assistants/components/AssignSubjectHeadModal';
import { useToast } from '@/features/admin/components/ToastProvider';

/* ---------------- helpers ---------------- */
function useDebounce<T>(value: T, delay = 300) {
  const [v, setV] = useState(value);
  useEffect(() => {
    const t = setTimeout(() => setV(value), delay);
    return () => clearTimeout(t);
  }, [value, delay]);
  return v;
}
function norm(v?: string) {
  return (v || '').toLowerCase().normalize('NFD').replace(/\p{Diacritic}/gu, '');
}

/** Thanh phân trang giống mẫu (có đầu/cuối) */
function PageNav({
  page,
  totalPages,
  onChange,
}: {
  page: number;            // 0-based
  totalPages: number;      // >= 1
  onChange: (p: number) => void;
}) {
  const MAX_WINDOW = 5; // hiển thị tối đa 5 trang liên tiếp
  const p1 = page + 1;   // 1-based
  const tp = totalPages;

  // Tính dải trang hiển thị
  let start = Math.max(1, p1 - Math.floor(MAX_WINDOW / 2));
  let end   = Math.min(tp, start + MAX_WINDOW - 1);
  if (end - start + 1 < MAX_WINDOW) {
    start = Math.max(1, end - MAX_WINDOW + 1);
  }
  const pages: number[] = [];
  for (let i = start; i <= end; i++) pages.push(i);

  const go = (p: number) => {
    const clamped = Math.min(Math.max(0, p), tp - 1);
    onChange(clamped);
  };

  const btn = (label: string | number, active = false, disabled = false, to?: number) => (
    <button
      key={`${label}-${to ?? label}`}
      className={`min-w-9 h-9 px-2 rounded border text-sm ${
        active
          ? 'bg-blue-600 text-white border-blue-600'
          : 'bg-white hover:bg-slate-50'
      } ${disabled ? 'opacity-40 cursor-not-allowed' : ''}`}
      onClick={() => (to != null && !disabled ? go(to) : undefined)}
      disabled={disabled}
    >
      {label}
    </button>
  );

  return (
    <div className="flex items-center gap-2">
      {btn('«', false, page === 0, 0)}
      {btn('‹', false, page === 0, page - 1)}

      {pages.map((n) => btn(n, n === p1, false, n - 1))}
      {tp > end && <span className="px-2 select-none">…</span>}

      {btn('›', false, page >= tp - 1, page + 1)}
      {btn('»', false, page >= tp - 1, tp - 1)}
    </div>
  );
}

/* ---------------- page ---------------- */
const PAGE_SIZE = 12;

type ModalState   = { open: boolean; editing?: Subject | null };
type ConfirmState = { open: boolean; row?: Subject | null; busy?: boolean };

export default function SubjectsPage() {
  const { success, error: toastError } = useToast();

  const [rows, setRows]   = useState<Subject[]>([]);
  const [deps, setDeps]   = useState<Department[]>([]);
  const [page, setPage]   = useState(0);                 // 0-based
  const [size, setSize]   = useState<number>(PAGE_SIZE); // dòng/trang
  const [total, setTotal] = useState(0);
  const [q, setQ]         = useState('');
  const qDebounced        = useDebounce(q, 300);
  const [loading, setLoading] = useState(false);
  const [modal, setModal]     = useState<ModalState>({ open: false });
  const [confirm, setConfirm] = useState<ConfirmState>({ open: false });
  const [headSubject, setHeadSubject] = useState<Subject | null>(null);

  const totalPages = Math.max(1, Math.ceil(total / size));

  async function loadOptions() {
    try {
      const res = await listDepartments({ page: 0, size: 999 });
      const pg = toPage<Department>(res, { page: 0, size: 999 });
      setDeps(pg.content);
    } catch (e: any) {
      setDeps([]);
      toastError(e?.response?.data?.message || 'Không tải được danh sách khoa.');
    }
  }

  async function load() {
    setLoading(true);
    try {
      // lấy dữ liệu theo trang từ BE (đã chuẩn hoá để có tên Trưởng BM nếu BE trả)
      const pg = await listSubjectsAnyNormalized({ page, size });
      setRows(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setRows([]); setTotal(0);
      toastError(e?.response?.data?.message || 'Không tải được danh sách bộ môn.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { loadOptions(); }, []);
  useEffect(() => { load(); }, [page, size]);

  // Tìm kiếm client-side trên page hiện tại (theo tên BM hoặc tên Khoa)
  const filtered = useMemo(() => {
    const k = norm(qDebounced.trim());
    if (!k) return rows;
    return rows.filter(r => {
      const name = norm(r.tenBoMon);
      const dept = norm(
        (r as any).tenKhoa ??
        (r as any).khoaTen ??
        deps.find(d => `${d.id}` === `${r.khoaId}`)?.tenKhoa ?? ''
      );
      return name.includes(k) || dept.includes(k);
    });
  }, [rows, qDebounced, deps]);

  const openCreate = () => setModal({ open: true, editing: null });
  const openEdit   = (row: Subject) => setModal({ open: true, editing: row });

  function askDelete(row: Subject) { setConfirm({ open: true, row, busy: false }); }
  async function doDelete() {
    if (!confirm.row) return;
    try {
      setConfirm(c => ({ ...c, busy: true }));
      await deleteSubject(confirm.row.id);
      success('Xóa bộ môn thành công.');
      setConfirm({ open: false, row: null, busy: false });
      await load();
    } catch (e: any) {
      setConfirm(c => ({ ...c, busy: false }));
      toastError(e?.response?.data?.message || 'Không thể xóa bộ môn.');
    }
  }

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <h1 className="text-3xl font-semibold text-center">Danh sách bộ môn</h1>

      <div className="flex items-center gap-3">
        <button onClick={openCreate} className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          + Thêm bộ môn
        </button>
        <input
          className="h-10 px-3 rounded border w-80"
          placeholder="Tìm theo tên bộ môn hoặc tên khoa…"
          value={q}
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
        />
        <div className="ml-auto text-sm text-slate-600">
          {`${filtered.length}/${total || filtered.length}`}
        </div>
      </div>

      <div className="rounded-lg border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4 w-16">STT</th>
              <th className="px-4">Tên bộ môn</th>
              <th className="px-4">Khoa</th>
              <th className="px-4">Trưởng bộ môn</th>
              <th className="px-4 w-[220px]">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Đang tải…</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={5}>Không có dữ liệu.</td></tr>
            ) : filtered.map((r, idx) => {
              const deptName =
                (r as any).tenKhoa ??
                (r as any).khoaTen ??
                deps.find(d => `${d.id}` === `${r.khoaId}`)?.tenKhoa ?? '—';

              const headName =
                (r as any).truongBoMonHoTen ??
                (r as any).truongBoMonTen ??
                (r as any).truongBoMon?.hoTen ??
                (r as any).tenTruongBoMon ??
                (r as any).headName ?? '—';

              const hasHead = headName && headName !== '—';

              return (
                <tr key={`${r.id}`} className="border-t">
                  <td className="px-4 py-3">{page * size + idx + 1}</td>
                  <td className="px-4 py-3">{r.tenBoMon}</td>
                  <td className="px-4 py-3">{deptName}</td>
                  <td className="px-4 py-3">
                    {hasHead ? <span className="text-green-700">{headName}</span> : <span className="text-slate-500">—</span>}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-2">
                      {/* Gán Trưởng bộ môn */}
                      <button
                        className="inline-flex items-center justify-center h-9 w-9 rounded-md hover:bg-slate-100"
                        onClick={() => setHeadSubject(r)}
                        title="Gán Trưởng bộ môn"
                        aria-label="Gán Trưởng bộ môn"
                      >
                        <IdCardLanyard size={16} className={hasHead ? 'text-amber-500' : 'text-slate-600'} />
                      </button>

                      {/* Sửa */}
                      <button
                        className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                        onClick={() => openEdit(r)}
                        title="Sửa"
                        aria-label="Sửa bộ môn"
                      >
                        <Pencil size={16} />
                      </button>

                      {/* Xóa */}
                      <button
                        className="ml-1 inline-flex items-center justify-center h-9 w-9 rounded-md text-red-600 hover:bg-red-50"
                        onClick={() => askDelete(r)}
                        title="Xóa"
                        aria-label="Xóa bộ môn"
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>

        {/* Footer phân trang CĂN GIỮA */}
        <div className="p-3">
          <div className="flex justify-center">
            <PageNav
              page={page}
              totalPages={totalPages}
              onChange={(p) => { if (p !== page) setPage(p); }}
            />
          </div>

          {/* (tuỳ chọn) chọn số dòng/trang — cũng căn giữa */}
          <div className="mt-3 flex justify-center">
            <select
              className="h-9 border rounded px-2 bg-white"
              value={size}
              onChange={(e) => { setPage(0); setSize(Number(e.target.value) || PAGE_SIZE); }}
            >
              {[12, 20, 50, 100].map(s => (
                <option key={s} value={s}>{s}/trang</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Modal xác nhận xóa */}
      {confirm.open && confirm.row && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
          <div className="w-[460px] rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold mb-2">Xác nhận xóa</h3>
            <p className="text-sm text-slate-600">
              Bạn có chắc muốn xóa bộ môn <span className="font-medium">{confirm.row.tenBoMon}</span>?
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
              >
                <Trash2 size={16} />
                {confirm.busy ? 'Đang xóa…' : 'Xóa'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal gán Trưởng bộ môn */}
      {headSubject && (
        <AssignSubjectHeadModal
          subject={headSubject}
          onClose={() => setHeadSubject(null)}
          onSaved={() => load()}
        />
      )}

      {/* Modal thêm/sửa bộ môn */}
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
            } catch (e: any) {
              toastError(e?.response?.data?.message || 'Lưu bộ môn thất bại.');
            }
          }}
        />
      )}
    </div>
  );
}
