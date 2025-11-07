import { useEffect, useMemo, useRef, useState } from 'react';
import {
  type DefenseRoundUI,
  type CreateUpdateDefenseRound,
  listDefenseRoundsNormalized,
  createDefenseRound,
  updateDefenseRound,
  deleteDefenseRound,
  importStudentsToRound,
  lockDefenseRound,
} from '@/features/assistants/services/topic/topicApi';
import DefenseRoundFormModal from '@/features/assistants/components/DefenseRoundFormModal';
import { Pencil, Trash2, Lock, FileUp } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';
// ✅ dùng chung Pagination
import Pagination from '@/features/assistants/components/Pagination';

type ModalState = { open: boolean; editing?: DefenseRoundUI | null };

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

type ConfirmState = { open: boolean; round?: DefenseRoundUI | null; intent?: 'lock' | 'unlock' };
type DeleteState  = { open: boolean; row?: DefenseRoundUI | null; busy?: boolean };

export default function DefenseRoundsPage() {
  const { success, error } = useToast();

  const [items, setItems] = useState<DefenseRoundUI[]>([]);
  const [page, setPage]   = useState(0);   // 0-based
  const [size]            = useState(10);
  const [total, setTotal] = useState(0);
  const [q, setQ]         = useState('');
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const [modal, setModal] = useState<ModalState>({ open: false });

  // import file
  const fileRef = useRef<HTMLInputElement | null>(null);
  const [importingFor, setImportingFor] = useState<DefenseRoundUI | null>(null);
  const [importBusy, setImportBusy] = useState(false);

  // xác nhận khóa/mở đợt
  const [confirmBox, setConfirmBox] = useState<ConfirmState>({ open: false });
  const [agree, setAgree] = useState(false);
  const [confirmBusy, setConfirmBusy] = useState(false);

  // xác nhận xoá
  const [delBox, setDelBox] = useState<DeleteState>({ open: false, row: null, busy: false });

  const keyword = useMemo(() => q.trim(), [q]);

  async function load() {
    setLoading(true);
    setErr(null);
    try {
      const pg = await listDefenseRoundsNormalized({ page, size, q: keyword || undefined });
      setItems(pg.content);
      setTotal(pg.totalElements ?? pg.content.length ?? 0);
    } catch (e: any) {
      setItems([]); setTotal(0);
      setErr(e?.response?.data?.message || 'Không tải được danh sách đợt bảo vệ.');
    } finally {
      setLoading(false);
    }
  }
  useEffect(() => { load(); }, [page, size, keyword]);

  // import SV
  async function onPickFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    e.target.value = '';
    if (!file || !importingFor) return;
    try {
      setImportBusy(true);
      await importStudentsToRound(
        { id: importingFor.id, hocKi: importingFor.hocKi, namHoc: importingFor.namHoc },
        file
      );
      success('Import sinh viên thành công.');
      await load();
    } catch (ex: any) {
      error(ex?.response?.data?.message || 'Import thất bại.');
    } finally {
      setImportBusy(false);
      setImportingFor(null);
    }
  }

  // mở hộp xác nhận khóa/mở
  function openConfirm(r: DefenseRoundUI) {
    const isLocked = getLockedFlag(r);
    setConfirmBox({ open: true, round: r, intent: isLocked ? 'unlock' : 'lock' });
    setAgree(false);
  }

  // xác nhận thao tác khóa/mở
  async function doConfirm() {
    if (!confirmBox.round || !confirmBox.intent) return;
    try {
      setConfirmBusy(true);
      await lockDefenseRound(confirmBox.round.id);
      setItems(prev =>
        prev.map(it =>
          String(it.id) === String(confirmBox.round!.id)
            ? ({ ...it, lockedFlag: confirmBox.intent === 'lock' } as any)
            : it
        )
      );
      success(confirmBox.intent === 'lock' ? 'Khóa đợt thành công.' : 'Mở đợt thành công.');
      setConfirmBox({ open: false });
    } catch (ex: any) {
      error(ex?.response?.data?.message || 'Thao tác thất bại.');
    } finally {
      setConfirmBusy(false);
    }
  }

  // xoá đợt
  function askDelete(row: DefenseRoundUI) { setDelBox({ open: true, row, busy: false }); }
  async function doDelete() {
    if (!delBox.row) return;
    try {
      setDelBox(c => ({ ...c, busy: true }));
      await deleteDefenseRound(delBox.row.id);
      success('Xóa đợt thành công.');
      setDelBox({ open: false, row: null, busy: false });
      await load();
    } catch (ex: any) {
      setDelBox(c => ({ ...c, busy: false }));
      error(ex?.response?.data?.message || 'Không thể xóa đợt.');
    }
  }

  const from = page * size + 1;
  const to   = Math.min(total, page * size + items.length);
  const totalPages = Math.max(1, Math.ceil(total / size));

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
          onChange={(e) => { setPage(0); setQ(e.target.value); }}
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
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Đang tải…</td></tr>
            ) : items.length === 0 ? (
              <tr><td className="px-4 py-6 text-center" colSpan={6}>Chưa có đợt bảo vệ.</td></tr>
            ) : (
              items.map((r) => {
                const isLocked  = getLockedFlag(r);
                const busyThis  = importBusy && importingFor && String(importingFor.id) === String(r.id);
                const statusTxt = isLocked ? 'Kết thúc' : 'Đang diễn ra';
                return (
                  <tr key={`${r.id}`} className="border-t">
                    <td className="px-4 py-3">{r.tenDotBaoVe}</td>
                    <td className="px-4 py-3">{r.hocKi}</td>
                    <td className="px-4 py-3">{r.namHoc}</td>
                    <td className="px-4 py-3">{r.thoiGianBatDau || '—'} → {r.thoiGianKetThuc || '—'}</td>
                    <td className="px-4 py-3">
                      {isLocked ? <span className="text-red-600">{statusTxt}</span>
                                : <span className="text-green-600">{statusTxt}</span>}
                    </td>
                    <td className="px-4 py-3">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => { setImportingFor(r); fileRef.current?.click(); }}
                          className="rounded border px-3 py-1 inline-flex items-center gap-1 disabled:opacity-50"
                          disabled={!!busyThis}
                          title="Import sinh viên (Excel/CSV)"
                        >
                          <FileUp size={16}/>
                        </button>
                        <button
                          onClick={() => openConfirm(r)}
                          className="h-9 w-9 rounded border inline-grid place-items-center"
                          title={isLocked ? 'Mở lại đợt' : 'Khóa đợt'}
                        >
                          <Lock size={16} className={isLocked ? 'text-red-600' : 'text-slate-600'} />
                        </button>
                        <button
                          onClick={() => setModal({ open: true, editing: r })}
                          className="inline-flex items-center justify-center h-9 w-9 rounded-md text-blue-600 hover:bg-slate-100"
                          title="Sửa"
                        >
                          <Pencil size={16} />
                        </button>
                        <button
                          onClick={() => askDelete(r)}
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

        {/* ✅ dùng chung Pagination */}
        <Pagination
          page={page}
          totalPages={totalPages}
          onChange={setPage}
          disabled={loading}
        />
      </div>

      {/* input file ẩn dùng chung */}
      <input ref={fileRef} type="file" accept=".xlsx,.xls,.csv" className="hidden" onChange={onPickFile} />

      {/* Modal xác nhận khóa/mở */}
      {confirmBox.open && confirmBox.round && (
        /* ... giữ nguyên modal như trước ... */
        <></>
      )}

      {/* Modal xác nhận xoá */}
      {delBox.open && delBox.row && (
        /* ... giữ nguyên modal như trước ... */
        <></>
      )}

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
