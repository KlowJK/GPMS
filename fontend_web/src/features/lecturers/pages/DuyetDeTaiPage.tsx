import React, { useState, useEffect } from 'react'
import { Check, Eye, Trash, FileText } from 'lucide-react'
import { toast } from 'sonner'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'
import type { XetDuyetItem } from '../models/DanhSachDuyetModels'

export default function DuyetDeTaiPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [rejectingId, setRejectingId] = useState<string | null>(null)
  const [approvingIdLocal, setApprovingIdLocal] = useState<string | null>(null)
    // client-side search/paging moved to viewmodel
    const [localQuery, setLocalQuery] = useState('')
    useEffect(() => { vm.setClientPage(0) }, [vm.data, vm.clientSize, vm.search])

  const onApprove = (id: string) => {
    // open confirm modal to collect note before approving
    setApprovingIdLocal(id)
  }

  const onRejectConfirm = () => {
    // kept for old signature; not used now
  }

  const onRejectWithReason = (nhanXet: string) => {
    if (!rejectingId) return
    // call viewmodel method that accepts reason
    if ((vm as any).rejectWithReason) {
      const res = (vm as any).rejectWithReason(rejectingId, nhanXet)
      Promise.resolve(res).then(() => toast.success('Từ chối thành công')).catch(() => toast.error('Từ chối không thành công'))
    } else {
      const r = vm.reject(rejectingId)
      Promise.resolve(r).then(() => toast.success('Từ chối thành công')).catch(() => toast.error('Từ chối không thành công'))
    }
    setRejectingId(null)
  }

    // use client-side derived rows from viewmodel
    const pagedRows = vm.pagedRows ?? []
    const totalElements = vm.totalElements ?? 0
    const totalPages = vm.totalPages ?? 1

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-3xl font-semibold">Duyệt đề tài</h2>
        <div className="w-64">
          <input value={vm.search} onChange={e => vm.setSearch(e.target.value)} placeholder="Tìm theo mã sinh viên" className="w-full border rounded px-3 py-2 text-sm" />
        </div>
      </div>

      <div className="bg-white shadow rounded">
        <BangDuyetDeTai rows={pagedRows as any} isLoading={vm.isLoading} onApprove={onApprove} onReject={(id) => setRejectingId(id)} onView={(url) => vm.openPdf(url)} approvingId={vm.approvingId} />

        {/* Pagination controls (client-side, same as DoAnListPage) */}
        {(() => {
          if (!totalPages || totalPages <= 1) return null
          const showPageButtons = totalPages <= 10
          const pages = showPageButtons ? Array.from({ length: totalPages }).map((_, i) => i) : []
          return (
            <div className="p-4 border-t flex items-center justify-between">
              <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {vm.clientPage + 1} / {totalPages}</div>
              <div className="flex items-center gap-2">
                <button aria-label="previous page" disabled={vm.clientPage <= 0} onClick={() => vm.setClientPage(Math.max(0, vm.clientPage - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                {showPageButtons ? (
                  pages.map(p => (
                    <button key={p} onClick={() => vm.setClientPage(p)} className={[(p === vm.clientPage ? 'bg-sky-600 text-white' : 'bg-white border'), 'px-3 py-1 rounded'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={vm.clientPage >= totalPages - 1} onClick={() => vm.setClientPage(Math.min(totalPages - 1, vm.clientPage + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}
      </div>

      <ModalXacNhan open={!!rejectingId} title="Xác nhận từ chối" message="Bạn có chắc muốn từ chối đề tài này?" onConfirm={onRejectWithReason} onCancel={() => setRejectingId(null)} />

      {/* Approve with note modal */}
      <ModalXacNhan
        open={!!approvingIdLocal}
        title="Xác nhận duyệt"
        message="Nhập nhận xét (tối thiểu 5 ký tự) để duyệt đề tài này"
        confirmClass="bg-emerald-600"
        confirmText="Xác nhận"
        onConfirm={(nhanXet: string) => {
          if (!approvingIdLocal) return
          if ((vm as any).approveWithReason) {
            const res = (vm as any).approveWithReason(approvingIdLocal, nhanXet)
            Promise.resolve(res).then(() => toast.success('Duyệt thành công')).catch(() => toast.error('Duyệt không thành công'))
          } else {
            const r = vm.approve(approvingIdLocal)
            Promise.resolve(r).then(() => toast.success('Duyệt thành công')).catch(() => toast.error('Duyệt không thành công'))
          }
          setApprovingIdLocal(null)
        }}
        onCancel={() => setApprovingIdLocal(null)}
      />
    </div>
  )
}

// Inlined ModalXacNhan component (previously in components/ModalXacNhan.tsx)
function ModalXacNhan({ open, title, message, onConfirm, onCancel, confirmClass, confirmText }: { open: boolean; title: string; message: string; onConfirm: (nhanXet: string) => void; onCancel: () => void; confirmClass?: string; confirmText?: string }) {
  const [text, setText] = useState('')
  if (!open) return null
  const canConfirm = text.trim().length >= 5
  const confirmBtnClass = confirmClass ?? 'bg-red-600'
  const confirmBtnText = confirmText ?? 'Xác nhận'
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md p-6 w-96">
        <h3 className="text-lg font-semibold mb-2">{title}</h3>
        <p className="text-sm text-slate-600 mb-4">{message}</p>
        <textarea value={text} onChange={e => setText(e.target.value)} placeholder="Nhập lý do (tối thiểu 5 ký tự)" className="w-full border rounded p-2 mb-4 h-24 text-sm" />
        <div className="flex justify-end gap-2">
          <button className="px-3 py-1 border rounded" onClick={() => { setText(''); onCancel() }}>Hủy</button>
          <button disabled={!canConfirm} className={["px-3 py-1 text-white rounded disabled:opacity-50", confirmBtnClass].join(' ')} onClick={() => { onConfirm(text.trim()); setText('') }}>{confirmBtnText}</button>
        </div>
      </div>
    </div>
  )
}

// Inlined BangDuyetDeTai component (previously in components/BangDuyetDeTai.tsx)
function BangDuyetDeTai({ rows, isLoading, onApprove, onReject, onView, onViewCv, approvingId }: { rows: XetDuyetItem[]; isLoading: boolean; onApprove: (id: string) => void; onReject: (id: string) => void; onView: (url?: string | null) => void; onViewCv?: (url?: string | null) => void; approvingId?: string | null }) {
  if (isLoading) return <div className="p-6 text-center">Đang tải...</div>

  if (!rows.length) return <div className="p-6 text-center">Không có dữ liệu</div>

  return (
    <table className="min-w-full table-auto">
      <thead>
        <tr className="border-b">
          <th className="text-left px-6 py-4">Mã sinh viên</th>
          <th className="text-left px-6 py-4">Họ và tên</th>
          <th className="text-left px-6 py-4">Lớp</th>
          <th className="text-left px-6 py-4">Tên đề tài</th>
          <th className="text-left px-6 py-4">Trạng thái</th>
          <th className="text-center px-6 py-4">Hành động</th>
        </tr>
      </thead>
      <tbody>
        {rows.map(r => (
          <tr key={r.idDeTai} className="border-b hover:bg-slate-50">
            <td className="px-6 py-4 font-medium">{r.maSV}</td>
            <td className="px-6 py-4">{r.hoTen}</td>
            <td className="px-6 py-4">{r.tenLop}</td>
            <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
            <td className="px-6 py-4">
              {r.trangThai === 'CHO_XET_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-yellow-100 text-yellow-800">Chờ xét duyệt</span>)}
              {r.trangThai === 'DA_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-green-100 text-green-800">Đã duyệt</span>)}
              {r.trangThai === 'TU_CHOI' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-red-100 text-red-800">Từ chối</span>)}
            </td>
            <td className="px-6 py-4 text-center align-middle">
              <div className="flex items-center justify-center gap-3">
                {/* Approve */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.trangThai === 'CHO_XET_DUYET' ? (
                      approvingId === r.idDeTai ? (
                      <div className="w-9 h-9 flex items-center justify-center text-green-600">...</div>
                    ) : (
                      <button title="Duyệt" onClick={() => onApprove(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-emerald-50 text-emerald-600 rounded-full hover:bg-emerald-100 transition">
                        <Check size={16} />
                      </button>
                    )
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>

                {/* View proposal */}
                <div className="w-9 h-9 flex items-center justify-center">
                  <button title="Xem tổng quan" onClick={() => onView(r.tongQuanDeTaiUrl)} className="w-9 h-9 flex items-center justify-center bg-slate-50 text-sky-600 rounded-full hover:bg-sky-100 transition"><Eye size={16} /></button>
                </div>

                {/* View CV (optional) */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.duongDanCv ? (
                    <button title="Xem CV" onClick={() => onViewCv ? onViewCv(r.duongDanCv) : window.open(r.duongDanCv as string, '_blank')} className="w-9 h-9 flex items-center justify-center bg-slate-50 text-sky-600 rounded-full hover:bg-sky-100 transition"><FileText size={16} /></button>
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>

                {/* Reject */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.trangThai === 'CHO_XET_DUYET' ? (
                    <button title="Từ chối" onClick={() => onReject(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-rose-50 text-rose-600 rounded-full hover:bg-rose-100 transition"><Trash size={16} /></button>
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
