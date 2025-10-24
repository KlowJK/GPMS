import React, { useEffect } from 'react'
import { useReviewsViewModel } from '../viewmodels/duyet-de-tai'
import { Eye } from 'lucide-react'
import StudentDetail from '../components/StudentDetail'
import { useState } from 'react'

export default function DoAnListPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [selectedMaSV, setSelectedMaSV] = useState<string | null>(null)

  // Show only approved topics
  useEffect(() => {
    vm.setStatusFilter('DA_DUYET')
  }, [])

  const rows = (vm.data?.content ?? [])

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-semibold">Danh sách sinh viên hướng dẫn</h2>
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

        {/* <div className="p-4 border-t flex items-center justify-center">
          <div className="flex items-center gap-3">
            <button className="px-3 py-1 border rounded">«</button>
            <button className="px-3 py-1 border rounded bg-slate-200">1</button>
            <button className="px-3 py-1 border rounded">2</button>
            <button className="px-3 py-1 border rounded">3</button>
            <span className="px-3 py-1">...</span>
            <button className="px-3 py-1 border rounded">10</button>
            <button className="px-3 py-1 border rounded">»</button>
          </div>
        </div> */}
      </div>
      <StudentDetail open={!!selectedMaSV} maSV={selectedMaSV ?? undefined} onClose={() => setSelectedMaSV(null)} />
    </div>
  )
}
