import React, { useEffect, useState } from 'react'
import { fetchStudentsWithoutSupervisor, fetchStudentByCode } from '../services'
import { loadLecturersForStudent } from '../viewmodels/TruongBoMonViewmodels'
import { toast } from 'sonner'
import ReportHeader from './ThongTinSinhVien'

type Props = {
  open: boolean
  onClose: () => void
  row: any | null
  onAssigned?: (payload: { idDeTai?: any; idGiangVien?: any; idBoMon?: any; mode?: string }) => void
}

export default function PhanCongPhanBienModal({ open, onClose, row, onAssigned }: Props) {
  const [loading, setLoading] = useState(false)
  const [student, setStudent] = useState<any | null>(null)
  const [lecturers, setLecturers] = useState<any[]>([])
  const [lecturerId, setLecturerId] = useState<string | null>(null)
  const [lecturersLoading, setLecturersLoading] = useState(false)

  function extractBoMonId(s: any) {
    if (!s) return null
    return s.idBoMon ?? s.boMonId ?? s.id_bm ?? s.id_bomon ?? s.boMon?.id ?? s.boMonId ?? null
  }

  useEffect(() => {
    if (!open) return
    let mounted = true
    async function load() {
      setLoading(true)
      try {
        const svResp = await fetchStudentsWithoutSupervisor({ page: 0, size: 1000 })
        const svItems: any[] = Array.isArray(svResp?.content) ? svResp.content : (Array.isArray(svResp) ? svResp : [])
        const found = svItems.find(it => String(it.maSV ?? it.maSinhVien ?? it.id ?? '') === String(row?.maSV ?? row?.maSinhVien ?? row?.id ?? ''))

        let studentRecord: any = found ?? row
        const ma = String(studentRecord?.maSV ?? studentRecord?.maSinhVien ?? '')
        if (ma) {
          try {
            const full = await fetchStudentByCode(ma)
            if (mounted && full) studentRecord = full
          } catch (e) {
            console.debug('fetchStudentByCode failed', e)
          }
        }

        if (mounted) setStudent(studentRecord)

        try {
          setLecturersLoading(true)
          const list = await loadLecturersForStudent(found ?? studentRecord)
          if (mounted) setLecturers(Array.isArray(list) ? list : [])
        } catch (e) {
          console.debug('loadLecturersForStudent failed', e)
        } finally {
          setLecturersLoading(false)
        }
      } catch (err) {
        console.error(err)
        toast.error('Lỗi khi tải dữ liệu')
      } finally {
        if (mounted) setLoading(false)
      }
    }
    load()
    return () => { mounted = false }
  }, [open, row])

  function handleClose() {
    setLecturerId(null)
    setStudent(null)
    onClose()
  }

  async function handleSave() {
    // Static save for reviewer assignment (no backend API yet)
    try {
      if (!lecturerId) {
        toast.error('Vui lòng chọn giảng viên')
        return
      }

      const bomon = extractBoMonId(student)
      // simulate save (caller will refresh)
      onAssigned?.({ idDeTai: row?.idDeTai ?? row?.id ?? null, idGiangVien: lecturerId, idBoMon: bomon, mode: 'phan-bien' })
      toast.success('Phân công phản biện (tạm) thành công')
      handleClose()
    } catch (err) {
      console.error('[PhanCongPhanBienModal] save failed', err)
      toast.error('Lưu phân công phản biện thất bại')
    }
  }

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-[720px] bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Phân công giảng viên phản biện</h2>

        <ReportHeader student={student} onClose={onClose} />

        <div>
          <div className="mb-4">
            <label className="block text-sm text-slate-600 mb-2">Giảng viên phản biện</label>
            <select value={lecturerId ?? ''} onChange={e => setLecturerId(e.target.value || null)} className="w-full border rounded px-3 py-2">
              <option value="">Chọn giảng viên</option>
              {lecturers.map((g: any) => {
                const code = g.maGiangVien ?? g.maGV ?? String(g.id ?? '')
                return (
                  <option key={`${g.id}-${code}`} value={String(code)}>{g.hoTen} {code ? `(${code})` : ''}</option>
                )
              })}
            </select>
            {lecturersLoading && <div className="text-xs text-slate-500 mt-1">Đang tải giảng viên...</div>}
          </div>
          <div className="mt-6 flex justify-end gap-3 col-span-2">
            <button onClick={handleClose} className="px-4 py-2 rounded bg-gray-200">Hủy</button>
            <button onClick={handleSave} className="px-4 py-2 rounded bg-sky-600 text-white">Lưu</button>
          </div>
        </div>
      </div>
    </div>
  )
}
