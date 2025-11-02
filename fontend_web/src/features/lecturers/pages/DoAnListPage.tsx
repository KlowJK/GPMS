import React, { useEffect, useState } from 'react'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'
import { Eye } from 'lucide-react'
import StudentDetail from '../components/DanhSachSinhVienHD'

export default function DoAnListPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)

  // client-side search/paging moved to viewmodel
  useEffect(() => { vm.setStatusFilter('DA_DUYET') }, [])
  useEffect(() => { vm.setClientPage(0) }, [vm.data, vm.clientSize, vm.search])

  const pagedRows = vm.pagedRows ?? []
  const totalElements = vm.totalElements ?? 0
  const totalPages = vm.totalPages ?? 1

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Danh sách sinh viên hướng dẫn</h2>
        <div className="w-64">
          <input
            value={vm.search}
            onChange={e => vm.setSearch(e.target.value)}
            placeholder="Tìm theo mã sinh viên"
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>
      </div>

      <div className="bg-white shadow rounded">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
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
                        <Eye size={16} />
                        Xem chi tiết
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {/* Pagination controls */}
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
      <StudentDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
