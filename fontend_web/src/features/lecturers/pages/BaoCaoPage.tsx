import React, { useEffect, useState } from 'react'
import { useReviewsViewModel } from '../viewmodels/DuyetDeTaiViewmodels'
import { Eye } from 'lucide-react'
import ReportDetail from '../components/BaoCaoChiTiet'

export default function BaoCao() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)
  // local client-side search query (do not modify vm.search to avoid server-side effects)
  const [query, setQuery] = useState<string>('')

  // local UI-only pagination (client-side) — do not call API when changing pages
  const [page, setPage] = React.useState<number>(0)
  // default pageSize reduced to 3 so pagination shows when rows > 3
  const [pageSize, setPageSize] = React.useState<number>(10)

  // reset to first page when client-side query, pageSize or source data changes
  React.useEffect(() => { setPage(0) }, [query, pageSize, vm.data])

  // when pageSize changes reset to first page to avoid out-of-range page
  React.useEffect(() => {
    setPage(0)
  }, [pageSize])

  // For report page show only approved topics by default
  useEffect(() => {
    vm.setStatusFilter('DA_DUYET')
  }, [])

  // source rows from API
  const sourceRows = (vm.data?.content ?? [])

  // client-side filter by student code (maSV or maSinhVien)
  const filteredRows = (() => {
    const q = String(query ?? '').trim()
    if (!q) return sourceRows
    const lower = q.toLowerCase()
    return sourceRows.filter((r: any) => {
      const code = String(r.maSV ?? r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    })
  })()

  const rows = filteredRows
  const totalElements = rows.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const pagedRows = rows.slice(page * pageSize, (page + 1) * pageSize)

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Báo cáo </h2>
        <div className="w-64">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter') { /* immediate filter already applied */ } }}
            placeholder="Tìm theo mã sinh viên"
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>
      </div>

      <div className="bg-white shadow rounded">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : (!rows.length && query) ? (
          <div className="p-6 text-center">Không tìm thấy kết quả cho "{query}"</div>
        ) : !rows.length ? (
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
      </div>

      {/* Pagination */}
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
                    <button key={p} onClick={() => setPage(p)} className={["px-3 py-1 rounded", p === page ? 'bg-sky-600 text-white' : 'bg-white border'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={page >= totalPages - 1} onClick={() => setPage(Math.min(totalPages - 1, page + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}

  <ReportDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
