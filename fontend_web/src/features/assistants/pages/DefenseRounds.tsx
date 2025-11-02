// src/features/assistants/pages/DefenseRoundsPage.tsx
import { useEffect, useMemo, useRef, useState } from 'react';
import {
  type DefenseRoundUI,
  type CreateUpdateDefenseRound,
  listDefenseRoundsNormalized,
  createDefenseRound,
  updateDefenseRound,
  deleteDefenseRound,
  importStudentsToRound,
  lockDefenseRound, // toggle khóa/mở theo BE
} from '@/features/assistants/services/topic/topicApi';
import DefenseRoundFormModal from '@/features/assistants/components/DefenseRoundFormModal';
import { UploadCloud, Pencil, Trash2, Lock } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';

type ModalState = { open: boolean; editing?: DefenseRoundUI | null };

/** Chuẩn hóa cờ khóa từ nhiều key BE có thể trả */
function getLockedFlag(row: any): boolean {
  const v =
    row?.lockedFlag ??
    row?.daKhoa ??
    row?.khoa ??
    row?.isLocked ??
    row?.locked ??
    (typeof row?.trangThai === 'boolean' ? row.trangThai : undefined);
  return Boolean(v);
}

export default function DefenseRoundsPage() {
  const { success, error } = useToast();

  const [items, setItems] = useState<DefenseRoundUI[]>([]);
  const [page, setPage] = useState(0);
  const [size] = useState(1000);
  const [total, setTotal] = useState(0);
  const [q, setQ] = useState('');
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // import file
  const fileRef = useRef<HTMLInputElement | null>(null);
  const [importingFor, setImportingFor] = useState<number | string | null>(null);
  const [importBusy, setImportBusy] = useState(false);

  const keyword = useMemo(() => q.trim(), [q]);

  async function load() {
    setLoading(true);
    setErr(null);
    try {
      const pg = await listDefenseRoundsNormalized({ page, size, q: keyword || undefined });
      setItems(pg.content);
      setTotal(pg.totalElements);
    } catch (e: any) {
      setItems([]);
      setTotal(0);
      setErr(e?.response?.data?.message || 'Không tải được danh sách đợt bảo vệ.');
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, size, keyword]);

  // import SV
  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file || importingFor == null) return;

    try {
      setImportBusy(true);
      await importStudentsToRound(importingFor, file);
      success('Import sinh viên thành công.');
      await load();
    } catch (ex: any) {
      error(ex?.response?.data?.message || 'Import thất bại.');
    } finally {
      setImportBusy(false);
      setImportingFor(null);
    }
  }

  const from = page * size + 1;
  const to = Math.min(total, page * size + items.length);

  return (
    <div className="mx-auto max-w-6xl space-y-4">
      <h1 className="text-center text-3xl font-semibold">Danh sách các đợt bảo vệ</h1>

      <div className="flex items-center gap-3">
        <button
          onClick={() => setModal({ open: true, editing: null })}
          className="rounded-lg bg-blue-600 px-4 py-2 text-white"
        >
          + Thêm đợt
        </button>

        <input
          className="h-10 w-72 rounded border px-3"
          placeholder="Tìm theo tên…"
          value={q}
          onChange={(e) => {
            setPage(0);
            setQ(e.target.value);
          }}
        />

        <div className="ml-auto text-sm text-slate-600">
          {err ? <span className="text-red-600">{err}</span> : total ? `${from}–${to}/${total}` : ''}
        </div>
      </div>

      <div className="rounded border bg-white">
        <table className="w-full text-left">
          <thead className="bg-slate-50">
            <tr className="h-12">
              <th className="px-4">Tên đợt</th>
              <th className="px-4">Học kì</th>
              <th className="px-4">Năm học</th>
              <th className="px-4">Thời gian</th>
              <th className="px-4">Trạng thái</th>
              <th className="px-4 w-[300px]">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td className="px-4 py-6 text-center" colSpan={6}>
                  Đang tải…
                </td>
              </tr>
            ) : items.length === 0 ? (
              <tr>
                <td className="px-4 py-6 text-center" colSpan={6}>
                  Chưa có đợt bảo vệ.
                </td>
              </tr>
            ) : (
              items.map((r) => {
                const isLocked = getLockedFlag(r); // true = đã khóa → Kết thúc
                const busyThis = importBusy && String(importingFor) === String(r.id);
                const statusText = isLocked ? 'Kết thúc' : 'Đang diễn ra';
                return (
                  <tr key={`${r.id}`} className="border-t">
                    <td className="px-4 py-3">{r.tenDotBaoVe}</td>
                    <td className="px-4 py-3">{r.hocKi}</td>
                    <td className="px-4 py-3">{r.namHoc}</td>
                    <td className="px-4 py-3">
                      {r.thoiGianBatDau || '—'} → {r.thoiGianKetThuc || '—'}
                    </td>
                    <td className="px-4 py-3">
                      {isLocked ? (
                        <span className="text-red-600">{statusText}</span>
                      ) : (
                        <span className="text-green-600">{statusText}</span>
                      )}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        {/* Import SV */}
                        <button
                          onClick={() => {
                            setImportingFor(r.id);
                            fileRef.current?.click();
                          }}
                          className="rounded border px-3 py-1 inline-flex items-center gap-1 disabled:opacity-50"
                          disabled={busyThis}
                          title="Import sinh viên (Excel/CSV)"
                        >
                          <UploadCloud size={16} />
                          {busyThis ? 'Đang import…' : 'Import SV'}
                        </button>

                        {/* Khóa/Mở đợt – toggle; đổi màu icon theo trạng thái */}
                        <button
                          onClick={async () => {
                            const ok = confirm(
                              isLocked
                                ? `Mở lại đợt "${r.tenDotBaoVe}"?`
                                : `Khóa đợt "${r.tenDotBaoVe}"?`
                            );
                            if (!ok) return;
                            try {
                              await lockDefenseRound(r.id);
                              // cập nhật lạc quan để đổi trạng thái & màu ngay
                              setItems((prev) =>
                                prev.map((it) =>
                                  String(it.id) === String(r.id)
                                    ? ({ ...it, lockedFlag: !isLocked } as any)
                                    : it
                                )
                              );
                              success(isLocked ? 'Mở đợt thành công.' : 'Khóa đợt thành công.');
                              // optional: refresh lại để đồng bộ tuyệt đối
                              // await load();
                            } catch (ex: any) {
                              error(ex?.response?.data?.message || 'Thao tác thất bại.');
                            }
                          }}
                          className="h-9 w-9 rounded border inline-grid place-items-center"
                          title={isLocked ? 'Mở lại đợt' : 'Khóa đợt'}
                        >
                          <Lock size={16} className={isLocked ? 'text-red-600' : 'text-slate-600'} />
                        </button>

                        {/* Sửa */}
                        <button
                          onClick={() => setModal({ open: true, editing: r })}
                          className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                          title="Sửa"
                        >
                          <Pencil size={16} />
                        </button>

                        {/* Xóa */}
                        <button
                          onClick={async () => {
                            if (!confirm(`Xóa đợt "${r.tenDotBaoVe}"?`)) return;
                            try {
                              await deleteDefenseRound(r.id);
                              success('Xóa đợt thành công.');
                              await load();
                            } catch (ex: any) {
                              error(ex?.response?.data?.message || 'Không thể xóa đợt.');
                            }
                          }}
                          className="ml-1 inline-flex items-center justify-center h-9 w-9 rounded-md text-red-600 hover:bg-red-50"
                          title="Xóa"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>

        <div className="flex items-center justify-end gap-3 p-3">
          <button
            className="rounded border px-3 py-1 disabled:opacity-40"
            onClick={() => setPage((p) => Math.max(0, p - 1))}
            disabled={page === 0}
          >
            Trước
          </button>
          <span className="text-sm">{page + 1}</span>
          <button
            className="rounded border px-3 py-1 disabled:opacity-40"
            onClick={() => setPage((p) => (page * size + size < total ? p + 1 : p))}
            disabled={page * size + size >= total}
          >
            Sau
          </button>
        </div>
      </div>

      {/* input file ẩn dùng chung */}
      <input ref={fileRef} type="file" accept=".xlsx,.xls,.csv" className="hidden" onChange={onPickFile} />

      {modal.open && (
        <DefenseRoundFormModal
          initial={modal.editing ?? undefined}
          onClose={() => setModal({ open: false })}
          onSubmit={async (payload: CreateUpdateDefenseRound) => {
            if (modal.editing) await updateDefenseRound(modal.editing.id, payload);
            else await createDefenseRound(payload);
            setModal({ open: false });
            await load();
          }}
        />
      )}
    </div>
  );
}
