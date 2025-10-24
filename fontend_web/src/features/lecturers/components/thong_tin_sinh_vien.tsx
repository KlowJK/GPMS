import React from 'react'

export default function ReportHeader({ student, onClose }: { student: any; onClose?: () => void }) {
  return (
    <div className="flex items-start gap-6 mb-6">
      <div className="flex items-center gap-4">
        <div className="w-20 h-20 rounded-full bg-slate-100 flex items-center justify-center text-2xl font-semibold text-slate-700">{(student?.hoTen || 'SV').split(' ').slice(-1)[0].slice(0,1)}</div>
        <div>
          <div className="text-lg font-semibold">{student?.hoTen}</div>
          <div className="text-sm text-slate-500">Mã SV: <span className="font-medium text-slate-700">{student?.maSV}</span></div>
          <div className="mt-2">
            <span className="inline-block px-3 py-1 rounded-full bg-amber-100 text-amber-700 text-sm">Sinh viên</span>
          </div>
        </div>
      </div>

      <div className="flex-1">
        <div className="grid grid-cols-3 gap-4">
          <div>
            <div className="text-xs text-slate-500">Số điện thoại</div>
            <div className="font-medium">{student?.soDienThoai ?? '—'}</div>
          </div>
          <div>
            <div className="text-xs text-slate-500">Ngày sinh</div>
            <div className="font-medium">{student?.ngaySinh ?? '—'}</div>
          </div>
          <div>
            <div className="text-xs text-slate-500">Ngành</div>
            <div className="font-medium">{(student?.tenNganh ?? student?.nganh) || '—'}</div>
          </div>
        </div>
      </div>
    </div>
  )
}
