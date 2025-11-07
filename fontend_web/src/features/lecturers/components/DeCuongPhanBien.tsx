import React, { useEffect, useRef, useState } from 'react'
import { toast } from 'sonner'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchStudentProposals, approveDeCuong, rejectDeCuong } from '../services'
import { formatDateTime } from '@shared/utils/format'
import type { DeCuong } from '../models/DeCuong'
import type { NhatKy } from '../models/NhatKy'

type DeCuongItem = DeCuong

interface DeCuongDetailModalProps {
  open: boolean
  onClose: () => void
  item: DeCuong | null
  currentName: string
  useTbmStatus?: boolean
  showChoActions?: boolean
}

export default function DeCuongDetailModal({ open, onClose, item, currentName, useTbmStatus, showChoActions }: DeCuongDetailModalProps) {
  if (!open || !item) return null

  // prefer maSinhVien then maSV
  const maSV = item.maSinhVien ?? item.maSV ?? ''

  const modalRef = useRef<HTMLDivElement | null>(null)
  useEffect(() => {
    if (open) {
      // focus modal container for a11y
      try { modalRef.current?.focus() } catch (e) {}
    }
  }, [open])

  const query = useQuery<any, Error>({
    queryKey: ['student-proposals', maSV],
    queryFn: () => fetchStudentProposals(String(maSV)),
    enabled: !!maSV,
    staleTime: 1000 * 60,
  })

  const proposals = query.data ?? []

  const qc = useQueryClient()

  // local UI state
  const [rejectOpenId, setRejectOpenId] = useState<string | number | null>(null)
  const [rejectReasonInput, setRejectReasonInput] = useState<string>('')
  const [approveOpenId, setApproveOpenId] = useState<string | number | null>(null)
  const [approveReasonInput, setApproveReasonInput] = useState<string>('')
  // extracted comments across related proposals (typed as any for now, but NhanXet model exists)
  const [comments, setComments] = useState<NhatKy[] | any[]>([])
  const [fileUrl, setFileUrl] = useState<string | null>(null)

  const approveMut = useMutation<any, Error, { id: string | number; phienBan?: number | string; reason?: string }>({
    mutationFn: (payload) => approveDeCuong(payload.id, payload.phienBan, payload.reason),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['student-proposals', maSV] })
      qc.invalidateQueries({ queryKey: ['de-cuong-page'] })
      // close inline approve box on success
      setApproveOpenId(null)
      setApproveReasonInput('')
      try { toast.success('Duyệt thành công') } catch (e) {}
    },
    onError: (err: any) => {
      try {
        const message = String(err?.message ?? err)
        // simple prettify for common ascii-only backend messages
        const pretty = message.replace(/Ngoai/gi, 'Ngoại').replace(/\bnop\b/gi, 'nộp').replace(/bao\s*cao/gi, 'báo cáo').replace(/khong/gi, 'không')
        toast.error(`Duyệt thất bại: ${pretty}`)
      } catch (e) {}
    }
  })

  const rejectMut = useMutation<any, Error, { id: string | number; phienBan?: number | string; reason?: string }>({
    mutationFn: (payload) => rejectDeCuong(payload.id, payload.phienBan, payload.reason),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['student-proposals', maSV] })
      qc.invalidateQueries({ queryKey: ['de-cuong-page'] })
      // close inline reject box on success
      setRejectOpenId(null)
      setRejectReasonInput('')
      try { toast.success('Từ chối thành công') } catch (e) {}
    },
    onError: (err: any) => {
      try {
        const message = String(err?.message ?? err)
        const pretty = message.replace(/Ngoai/gi, 'Ngoại').replace(/\bnop\b/gi, 'nộp').replace(/bao\s*cao/gi, 'báo cáo').replace(/khong/gi, 'không')
        toast.error(`Từ chối thất bại: ${pretty}`)
      } catch (e) {}
    }
  })

  

  // filter proposals to same title/id and only versions where currentName is among reviewers
  const related = (Array.isArray(proposals) ? proposals : []).filter((p: any) => {
    // match by proposal id if available, or by title
    const same = (item.id && p.id === item.id) || (String(p.tenDeTai || '').trim() === String(item.tenDeTai || item.title || '').trim())
    if (!same) return false
    // allow showing all versions, but we'll mark those assigned to current reviewer
    return true
  }).sort((a: any, b: any) => {
    const pa = a?.phienBan != null ? Number(a.phienBan) : Number.NEGATIVE_INFINITY
    const pb = b?.phienBan != null ? Number(b.phienBan) : Number.NEGATIVE_INFINITY
    return pb - pa
  })

  // derive simple comments and fileUrl from related proposals for easier consumption by the UI
  useEffect(() => {
    try {
      const allComments: any[] = []
      for (const r of related) {
        if (Array.isArray(r.nhanXets)) allComments.push(...r.nhanXets)
        else if (r.nhanXet) allComments.push(r.nhanXet)
      }
      setComments(allComments)
      const firstUrl = related.find((r: any) => r.deCuongUrl || r.fileUrl)
      setFileUrl(firstUrl ? (firstUrl.deCuongUrl ?? firstUrl.fileUrl ?? null) : null)
    } catch (e) {
      setComments([])
      setFileUrl(null)
    }
  }, [related])

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-11/12 md:w-3/4 lg:w-2/3 bg-white rounded shadow-lg p-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Chi tiết đề cương</h3>
          <button onClick={onClose} className="text-slate-500">✕</button>
        </div>

        <div className="mb-6">
          {/* Header: avatar + student basic info (styled similar to screenshot) */}
          {(() => {
            const fullName = item.hoTenSinhVien ?? item.hoVaTen ?? item.hoTen ?? item.hoVaTenSinhVien ?? item.tenSinhVien ?? item.hoTenSV ?? item.ho_ten ?? item.ten ?? ''
            const studentId = item.maSinhVien ?? item.maSV ?? ''
            return (
              <div className="flex items-start gap-6">
                <div className="flex-none">
                  <div className="w-14 h-14 rounded-full bg-slate-100 flex items-center justify-center text-xl font-semibold text-slate-700">{(fullName || studentId || '?').charAt(0).toUpperCase()}</div>
                </div>
                <div className="flex-1 grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-slate-500">Họ và tên</div>
                    <div className="font-medium">{fullName || ''}</div>
                    <div className="text-sm text-slate-500 mt-2">Mã SV</div>
                    <div className="font-medium">{studentId}</div>
                    <div className="inline-block mt-2 px-2 py-1 rounded-full bg-amber-100 text-amber-800 text-xs">Sinh viên</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Giảng viên phản biện</div>
                    <div className="font-medium">{item.giangVienPhanBien ?? item.raw?.giangVienPhanBien ?? ''}</div>
                    <div className="text-sm text-slate-500 mt-2">Trưởng bộ môn</div>
                    <div className="font-medium">{item.truongBoMon ?? item.raw?.truongBoMon ?? ''}</div>
                  </div>
                </div>
              </div>
            )
          })()}
          <div className="mt-4">
            <div className="text-sm text-slate-500">Tên đề tài</div>
            <div className="font-medium">{item.tenDeTai ?? item.title}</div>
          </div>
        </div>

        <div>
          <div className="text-sm text-slate-700 mb-3">Phiên bản ({related.length}):</div>
          {query.isLoading ? (
            <div className="p-4">Đang tải...</div>
          ) : related.length === 0 ? (
            <div className="p-4 text-slate-500">Không tìm thấy phiên bản liên quan</div>
          ) : (
            <div className="space-y-3">
              {related.map((v: any) => {
                const reviewers = String(v.raw?.giangVienPhanBien ?? v.giangVienPhanBien ?? '')
                const gvStatusRaw = v.raw?.gvPhanBienDuyet ?? v.gvPhanBienDuyet ?? null
                const tbmStatusRaw = v.raw?.tbmDuyet ?? v.tbmDuyet ?? null
                const statusRaw = useTbmStatus ? tbmStatusRaw : gvStatusRaw

                const normalizeName = (s?: string) => {
                  if (!s) return ''
                  try {
                    // remove diacritics
                    // remove common academic titles/prefixes (PGS, PGS., TS, ThS, Dr, etc.) to improve matching
                    const withoutTitle = String(s).replace(/\b(PGS|PGS\.|P\.G\.S|PGS\.|PG|TS|TS\.|THS|ThS|Th\.S|Dr|Dr\.|Mr|Mrs|Ms)\.?\s*/gi, '')
                    return withoutTitle.normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/Đ/g, 'D').replace(/đ/g, 'd').toLowerCase().replace(/\s+/g, ' ').trim()
                  } catch (e) {
                    return String(s).toLowerCase().replace(/\s+/g, ' ').trim()
                  }
                }

                const matchReviewer = (reviewersStr: string, name?: string) => {
                  if (!name) return false
                  const normName = normalizeName(name)
                  const parts = reviewersStr.split(/[;,|\n]/).map(p => normalizeName(p)).filter(Boolean)
                  // check exact match or includes full tokens
                  if (parts.includes(normName)) return true
                  // fallback: check if any part contains all name tokens
                  const nameTokens = normName.split(' ').filter(Boolean)
                  return parts.some(p => nameTokens.every(t => p.includes(t)))
                }

                // consider reviewer assignment OR (when modal is used for TBM) TBM ownership
                const assignedToCurrent = (
                  matchReviewer(reviewers, currentName)
                  || matchReviewer(String(item.giangVienPhanBien ?? item.raw?.giangVienPhanBien ?? ''), currentName)
                  || (useTbmStatus && matchReviewer(String(item.truongBoMon ?? item.raw?.truongBoMon ?? ''), currentName))
                )

                const normalizeStatusKey = (r?: any) => {
                  if (r == null) return ''
                  let s = String(r)
                  try { s = s.normalize('NFD').replace(/[\u0300-\u036f]/g, '') } catch (e) {}
                  s = s.replace(/Đ/g, 'D').replace(/đ/g, 'd')
                  return s.toUpperCase().replace(/\s+|_|-|\./g, '')
                }


                const isPending = (raw: any) => {
                  const k = normalizeStatusKey(raw)
                  return k.includes('CHO') || k.includes('CHOXET') || k.includes('CHO_DUYET')
                }

                // stricter pending check used for showing action buttons
                const isPendingStrict = (raw: any) => {
                  const k = normalizeStatusKey(raw)
                  // must be a pending-related key, and must NOT include approved/rejected/submitted flags
                  const looksPending = k.includes('CHO') || k.includes('CHOXET') || k.includes('CHO_DUYET') || k.includes('CHODUYET')
                  const looksFinalOrSubmitted = k.includes('DA') || k.includes('DADUYET') || k.includes('TU_CHOI') || k.includes('TUCH') || k.includes('NOP') || k.includes('DANOP')
                  return looksPending && !looksFinalOrSubmitted
                }

                const isRejected = (raw: any) => {
                  const k = normalizeStatusKey(raw)
                  return k.includes('TU_CHOI') || k.includes('TUCH')
                }

                const isApproved = (raw: any) => {
                  const k = normalizeStatusKey(raw)
                  return k.includes('DA_DUYET') || k === 'DA' || k.includes('DANOP')
                }

                const getStatusClasses = (raw: any) => {
                  const s = raw == null ? '' : String(raw)
                  const k = normalizeStatusKey(raw)
                  // return explicit colors (hex) to avoid Tailwind purge/override issues
                  if (!s || s.trim() === '') {
                    return { barColor: '#cbd5e1', badgeBg: '#f1f5f9', badgeText: '#334155', label: 'Chưa phản biện' }
                  }
                  if (k.includes('TU_CHOI') || k.includes('TUCH')) return { barColor: '#dc2626', badgeBg: '#dc2626', badgeText: '#ffffff', label: 'Từ chối' }
                  if (k.includes('NOP') || k.includes('DANOP') || k.includes('DA_NOP') || k.includes('DANỘP')) return { barColor: '#16a34a', badgeBg: '#dcfce7', badgeText: '#065f46', label: 'Đã nộp' }
                  if (k.includes('DADUYET') || k === 'DA') return { barColor: '#16a34a', badgeBg: '#dcfce7', badgeText: '#065f46', label: 'Đã duyệt' }
                  // For pending, use the same blue left bar as list view and a neutral badge (show raw label)
                  if (k.includes('CHO') || k.includes('CHOXET') || k.includes('CHODUYET')) return { barColor: '#0284c7', badgeBg: '#f1f5f9', badgeText: '#334155', label: String(raw ?? 'CHO_DUYET') }
                  return { barColor: '#0284c7', badgeBg: '#f1f5f9', badgeText: '#334155', label: s }
                }

                const status = getStatusClasses(statusRaw)
                const _normalizedStatusKey = normalizeStatusKey(statusRaw)
                // if status is specifically a pending-for-approval key (CHO + DUYET), hide its textual badge
                const isChoDuyet = _normalizedStatusKey.includes('CHO') && _normalizedStatusKey.includes('DUYET')
                return (
                  <div key={v.id} className="border rounded flex">
                    <div className="w-2" style={{ backgroundColor: status.barColor }} />
                    <div className="p-4 flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="font-medium">Phiên bản: {v.phienBan ?? '-'}</div>
                          <div className="text-sm text-slate-500">Ngày tạo: {formatDateTime(v.createdAt ?? v.raw?.createdAt ?? '')}</div>
                          <div className="text-sm text-slate-500">File đề cương: {
                            (() => {
                              const fileUrl = v.deCuongUrl ?? v.fileUrl
                              if (!fileUrl) return 'Không'
                              const fileName = String(fileUrl).split('/').pop() || 'Tải xuống'
                              return <a className="text-sky-600 underline" href={fileUrl} target="_blank" rel="noopener noreferrer">{fileName}</a>
                            })()
                          }</div>
                        </div>
                        <div className="text-right">
                          {status.label && !isChoDuyet ? (
                            <div className="inline-block px-3 py-1 rounded-full text-xs" style={{ backgroundColor: status.badgeBg, color: status.badgeText }}>{status.label}</div>
                          ) : null}
                          {isPendingStrict(statusRaw) && assignedToCurrent && (!isChoDuyet || !!showChoActions) ? (
                            rejectOpenId === v.id ? (
                              <div className="mt-2">
                                <textarea value={rejectReasonInput} onChange={(e) => setRejectReasonInput(e.target.value)} placeholder="Lý do từ chối (tùy chọn)" className="w-full p-2 border rounded text-sm" rows={3} />
                                <div className="mt-2 flex justify-end gap-2">
                                  <button onClick={() => { setRejectOpenId(null); setRejectReasonInput('') }} disabled={rejectMut.status === 'pending'} className="px-3 py-1 rounded bg-gray-200 text-sm">Hủy</button>
                                  <button onClick={() => rejectMut.mutate({ id: v.id, phienBan: v.phienBan, reason: rejectReasonInput })} disabled={rejectMut.status === 'pending'} className="px-3 py-1 rounded bg-rose-600 text-white text-sm">Xác nhận từ chối</button>
                                </div>
                              </div>
                            ) : (
                              approveOpenId === v.id ? (
                                <div className="mt-2">
                                  <textarea value={approveReasonInput} onChange={(e) => setApproveReasonInput(e.target.value)} placeholder="Ghi chú (tùy chọn)" className="w-full p-2 border rounded text-sm" rows={3} />
                                  <div className="mt-2 flex justify-end gap-2">
                                    <button onClick={() => { setApproveOpenId(null); setApproveReasonInput('') }} disabled={approveMut.status === 'pending'} className="px-3 py-1 rounded bg-gray-200 text-sm">Hủy</button>
                                    <button onClick={() => approveMut.mutate({ id: v.id, phienBan: v.phienBan, reason: approveReasonInput })} disabled={approveMut.status === 'pending'} className="px-3 py-1 rounded bg-emerald-500 text-white text-sm">Xác nhận duyệt</button>
                                  </div>
                                </div>
                              ) : (
                                <div className="mt-2 flex gap-2">
                                  <button disabled={approveMut.status === 'pending'} onClick={() => { setApproveOpenId(v.id); setApproveReasonInput('') }} className="inline-flex items-center justify-center w-28 h-8 rounded-full bg-emerald-500 text-white text-sm">Duyệt</button>
                                  <button disabled={rejectMut.status === 'pending'} onClick={() => { setRejectOpenId(v.id); setRejectReasonInput('') }} className="inline-flex items-center justify-center w-28 h-8 rounded-full bg-rose-600 text-white text-sm">Từ chối</button>
                                </div>
                              )
                            )
                          ) : null}
                        </div>
                      </div>

                      {/* comment area */}
                      {((isRejected(statusRaw) || isPending(statusRaw) || status.label === 'Đã duyệt' || status.label === 'Đã nộp') && ((Array.isArray(v.nhanXets) && v.nhanXets.length > 0) || v.nhanXet)) ? (
                        <div className={
                          `mt-2 p-3 rounded text-sm ` +
                          (isRejected(statusRaw)
                            ? 'bg-rose-50 border border-rose-100 text-rose-700'
                            : (status.label === 'Đã duyệt' || status.label === 'Đã nộp')
                            ? 'bg-emerald-50 border border-emerald-100 text-emerald-700'
                            : 'bg-slate-50 border border-slate-100 text-slate-700')
                        }>
                          <div className="font-medium text-sm">{isRejected(statusRaw) ? 'Lý do từ chối' : 'Nhận xét'}</div>
                          {Array.isArray(v.nhanXets) && v.nhanXets.length > 0 ? (
                            (() => {
                              const items = v.nhanXets as any[]
                              const latest = items[items.length - 1]
                              const text = latest?.nhanXet ?? latest ?? ''
                              const meta = latest ? (latest.hoTenGiangVien ? ` — ${latest.hoTenGiangVien}` : '') : ''
                              return (
                                <div className="mt-2">
                                  <div className="mt-1">{text || v.nhanXet || 'Không có nội dung'}{meta}</div>
                                </div>
                              )
                            })()
                          ) : (
                            <div className="mt-1">{v.nhanXet ?? 'Không có nội dung'}</div>
                          )}
                        </div>
                      ) : null}
                    </div>
                  </div>
                )
              })}
            </div>
          )}
        </div>

        <div className="mt-6 flex justify-end gap-2">
          <button onClick={onClose} className="px-4 py-2 rounded bg-gray-200">Đóng</button>
        </div>
      </div>
    </div>
  )
}
