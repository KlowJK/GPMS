import React, { useEffect, useState, useRef } from 'react'
import { fetchStudentsWithoutSupervisor, fetchStudentByCode, assignReviewerToDeCuong } from '../services'
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
  const [rawLecturers, setRawLecturers] = useState<GiangVien[]>([])
  const [lecturerId, setLecturerId] = useState<string | null>(null)
  const [lecturerQuery, setLecturerQuery] = useState<string>('')
  const [showSuggestions, setShowSuggestions] = useState<boolean>(false)
  const suggestionsRef = useRef<HTMLDivElement | null>(null)
  const [showAllLecturers, setShowAllLecturers] = useState<boolean>(false)
  const [lecturersLoading, setLecturersLoading] = useState<boolean>(false)
  const [saving, setSaving] = useState<boolean>(false)

  function extractBoMonId(s: any) {
    if (!s) return null
    return s.idBoMon ?? s.boMonId ?? s.id_bm ?? s.id_bomon ?? s.boMon?.id ?? s.boMonId ?? null
  }

  // Helpers
  function addCandidateToSet(set: Set<string>, v: any) {
    if (v == null) return
    if (Array.isArray(v)) return v.forEach(x => addCandidateToSet(set, x))
    const s = normalizeString(String(v ?? ''))
    if (s) set.add(s)
  }

  function normalizeString(s: string | null | undefined) {
    if (!s && s !== '') return ''
    try {
      return String(s)
        .normalize?.('NFD')
        .replace(/\p{Diacritic}/gu, '')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .trim()
    } catch (e) {
      // fallback if unicode property escapes are not supported
      return String(s).normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().trim()
    }
  }

  function collectSupervisorCandidates(studentObj: any, rowObj: any) {
    const candidates = new Set<string>()
    const srec = studentObj ?? {}
    const rowRec = rowObj ?? {}
    const topKeys = ['hoTenGiangVienHD', 'giangVienHuongDan', 'tenGiangVienHuongDan', 'tenGvhd', 'gvhd', 'tenGiangVien']
    const codeKeys = ['maGiangVienHuongDan', 'maGVHD', 'maGV', 'maGiangVien']
    const idKeys = ['idGiangVienHuongDan', 'idGvhd', 'gvhdId', 'giangVienHuongDanId', 'idGiangVien']

    for (const k of [...topKeys, ...codeKeys, ...idKeys]) {
      addCandidateToSet(candidates, srec?.[k])
      addCandidateToSet(candidates, rowRec?.[k])
      addCandidateToSet(candidates, srec?.raw?.[k])
      addCandidateToSet(candidates, rowRec?.raw?.[k])
    }

    function collectFromObj(obj: any) {
      if (!obj || typeof obj !== 'object') return
      addCandidateToSet(candidates, obj.id)
      addCandidateToSet(candidates, obj.maGiangVien ?? obj.maGV ?? obj.ma)
      addCandidateToSet(candidates, obj.hoTen ?? obj.hoVaTen ?? obj.ten ?? obj.name)
      for (const v of Object.values(obj)) {
        if (v && typeof v === 'object') collectFromObj(v)
        else addCandidateToSet(candidates, v)
      }
    }

    collectFromObj(srec?.giangVien ?? srec?.giangVienHuongDan ?? srec?.gvhd)
    collectFromObj(rowRec?.giangVien ?? rowRec?.giangVienHuongDan ?? rowRec?.gvhd)
    collectFromObj(srec?.raw?.giangVien ?? srec?.raw?.giangVienHuongDan ?? srec?.raw?.gvhd)
    collectFromObj(rowRec?.raw?.giangVien ?? rowRec?.raw?.giangVienHuongDan ?? rowRec?.raw?.gvhd)

    addCandidateToSet(candidates, srec?.tenGiangVienHuongDan)
    addCandidateToSet(candidates, rowRec?.tenGiangVienHuongDan)

    return candidates
  }

  function deriveLecturerIdParamFrom(selected: any, originalLecturerId: string | null) {
    try {
      const cand = selected?.raw ?? selected
      const possible = [cand?.id, cand?.giangVienId, cand?.user?.id, selected?.id]
      for (const p of possible) {
        if (p == null) continue
        if (isFinite(Number(p))) return Number(p)
      }
      if (typeof originalLecturerId === 'string') {
        const m = originalLecturerId.match(/(\d+)$/)
        if (m) return Number(m[1])
      }
      return selected?.raw?.id ?? selected?.id ?? originalLecturerId
    } catch (e) {
      return originalLecturerId
    }
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
            const rawList: GiangVien[] = Array.isArray(list) ? (list as GiangVien[]) : []
            // filter out any lecturer that is the student's supervisor
            const candidates = collectSupervisorCandidates(studentRecord, row)
            const filtered = rawList.filter(g => {
              try {
                const gid = normalizeString(String(g.id ?? g.raw?.id ?? ''))
                const gcode = normalizeString(String(g.maGiangVien ?? g.raw?.maGiangVien ?? g.raw?.maGV ?? ''))
                const gname = normalizeString(String(g.hoTen ?? g.raw?.hoTen ?? g.raw?.hoVaTen ?? g.raw?.ten ?? ''))
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

            if (mounted) {
              if (import.meta.env.DEV) {
                console.debug('[PhanCongPhanBienModal] lecturers (filtered)', filtered)
                console.debug('[PhanCongPhanBienModal] supervisor candidates', Array.from(candidates))
                console.debug('[PhanCongPhanBienModal] studentRecord', studentRecord)
              }
              setRawLecturers(rawList)
              setLecturers(filtered)
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

  function handleClose() {
    setLecturerId(null)
    setStudent(null)
    onClose()
  }

  async function handleSave() {
    // Call backend API to assign reviewer
    if (!lecturerId) {
      toast.error('Vui lòng chọn giảng viên')
      return
    }

    const bomon = extractBoMonId(student)
    const idDeTai = row?.idDeTai ?? row?.id
    if (!idDeTai) {
      toast.error('Không xác định đề tài')
      return
    }

    try {
      setSaving(true)
      // derive the best numeric id to send to backend from the selected lecturer
      const selected = (lecturers || []).find(x => String(x.id ?? x.raw?.id ?? x.maGiangVien ?? '') === String(lecturerId))
      // debug: log what will be sent
      try { console.debug('[PhanCongPhanBienModal] assign payload', { idDeTai, lecturerId, selected }) } catch (e) { console.debug(e) }

      const lecturerIdParam = deriveLecturerIdParamFrom(selected, lecturerId)
      const resp = await assignReviewerToDeCuong(idDeTai as any, lecturerIdParam)
      if (import.meta.env.DEV) console.debug('[PhanCongPhanBienModal] assign response', resp)
      toast.success('Phân công phản biện thành công')
      // notify parent and close
      onAssigned?.({ idDeTai: idDeTai ?? null, idGiangVien: lecturerId, idBoMon: bomon, mode: 'phan-bien' })
      handleClose()
    } catch (err) {
      console.error('[PhanCongPhanBienModal] assign API failed', err)
      const anyErr: any = err
      const serverMsg = anyErr?.response?.data?.message ?? anyErr?.response?.data?.error ?? anyErr?.message
      toast.error(serverMsg ? String(serverMsg) : 'Lưu phân công phản biện thất bại')
    } finally {
      setSaving(false)
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
            <div className="mb-2 flex items-center gap-3">
              <label className="text-sm flex items-center gap-2">
                <input type="checkbox" checked={showAllLecturers} onChange={e => setShowAllLecturers(e.target.checked)} />
                <span className="text-sm text-slate-600">Hiển thị tất cả giảng viên</span>
              </label>
              <div className="ml-auto text-xs text-slate-400">Hiện: {showAllLecturers ? 'Tất cả' : 'Đã lọc'}</div>
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

              {showSuggestions && !lecturersLoading && ((showAllLecturers ? rawLecturers : lecturers).length > 0) && (
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
                      const idVal = String(g.id ?? g.raw?.id ?? g.maGiangVien ?? '')
                      const code = String(g.maGiangVien ?? (g as any).maGV ?? '')
                      const label = `${g.hoTen ?? ''}${code ? ` (${code})` : ''}`
                      return (
                        <div
                          key={`${String(g.id)}-${code}`}
                          className={`px-3 py-2 cursor-pointer text-sm hover:bg-slate-100`}
                          onClick={() => {
                            setLecturerQuery(label)
                            setLecturerId(idVal)
                            setShowSuggestions(false)
                          }}
                        >
                          <div className="flex items-center justify-between">
                            <div>{label}</div>
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
