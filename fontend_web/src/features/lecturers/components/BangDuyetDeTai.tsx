import React from 'react'
import { Check, Eye, Trash, FileText } from 'lucide-react'
import type { XetDuyetItem } from '../models/DanhSachDuyetModels'

export default function BangDuyetDeTai({ rows, isLoading, onApprove, onReject, onView, onViewCv, approvingId }: { rows: XetDuyetItem[]; isLoading: boolean; onApprove: (id: string) => void; onReject: (id: string) => void; onView: (url?: string | null) => void; onViewCv?: (url?: string | null) => void; approvingId?: string | null }) {
  if (isLoading) return <div className="p-6 text-center">Đang tải...</div>

  if (!rows.length) return <div className="p-6 text-center">Không có dữ liệu</div>

  return (
    <table className="min-w-full table-auto">
      <thead>
        <tr className="border-b">
          <th className="text-left px-6 py-4">Mã sinh viên</th>
          <th className="text-left px-6 py-4">Họ và tên</th>
          <th className="text-left px-6 py-4">Lớp</th>
          <th className="text-left px-6 py-4">Tên đề tài</th>
          <th className="text-left px-6 py-4">Trạng thái</th>
          <th className="text-center px-6 py-4">Hành động</th>
        </tr>
      </thead>
      <tbody>
        {rows.map(r => (
          <tr key={r.idDeTai} className="border-b hover:bg-slate-50">
            <td className="px-6 py-4 font-medium">{r.maSV}</td>
            <td className="px-6 py-4">{r.hoTen}</td>
            <td className="px-6 py-4">{r.tenLop}</td>
            <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{r.tenDeTai}</td>
            <td className="px-6 py-4">
              {r.trangThai === 'CHO_XET_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-yellow-100 text-yellow-800">Chờ xét duyệt</span>)}
              {r.trangThai === 'DA_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-green-100 text-green-800">Đã duyệt</span>)}
              {r.trangThai === 'TU_CHOI' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-red-100 text-red-800">Từ chối</span>)}
            </td>
            <td className="px-6 py-4 text-center align-middle">
              <div className="flex items-center justify-center gap-3">
                {/* Approve */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.trangThai === 'CHO_XET_DUYET' ? (
                      approvingId === r.idDeTai ? (
                      <div className="w-9 h-9 flex items-center justify-center text-green-600">...</div>
                    ) : (
                      <button title="Duyệt" onClick={() => onApprove(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-emerald-50 text-emerald-600 rounded-full hover:bg-emerald-100 transition">
                        <Check size={16} />
                      </button>
                    )
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>

                {/* View proposal */}
                <div className="w-9 h-9 flex items-center justify-center">
                  <button title="Xem" onClick={() => onView(r.tongQuanDeTaiUrl)} className="w-9 h-9 flex items-center justify-center bg-slate-50 text-sky-600 rounded-full hover:bg-sky-100 transition"><Eye size={16} /></button>
                </div>

                {/* View CV (optional) */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.duongDanCv ? (
                    <button title="Xem CV" onClick={() => onViewCv ? onViewCv(r.duongDanCv) : window.open(r.duongDanCv as string, '_blank')} className="w-9 h-9 flex items-center justify-center bg-slate-50 text-sky-600 rounded-full hover:bg-sky-100 transition"><FileText size={16} /></button>
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>

                {/* Reject */}
                <div className="w-9 h-9 flex items-center justify-center">
                  {r.trangThai === 'CHO_XET_DUYET' ? (
                    <button title="Từ chối" onClick={() => onReject(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-rose-50 text-rose-600 rounded-full hover:bg-rose-100 transition"><Trash size={16} /></button>
                  ) : (
                    <div className="w-9 h-9" />
                  )}
                </div>
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
