import React, { useEffect, useState } from 'react'
import { fetchLecturersByTruongBoMon, GiangVienTb } from '../services/giangVienApi'

export default function TruongBoMonDanhSachGiangVienPage() {
  const [rows, setRows] = useState<GiangVienTb[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  // paging / search UI state (mirrors TBM duyệt page)
  const [query, setQuery] = useState<string>('')
  const [page, setPage] = useState<number>(0)
  const [pageSize, setPageSize] = useState<number>(10)

  useEffect(() => {
    let mounted = true
    async function load() {
      setLoading(true)
      setError(null)
      try {
        const resp = await fetchLecturersByTruongBoMon()
        const items: any[] = Array.isArray(resp) ? resp : resp?.result ?? []
        if (mounted) setRows(items)
      } catch (e: any) {
        console.error('[TBM] fetch lecturers failed', e)
        if (mounted) setError(e?.message ?? String(e))
      } finally {
        if (mounted) setLoading(false)
      }
    }
    load()
    return () => { mounted = false }
  }, [])

  // client-side search (search by mã GV or tên)
  const filtered = React.useMemo(() => {
    const q = String(query ?? '').trim().toLowerCase()
    if (!q) return rows
    return rows.filter(r => {
      const fields = [r.maGV ?? '', r.hoTen ?? '', r.email ?? '']
      return fields.some(f => String(f).toLowerCase().includes(q))
    })
  }, [rows, query])

  const totalElements = filtered.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const paged = React.useMemo(() => filtered.slice(page * pageSize, (page + 1) * pageSize), [filtered, page, pageSize])

  // reset page when query/pageSize/rows change
  useEffect(() => { setPage(0) }, [query, pageSize, rows])

  return (
    <div>
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-semibold">Danh sách giảng viên theo bộ môn</h1>
      </div>

      <div className="bg-white shadow rounded">
        <div className="p-4 flex items-center justify-between">
          <div className="w-64">
            <input value={query} onChange={e => setQuery(e.target.value)} placeholder="Tìm theo mã/tên/email" className="w-full border rounded px-3 py-2 text-sm" />
          </div>
          <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả</div>
        </div>

        {loading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : error ? (
          <div className="p-6 text-center text-red-600">Lỗi: {error}</div>
        ) : paged.length === 0 ? (
          <div className="p-6 text-center">Không có giảng viên</div>
        ) : (
          <table className="min-w-full table-auto">
            <thead>
              <tr className="border-b">
                <th className="text-left px-6 py-4">Mã GV</th>
                <th className="text-left px-6 py-4">Họ và tên</th>
                <th className="text-left px-6 py-4">Email</th>
                <th className="text-left px-6 py-4">SĐT</th>
                <th className="text-left px-6 py-4">Số đề tài</th>
                <th className="text-left px-6 py-4">Số cho phép HD</th>
              </tr>
            </thead>
            <tbody>
              {paged.map(r => (
                <tr key={r.id ?? r.maGV} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maGV}</td>
                  <td className="px-6 py-4">{r.hoTen}</td>
                  <td className="px-6 py-4">{r.email ?? <span className="text-sm text-slate-500">—</span>}</td>
                  <td className="px-6 py-4">{r.soDienThoai ?? <span className="text-sm text-slate-500">—</span>}</td>
                  <td className="px-6 py-4">{String(r.soLuongDeTai ?? '')}</td>
                  <td className="px-6 py-4">{String(r.soLuongChoPhepHuongDan ?? '')}</td>
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
    </div>
  )
}
