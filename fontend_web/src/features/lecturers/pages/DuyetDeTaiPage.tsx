import React, { useState, useEffect } from 'react'
import BangDuyetDeTai from '../components/BangDuyetDeTai'
import ModalXacNhan from '../components/ModalXacNhan'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'

export default function DuyetDeTaiPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [rejectingId, setRejectingId] = useState<string | null>(null)
    // client-side search/paging moved to viewmodel
    const [localQuery, setLocalQuery] = useState('')
    useEffect(() => { vm.setClientPage(0) }, [vm.data, vm.clientSize, vm.search])

  const onApprove = (id: string) => {
    vm.approve(id)
  }

  const onRejectConfirm = () => {
    // kept for old signature; not used now
  }

  const onRejectWithReason = (nhanXet: string) => {
    if (!rejectingId) return
    // call viewmodel method that accepts reason
    if ((vm as any).rejectWithReason) {
      ;(vm as any).rejectWithReason(rejectingId, nhanXet)
      // show a simple alert toast (replace with app toast lib if available)
      try { window.alert('Từ chối thành công') } catch {}
    } else {
      vm.reject(rejectingId)
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
    </div>
  )
}
