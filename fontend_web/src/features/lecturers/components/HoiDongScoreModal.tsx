import React, { useEffect, useState } from 'react'
import { fetchHoiDongStudentDetail, saveCommonScore } from '../services/api'
import { useAuth } from '@shared/hooks/useAuth'

export default function HoiDongScoreModal({
  open,
  onClose,
  student,
  members,
}: {
  open: boolean
  onClose: () => void
  student?: any
  members: string[]
}) {
  const { user } = useAuth()
  const [membersFromApi, setMembersFromApi] = useState<Array<{ idGiangVien?: number; hoTen?: string; vaiTro?: string; diem?: number | null }>>([])
  const [scores, setScores] = useState<Record<string, number | null>>({})
  const [isSaving, setIsSaving] = useState(false)
  const [summary, setSummary] = useState<{ diemBaoCao?: number | null; diemPhanBien?: number | null; diemHoiDong?: number | null } | null>(null)

  useEffect(() => {
    if (!open || !student) return

    async function load() {
      if (student.idDeTai) {
        try {
          const res = await fetchHoiDongStudentDetail(student.idDeTai)
          const g = Array.isArray(res?.giangVien) ? res.giangVien : []
          const mapped = g.map((it: any) => ({ idGiangVien: it.idGiangVien ?? it.maGiangVien, hoTen: it.hoTen, vaiTro: it.vaiTro, diem: typeof it.diem === 'number' ? it.diem : null }))
          setMembersFromApi(mapped)
          // extract summary scores if provided by API
          setSummary({
            diemBaoCao: typeof res?.diemBaoCao === 'number' ? res.diemBaoCao : (typeof res?.diemBaoCao === 'string' ? Number(res.diemBaoCao) : null),
            diemPhanBien: typeof res?.diemPhanBien === 'number' ? res.diemPhanBien : (typeof res?.diemPhanBien === 'string' ? Number(res.diemPhanBien) : null),
            diemHoiDong: typeof res?.diemHoiDong === 'number' ? res.diemHoiDong : (typeof res?.diemHoiDong === 'string' ? Number(res.diemHoiDong) : null),
          })
          // initialize score inputs from API diem when available
          const initialScores: Record<string, number | null> = {}
          mapped.forEach((it: any, i: number) => {
            const key = (typeof it.idGiangVien !== 'undefined') ? String(it.idGiangVien) : (it.hoTen ?? String(i))
            initialScores[key] = typeof it.diem === 'number' ? it.diem : null
          })
          setScores(initialScores)
          return
        } catch (e) {
          // ignore and fall back
        }
      }

      // fallback to provided members array and initialize empty scores
      const fallback = members.map(m => ({ hoTen: m, vaiTro: undefined, diem: null }))
      setMembersFromApi(fallback)
  setSummary(null)
      const initialScores: Record<string, number | null> = {}
      members.forEach((m, i) => {
        initialScores[m ?? String(i)] = null
      })
      setScores(initialScores)
    }

    void load()
  }, [open, student])

  if (!open) return null

  const rows = membersFromApi.length > 0 ? membersFromApi : members.map(m => ({ hoTen: m, vaiTro: undefined, diem: null }))

  function renderRole(raw?: string | null) {
    if (!raw) return '-'
    const s = String(raw).toUpperCase().replace(/\s+/g, '_')
    if (s.includes('CHU') && s.includes('TICH')) return 'Chủ tịch'
    if (s.includes('THU') && s.includes('KY')) return 'Thư ký'
    if (s.includes('PHAN') && s.includes('BIEN')) return 'Phản biện'
    if (s.includes('UY') && s.includes('VIEN')) return 'Ủy viên'
    // common variants
    if (s === 'CHAIR' || s === 'PRESIDENT') return 'Chủ tịch'
    if (s === 'SECRETARY') return 'Thư ký'
    return raw
  }

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md w-[800px] max-h-[88vh] overflow-auto shadow-lg">
        <div className="flex items-center justify-between px-5 py-3 bg-blue-600 rounded-t-md text-white">
          <div className="flex items-center gap-3">
            <h3 className="text-lg font-semibold">Phiếu điểm - {student?.maSV ?? ''} {student?.hoTen ?? ''}</h3>
          </div>
          <div>
            <button onClick={onClose} className="text-white text-2xl leading-none">×</button>
          </div>
        </div>

        <div className="p-4">
          {summary && (
            <div className="mb-4 grid grid-cols-3 gap-4 text-sm">
              <div>
                <div className="text-slate-500">Điểm báo cáo</div>
                <div className="font-medium">{typeof summary.diemBaoCao === 'number' ? summary.diemBaoCao.toFixed(2) : 'Chưa có'}</div>
              </div>
              <div>
                <div className="text-slate-500">Điểm phản biện</div>
                <div className="font-medium">{typeof summary.diemPhanBien === 'number' ? summary.diemPhanBien.toFixed(2) : 'Chưa có'}</div>
              </div>
              <div>
                <div className="text-slate-500">Điểm hội đồng</div>
                <div className="font-medium">{typeof summary.diemHoiDong === 'number' ? summary.diemHoiDong.toFixed(2) : 'Chưa có'}</div>
              </div>
            </div>
          )}
          <div className="overflow-x-auto">
            <table className="min-w-full text-sm">
              <thead>
                <tr className="bg-slate-50">
                  <th className="px-3 py-2 text-left">Thành viên</th>
                  <th className="px-3 py-2 text-left">Vai trò</th>
                  <th className="px-3 py-2 text-left">Điểm</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((m, idx) => {
                  const idKey = (m as any).idGiangVien
                  const key = typeof idKey !== 'undefined' ? String(idKey) : (m.hoTen ?? String(idx))
                  // determine if current user is the owner of this member record
                  const isOwner = (() => {
                    if (typeof idKey !== 'undefined' && (user?.teacherId != null || user?.id != null)) {
                      return user?.teacherId === idKey || user?.id === idKey
                    }
                    // fallback: compare full name if available
                    if (m.hoTen && user?.fullName) return m.hoTen === user.fullName
                    return false
                  })()

                  const alreadyScored = typeof m.diem === 'number'
                  const disabled = alreadyScored || !isOwner

                  return (
                    <tr key={key} className="border-b hover:bg-slate-50">
                      <td className="px-3 py-2 align-top w-56">{m.hoTen ?? '-'}</td>
                      <td className="px-3 py-2">{renderRole(m.vaiTro)}</td>
                      <td className="px-3 py-2">
                        <input
                          type="number"
                          min={0}
                          max={10}
                          step={0.1}
                          value={scores[key] ?? ''}
                          onChange={e => {
                            const v = e.target.value
                            setScores(prev => ({ ...prev, [key]: v === '' ? null : Number(v) }))
                          }}
                          className={"w-24 border rounded px-2 py-1 " + (disabled ? 'bg-slate-100 cursor-not-allowed' : '')}
                          disabled={disabled}
                          placeholder="Chưa chấm"
                          title={alreadyScored ? 'Đã có điểm, không thể sửa' : !isOwner ? 'Chỉ được chấm bởi chính bạn' : 'Nhập điểm (0-10)'}
                        />
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>

          <div className="flex justify-end gap-2 mt-4">
            <button onClick={onClose} className="px-4 py-2 rounded border text-slate-700">Hủy</button>
            <button
              onClick={async () => {
                // find the current user's key (if any) and save only that score
                try {
                  setIsSaving(true)
                  // locate member key for current user
                  const ownerEntry = rows.find((m: any) => {
                    const idKey = m.idGiangVien
                    if (typeof idKey !== 'undefined' && (user?.teacherId != null || user?.id != null)) {
                      return user?.teacherId === idKey || user?.id === idKey
                    }
                    if (m.hoTen && user?.fullName) return m.hoTen === user.fullName
                    return false
                  })

                  if (!ownerEntry) {
                    // nothing to save for this user
                    // eslint-disable-next-line no-console
                    console.warn('No editable entry for current user')
                    setIsSaving(false)
                    onClose()
                    return
                  }

                  const idKey = (ownerEntry as any).idGiangVien
                  const key = typeof idKey !== 'undefined' ? String(idKey) : (ownerEntry.hoTen ?? '')
                  const val = scores[key]
                  if (val == null) {
                    // nothing entered
                    // eslint-disable-next-line no-console
                    console.warn('No score entered')
                    setIsSaving(false)
                    onClose()
                    return
                  }

                  // call API to save
                  const payload: any = { idDeTai: student.idDeTai ?? student.id, diem: val, nhanXet: '' }
                  const resp = await saveCommonScore(payload)
                  // eslint-disable-next-line no-console
                  console.log('Save response', resp)

                  // update local state to mark as saved
                  setMembersFromApi(prev => prev.map(p => {
                    const pid = (p as any).idGiangVien
                    const match = (typeof pid !== 'undefined' ? String(pid) === key : (p.hoTen === ownerEntry.hoTen))
                    return match ? { ...p, diem: val } : p
                  }))
                  setScores(prev => ({ ...prev, [key]: val }))

                  setIsSaving(false)
                  onClose()
                } catch (err) {
                  setIsSaving(false)
                  // eslint-disable-next-line no-console
                  console.error('Error saving score', err)
                  alert('Lỗi khi lưu điểm')
                }
              }}
              disabled={isSaving}
              className="px-4 py-2 rounded bg-sky-600 text-white"
            >
              {isSaving ? 'Đang lưu...' : 'Lưu'}
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
