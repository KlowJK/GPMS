import React, { useState } from 'react'
import { formatDateTime } from '@shared/utils/format'
import useDiaryDetailViewModel from '../viewmodels/useDiaryDetailViewModel'

export default function DiaryProgressModal({ open, onClose, data }: { open: boolean; onClose: () => void; data: any[] | null }) {
  if (!open) return null

  const normalizeStatusString = (raw?: any) => {
    if (raw == null) return ''
    // remove accents, normalize and remove separators
    let s = String(raw)
    // normalize unicode accents (remove combining diacritics)
    s = s.normalize && s.normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    // replace Vietnamese Đ/đ with D/d
    s = s.replace(/Đ/g, 'D').replace(/đ/g, 'd')
    return s.toUpperCase().replace(/\s+|_|-|\./g, '')
  }

  const getStatusInfo = (raw?: any) => {
    if (raw == null) return { label: '', badgeClass: 'bg-slate-100 text-slate-700' }
    const s = normalizeStatusString(raw)
    if (s.includes('HOANTHANH') || s.includes('COMPLETED') || s.includes('FINISHED')) return { label: 'Hoàn thành', badgeClass: 'bg-emerald-100 text-emerald-800' }
    if (s.includes('DANOP') || s === 'DA' || s.includes('DADUYET')) return { label: 'Đã nộp', badgeClass: 'bg-green-100 text-green-700' }
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO') return { label: 'Chờ duyệt', badgeClass: 'bg-sky-100 text-sky-700' }
    if (s.includes('CHUA') || s.includes('CHUANOP')) return { label: 'Chưa nộp', badgeClass: 'bg-yellow-100 text-yellow-700' }
    if (s.includes('TUCHOI') || s.includes('REJECT')) return { label: 'Từ chối', badgeClass: 'bg-red-100 text-red-700' }
    return { label: String(raw), badgeClass: 'bg-slate-100 text-slate-700' }
  }

  // compute summary counts
  // count separately: 'Đã nộp' and 'Hoàn thành', then sum them
  const [countSubmitted, countCompleted] = Array.isArray(data)
    ? data.reduce((acc: number[], d: any) => {
        const s = normalizeStatusString(d.trangThaiNhatKy ?? d.trangThai ?? d.trangthai)
        const isSubmitted = s.includes('DANOP') || s.includes('DADUYET')
        const isCompleted = s.includes('HOANTHANH') || s.includes('COMPLETED') || s.includes('FINISHED')
        if (isSubmitted) acc[0]++
        if (isCompleted) acc[1]++
        return acc
      }, [0, 0])
    : [0, 0]

  const submittedCount = countSubmitted + countCompleted
  const totalWeeks = 11
  const remaining = Math.max(0, totalWeeks - submittedCount)
  const percent = Math.round((submittedCount / totalWeeks) * 100)

  const detailVm = useDiaryDetailViewModel()

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-11/12 md:w-3/4 lg:w-2/3 bg-white rounded shadow-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Tiến độ</h3>
          <button onClick={onClose} className="text-slate-500">✕</button>
        </div>

        <div className="grid grid-cols-3 gap-4 mb-6">
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{submittedCount}</div>
            <div className="text-sm text-slate-600">Số tuần đã nộp</div>
          </div>
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{remaining}</div>
            <div className="text-sm text-slate-600">Tuần chưa nộp</div>
          </div>
          <div className="p-4 bg-slate-50 rounded text-center">
            <div className="text-2xl font-bold text-sky-600">{percent}%</div>
            <div className="text-sm text-slate-600">Hoàn thành</div>
          </div>
        </div>

        <div>
          <div className="text-sm text-slate-700 mb-3">Tiến độ từng tuần:</div>
          <div className="space-y-4">
            {Array.isArray(data) && data.map((w: any) => {
              const info = getStatusInfo(w.trangThaiNhatKy ?? w.trangThai ?? w.trangthai)
              return (
                <div key={w.tuan || w.id} className="p-4 bg-white border rounded flex">
                  <div className="w-3.5 bg-sky-600 mr-4" />
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <div className="text-sm text-slate-600 font-semibold">Tuần: {w.tuan}</div>
                      <div className={`inline-block px-3 py-1 text-xs rounded ${info.badgeClass}`}>{info.label}</div>
                    </div>
                    <div className="text-xs text-slate-500">Thời gian: {formatDateTime(w.ngayBatDau)} - {formatDateTime(w.ngayKetThuc)}</div>
                    <div className="mt-2 text-sm text-slate-700">Nội dung công việc đã thực hiện: <span className="font-medium">{w.noiDung ?? w.content ?? ''}</span></div>
                    <div className="mt-2 text-sm">Kết quả đã thực hiện: {w.fileUrl ? <a href={w.fileUrl} className="text-sky-600 underline">{w.fileUrl.split('/').pop()}</a> : 'Không'}</div>
                    <div className="mt-2 text-sm text-slate-700">Nhận xét: <span className="font-medium">{w.nhanXet ?? 'Chưa nhận xét'}</span></div>
                  </div>
                  <div className="flex items-end">
                    <CommentEditor entry={w} detailVm={detailVm} />
                  </div>
                </div>
              )
            })}
          </div>
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 rounded bg-gray-200">Quay lại</button>
        </div>
      </div>
    </div>
  )
}

function CommentEditor({ entry, detailVm }: { entry: any; detailVm: any }) {
  const [showForm, setShowForm] = useState(false)
  const [text, setText] = useState<string>(entry.nhanXet ?? '')
  const loading = detailVm.review.isLoading

  const _normalize = (raw?: any) => {
    if (raw == null) return ''
    let s = String(raw)
    s = s.normalize && s.normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    s = s.replace(/Đ/g, 'D').replace(/đ/g, 'd')
    return s.toUpperCase().replace(/\s+|_|-|\./g, '')
  }

  const open = () => {
  // block opening form for 'Chưa nộp' or 'Hoàn thành'
  const s = _normalize(entry.trangThaiNhatKy ?? entry.trangThai ?? entry.trangthai)
    if (s.includes('CHUA') || s.includes('CHUANOP')) {
      // Chưa nộp -> cannot comment
      window.alert('Không thể nhận xét: tuần chưa nộp.')
      return
    }
    if (s.includes('HOANTHANH') || s.includes('COMPLETED') || s.includes('FINISHED')) {
      // Hoàn thành -> cannot comment
      window.alert('Không thể nhận xét: tuần đã hoàn thành.')
      return
    }

    setText(entry.nhanXet ?? '')
    setShowForm(true)
  }

  const close = () => setShowForm(false)

  const onConfirm = () => {
    const id = entry.id
    detailVm.review.mutate(
      { entryId: id, payload: { id, nhanXet: text } },
      {
        onSuccess: () => {
          setShowForm(false)
        },
      }
    )
  }

  return (
    <div>
      <button onClick={open} className="px-3 py-1 bg-sky-600 text-white rounded">Nhận xét</button>

      {showForm && (
        <div className="fixed inset-0 z-60 flex items-center justify-center bg-black/40">
          <div className="w-96 bg-white rounded shadow-lg p-4">
            <div className="flex items-center justify-between mb-3">
              <h4 className="font-semibold">Nhận xét</h4>
              <button onClick={close} className="text-slate-500">✕</button>
            </div>
            <textarea placeholder="Đưa ra nhận xét ..." className="border rounded p-2 w-full h-40 mb-3" value={text} onChange={e => setText(e.target.value)} />
            <div className="flex justify-end gap-2">
              <button onClick={close} className="px-3 py-1 rounded bg-gray-200">Hủy</button>
              <button onClick={onConfirm} disabled={loading} className="px-3 py-1 rounded bg-sky-600 text-white">
                {loading ? 'Đang lưu...' : 'Xác nhận'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
