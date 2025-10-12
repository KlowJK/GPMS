import React from 'react'
import type { AxiosError } from 'axios'

export default function HoiDongDetail({ open, onClose, data, isLoading, isError }: { open: boolean; onClose: () => void; data?: any; isLoading: boolean; isError: boolean | AxiosError }) {
  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md p-6 w-[760px] max-h-[80vh] overflow-auto">
        <div className="flex justify-between items-start mb-4">
          <h3 className="text-lg font-semibold">Chi tiết hội đồng</h3>
          <button onClick={onClose} className="text-sm text-slate-500">Đóng</button>
        </div>

        {isLoading ? (
          <div className="p-6 text-center">Đang tải chi tiết...</div>
        ) : isError ? (
          <div className="p-4 text-red-600">Lỗi khi tải chi tiết</div>
        ) : !data ? (
          <div className="p-4">Không có dữ liệu</div>
        ) : (
          <div className="space-y-4">
            <div>
              <div className="text-sm text-slate-600">Tên hội đồng</div>
              <div className="font-medium">{data.tenHoiDong}</div>
            </div>

            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-sm text-slate-600">Thời gian bắt đầu</div>
                <div>{data.thoiGianBatDau}</div>
              </div>
              <div>
                <div className="text-sm text-slate-600">Thời gian kết thúc</div>
                <div>{data.thoiGianKetThuc}</div>
              </div>
            </div>

            <div>
              <div className="text-sm text-slate-600">Chủ tịch</div>
              <div>{data.chuTri ?? '—'}</div>
            </div>

            <div>
              <div className="text-sm text-slate-600">Thư ký</div>
              <div>{data.thuKy ?? '—'}</div>
            </div>

            <div>
              <div className="text-sm text-slate-600 mb-2">Giảng viên phản biện</div>
              <ul className="list-disc pl-5">
                {(data.giangVienPhanBien || []).map((g: string, i: number) => (
                  <li key={i}>{g}</li>
                ))}
              </ul>
            </div>

            <div>
              <div className="text-sm text-slate-600 mb-2">Danh sách sinh viên</div>
              <table className="min-w-full table-auto text-sm">
                <thead>
                  <tr className="border-b">
                    <th className="text-left px-3 py-2">Mã SV</th>
                    <th className="text-left px-3 py-2">Họ và tên</th>
                    <th className="text-left px-3 py-2">Lớp</th>
                    <th className="text-left px-3 py-2">Tên đề tài</th>
                    <th className="text-left px-3 py-2">GVHD</th>
                  </tr>
                </thead>
                <tbody>
                  {(data.sinhVienList || []).map((s: any) => (
                    <tr key={s.maSV} className="border-b hover:bg-slate-50">
                      <td className="px-3 py-2">{s.maSV}</td>
                      <td className="px-3 py-2">{s.hoTen}</td>
                      <td className="px-3 py-2">{s.lop}</td>
                      <td className="px-3 py-2">{s.tenDeTai}</td>
                      <td className="px-3 py-2">{s.gvhd}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
