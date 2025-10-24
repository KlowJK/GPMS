import React from 'react'
import useReportDetailViewModel from '../viewmodels/bao-cao-chi-tiet'
import ReportHeader from './thong_tin_sinh_vien'
import ReportVersionItem from './danh_sach_bao_cao'

export default function ReportDetail({ open, maSV, onClose }: { open: boolean; maSV?: string | null; onClose: () => void }) {
  if (!open) return null

  // Default empty student object (no mock/demo data)
  const defaultStudent = {
    maSV: maSV ?? '',
    hoTen: '',
    email: '',
    soDienThoai: '',
    ngaySinh: '',
    tenNganh: '',
    gioiTinh: '',
    tenLop: '',
  }

  // viewmodel: encapsulate data + mutations
  const vm = useReportDetailViewModel(maSV)

  // student: prefer API result when available, otherwise fallback to empty object
  const student = vm.student ?? defaultStudent

  // displayProposals and counts come from the viewmodel
  const displayProposals = vm.displayProposals ?? []
  const versionCount = vm.versionCount

  // status helpers (same as StudentDetail)
  const normalizeStatusKey = (raw: any) => String(raw ?? '').toUpperCase().replace(/\s+|_|-|\./g, '')
  const isRejected = (raw: any) => {
    const k = normalizeStatusKey(raw)
    return k.includes('TUCHOI') || k === 'TUCHOI' || k.includes('TUCH')
  }
  const isPending = (raw: any) => {
    const k = normalizeStatusKey(raw)
    if (isRejected(k)) return false
    return k === 'CHO' || k.includes('CHOXET') || k.includes('CHODUYET') || k.includes('CHODUYET')
  }
  const isApproved = (raw: any) => {
    const k = normalizeStatusKey(raw)
    return k.includes('DADUYET') || k === 'DADUYET'
  }

  // approve/reject are provided by the viewmodel (vm.approve / vm.reject)
  const loadingId = vm.loadingId

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md shadow-lg w-[920px] max-h-[88vh] overflow-auto">
        <div className="bg-blue-600 text-white px-4 py-3 rounded-t-md flex items-center justify-between">
          <div className="font-semibold">Thông tin chi tiết</div>
          <button onClick={onClose} className="text-white text-xl leading-none">×</button>
        </div>

        <div className="p-6">
          {/* Header */}
          <ReportHeader student={student} onClose={onClose} />

          {/* Versions list (unchanged) */}
          <div className="mt-2">
            <div className="font-medium mb-2">Các phiên bản báo cáo ({versionCount}):</div>

            { vm.isLoading ? (
              <div className="p-4 text-center">Đang tải...</div>
            ) : !displayProposals.length ? (
              <div className="p-4 text-center text-slate-500">Không có báo cáo</div>
            ) : (
              <div className="space-y-4">
                {displayProposals.map((v: any) => (
                  <ReportVersionItem
                    key={v.id}
                    v={v}
                    loadingId={loadingId}
                    onApprove={(item) => {
                      const ok = window.confirm('Xác nhận duyệt báo cáo này?')
                      if (!ok) return
                      const note = window.prompt('Ghi chú (tuỳ chọn):', '')
                      vm.approve(item.id, item.phienBan, note ?? '')
                    }}
                    onReject={(item) => {
                      const reason = window.prompt('Lý do từ chối (tùy chọn):', '')
                      vm.reject(item.id, item.phienBan, reason ?? '')
                    }}
                    isApproved={isApproved}
                    isRejected={isRejected}
                  />
                ))}
              </div>
            )}
          </div>

          <div className="mt-6 flex justify-end">
            <button onClick={onClose} className="px-4 py-2 border rounded text-slate-600">Quay lại</button>
            <button onClick={() => alert('Lưu (giả lập)')} className="px-4 py-2 ml-3 rounded bg-sky-600 text-white">Lưu</button>
          </div>
        </div>
      </div>
    </div>
  )
}
