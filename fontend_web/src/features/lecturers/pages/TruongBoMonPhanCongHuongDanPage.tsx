import React, { useEffect, useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { fetchStudentsWithoutSupervisor } from '../services'
import PhanCongModal from '../components/PhanCongModal'

export default function TruongBoMonPhanCongGiangVienPage() {
  const navigate = useNavigate()
  const [rows, setRows] = useState<any[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [isError, setIsError] = useState(false)
  const [errorDetails, setErrorDetails] = useState<any | null>(null)
  const [page, setPage] = useState<number>(0)
  const [pageSize, setPageSize] = useState<number>(10)
  const [query, setQuery] = useState<string>('')
  const [assignRow, setAssignRow] = useState<any | null>(null)
  const [showAssignModal, setShowAssignModal] = useState(false)

  useEffect(() => {
    // fetchData is intentionally defined here and used on mount and after assignments
    async function fetchData() {
      setIsLoading(true)
      setIsError(false)
      try {
        // request a reasonably sized page so server filtering is used
        const resp = await fetchStudentsWithoutSupervisor({ page: 0, size: 100, sort: ['hoTen,ASC'], status: 'TU_CHOI' })
        console.debug('[TBM] fetchStudentsWithoutSupervisor resp:', resp)
        const items = Array.isArray(resp?.content) ? resp.content : []
        console.debug('[TBM] items length:', items.length)
        setRows(items)
      } catch (err) {
        console.error('[TBM] load error:', err, (err as any)?.response?.status, (err as any)?.response?.data)
        setErrorDetails({
          message: (err as any)?.message ?? String(err),
          status: (err as any)?.response?.status ?? null,
          data: (err as any)?.response?.data ?? null,
        })
        setIsError(true)
      } finally {
        setIsLoading(false)
      }
    }

    fetchData()
    // expose fetchData to outer scope via a ref if needed by children; simpler: attach to window for quick debugging
    // (we won't rely on window in production)
    ;(window as any).__tbm_fetch = fetchData
    return () => { delete (window as any).__tbm_fetch }
  }, [])

  // reset to first page when data, pageSize or query changes
  useEffect(() => { setPage(0) }, [rows, pageSize, query])

  const q = (query || '').toLowerCase().trim()
  const filtered = q ? rows.filter(r => (((r.maSV ?? '') + ' ' + (r.hoTen ?? '') + ' ' + (r.tenLop ?? '') + ' ' + (r.tenDeTai ?? '')).toLowerCase().includes(q))) : rows
  const totalElements = filtered.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const paged = filtered.slice(page * pageSize, (page + 1) * pageSize)

  const location = useLocation()
  const isGuidance = location.pathname.startsWith('/lecturers/truong-bo-mon/phan-cong-giang-vien')
  const isReviewer = location.pathname.startsWith('/lecturers/truong-bo-mon/phan-cong-phan-bien')

  return (
    <div >
      <div className="flex items-center justify-between mb-4">
        <h1 className="text-2xl font-semibold">Phân công giảng viên hướng dẫn </h1>
        <div className="flex items-center gap-3">
        
          <div className="inline-flex items-center rounded-full bg-transparent p-1">
            <button
              onClick={() => navigate('/lecturers/truong-bo-mon/phan-cong-giang-vien')}
              className={[(isGuidance ? 'bg-sky-600 text-white' : 'bg-white text-slate-700 border'), 'px-6 py-2 rounded-full'].join(' ')}
              aria-pressed={isGuidance}
            >
              Phân công GV hướng dẫn
            </button>
            <button
              onClick={() => navigate('/lecturers/truong-bo-mon/phan-cong-phan-bien')}
              className={[(isReviewer ? 'bg-sky-600 text-white' : 'bg-white text-slate-700 border'), 'ml-2 px-6 py-2 rounded-full'].join(' ')}
              aria-pressed={isReviewer}
            >
              Phân công GV phản biện
            </button>
          </div>
            <div className="w-64">
            <input value={query} onChange={e => setQuery(e.target.value)} placeholder="Tìm theo mã/tên/lớp/đề tài" className="w-full border rounded px-3 py-2 text-sm" />
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded">
        {isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : isError ? (
          <div className="p-6 text-center text-red-600">
            <div>Lỗi khi tải dữ liệu</div>
            {errorDetails && (
              <div className="mt-2 text-xs text-left text-red-500 max-w-3xl mx-auto break-words bg-white/5 p-3 rounded">
                <div><strong>message:</strong> {String(errorDetails.message)}</div>
                <div><strong>status:</strong> {String(errorDetails.status)}</div>
                <div><strong>data:</strong> <pre className="whitespace-pre-wrap">{JSON.stringify(errorDetails.data, null, 2)}</pre></div>
              </div>
            )}
          </div>
        ) : !rows || rows.length === 0 ? (
          <div className="p-6 text-center">Không có dữ liệu</div>
        ) : (
          <table className="min-w-full table-auto">
            <thead>
              <tr className="border-b">
                <th className="text-left px-6 py-4">Mã sinh viên</th>
                <th className="text-left px-6 py-4">Họ và tên</th>
                <th className="text-left px-6 py-4">Lớp</th>
                <th className="text-left px-6 py-4">Tên đề tài</th>
                 <th className="text-left px-6 py-4">Tổng quan</th>
                {/* Trạng thái column removed */}
                <th className="text-left px-6 py-4">Hành động</th>
              </tr>
            </thead>
            <tbody>
              {paged.map(r => (
                <tr key={r.idDeTai ?? r.id ?? r.maSV} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maSV}</td>
                  <td className="px-6 py-4">{r.hoTen}</td>
                  <td className="px-6 py-4">{r.tenLop}</td>
                  <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
                    <td className="px-6 py-4">
                      {r.tongQuanDeTaiUrl ? (
                        <a href={r.tongQuanDeTaiUrl} target="_blank" rel="noreferrer" className="text-sky-600 underline text-sm">Xem tổng quan</a>
                      ) : (
                        <span className="text-sm text-slate-500">—</span>
                      )}
                    </td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <button
                        title="Phân công"
                        onClick={() => { setAssignRow(r); setShowAssignModal(true) }}
                        className="inline-flex items-center gap-2 px-3 py-1 bg-emerald-50 border rounded text-emerald-700 hover:bg-emerald-100"
                      >
                        Phân công
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        <PhanCongModal
          open={showAssignModal}
          onClose={() => { setShowAssignModal(false); setAssignRow(null) }}
          row={assignRow}
          onAssigned={async (payload) => {
              // After successful assignment, re-fetch the server list so we reflect current state.
              console.log('assigned', payload)
              // close modal first for better UX
              setShowAssignModal(false)
              setAssignRow(null)
              try {
                // call the same fetch we used on mount; use the helper attached to window
                const fn = (window as any).__tbm_fetch as (() => Promise<void>) | undefined
                if (typeof fn === 'function') await fn()
                else {
                  // fallback: perform a manual fetch
                  const resp = await fetchStudentsWithoutSupervisor({ page: 0, size: 100, sort: ['hoTen,ASC'], status: 'TU_CHOI' })
                  const items = Array.isArray(resp?.content) ? resp.content : []
                  setRows(items)
                }
              } catch (e) {
                console.error('[TBM] refetch after assign failed', e)
              }
            }}
        />

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
