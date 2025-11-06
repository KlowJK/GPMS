import React, { useState } from 'react'
import useReportDetailViewModel from '../viewmodels/BaoCaoChiTietViewmodels'
import ReportHeader from './ThongTinSinhVien'
import ReportVersionItem from './DanhSachBaoCao'
import { toast } from 'sonner'

// Heuristic fixer for Vietnamese messages returned without diacritics from backend.
// It applies common word replacements (ASCII -> proper Vietnamese diacritics).
// This is intentionally conservative and only replaces whole words (case-insensitive).
function prettifyVietnamese(raw?: any) {
  if (!raw && raw !== 0) return ''
  let s = String(raw)
  // quick bail if string already contains diacritic characters (common Vietnamese vowels)
  if (/[\u00C0-\u1EF9]/.test(s)) return s

  const replacements: Array<[RegExp, string]> = [
    [/\bNgoai\b/gi, 'Ngoại'],
    [/\bngoai\b/gi, 'ngoại'],
    [/\bthoi\s+gian\b/gi, 'thời gian'],
    [/\bthoi_gian\b/gi, 'thời gian'],
    [/\bthoi\b/gi, 'thời'],
    [/\bnop\b/gi, 'nộp'],
    [/\bbao\s+cao\b/gi, 'báo cáo'],
    [/\bduyet\b/gi, 'duyệt'],
    [/\btu\s*choi\b/gi, 'từ chối'],
    [/\btu-choi\b/gi, 'từ chối'],
    [/(\b|\s)khong\b/gi, ' không'],
    [/\bkhong\s+thanh\s+cong\b/gi, 'không thành công'],
    [/\bthanh\s+cong\b/gi, 'thành công'],
    [/\bdiem\b/gi, 'điểm'],
    [/\bsinh\s+vien\b/gi, 'sinh viên'],
    [/\bma\s+sinh\s+vien\b/gi, 'mã sinh viên'],
  ]

  for (const [re, rep] of replacements) {
    s = s.replace(re, rep)
  }

  // trim and fix double spaces
  return s.replace(/\s{2,}/g, ' ').trim()
}

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
  const [approveModal, setApproveModal] = useState<{ open: boolean; item?: any }>({ open: false })
  const [approveNote, setApproveNote] = useState<string>('')
  const [approveScore, setApproveScore] = useState<string>('')
  const [rejectModal, setRejectModal] = useState<{ open: boolean; item?: any }>({ open: false })
  const [rejectReason, setRejectReason] = useState<string>('')

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
                    onApprove={async (item) => {
                      // open approve modal with item
                      setApproveModal({ open: true, item })
                      setApproveNote('')
                      setApproveScore(item.diem != null ? String(item.diem) : '')
                    }}
                    onReject={async (item) => {
                      // open reject modal
                      setRejectModal({ open: true, item })
                      setRejectReason('')
                    }}
                    isApproved={isApproved}
                    isRejected={isRejected}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Approve modal */}
          {approveModal.open && (
            <div className="fixed inset-0 z-60 grid place-items-center bg-black/40">
              <div className="w-[520px] bg-white rounded-md shadow-lg p-6">
                <div className="flex items-center justify-between mb-4">
                  <div className="font-semibold">Duyệt báo cáo</div>
                  <button onClick={() => setApproveModal({ open: false })} className="text-xl leading-none">×</button>
                </div>
                <div className="mb-3">
                  <div className="text-sm text-slate-500">Tiêu đề</div>
                  <div className="font-medium">{approveModal.item?.title ?? approveModal.item?.tenDeTai ?? 'Báo cáo'}</div>
                </div>
                <div className="mb-3">
                  <label className="block text-sm text-slate-600 mb-1">Ghi chú (tuỳ chọn)</label>
                  <textarea value={approveNote} onChange={e => setApproveNote(e.target.value)} rows={3} className="w-full border rounded p-2" />
                </div>
                <div className="mb-4">
                  <label className="block text-sm text-slate-600 mb-1">Điểm hướng dẫn (số, tuỳ chọn)</label>
                  <input type="number" value={approveScore} onChange={e => setApproveScore(e.target.value)} className="w-36 border rounded px-3 py-2" />
                </div>
                <div className="flex justify-end gap-3">
                  <button onClick={() => setApproveModal({ open: false })} className="px-4 py-2 rounded bg-gray-200">Huỷ</button>
                  <button
                    onClick={async () => {
                      try {
                        const score = (approveScore ?? '').trim() === '' ? undefined : Number(approveScore)
                        await vm.approve(approveModal.item.id, score, approveNote ?? '')
                        toast.success('Duyệt báo cáo thành công')
                        setApproveModal({ open: false })
                      } catch (err: any) {
                        const message = prettifyVietnamese(err?.message ?? String(err))
                        toast.error('Duyệt không thành công: ' + message)
                      }
                    }}
                    className="px-4 py-2 rounded bg-emerald-600 text-white"
                  >Duyệt</button>
                </div>
              </div>
            </div>
          )}

          {/* Reject modal */}
          {rejectModal.open && (
            <div className="fixed inset-0 z-60 grid place-items-center bg-black/40">
              <div className="w-[520px] bg-white rounded-md shadow-lg p-6">
                <div className="flex items-center justify-between mb-4">
                  <div className="font-semibold">Từ chối báo cáo</div>
                  <button onClick={() => setRejectModal({ open: false })} className="text-xl leading-none">×</button>
                </div>
                <div className="mb-3">
                  <div className="text-sm text-slate-500">Tiêu đề</div>
                  <div className="font-medium">{rejectModal.item?.title ?? rejectModal.item?.tenDeTai ?? 'Báo cáo'}</div>
                </div>
                <div className="mb-4">
                  <label className="block text-sm text-slate-600 mb-1">Lý do từ chối (tuỳ chọn)</label>
                  <textarea value={rejectReason} onChange={e => setRejectReason(e.target.value)} rows={4} className="w-full border rounded p-2" />
                </div>
                <div className="flex justify-end gap-3">
                  <button onClick={() => setRejectModal({ open: false })} className="px-4 py-2 rounded bg-gray-200">Huỷ</button>
                  <button
                    onClick={async () => {
                      try {
                        await vm.reject(rejectModal.item.id, rejectModal.item.phienBan, rejectReason ?? '')
                        toast.success('Từ chối báo cáo thành công')
                        setRejectModal({ open: false })
                      } catch (err: any) {
                        const message = prettifyVietnamese(err?.message ?? String(err))
                        toast.error('Từ chối không thành công: ' + message)
                      }
                    }}
                    className="px-4 py-2 rounded bg-rose-600 text-white"
                  >Từ chối</button>
                </div>
              </div>
            </div>
          )}

          <div className="mt-6 flex justify-end">
            <button onClick={onClose} className="px-4 py-2 border rounded text-slate-600">Quay lại</button>
          </div>
        </div>
      </div>
    </div>
  )
}
