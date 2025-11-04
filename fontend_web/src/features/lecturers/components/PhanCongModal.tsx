import React, { useEffect, useState } from 'react'
import { fetchStudentsWithoutSupervisor, fetchStudentByCode, assignDeTai } from '../services'
import { listLecturersNormalized } from '@/features/assistants/services/user/userApi'
import { axios } from '@shared/libs/axios'
import { loadLecturersForStudent } from '../viewmodels/TruongBoMonViewmodels'
import { toast } from 'sonner'
import ReportHeader from './ThongTinSinhVien'
import type { DeCuong } from '../models/DeCuong'
import type { SinhVien } from '../models/SinhVien'
import type { GiangVien } from '../models/GiangVien'

type Props = {
  open: boolean
  onClose: () => void
  row: DeCuong | null
  onAssigned?: (payload: { idDeTai?: string | number | null; idGiangVien?: string | null; idBoMon?: string | number | null; mode?: 'huong-dan' | 'phan-bien' }) => void
}

export default function PhanCongModal({ open, onClose, row, onAssigned }: Props) {
  const [loading, setLoading] = useState<boolean>(false)
  const [student, setStudent] = useState<SinhVien | null>(null)
  const [lecturers, setLecturers] = useState<GiangVien[]>([])
  // store selected lecturer code (maGiangVien / maGV) because backend expects maGV
  const [lecturerId, setLecturerId] = useState<string | null>(null)
  const [lecturersLoading, setLecturersLoading] = useState<boolean>(false)

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
        // Try to find student in the "sinh-vien-chua-co-gvhd" endpoint which includes idBoMon.
        // This lets us get idBoMon directly and call /api/giang-vien/{boMonId}.
        const svResp = await fetchStudentsWithoutSupervisor({ page: 0, size: 1000 })
  const svItems: any[] = Array.isArray(svResp?.content) ? svResp.content : (Array.isArray(svResp) ? svResp : [])
  const found = svItems.find(it => String(it.maSV ?? it.maSinhVien ?? it.ma ?? it.msv ?? it.id ?? '') === String((row as any)?.maSV ?? (row as any)?.maSinhVien ?? (row as any)?.ma ?? (row as any)?.msv ?? (row as any)?.id ?? ''))

  // Try to fetch the full student record (same as DanhSachSinhVienHD) so ThongTinSinhVien has all fields
  // Prefer the record from sinh-vien-chua-co-gvhd (found) because it contains idBoMon
  let studentRecord: any = found ?? row
        const ma = String(studentRecord?.maSV ?? studentRecord?.maSinhVien ?? '')
        if (ma) {
          try {
            const full = await fetchStudentByCode(ma)
            if (mounted && full) studentRecord = full as SinhVien
          } catch (e) {
            // ignore and fall back to partial record
            console.debug('fetchStudentByCode failed', e)
          }
        }

  if (mounted) setStudent(studentRecord as SinhVien)

        // delegate lecturer loading to viewmodel helper (prefers boMon -> falls back)
        try {
          setLecturersLoading(true)
          const list = await loadLecturersForStudent(found ?? studentRecord)
          if (mounted) setLecturers(Array.isArray(list) ? (list as GiangVien[]) : [])
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

  // no subject select — lecturers are loaded based on student's department during open

  function handleClose() {
    setLecturerId(null)
    setStudent(null)
    onClose()
  }

  async function handleSave() {
    // Call assignment API: POST /api/de-tai/gan-de-tai with { maSV, maGV }
    try {
      if (!lecturerId) {
        toast.error('Vui lòng chọn giảng viên')
        return
      }

      const ma = String(student?.maSV ?? student?.maSinhVien ?? student?.ma ?? '')
      if (!ma) {
        toast.error('Không xác định được mã sinh viên')
        return
      }

      setLoading(true)
      const resp = await assignDeTai({ maSV: ma, maGV: String(lecturerId) })

      // API returns result with success/message in various shapes
      const success = resp?.success ?? resp?.result?.success ?? true
      const message = resp?.message ?? resp?.result?.message ?? 'Phân công thành công'

      if (!success) {
        toast.error(message || 'Phân công thất bại')
        return
      }

      const bomon = extractBoMonId(student)
      onAssigned?.({ idDeTai: row?.idDeTai ?? row?.id ?? null, idGiangVien: lecturerId, idBoMon: bomon })
      toast.success(String(message))
      handleClose()
    } catch (err) {
      console.error('[PhanCongModal] assign failed', err)
      toast.error('Lưu phân công thất bại')
    } finally {
      setLoading(false)
    }
  }

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-[720px] bg-white rounded-lg shadow p-6">
        <h2 className="text-lg font-semibold mb-4">Phân công giảng viên hướng dẫn</h2>

            
              {/* reuse existing ThongTinSinhVien presentation component */}
                <ReportHeader student={student} onClose={onClose} />
            
            <div>
              <div className="mb-4">
                <label className="block text-sm text-slate-600 mb-2">Giảng viên</label>
                <select value={lecturerId ?? ''} onChange={e => setLecturerId(e.target.value || null)} className="w-full border rounded px-3 py-2">
                  <option value="">Chọn giảng viên</option>
                  {lecturers.map((g: GiangVien) => {
                      const code = (g.maGiangVien ?? (g as any).maGV ?? String(g.id ?? '')) as string
                    return (
                        <option key={`${String(g.id)}-${code}`} value={String(code)}>{(g.hoTen ?? '')} {code ? `(${code})` : ''}</option>
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
