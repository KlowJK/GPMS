import React from 'react'
import { formatDateTime } from '@shared/utils/format'

export default function DiaryProgressModal({ open, onClose, data }: { open: boolean; onClose: () => void; data: any[] | null }) {
  if (!open) return null

  // compute summary counts
  const total = Array.isArray(data) ? data.length : 0
  const completed = Array.isArray(data) ? data.filter(d => String(d.trangThaiNhatKy ?? d.trangThai ?? '').toUpperCase().includes('HOANTHANH') || String(d.trangThaiNhatKy ?? '').toUpperCase().includes('DANOP')).length : 0
  const late = 0 // backend may return late info
  const percent = total > 0 ? Math.round((completed / total) * 100) : 0

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-11/12 md:w-3/4 lg:w-2/3 bg-white rounded shadow-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Tiến độ</h3>
          <button onClick={onClose} className="text-slate-500">✕</button>
        </div>

        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{total}</div>
            <div className="text-sm text-slate-600">Tuần nộp đúng hạn</div>
          </div>
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{late}</div>
            <div className="text-sm text-slate-600">Tuần nộp muộn</div>
          </div>
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{percent}%</div>
            <div className="text-sm text-slate-600">Hoàn thành</div>
          </div>
        </div>

        <div>
          <div className="text-sm text-slate-700 mb-3">Tiến độ từng tuần:</div>
          <div className="space-y-4">
            {Array.isArray(data) && data.map((w: any) => (
              <div key={w.tuan || w.id} className="p-4 bg-white border rounded flex">
                <div className="w-3.5 bg-sky-600 mr-4" />
                <div className="flex-1">
                  <div className="text-sm text-slate-600 font-semibold">Tuần: {w.tuan}</div>
                  <div className="text-xs text-slate-500">Thời gian: {formatDateTime(w.ngayBatDau)} - {formatDateTime(w.ngayKetThuc)}</div>
                  <div className="mt-2 text-sm text-slate-700">Nội dung công việc đã thực hiện: <span className="font-medium">{w.noiDung ?? w.content ?? ''}</span></div>
                  <div className="mt-2 text-sm">Kết quả đã thực hiện: {w.fileUrl ? <a href={w.fileUrl} className="text-sky-600 underline">{w.fileUrl.split('/').pop()}</a> : 'Không'}</div>
                </div>
                <div className="flex items-end">
                  <button className="px-3 py-1 bg-sky-600 text-white rounded">Nhận xét</button>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 rounded bg-gray-200">Quay lại</button>
          <button className="px-4 py-2 rounded bg-sky-600 text-white">Lưu</button>
        </div>
      </div>
    </div>
  )
}
