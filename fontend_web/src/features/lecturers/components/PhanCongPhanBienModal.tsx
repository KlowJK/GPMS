import React, { useEffect, useState } from 'react'
import { fetchStudentsWithoutSupervisor, fetchStudentByCode } from '../services'
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
  onAssigned?: (payload: { idDeTai?: string | number | null; idGiangVien?: string | null; idBoMon?: string | number | null; mode?: 'phan-bien' }) => void
}

export default function PhanCongPhanBienModal({ open, onClose, row, onAssigned }: Props) {
  const [loading, setLoading] = useState<boolean>(false)
  const [student, setStudent] = useState<SinhVien | null>(null)
  const [lecturers, setLecturers] = useState<GiangVien[]>([])
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
        const svResp = await fetchStudentsWithoutSupervisor({ page: 0, size: 1000 })
  const svItems: any[] = Array.isArray(svResp?.content) ? svResp.content : (Array.isArray(svResp) ? svResp : [])
  const found = svItems.find(it => String(it.maSV ?? it.maSinhVien ?? it.id ?? '') === String((row as any)?.maSV ?? (row as any)?.maSinhVien ?? (row as any)?.id ?? ''))

  let studentRecord: any = found ?? row
  const ma = String(studentRecord?.maSV ?? studentRecord?.maSinhVien ?? '')
        if (ma) {
          try {
            const full = await fetchStudentByCode(ma)
            if (mounted && full) studentRecord = full as SinhVien
          } catch (e) {
            console.debug('fetchStudentByCode failed', e)
          }
        }

  if (mounted) setStudent(studentRecord as SinhVien)

        try {
          setLecturersLoading(true)
          const list = await loadLecturersForStudent(found ?? studentRecord)
          // filter out any lecturer that is the student's supervisor
          const candidates = new Set<string>()
          function addCandidate(v: any) {
            if (v == null) return
            if (Array.isArray(v)) {
              v.forEach(addCandidate)
              return
            }
            const s = String(v ?? '').toLowerCase().trim()
            if (s) candidates.add(s)
          }

          // collect from obvious top-level aliases on the student/row
          const srec: any = studentRecord ?? {}
          const rowRec: any = row ?? {}
          const topKeys = ['hoTenGiangVienHD', 'giangVienHuongDan', 'tenGiangVienHuongDan', 'tenGvhd', 'gvhd', 'tenGiangVien']
          const codeKeys = ['maGiangVienHuongDan', 'maGVHD', 'maGV', 'maGiangVien']
          const idKeys = ['idGiangVienHuongDan', 'idGvhd', 'gvhdId', 'giangVienHuongDanId', 'idGiangVien']

          for (const k of [...topKeys, ...codeKeys, ...idKeys]) {
            addCandidate((srec as any)[k])
            addCandidate((rowRec as any)[k])
            addCandidate((srec as any).raw?.[k])
            addCandidate((rowRec as any).raw?.[k])
          }

          // nested objects: giangVien, giangVienHuongDan may be objects with id/ma/hoTen
          function collectFromObj(obj: any) {
            if (!obj || typeof obj !== 'object') return
            addCandidate(obj.id)
            addCandidate(obj.maGiangVien ?? obj.maGV ?? obj.ma)
            addCandidate(obj.hoTen ?? obj.hoVaTen ?? obj.ten ?? obj.name)
            // also look deeper
            Object.values(obj).forEach(v => {
              if (v && typeof v === 'object') collectFromObj(v)
              else if (typeof v === 'string' || typeof v === 'number') addCandidate(v)
            })
          }

          collectFromObj((srec as any).giangVien ?? (srec as any).giangVienHuongDan ?? (srec as any).gvhd ?? (srec as any).giangVienHuongDan)
          collectFromObj((rowRec as any).giangVien ?? (rowRec as any).giangVienHuongDan ?? (rowRec as any).gvhd ?? (rowRec as any).giangVienHuongDan)
          collectFromObj((srec as any).raw?.giangVien ?? (srec as any).raw?.giangVienHuongDan ?? (srec as any).raw?.gvhd)
          collectFromObj((rowRec as any).raw?.giangVien ?? (rowRec as any).raw?.giangVienHuongDan ?? (rowRec as any).raw?.gvhd)

          // also try common free-form fields
          addCandidate((srec as any).tenGiangVienHuongDan)
          addCandidate((rowRec as any).tenGiangVienHuongDan)

          const filtered = (Array.isArray(list) ? (list as GiangVien[]) : []).filter(g => {
            try {
              const gid = String(g.id ?? g.raw?.id ?? '').toLowerCase().trim()
              const gcode = String(g.maGiangVien ?? g.raw?.maGiangVien ?? g.raw?.maGV ?? '').toLowerCase().trim()
              const gname = String(g.hoTen ?? g.raw?.hoTen ?? g.raw?.hoVaTen ?? g.raw?.ten ?? '').toLowerCase().trim()
              // exclude if any candidate equals id/code/name or is substring-match on name
              for (const cand of candidates) {
                if (!cand) continue
                if (cand === gid || cand === gcode) return false
                if (gname && (cand === gname || gname.includes(cand) || cand.includes(gname))) return false
              }
              return true
            } catch (e) {
              return true
            }
          })

          if (mounted) setLecturers(filtered)
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
