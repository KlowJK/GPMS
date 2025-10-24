import React, { useEffect, useState } from 'react'
import { useReviewsViewModel } from '../viewmodels/duyet-de-tai'
import { Eye } from 'lucide-react'
import ReportDetail from '../components/bao_cao_chi_tiet'

export default function BaoCao() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)

  // For report page show only approved topics by default
  useEffect(() => {
    vm.setStatusFilter('DA_DUYET')
  }, [])

  const rows = (vm.data?.content ?? [])

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Báo cáo - Danh sách đề tài</h2>
        <div className="w-64">
          <input value={vm.search} onChange={e => vm.setSearch(e.target.value)} placeholder="Tìm theo mã sinh viên" className="w-full border rounded px-3 py-2 text-sm" />
        </div>
      </div>

      <div className="bg-white shadow rounded">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
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
              {rows.map((r: any) => (
                <tr key={r.idDeTai} className="border-b hover:bg-slate-50">
                  <td className="px-6 py-4 font-medium">{r.maSV}</td>
                  <td className="px-6 py-4">{r.hoTen}</td>
                  <td className="px-6 py-4">{r.tenLop}</td>
                  <td className="px-6 py-4">{r.soDienThoai ?? '—'}</td>
                  <td className="px-6 py-4">{r.tenDeTai}</td>
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-9 h-9 flex items-center justify-center">
                        <button title="Xem" onClick={() => setSelectedMaSV(r.maSV)} className="p-2 bg-slate-50 text-sky-600 rounded-full flex items-center justify-center"><Eye size={16} /></button>
                      </div>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

  <ReportDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
