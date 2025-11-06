import React, { useEffect, useState, useMemo } from 'react'
import useTruongBoMonViewModel from '../viewmodels/TruongBoMonViewmodels'
import { exportDeCuongAcceptedExcelForTbm } from '../services/deCuongApi'
import { useAuth } from '@shared/hooks/useAuth'
import { Eye, FileSpreadsheet } from 'lucide-react'
import DeCuongDetailModal from '../components/DeCuongPhanBien'

export default function TruongBoMonDuyetDeCuongCuoiPage() {
  return <Inner />
}

function normalizeString(x: any) {
  if (!x && x !== 0) return ''
  try {
    // remove common academic titles (PGS., PGS, ThS., TS., Dr., Mr., Mrs., etc.) to avoid mismatches
    const noTitle = String(x).replace(/\b(p\.?g\.?s|pgs|ths|th\.s|ts|dr|mr|mrs|ms)\.?\b\s*/gi, '')
    return noTitle.toLowerCase().normalize('NFKD').replace(/\p{M}/gu, '').replace(/\s+/g, ' ').trim()
  } catch {
    const noTitle = String(x).replace(/\b(p\.?g\.?s|pgs|ths|th\.s|ts|dr|mr|mrs|ms)\.?\b\s*/gi, '')
    return noTitle.toLowerCase().replace(/[^\w\s]/g, '').replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, ' ').trim()
  }
}

function Inner() {
  // use TBM-specific viewmodel to fetch proposals and helpers
  const vm = useTruongBoMonViewModel()

  // local UI state
  const [query, setQuery] = useState<string>('')
  const [page, setPage] = useState<number>(0)
  const [pageSize, setPageSize] = useState<number>(10)
  const [modalOpen, setModalOpen] = useState(false)
  const [selected, setSelected] = useState<any | null>(null)
  const [exportLoading, setExportLoading] = useState(false)

  // derive source rows from vm (already normalized)
  const { user } = useAuth()

  const userName = useMemo(() => {
    const candidates = [user?.fullName, user?.hoTen, user?.name, user?.ten, user?.full_name]
    for (const c of candidates) {
      const n = normalizeString(c)
      if (n) return n
    }
    return ''
  }, [user])
  // raw display name for passing to detail modal (non-normalized)
  const currentName = useMemo(() => (user?.fullName ?? user?.name ?? user?.hoTen ?? user?.username ?? '').toString(), [user])
  // prefer the viewmodel's visibleForName helper (keeps normalization consistent)
  const ownedRows = useMemo(() => vm.visibleForName(userName), [vm, userName])

  // (no debug data shown in production)

  // client-side search by student code
  const filteredRows = useMemo(() => {
    const q = String(query ?? '').trim()
    const base = ownedRows
    if (!q) return base
    const lower = q.toLowerCase()
    return base.filter((r: any) => {
      const code = String(r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    })
  }, [query, ownedRows])

  // paging
  const totalElements = filteredRows.length
  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
  const pagedRows = useMemo(() => filteredRows.slice(page * pageSize, (page + 1) * pageSize), [filteredRows, page, pageSize])

  useEffect(() => { setPage(0) }, [query, pageSize, vm.data, userName])

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Duyệt đề cương cuối </h2>
        <div className="flex items-center gap-3">
          <div>
          <button
            aria-label="Xuất danh sách đề cương (Excel)"
            onClick={async () => {
                setExportLoading(true)
                try {
                  const resp = await exportDeCuongAcceptedExcelForTbm()
                  const blob = new Blob([resp.data], { type: resp.headers['content-type'] ?? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
                  // try to extract filename from content-disposition
                  let filename = 'de-cuong-accepted.xlsx'
                  const cd = resp.headers && (resp.headers['content-disposition'] || resp.headers['Content-Disposition'])
                  if (cd) {
                    const m = /filename\*=UTF-8''([^;\n\r]*)/.exec(cd) || /filename=(?:"?)([^";\n\r]*)/.exec(cd)
                    if (m && m[1]) filename = decodeURIComponent(m[1].replace(/"/g, ''))
                  }
                    if (window.navigator && (window.navigator as any).msSaveOrOpenBlob) {
                      ;(window.navigator as any).msSaveOrOpenBlob(blob, filename)
                    } else {
                      const url = window.URL.createObjectURL(blob)
                      const a = document.createElement('a')
                      a.href = url
                      a.download = filename
                      document.body.appendChild(a)
                      a.click()
                      a.remove()
                      window.URL.revokeObjectURL(url)
                    }
                } catch (err) {
                  console.error('Export failed', err)
                  // optionally surface error to user via toast - left minimal here
                } finally {
                  setExportLoading(false)
                }
                }}
                disabled={exportLoading}
                className={[
                  'inline-flex items-center gap-2 px-4 py-2 border rounded-md shadow-sm',
                  exportLoading ? 'bg-emerald-500 text-white border-emerald-500 cursor-wait' : 'bg-emerald-600 text-white border-emerald-600 hover:bg-emerald-700',
                  'disabled:opacity-50 disabled:cursor-not-allowed'
                ].join(' ')}
              >
                <FileSpreadsheet size={16} className={exportLoading ? 'animate-spin' : ''} />
                <span className="whitespace-nowrap">{exportLoading ? 'Đang xuất...' : 'Xuất Excel'}</span>
              </button>
          </div>
             <div className="w-64">
            <input value={query} onChange={e => setQuery(e.target.value)} placeholder="Tìm theo mã sinh viên" className="w-full border rounded px-3 py-2 text-sm" />
          </div>
        </div>
      </div>
      

      <div className="bg-white shadow rounded">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : !pagedRows.length ? (
          <div className="p-6 text-center">Không có dữ liệu</div>
        ) : (
          <table className="min-w-full table-auto">
            <thead>
              <tr className="border-b">
                <th className="text-left px-6 py-4">Mã sinh viên</th>
                <th className="text-left px-6 py-4">Họ và tên</th>
                <th className="text-left px-6 py-4">Tên đề tài</th>
                <th className="text-left px-6 py-4">GV hướng dẫn</th>
                <th className="text-left px-6 py-4">TBM duyệt</th>
                <th className="text-left px-6 py-4">Hoạt động</th>
              </tr>
            </thead>
            <tbody>
              {pagedRows.map((r: any) => (
                <tr key={r.id} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maSinhVien ?? r.maSV}</td>
                  <td className="px-6 py-4">{r.hoTenSinhVien ?? r.hoTen}</td>
                  <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
                  <td className="px-6 py-4">{r.giangVienHuongDan ?? r.giangVienHuongDan}</td>
                  <td className="px-6 py-4">
                    {(() => {
                      const st = vm.renderStatusBadge(r.tbmDuyet)
                      const cls = st.variant === 'success'
                        ? 'bg-emerald-100 text-emerald-800'
                        : st.variant === 'warn'
                          ? 'bg-amber-100 text-amber-800'
                          : st.variant === 'danger'
                            ? 'bg-rose-100 text-rose-800'
                            : 'bg-slate-100 text-slate-700'
                      return <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${cls}`}>{st.label}</span>
                    })()}
                  </td>
                  <td className="px-6 py-4">
                    <div className="flex gap-2">
                      <button
                        title="Xem chi tiết"
                        onClick={() => { setSelected(r); setModalOpen(true) }}
                        className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                        aria-label={`Xem chi tiết ${r.maSinhVien ?? r.maSV}`}
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
      <DeCuongDetailModal open={modalOpen} onClose={() => setModalOpen(false)} item={selected} currentName={currentName} useTbmStatus={true} showChoActions={true} />
    </div>
  )
}
