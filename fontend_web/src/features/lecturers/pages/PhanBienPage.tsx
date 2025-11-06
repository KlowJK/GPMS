import React, { useEffect, useState } from 'react'
import usePhanBienViewModel from '../viewmodels/PhanBienViewmodels'
import { useAuth } from '@features/auth/useAuth'
import { FileText } from 'lucide-react'
// (useState imported above)
import DeCuongDetailModal from '../components/DeCuongPhanBien'

export default function PhanBienPage() {
  const vm = usePhanBienViewModel()
  const { user } = useAuth()
  const [modalOpen, setModalOpen] = useState(false)
  const [selected, setSelected] = useState<any | null>(null)
  const [query, setQuery] = useState<string>('')

  // determine a reasonable display name from the logged in user
  const currentName = (user?.fullName ?? user?.name ?? user?.hoTen ?? user?.username ?? '').toString()
  // use viewmodel with current reviewer name to get visible + paged items
  const vmWithName = usePhanBienViewModel(currentName)

  // Ensure client-side page size stays at 10 for UI even if server returns up to 1000
  // (server fetch size is controlled in the viewmodel default initialSize)
  useEffect(() => {
    try {
      vmWithName.setClientSize(10);
      vmWithName.setClientPage(0);
    } catch (e) {}
    // run once on mount
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  // reset to first page in viewmodel when visible items, clientSize or query changes
  useEffect(() => { vmWithName.setClientPage(0) }, [vmWithName.visibleItems.length, vmWithName.clientSize, query])

  // dev-time logging to help diagnose empty lists
  useEffect(() => {
    // eslint-disable-next-line no-console
    console.log('[PhanBienPage] raw items:', vm.items)
    // eslint-disable-next-line no-console
    console.log('[PhanBienPage] visibleItems for current user:', vmWithName.visibleItems)
  }, [vm.items, vmWithName.visibleItems])

  // derive client-side filtered + paged items from vmWithName.visibleItems
  const sourceItems = vmWithName.visibleItems ?? []
  const filteredItems = query ? sourceItems.filter((it: any) => (((it.maSinhVien ?? it.maSV ?? '') + '').toLowerCase().includes(query.toLowerCase()))) : sourceItems
  const totalElements = filteredItems.length
  const totalPages = Math.max(1, Math.ceil(totalElements / vmWithName.clientSize))
  const pagedItems = filteredItems.slice(vmWithName.clientPage * vmWithName.clientSize, (vmWithName.clientPage + 1) * vmWithName.clientSize)



  return (
    <div className="min-h-[calc(100vh-80px)]">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Phản biện</h1>
        <div className="w-60">
          <input
            value={query}
            onChange={e => setQuery(e.target.value)}
            placeholder="Tìm theo mã sinh viên"
            className="w-full border rounded px-3 py-2 text-sm"
          />
        </div>
      </div>

      <div className="bg-white shadow rounded p-6">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : !(vmWithName.visibleItems && vmWithName.visibleItems.length) ? (
          <div className="p-6 text-center text-slate-500">Chưa có nhiệm vụ phản biện cho bạn</div>
        ) : (
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-slate-50">
                <th className="px-3 py-2 text-left">Mã SV</th>
                <th className="px-3 py-2 text-left">Họ và tên</th>
                <th className="px-3 py-2 text-left">Đề tài</th>
                <th className="px-3 py-2 text-left">Giảng viên hướng dẫn</th>
                <th className="px-3 py-2 text-left">Trạng thái</th>
                <th className="px-3 py-2 text-left">Hành động</th>
              </tr>
            </thead>
              <tbody>
              {pagedItems.map((it: any) => (
                <tr key={it.id} className="border-b hover:bg-slate-50">
                  <td className="px-3 py-2">{it.maSinhVien}</td>
                  <td className="px-3 py-2">{it.hoTenSinhVien}</td>
                  <td className="px-3 py-2">{it.tenDeTai}</td>
                  <td className="px-3 py-2">{it.giangVienHuongDan ?? it.giangVienPhanBien}</td>
                  <td className="px-3 py-2">
                    {(() => {
                      const st = vmWithName.renderStatusBadge(it.gvPhanBienDuyet)
                      const cls = st.variant === 'success' ? 'bg-emerald-100 text-emerald-800' : st.variant === 'warn' ? 'bg-amber-100 text-amber-800' : st.variant === 'danger' ? 'bg-rose-100 text-rose-800' : 'bg-slate-100 text-slate-700'
                      return <span className={`inline-flex items-center px-2 py-1 rounded-full text-xs font-medium ${cls}`}>{st.label}</span>
                    })()}
                  </td>
                  <td className="px-3 py-2">
                    <div className="flex gap-2">
                      <button
                        title="Xem chi tiết"
                        onClick={() => { setSelected(it); setModalOpen(true) }}
                        className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                        aria-label={`Xem chi tiết ${it.maSinhVien}`}
                      >
                        <FileText size={16} />
                        <span>Duyệt đề cương PB</span>
                      </button>
                    </div>
                   </td>
                 </tr>
               ))}
               </tbody>
           </table>
         )}
        {/* Debug panel removed - no debug output in production UI */}
        {/* Pagination controls */}
        {(() => {
          if (!totalPages || totalPages <= 1) return null
          const showPageButtons = totalPages <= 10
          const pages = showPageButtons ? Array.from({ length: totalPages }).map((_, i) => i) : []
          return (
            <div className="p-4 border-t flex items-center justify-between">
              <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {vmWithName.clientPage + 1} / {totalPages}</div>
              <div className="flex items-center gap-2">
                <button aria-label="previous page" disabled={vmWithName.clientPage <= 0} onClick={() => vmWithName.setClientPage(Math.max(0, vmWithName.clientPage - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                {showPageButtons ? (
                  pages.map(p => (
                    <button key={p} onClick={() => vmWithName.setClientPage(p)} className={["px-3 py-1 rounded", p === vmWithName.clientPage ? 'bg-sky-600 text-white' : 'bg-white border'].join(' ')}>{p + 1}</button>
                  ))
                ) : null}
                <button aria-label="next page" disabled={vmWithName.clientPage >= totalPages - 1} onClick={() => vmWithName.setClientPage(Math.min(totalPages - 1, vmWithName.clientPage + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
              </div>
            </div>
          )
        })()}
      </div>
      <DeCuongDetailModal open={modalOpen} onClose={() => setModalOpen(false)} item={selected} currentName={currentName} showChoActions={true} />
    </div>
  )
}

