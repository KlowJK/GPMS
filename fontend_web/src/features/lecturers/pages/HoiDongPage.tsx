import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'
import HoiDongDetail from '../components/HoiDongDetail'
import { Eye } from 'lucide-react'


async function fetchHoiDong(params: { idGiangVien?: number; page?: number; size?: number; sort?: string }) {
  const resp = await axios.get('/api/hoi-dong', {
    params: {
      idGiangVien: params.idGiangVien,
      page: params.page,
      size: params.size,
      sort: params.sort,
    },
    headers: { Accept: '*/*' },
    timeout: 10000,
  })
  return resp.data?.result
}

function Inner() {
  // client-side pagination: fetch full list then page in UI (like DoAnListPage)
  const [page, setPage] = useState(0)
  // match DoAnListPage default pageSize
  const [pageSize, setPageSize] = useState(3)
  const idGiangVien = 5

  const { data, isLoading, isError } = useQuery<any, Error>({
    queryKey: ['hoi-dong', idGiangVien],
    // do not pass page/size so API may return full list (or large page)
    queryFn: () => fetchHoiDong({ idGiangVien, sort: 'thoiGianBatDau,DESC' }),
  })

  // derive client-side pagination values
  const rows = (((data as any)?.content) ?? [])
  const totalElements = rows.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const pagedRows = rows.slice(page * pageSize, (page + 1) * pageSize)
  // reset to first page when pageSize changes to avoid out-of-range
  React.useEffect(() => { setPage(0) }, [pageSize])

  const [detailId, setDetailId] = useState<number | null>(null)
  const detailQuery = useQuery<any, Error>({
    queryKey: ['hoi-dong-detail', detailId],
    queryFn: async () => {
      if (!detailId) return null
      const resp = await axios.get(`/api/hoi-dong/${detailId}`, { headers: { Accept: '*/*' }, timeout: 10000 })
      return resp.data?.result
    },
    enabled: !!detailId,
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Hội đồng</h1>
      </div>

      <div className="bg-white shadow rounded p-4">
        {isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : isError ? (
          <div className="p-6 text-center text-red-600">Lỗi khi tải dữ liệu</div>
        ) : (
          <>
            <table className="min-w-full table-auto">
              <thead>
                <tr className="border-b">
                  <th className="text-left px-6 py-4">ID</th>
                  <th className="text-left px-6 py-4">Tên hội đồng</th>
                  <th className="text-left px-6 py-4">Thời gian bắt đầu</th>
                  <th className="text-left px-6 py-4">Thời gian kết thúc</th>
                  <th className="text-left px-6 py-4">Trạng thái</th>
                  <th className="text-left px-6 py-4">Hành động</th>
                </tr>
              </thead>
              <tbody>
                {pagedRows.map((h: any) => {
                  // compute status from start/end times
                  const now = new Date()
                  const start = h.thoiGianBatDau ? new Date(h.thoiGianBatDau) : null
                  const end = h.thoiGianKetThuc ? new Date(h.thoiGianKetThuc) : null
                  let status = 'sắp diễn ra'
                  if (start && end) {
                    if (now < start) status = 'sắp diễn ra'
                    else if (now >= start && now <= end) status = 'đang diễn ra'
                    else status = 'đã kết thúc'
                  } else if (start && !end) {
                    status = now < start ? 'sắp diễn ra' : 'đang diễn ra'
                  } else if (!start && end) {
                    status = now <= end ? 'đang diễn ra' : 'đã kết thúc'
                  }

                  const badgeClass = status === 'sắp diễn ra' ? 'bg-sky-100 text-sky-700' : status === 'đang diễn ra' ? 'bg-emerald-100 text-emerald-800' : 'bg-slate-100 text-slate-700'

                  return (
                    <tr key={h.id} className="border-b hover:bg-slate-50">
                      <td className="px-6 py-4">{h.id}</td>
                      <td className="px-6 py-4">{h.tenHoiDong}</td>
                      <td className="px-6 py-4">{h.thoiGianBatDau}</td>
                      <td className="px-6 py-4">{h.thoiGianKetThuc}</td>
                      <td className="px-6 py-4">
                        <span className={`inline-block px-3 py-1 rounded-full text-xs ${badgeClass}`}>{status}</span>
                      </td>
                      <td className="px-6 py-4">
                 
                            <button
                              title="Xem chi tiết"
                              onClick={() => setDetailId(h.id)}
                              className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                            >
                              <Eye size={16} />
                              Xem chi tiết
                            </button>
                
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>

            {/* Pagination controls (match DoAnListPage) */}
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
          </>
        )}
      </div>
      <HoiDongDetail open={!!detailId} onClose={() => setDetailId(null)} data={detailQuery.data} isLoading={detailQuery.isLoading} isError={detailQuery.isError} />
    </div>
  )
}

export default function HoiDong() {
  return <Inner />
}
