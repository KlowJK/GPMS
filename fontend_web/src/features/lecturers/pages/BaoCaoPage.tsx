import React, { useEffect, useState } from 'react'
import { useReportsViewModel } from '../viewmodels/BaoCaoViewmodel'
import { FileText } from 'lucide-react'
import ReportDetail from '../components/BaoCaoChiTiet'

// Map raw status keys to friendly label + color classes
function getStatusBadge(raw?: any) {
  const k = (String(raw ?? '') || '').normalize('NFD').replace(/\p{Diacritic}/gu, '').replace(/Đ/g, 'D').replace(/đ/g, 'd').toUpperCase().replace(/\s+|_|-|\./g, '')
  let label = String(raw ?? '')
  let classes = 'inline-block px-3 py-1 rounded-full text-xs bg-slate-100 text-slate-700'

  if (!k || k === '') {
    label = 'Chưa xử lý'
    classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700'
    return { label, classes }
  }

  if (k.includes('TUCHOI') || k.includes('TUCH')) {
    label = 'Từ chối'
    classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-rose-50 text-rose-700'
    return { label, classes }
  }

  if (k.includes('DADUYET') || k === 'DA' || k.includes('DANOP')) {
    label = 'Đã duyệt'
    classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700'
    return { label, classes }
  }

  if (k.includes('CHO') || k.includes('CHOXET') || k.includes('CHODUYET')) {
    label = 'Chờ duyệt'
    classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-amber-50 text-amber-700'
    return { label, classes }
  }

  return { label, classes }
}

export default function BaoCao() {
  return <Inner />
}

function Inner() {
  const vm = useReportsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)

  // use viewmodel for client-side search/paging

  // ensure UI resets to first server page when search/pageSize or source data changes
  useEffect(() => { vm.setPage(0) }, [vm.data, vm.size, vm.search])

  // Do not force a status filter on mount — show all reports by default

  // use viewmodel's derived server-side page rows (with optional client-side filtering)
  const pagedRows = vm.pagedRows ?? []
  // deduplicate by topic (idDeTai or id) keeping only the item with the largest phienBan
  const dedupedRows = (() => {
    const m = new Map<string | number, any>()
    for (const it of pagedRows) {
      const key = it.idDeTai ?? it.id ?? ''
      if (!key) continue
      const existing = m.get(key)
      const a = Number(it.phienBan ?? -Infinity)
      const b = Number(existing?.phienBan ?? -Infinity)
      if (!existing || a > b) m.set(key, it)
    }
    // preserve ordering by phienBan desc then createdAt desc for predictability
    return Array.from(m.values()).sort((x: any, y: any) => {
      const pa = Number(x?.phienBan ?? -Infinity)
      const pb = Number(y?.phienBan ?? -Infinity)
      if (pb !== pa) return pb - pa
      const da = x?.createdAt ? Date.parse(String(x.createdAt)) : 0
      const db = y?.createdAt ? Date.parse(String(y.createdAt)) : 0
      return db - da
    })
  })()
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
                 <th className="text-left px-6 py-4">Tên đề tài</th>
                <th className="text-left px-6 py-4">Trạng thái</th>
                <th className="text-left px-6 py-4">Hành động</th>
              </tr>
            </thead>
            <tbody>
              {dedupedRows.map((r: any) => (
                <tr key={r.idDeTai ?? r.id} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maSinhVien ?? r.maSV ?? r.maSV}</td>
                  <td className="px-6 py-4">{r.tenSinhVien ?? r.hoTen ?? '—'}</td>
                  <td className="px-6 py-4">{r.lop ?? r.tenLop ?? '—'}</td>
                  <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
                  <td className="px-6 py-4">
                    {(() => {
                      const s = getStatusBadge(r.trangThai)
                      return <span className={s.classes}>{s.label}</span>
                    })()}
                  </td>
                  
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <button
                        title="Xem chi tiết"
                        onClick={() => setSelectedMaSV(r.maSinhVien ?? r.maSV ?? null)}
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
              <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {vm.page + 1} / {totalPages}</div>
              <div className="flex items-center gap-2">
                <button aria-label="previous page" disabled={vm.page <= 0} onClick={() => vm.setPage(Math.max(0, vm.page - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                {showPageButtons ? (
                  pages.map(p => (
                    <button key={p} onClick={() => vm.setPage(p)} className={["px-3 py-1 rounded", p === vm.page ? 'bg-sky-600 text-white' : 'bg-white border'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={vm.page >= totalPages - 1} onClick={() => vm.setPage(Math.min(totalPages - 1, vm.page + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}

  <ReportDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
