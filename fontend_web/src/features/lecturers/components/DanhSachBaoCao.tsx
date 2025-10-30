import React from 'react'

export default function ReportVersionItem({
  v,
  loadingId,
  onApprove,
  onReject,
  isApproved,
  isRejected,
}: {
  v: any
  loadingId: string | number | null
  onApprove: (v: any) => void
  onReject: (v: any) => void
  isApproved: (raw: any) => boolean
  isRejected: (raw: any) => boolean
}) {
  return (
    <div className="border rounded flex">
      <div className={`w-2 ${isApproved(v.trangThai) ? 'bg-emerald-500' : isRejected(v.trangThai) ? 'bg-rose-600' : 'bg-sky-600'}`} />
      <div className="p-4 flex-1">
        <div className="flex items-start justify-between">
          <div>
            <div className="font-medium">{v.title || v.tenDeTai || 'Báo cáo'}</div>
            <div className="text-xs text-slate-500">Ngày nộp: {v.ngayNop}{v.phienBan != null ? ` · Phiên bản: ${v.phienBan}` : ''}</div>
          </div>
          <div className="text-right">
            {/* Only show score when the report is approved and a score exists */}
            {(v.diem != null && isApproved(v.trangThai)) ? (<div className="text-sm font-semibold">Điểm: {v.diem}</div>) : null}
            <div className="mt-2">
              {isApproved(v.trangThai) ? (
                <div className="inline-block px-3 py-1 rounded-full bg-emerald-100 text-emerald-700 text-sm">Đã duyệt</div>
              ) : isRejected(v.trangThai) ? (
                <div className="inline-block px-3 py-1 rounded-full bg-rose-600 text-white text-sm">Từ chối</div>
              ) : (
                <div className="flex gap-2">
                  <button disabled={loadingId === v.id} onClick={() => onApprove(v)} className="px-3 py-1 rounded-full bg-emerald-500 text-white text-sm">Duyệt</button>
                  <button disabled={loadingId === v.id} onClick={() => onReject(v)} className="px-3 py-1 rounded-full bg-rose-600 text-white text-sm">Từ chối</button>
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="mt-3">
          <div className="text-sm">File: {v.fileUrl ? (<a href={v.fileUrl} className="text-sky-600 underline" target="_blank" rel="noreferrer">{v.fileName || v.fileUrl}</a>) : (<span className="text-slate-500">Không có file</span>)}</div>
          { (Array.isArray(v.nhanXets) && v.nhanXets.length > 0) || v.nhanXet ? (
            <div className={`mt-2 p-3 rounded text-sm ${isRejected(v.trangThai) ? 'bg-rose-50 border border-rose-100 text-rose-700' : isApproved(v.trangThai) ? 'bg-emerald-50 border border-emerald-100 text-emerald-700' : 'bg-slate-50 border border-slate-100 text-slate-700'}`}>
              <div className="font-medium text-sm">Nhận xét</div>
              <div className="mt-2">{(Array.isArray(v.nhanXets) && v.nhanXets.length > 0) ? (v.nhanXets[v.nhanXets.length - 1].nhanXet) : (v.nhanXet ?? 'Không có nội dung')}</div>
            </div>
          ) : null }
        </div>
      </div>
    </div>
  )
}
