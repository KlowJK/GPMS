import React, { useEffect, useState } from 'react'
import { updateTenDeTai } from '../services/deCuongApi'
import { fetchStudentByCode } from '../services'
import ReportHeader from './ThongTinSinhVien'
import type { SinhVien } from '../models/SinhVien'
import { toast } from 'sonner'
import { useQueryClient } from '@tanstack/react-query'

type Props = {
  open: boolean
  maSV?: string
  onClose: () => void
  onSaved?: () => void
}

export default function UpdateTenDeTaiModal({ open, maSV, onClose, onSaved }: Props) {
  const [tenDeTai, setTenDeTai] = useState<string>('')
  const [file, setFile] = useState<File | null>(null)
  const [saving, setSaving] = useState<boolean>(false)
  const qc = useQueryClient()
  const [student, setStudent] = useState<SinhVien | null>(null)

  useEffect(() => {
    let mounted = true
    async function load() {
      if (!open) return
      setFile(null)
      setSaving(false)
      setStudent(null)
      setTenDeTai('')
      if (!maSV) return
      try {
        const sv = await fetchStudentByCode(String(maSV))
        if (!mounted) return
        setStudent(sv)
        // prefill tenDeTai if available on returned student or raw
        const pref = (sv as any)?.tenDeTai ?? (sv as any)?.raw?.tenDeTai ?? ''
        if (pref) setTenDeTai(String(pref))
      } catch (err) {
        console.debug('[UpdateTenDeTaiModal] fetchStudent failed', err)
      }
    }
    load()
    return () => { mounted = false }
  }, [open, maSV])

  if (!open) return null

  async function handleSave() {
    if (!maSV) {
      toast.error('Không xác định mã sinh viên')
      return
    }
    if (!tenDeTai || !String(tenDeTai).trim()) {
      toast.error('Vui lòng nhập tên đề tài')
      return
    }

    setSaving(true)
    try {
      const resp = await updateTenDeTai(String(maSV), String(tenDeTai).trim(), file)
      // try to refresh reviews list
      try { qc.invalidateQueries({ queryKey: ['lecturers-reviews'] }) } catch (e) { /* ignore */ }
      toast.success(typeof resp === 'string' ? resp : (resp?.message ?? 'Cập nhật thành công'))
      onSaved?.()
      onClose()
    } catch (err: any) {
      console.error('[UpdateTenDeTaiModal] save failed', err)
      const serverMsg = err?.response?.data?.message ?? err?.message ?? 'Cập nhật thất bại'
      toast.error(String(serverMsg))
    } finally {
      setSaving(false)
    }
  }

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-[640px] bg-white rounded-lg shadow relative overflow-hidden">
        {/* Blue header bar matching screenshot */}
  <div className="flex items-center justify-between px-6 py-3 bg-blue-600 text-white">
          <h2 className="text-lg font-semibold">Cập nhật tên đề tài</h2>
          <button
            onClick={onClose}
            disabled={saving}
            aria-label="Đóng"
            title="Đóng"
            className="w-8 h-8 rounded-full flex items-center justify-center bg-blue-600 text-white hover:bg-blue-700"
          >
            ×
          </button>
        </div>

        <div className="p-6">

          {/* student info header (from ThongTinSinhVien) */}
          <ReportHeader student={student} />

          <div className="grid grid-cols-1 gap-4">
            <div>
              <label className="block text-sm text-slate-600 mb-2">Tên đề tài <span className="text-red-500">*</span></label>
              <input value={tenDeTai} onChange={e => setTenDeTai(e.target.value)} className="w-full border rounded px-3 py-2" />
            </div>

            <div>
              <label className="block text-sm text-slate-600 mb-2">Tải file tổng quan (tùy chọn)</label>
              <input type="file" accept="application/pdf" onChange={e => setFile(e.target.files?.[0] ?? null)} />
              {file && <div className="text-sm text-slate-600 mt-1">{file.name}</div>}
            </div>

            <div className="mt-4 flex justify-end gap-3">
              <button onClick={onClose} disabled={saving} className="px-4 py-2 rounded bg-gray-200">Hủy</button>
              <button onClick={handleSave} disabled={saving} className={['px-4 py-2 rounded text-white', saving ? 'bg-blue-400 cursor-not-allowed opacity-70' : 'bg-blue-600'].join(' ')}>
                {saving ? 'Đang lưu...' : 'Lưu'}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
