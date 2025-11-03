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
  lockDefenseRound,
} from '@/features/assistants/services/topic/topicApi';
import DefenseRoundFormModal from '@/features/assistants/components/DefenseRoundFormModal';
import { UploadCloud, Pencil, Trash2, Lock } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';

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
// Modal xác nhận xoá
type DeleteState = { open: boolean; row?: DefenseRoundUI | null; busy?: boolean };

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
    if (!file || !importingFor) return;

    try {
      setImportBusy(true);
      await importStudentsToRound(
        { id: importingFor.id, hocKi: importingFor.hocKi, namHoc: importingFor.namHoc },
        file
      ); // gửi đủ hocKi & namHoc
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
      // cập nhật lạc quan
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

  // mở modal xác nhận xoá
  function askDelete(row: DefenseRoundUI) {
    setDelBox({ open: true, row, busy: false });
  }
  // thực hiện xoá
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
                const busyThis = importBusy && importingFor && String(importingFor.id) === String(r.id);
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
                            setImportingFor(r);
                            fileRef.current?.click();
                          }}
                          className="rounded border px-3 py-1 inline-flex items-center gap-1 disabled:opacity-50"
                          disabled={!!busyThis}
                          title="Import sinh viên (Excel/CSV)"
                        >
                          <UploadCloud size={16} />
                          {busyThis ? 'Đang import…' : 'Import SV'}
                        </button>

                        {/* Khóa/Mở đợt – toggle; icon đỏ khi đã khóa */}
                        <button
                          onClick={() => openConfirm(r)}
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

                        {/* Xóa (mở modal xác nhận) */}
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

      {/* Modal xác nhận khóa/mở */}
      {confirmBox.open && confirmBox.round && (
        <div className="fixed inset-0 bg-black/40 grid place-items-center z-50">
          <div className="bg-white rounded-2xl p-6 w-[520px]">
            <h3 className="text-lg font-semibold">
              {confirmBox.intent === 'lock' ? 'Khóa đợt bảo vệ' : 'Mở lại đợt bảo vệ'}
            </h3>
            <p className="mt-2 text-sm text-slate-600">
              {confirmBox.round.tenDotBaoVe} — {confirmBox.round.hocKi} / {confirmBox.round.namHoc}
              <br />
              Thời gian: {confirmBox.round.thoiGianBatDau} → {confirmBox.round.thoiGianKetThuc}
            </p>

            {confirmBox.intent === 'lock' && (
              <label className="mt-4 flex items-start gap-2 select-none">
                <input
                  type="checkbox"
                  className="mt-1 h-4 w-4"
                  checked={agree}
                  onChange={(e) => setAgree(e.target.checked)}
                />
                <span className="text-sm">
                  Tôi xác nhận khóa đợt này. Thao tác có thể chặn/cố định một số quy trình (nộp bài, chỉnh sửa…).
                </span>
              </label>
            )}

            <div className="mt-6 flex justify-end gap-2">
              <button onClick={() => setConfirmBox({ open: false })} className="px-4 h-10 rounded border" disabled={confirmBusy}>
                Hủy
              </button>
              <button
                onClick={doConfirm}
                className={`px-4 h-10 rounded text-white ${confirmBox.intent === 'lock' ? 'bg-red-600' : 'bg-blue-600'} disabled:opacity-50`}
                disabled={confirmBusy || (confirmBox.intent === 'lock' && !agree)}
              >
                {confirmBusy ? 'Đang xử lý…' : confirmBox.intent === 'lock' ? 'Khóa đợt' : 'Mở lại đợt'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal xác nhận xoá đợt */}
      {delBox.open && delBox.row && (
        <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
          <div className="w-[480px] rounded-2xl bg-white p-6 shadow-xl">
            <h3 className="text-lg font-semibold mb-2">Xác nhận xóa</h3>
            <p className="text-sm text-slate-600">
              Bạn có chắc muốn xóa đợt <span className="font-medium">{delBox.row.tenDotBaoVe}</span>?
            </p>
            <div className="mt-5 flex justify-end gap-3">
              <button
                className="h-10 rounded bg-slate-200 px-4"
                onClick={() => setDelBox({ open: false, row: null, busy: false })}
                disabled={!!delBox.busy}
              >
                Hủy
              </button>
              <button
                className="inline-flex items-center gap-2 h-10 rounded bg-red-600 px-4 text-white disabled:opacity-50"
                onClick={doDelete}
                disabled={!!delBox.busy}
                title="Xóa đợt"
              >
                <Trash2 size={16} /> {delBox.busy ? 'Đang xóa…' : 'Xóa'}
              </button>
            </div>
          </div>
        </div>
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
