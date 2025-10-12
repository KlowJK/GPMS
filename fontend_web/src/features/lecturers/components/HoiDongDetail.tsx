import React from 'react'
import type { AxiosError } from 'axios'

export default function HoiDongDetail({ open, onClose, data, isLoading, isError }: { open: boolean; onClose: () => void; data?: any; isLoading: boolean; isError: boolean | AxiosError }) {
  if (!open) return null

  const fmt = (v?: string) => {
    if (!v) return '—'
    try {
      const d = new Date(v)
      return isNaN(d.getTime()) ? v : d.toLocaleString()
    } catch {
      return v
    }
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md w-[900px] max-h-[88vh] overflow-auto shadow-lg">
        <div className="flex items-center justify-between px-5 py-3 bg-sky-600 rounded-t-md text-white">
          <div className="flex items-center gap-3">
            <h3 className="text-lg font-semibold">Chi tiết hội đồng</h3>
            <div className="text-sm opacity-90">{data?.maHoiDong ? `#${data.maHoiDong}` : ''}</div>
          </div>
          <div>
            <button onClick={onClose} className="text-white text-2xl leading-none">×</button>
          </div>
        </div>

        <div className="p-6">
          {isLoading ? (
            <div className="p-6 text-center">Đang tải chi tiết...</div>
          ) : isError ? (
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
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-sm text-slate-500">Chủ tịch</div>
                  <div className="mt-1 font-medium">{data.chuTri ?? '—'}</div>
                </div>
                <div>
                  <div className="text-sm text-slate-500">Thư ký</div>
                  <div className="mt-1 font-medium">{data.thuKy ?? '—'}</div>
                </div>
              </div>

              <div>
                <div className="text-sm text-slate-500 mb-2">Giảng viên phản biện</div>
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
                        <th className="text-left px-3 py-2">Tên đề tài</th>
                        <th className="text-left px-3 py-2">GVHD</th>
                        <th className="text-left px-3 py-2">Hành động</th>
                      </tr>
                    </thead>
                    <tbody>
                      {(data.sinhVienList || []).map((s: any) => (
                        <tr key={s.maSV} className="border-b hover:bg-slate-50">
                          <td className="px-3 py-2 align-top">{s.maSV}</td>
                          <td className="px-3 py-2 align-top">{s.hoTen}</td>
                          <td className="px-3 py-2 align-top">{s.lop}</td>
                          <td className="px-3 py-2 align-top">{s.tenDeTai}</td>
                          <td className="px-3 py-2 align-top">{s.gvhd}</td>
                          <td className="px-3 py-2 align-top">
                            <div className="flex gap-2">
                              <button className="px-2 py-1 text-sm border rounded text-sky-600">Xem</button>
                              {s.cvUrl && (
                                <a className="px-2 py-1 text-sm border rounded text-slate-700" href={s.cvUrl} target="_blank" rel="noreferrer">CV</a>
                              )}
                            </div>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              <div className="flex justify-end">
                <button onClick={onClose} className="px-4 py-2 rounded border text-slate-700">Đóng</button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
