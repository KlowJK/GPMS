import React, { useEffect } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import useHoiDongViewModel, { useHoiDongDetailViewModel } from '../viewmodels/HoiDongViewmodels'
import HoiDongScoreModal from '../components/HoiDongScoreModal'
import { useState } from 'react'

export default function HoiDongDetailPage() {
  const { id } = useParams()
  const navigate = useNavigate()
  const detailVm = useHoiDongDetailViewModel()

  useEffect(() => {
    if (!id) return
    const n = Number(id)
    if (!isNaN(n)) detailVm.setDetailId(n)
    return () => detailVm.setDetailId(null)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  const fmt = (v?: string) => {
    if (!v) return '—'
    try {
      const d = new Date(v)
      return isNaN(d.getTime()) ? v : d.toLocaleString()
    } catch {
      return v
    }
  }

  const data = detailVm.data
  const [scoreOpen, setScoreOpen] = useState(false)
  const [selectedStudent, setSelectedStudent] = useState<any | null>(null)

  function openScore(s: any) {
    setSelectedStudent(s)
    setScoreOpen(true)
  }

  return (
    <div className="min-h-[calc(100vh-80px)]">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-4">
          <h1 className="text-2xl font-semibold">Chi tiết hội đồng</h1>
        </div>
      </div>

      <div className="bg-white shadow rounded-md p-6">
        {detailVm.isLoading ? (
          <div className="p-6 text-center">Đang tải chi tiết...</div>
        ) : detailVm.isError ? (
          <div className="p-4 text-red-600">Lỗi khi tải chi tiết</div>
        ) : !data ? (
          <div className="p-4">Không có dữ liệu</div>
        ) : (
          <div className="space-y-6">
            <div className="grid grid-cols-3 gap-4">
              <div>
                <div className="text-sm text-slate-500">Tên hội đồng</div>
                <div className="font-medium text-slate-800">{data.tenHoiDong}</div>
              </div>

              <div>
                <div className="text-sm text-slate-500">Thời gian bắt đầu</div>
                <div className="text-slate-700">{fmt(data.thoiGianBatDau)}</div>
              </div>

              <div>
                <div className="text-sm text-slate-500">Thời gian kết thúc</div>
                <div className="text-slate-700">{fmt(data.thoiGianKetThuc)}</div>
              </div>
            <div>
              <div className="text-sm text-slate-500">Địa chỉ</div>
              <div className="mt-1 font-medium">{(data.diaChi ?? data.diaDiem) ? (data.diaChi ?? data.diaDiem) : 'Chưa có địa chỉ'}</div>
            </div>
                <div>
                <div className="text-sm text-slate-500">Chủ tịch</div>
                <div className="mt-1 font-medium">{data.chuTich ?? '—'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Thư ký</div>
                <div className="mt-1 font-medium">{data.thuKy ?? '—'}</div>
              </div>
            </div>
            <div>
              <div className="text-sm text-slate-500 mb-2">Các thành viên</div>
              <div className="flex flex-wrap gap-2">
                {(data.giangVienPhanBien || []).map((g: string, i: number) => (
                  <span key={i} className="px-3 py-1 bg-slate-100 text-slate-800 rounded-full text-sm">{g}</span>
                ))}
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between">
                <div className="text-sm text-slate-500 mb-2">Danh sách sinh viên</div>
                <div className="text-sm text-slate-400">Tổng: {(data.sinhVienList || []).length}</div>
              </div>

              <div className="overflow-x-auto border rounded">
                <table className="min-w-full table-auto text-sm">
                  <thead>
                    <tr className="bg-slate-50">
                      <th className="text-left px-3 py-2">Mã SV</th>
                      <th className="text-left px-3 py-2">Họ và tên</th>
                      <th className="text-left px-3 py-2">Lớp</th>
                      <th className="text-left px-3 py-2">Bộ môn</th>
                      <th className="text-left px-3 py-2">Tên đề tài</th>
                      <th className="text-left px-3 py-2">GVHD</th>
                      <th className="text-left px-3 py-2">Hoạt động</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data.sinhVienList || []).map((s: any) => (
                      <tr key={s.maSV} className="border-b hover:bg-slate-50">
                        <td className="px-3 py-2 align-top">{s.maSV}</td>
                        <td className="px-3 py-2 align-top">{s.hoTen}</td>
                        <td className="px-3 py-2 align-top">{s.lop}</td>
                        <td className="px-3 py-2 align-top">{s.boMon ?? s.idBoMon ?? '—'}</td>
                        <td className="px-3 py-2 align-top">{s.tenDeTai}</td>
                        <td className="px-3 py-2 align-top">{s.gvhd}</td>
                         <td className="px-3 py-2 align-top">
                          <button onClick={() => openScore(s)} className="px-2 py-1 text-sm border rounded text-sky-600">Chấm điểm</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
            <div className="flex justify-end">
              <button onClick={() => navigate(-1)} className="flex items-center px-3 py-1 border rounded">Quay lại</button>
            </div>
          </div>
        )}
      </div>
        {/* Score modal for selected student */}
        <HoiDongScoreModal
          open={scoreOpen}
          onClose={() => { setScoreOpen(false); setSelectedStudent(null) }}
          student={selectedStudent || undefined}
          members={(() => {
            if (!data) return []
            const parents = [] as string[]
            if (data.chuTich) parents.push(data.chuTich)
            if (data.thuKy) parents.push(data.thuKy)
            if (Array.isArray(data.giangVienPhanBien)) parents.push(...data.giangVienPhanBien)
            // dedupe
            return Array.from(new Set(parents))
          })()}
        />
    </div>
  )
}
