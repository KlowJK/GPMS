import React, { useState } from 'react'
import BangDuyetDeTai from '../components/BangDuyetDeTai'
import ModalXacNhan from '../components/ModalXacNhan'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'

export default function DuyetDeTaiPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [rejectingId, setRejectingId] = useState<string | null>(null)
  // client-side pagination state (match DoAnListPage)
  const [page, setPage] = useState<number>(0)
  const [pageSize, setPageSize] = useState<number>(10)

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

  // prepare client-side paging
  const rows = (vm.data?.content ?? []) as any[]
  const totalElements = rows.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const pagedRows = rows.slice(page * pageSize, (page + 1) * pageSize)

  // reset page to first when search or pageSize changes
  React.useEffect(() => { setPage(0) }, [vm.search, pageSize, vm.data])

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
              <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {page + 1} / {totalPages}</div>
              <div className="flex items-center gap-2">
                <button aria-label="previous page" disabled={page <= 0} onClick={() => setPage(Math.max(0, page - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                {showPageButtons ? (
                  pages.map(p => (
                    <button key={p} onClick={() => setPage(p)} className={[(p === page ? 'bg-sky-600 text-white' : 'bg-white border'), 'px-3 py-1 rounded'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={page >= totalPages - 1} onClick={() => setPage(Math.min(totalPages - 1, page + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}
      </div>

      <ModalXacNhan open={!!rejectingId} title="Xác nhận từ chối" message="Bạn có chắc muốn từ chối đề tài này?" onConfirm={onRejectWithReason} onCancel={() => setRejectingId(null)} />
    </div>
  )
}
