import React, { useEffect, useState } from 'react'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'
import { FileText } from 'lucide-react'
import ReportDetail from '../components/BaoCaoChiTiet'

export default function BaoCao() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)

  // use viewmodel for client-side search/paging

  // ensure UI resets to first client page when search/pageSize or source data changes
  useEffect(() => { vm.setClientPage(0) }, [vm.data, vm.clientSize, vm.search])

  // For report page show only approved topics by default
  useEffect(() => { vm.setStatusFilter('DA_DUYET') }, [])

  // use viewmodel's derived client-side rows
  const pagedRows = vm.pagedRows ?? []
  const totalElements = vm.totalElements ?? 0
  const totalPages = vm.totalPages ?? 1

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Báo cáo </h2>
        <div className="w-64">
          <input
            value={vm.search}
            onChange={e => vm.setSearch(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter') { /* immediate filter already applied */ } }}
            placeholder="Tìm theo mã sinh viên"
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>
      </div>

      <div className="bg-white shadow rounded">
          {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : (totalElements === 0 && vm.search) ? (
          <div className="p-6 text-center">Không tìm thấy kết quả cho "{vm.search}"</div>
        ) : !totalElements ? (
          <div className="p-6 text-center">Không có dữ liệu</div>
        ) : (
          <table className="min-w-full table-auto">
            <thead>
              <tr className="border-b">
                <th className="text-left px-6 py-4">Mã sinh viên</th>
                <th className="text-left px-6 py-4">Họ và tên</th>
                <th className="text-left px-6 py-4">Lớp</th>
                <th className="text-left px-6 py-4">SĐT</th>
                <th className="text-left px-6 py-4">Tên đề tài</th>
                <th className="text-left px-6 py-4">Hành động</th>
              </tr>
            </thead>
            <tbody>
              {pagedRows.map((r: any) => (
                <tr key={r.idDeTai} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maSV}</td>
                  <td className="px-6 py-4">{r.hoTen}</td>
                  <td className="px-6 py-4">{r.tenLop}</td>
                  <td className="px-6 py-4">{r.soDienThoai ?? '—'}</td>
                  <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <button
                        title="Xem chi tiết"
                        onClick={() => setSelectedMaSV(r.maSV)}
                        className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                        aria-label={`Xem chi tiết ${r.maSV}`}
                      >
                        <FileText size={16} />
                        <span>Duyệt báo cáo</span>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {/* Pagination */}
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
                    <button key={p} onClick={() => vm.setClientPage(p)} className={["px-3 py-1 rounded", p === vm.clientPage ? 'bg-sky-600 text-white' : 'bg-white border'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={vm.clientPage >= totalPages - 1} onClick={() => vm.setClientPage(Math.min(totalPages - 1, vm.clientPage + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}

  <ReportDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
