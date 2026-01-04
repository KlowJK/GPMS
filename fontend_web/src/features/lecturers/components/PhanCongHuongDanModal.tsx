import React, { useEffect, useState, useRef } from 'react'
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
  const [rawLecturers, setRawLecturers] = useState<GiangVien[]>([])
  // store selected lecturer code (maGiangVien / maGV) because backend expects maGV
  const [lecturerId, setLecturerId] = useState<string | null>(null)
  const [lecturerQuery, setLecturerQuery] = useState<string>('')
  const [showSuggestions, setShowSuggestions] = useState<boolean>(false)
  const suggestionsRef = useRef<HTMLDivElement | null>(null)
  // close suggestions when clicking outside
  useEffect(() => {
    function onDoc(e: MouseEvent) {
      const el = suggestionsRef.current
      if (!el) return
      if (!el.contains(e.target as Node)) setShowSuggestions(false)
    }
    document.addEventListener('click', onDoc)
    return () => document.removeEventListener('click', onDoc)
  }, [])
  const [lecturersLoading, setLecturersLoading] = useState<boolean>(false)
  const [saving, setSaving] = useState<boolean>(false)
  const [showAllLecturers, setShowAllLecturers] = useState<boolean>(false)

  function extractBoMonId(s: any) {
    if (!s) return null
    return s.idBoMon ?? s.boMonId ?? s.id_bm ?? s.id_bomon ?? s.boMon?.id ?? s.boMonId ?? null
  }

  useEffect(() => {
    if (!open) return
    // close suggestions when modal opens/closes
    setShowSuggestions(false)
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
          const rawList: GiangVien[] = Array.isArray(list) ? (list as GiangVien[]) : []
          // Backend now provides the correct list (including capacity rules).
          // Use the backend-provided list directly and avoid client-side filtering.
          if (mounted) {
            if (import.meta.env.DEV) console.debug('[PhanCongModal] lecturers loaded', rawList.length)
            setRawLecturers(rawList)
            setLecturers(rawList)
          }
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
      // if user typed a label that matches exactly one lecturer, resolve id automatically
      if (!lecturerId && lecturerQuery) {
        const matched = lecturers.find(g => {
          const code = String(g.maGiangVien ?? (g as any).maGV ?? g.id ?? '')
          const label = `${g.hoTen ?? ''}${code ? ` (${code})` : ''}`
          return label === lecturerQuery || (g.hoTen ?? '').toLowerCase() === lecturerQuery.toLowerCase()
        })
        if (matched) setLecturerId(String(matched.maGiangVien ?? (matched as any).maGV ?? matched.id ?? ''))
      }

      if (!lecturerId) {
        toast.error('Vui lòng chọn giảng viên')
        return
      }

      const ma = String(student?.maSV ?? student?.maSinhVien ?? student?.ma ?? '')
      if (!ma) {
        toast.error('Không xác định được mã sinh viên')
        return
      }

  setSaving(true)
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
      setSaving(false)
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
                <div className="mb-2 flex items-center gap-3">
                  <label className="text-sm flex items-center gap-2">
                    <input type="checkbox" checked={showAllLecturers} onChange={e => setShowAllLecturers(e.target.checked)} />
                    <span className="text-sm text-slate-600">Hiển thị cả giảng viên đã đầy chỗ</span>
                  </label>
                  <div className="ml-auto text-xs text-slate-400">Hiện: {showAllLecturers ? 'Tất cả' : 'Chỉ còn chỗ'}</div>
                </div>

                <div className="relative" ref={suggestionsRef}>
                  <input
                    value={lecturerQuery}
                    onChange={e => {
                      setLecturerQuery(e.target.value)
                      setLecturerId(null)
                      setShowSuggestions(true)
                    }}
                    onFocus={() => setShowSuggestions(true)}
                    disabled={lecturersLoading || loading || saving}
                    aria-disabled={lecturersLoading || loading || saving}
                    placeholder="Nhập tên hoặc mã giảng viên"
                    className="w-full border rounded px-3 py-2"
                  />

                  {showSuggestions && !lecturersLoading && ( (showAllLecturers ? rawLecturers : lecturers).length > 0 ) && (
                    <div className="absolute z-40 left-0 right-0 mt-1 bg-white border rounded shadow max-h-52 overflow-auto">
                      {(showAllLecturers ? rawLecturers : lecturers)
                        .filter(g => {
                          const q = (lecturerQuery || '').toLowerCase().trim()
                          if (!q) return true
                          const code = String(g.maGiangVien ?? (g as any).maGV ?? g.id ?? '').toLowerCase()
                          const name = String(g.hoTen ?? '').toLowerCase()
                          return name.includes(q) || code.includes(q)
                        })
                        .map(g => {
                          const code = String(g.maGiangVien ?? (g as any).maGV ?? g.id ?? '')
                          const used = Number(g.soLuongDeTai ?? g.raw?.soLuongDeTai ?? 0)
                          const allowed = Number(g.soLuongChoPhepHuongDan ?? g.raw?.soLuongChoPhepHuongDan ?? Number.MAX_SAFE_INTEGER)
                          const isFull = Number.isFinite(used) && Number.isFinite(allowed) ? used >= allowed : false
                          const label = `${g.hoTen ?? ''}${code ? ` (${code})` : ''}`
                          return (
                            <div
                              key={`${String(g.id)}-${code}`}
                              className={`px-3 py-2 cursor-pointer text-sm ${isFull ? 'text-slate-400' : 'hover:bg-slate-100'}`}
                              onClick={() => {
                                setLecturerQuery(label)
                                setLecturerId(code)
                                setShowSuggestions(false)
                              }}
                              title={isFull ? `Đã hết chỗ (${used}/${allowed})` : `Còn chỗ (${used}/${allowed})`}
                            >
                              <div className="flex items-center justify-between">
                                <div>{label}</div>
                                <div className={`text-xs ${isFull ? 'text-rose-500' : 'text-slate-500'}`}>{isFull ? `Đã hết (${used}/${allowed})` : `${used}/${allowed}`}</div>
                              </div>
                            </div>
                          )
                        })}
                    </div>
                  )}

                  {lecturersLoading && <div className="text-xs text-slate-500 mt-1">Đang tải giảng viên...</div>}
                </div>
              </div>
              <div className="mt-6 flex justify-end gap-3 col-span-2">
                <button onClick={handleClose} className="px-4 py-2 rounded bg-gray-200">Hủy</button>
                <button
                  onClick={handleSave}
                  disabled={lecturersLoading || loading || saving}
                  aria-disabled={lecturersLoading || loading || saving}
                  className={`px-4 py-2 rounded text-white ${lecturersLoading || loading || saving ? 'bg-sky-400 cursor-not-allowed opacity-70' : 'bg-sky-600'}`}>
                  {saving ? 'Đang lưu...' : 'Lưu'}
                </button>
              </div>
            </div>
          </div>
      </div>
  )
}
