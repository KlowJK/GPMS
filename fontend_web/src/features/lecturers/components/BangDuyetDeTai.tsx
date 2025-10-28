import React from 'react'
import { Check, Eye, Trash } from 'lucide-react'
import type { XetDuyetItem } from '../models/DanhSachDuyetModels'

export default function BangDuyetDeTai({ rows, isLoading, onApprove, onReject, onView, approvingId }: { rows: XetDuyetItem[]; isLoading: boolean; onApprove: (id: string) => void; onReject: (id: string) => void; onView: (url?: string | null) => void; approvingId?: string | null }) {
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
          <th className="text-left px-6 py-4">Hành động</th>
        </tr>
      </thead>
      <tbody>
        {rows.map(r => (
          <tr key={r.idDeTai} className="border-b hover:bg-slate-50">
            <td className="px-6 py-4 font-medium">{r.maSV}</td>
            <td className="px-6 py-4">{r.hoTen}</td>
            <td className="px-6 py-4">{r.tenLop}</td>
            <td className="px-6 py-4">{r.tenDeTai}</td>
            <td className="px-6 py-4">
              {r.trangThai === 'CHO_XET_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-yellow-100 text-yellow-800">Chờ xét duyệt</span>)}
              {r.trangThai === 'DA_DUYET' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-green-100 text-green-800">Đã duyệt</span>)}
              {r.trangThai === 'TU_CHOI' && (<span className="inline-block px-3 py-1 rounded-full text-xs bg-red-100 text-red-800">Từ chối</span>)}
            </td>
            <td className="px-6 py-4">
              <div className="flex items-center gap-3">
                {r.trangThai === 'CHO_XET_DUYET' ? (
                  approvingId === r.idDeTai ? (
                    <div className="w-9 h-9 flex items-center justify-center text-green-600">...</div>
                  ) : (
                    <button title="Duyệt" onClick={() => onApprove(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-green-50 text-green-600 rounded-full"><Check size={16} /></button>
                  )
                ) : (
                  <div className="w-9 h-9" />
                )}

                <div className="w-9 h-9 flex items-center justify-center">
                  <button title="Xem" onClick={() => onView(r.tongQuanDeTaiUrl)} className="p-2 bg-slate-50 text-sky-600 rounded-full flex items-center justify-center"><Eye size={16} /></button>
                </div>

                {r.trangThai === 'CHO_XET_DUYET' ? (
                  <button title="Từ chối" onClick={() => onReject(r.idDeTai)} className="w-9 h-9 flex items-center justify-center bg-red-50 text-red-600 rounded-full"><Trash size={16} /></button>
                ) : (
                  <div className="w-9 h-9" />
                )}
              </div>
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}
