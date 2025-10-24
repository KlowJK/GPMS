import React from 'react'
import { useQuery } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { approveProposal, rejectProposal, fetchStudentProposals, rejectDeCuong, approveDeCuong } from '../services/api'

export default function StudentDetail({ open, maSV, onClose }: { open: boolean; maSV?: string | null; onClose: () => void }) {
  const query = useQuery<any, Error>({
    queryKey: ['sinh-vien', maSV],
    queryFn: async () => {
      if (!maSV) return null
      const resp = await axios.get(`/api/sinh-vien/${encodeURIComponent(maSV)}`, { headers: { Accept: '*/*' }, timeout: 10000 })
      return resp.data?.result
    },
    enabled: !!maSV,
  })

  // proposals list for the student (separate API)
  const proposalsQuery = useQuery<any[], Error>({
    queryKey: ['sinh-vien-proposals', maSV],
    queryFn: () => fetchStudentProposals(String(maSV)),
    enabled: !!maSV,
  })


  const data = query.data
  // ensure proposals are shown newest version first
  const displayProposals = (proposalsQuery.data ?? []).slice().sort((a: any, b: any) => {
    const pa = a?.phienBan != null ? Number(a.phienBan) : Number.NEGATIVE_INFINITY
    const pb = b?.phienBan != null ? Number(b.phienBan) : Number.NEGATIVE_INFINITY
    return pb - pa
  })

  // số lần nộp = số phiên bản (phienBan) nếu có, fallback về số items
  const versionSet = new Set(displayProposals.map((p: any) => (p?.phienBan != null ? String(p.phienBan) : null)).filter(Boolean))
  const versionCount = versionSet.size > 0 ? versionSet.size : displayProposals.length

  // helpers to check status more precisely
  const normalizeStatusKey = (raw: any) => String(raw ?? '').toUpperCase().replace(/\s+|_|-|\./g, '')
  const isRejected = (raw: any) => {
    const k = normalizeStatusKey(raw)
    return k.includes('TUCHOI') || k === 'TUCHOI' || k.includes('TUCH')
  }
  const isPending = (raw: any) => {
    const k = normalizeStatusKey(raw)
    // ensure not rejected
    if (isRejected(k)) return false
    return k === 'CHO' || k.includes('CHOXET') || k.includes('CHODUYET') || k.includes('CHODUYET')
  }
  const isApproved = (raw: any) => {
    const k = normalizeStatusKey(raw)
    return k.includes('DADUYET') || k === 'DADUYET' || k === 'DADUYET'
  }

  const qc = useQueryClient()
  const [loadingId, setLoadingId] = React.useState<string | number | null>(null)
  // track expanded comment lists per proposal id
  const [expandedComments, setExpandedComments] = React.useState<Record<string, boolean>>({})
  const approveMut = useMutation<any, Error, { id: string | number; phienBan?: number | string; nhanXet?: string }>({
    mutationFn: ({ id, phienBan, nhanXet }) => approveDeCuong(id, phienBan, nhanXet),
    onMutate: ({ id, nhanXet }) => {
      setLoadingId(id)
      // optimistic update: mark approved locally
      try {
        qc.setQueryData(['sinh-vien-proposals', maSV], (old: any[] | undefined) => {
          if (!Array.isArray(old)) return old
          return old.map(it => {
            if (it.id === id) {
              return {
                ...it,
                trangThai: 'DA_DUYET',
                nhanXets: Array.isArray(it.nhanXets) ? (nhanXet ? [...it.nhanXets, { nhanXet }] : it.nhanXets) : (nhanXet ? [{ nhanXet }] : []),
              }
            }
            return it
          })
        })
      } catch (e) {}
    },
    onSuccess: (data) => {
      // eslint-disable-next-line no-console
      console.debug('[approve] success', data)
    },
    onError: (err) => {
      // eslint-disable-next-line no-console
      console.error('[approve] error', err)
      try { alert('Lỗi khi duyệt: ' + (err as Error).message) } catch (e) {}
    },
    onSettled: () => { setLoadingId(null); qc.invalidateQueries({ queryKey: ['sinh-vien-proposals', maSV] }); qc.invalidateQueries({ queryKey: ['sinh-vien', maSV] }) },
  })
  const rejectMut = useMutation<any, Error, { id: string | number; nhanXet?: string; phienBan?: number | string }>({
    mutationFn: ({ id, nhanXet, phienBan }) => rejectDeCuong(id, phienBan, nhanXet),
    onMutate: ({ id, nhanXet }) => {
      setLoadingId(id)
      // optimistic update: mark the proposal as rejected locally so UI reflects change immediately
      try {
        qc.setQueryData(['sinh-vien-proposals', maSV], (old: any[] | undefined) => {
          if (!Array.isArray(old)) return old
          return old.map(it => {
            if (it.id === id) {
              return {
                ...it,
                trangThai: 'TU_CHOI',
                // keep existing nhanXets array and append new reason if provided
                nhanXets: Array.isArray(it.nhanXets) ? (nhanXet ? [...it.nhanXets, { nhanXet }] : it.nhanXets) : (nhanXet ? [{ nhanXet }] : []),
              }
            }
            return it
          })
        })
      } catch (e) {}
    },
    onSuccess: (data) => {
      // eslint-disable-next-line no-console
      console.debug('[reject] success', data)
    },
    onError: (err) => {
      // eslint-disable-next-line no-console
      console.error('[reject] error', err)
      try { alert('Lỗi khi từ chối: ' + (err as Error).message) } catch (e) {}
    },
    onSettled: () => { setLoadingId(null); qc.invalidateQueries({ queryKey: ['sinh-vien-proposals', maSV] }); qc.invalidateQueries({ queryKey: ['sinh-vien', maSV] }) },
  })

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md shadow-lg w-[820px] max-h-[88vh] overflow-auto">
        <div className="bg-blue-600 text-white px-4 py-3 rounded-t-md flex items-center justify-between">
          <div className="font-semibold">Thông tin chi tiết</div>
          <button onClick={onClose} className="text-white text-xl leading-none">×</button>
        </div>

        <div className="p-6">
          {query.isLoading ? (
            <div className="p-6 text-center">Đang tải...</div>
          ) : query.isError ? (
            <div className="p-4 text-red-600">Lỗi khi tải dữ liệu</div>
          ) : !data ? (
            <div className="p-4">Không có dữ liệu</div>
          ) : (
            <>
              <div className="grid grid-cols-3 gap-4 mb-4">
                <div>
                  <label className="text-xs text-slate-500">Mã sinh viên</label>
                  <input readOnly value={data.maSV ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
                <div>
                  <label className="text-xs text-slate-500">Họ và tên</label>
                  <input readOnly value={data.hoTen ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
                <div>
                  <label className="text-xs text-slate-500">Email</label>
                  <input readOnly value={data.email ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-4 mb-6">
                <div>
                  <label className="text-xs text-slate-500">Số điện thoại</label>
                  <input readOnly value={data.soDienThoai ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
                <div>
                  <label className="text-xs text-slate-500">Ngày sinh</label>
                  <input readOnly value={data.ngaySinh ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
                <div>
                  <label className="text-xs text-slate-500">Ngành</label>
                  <input readOnly value={data.tenNganh ?? ''} className="w-full border rounded px-2 py-1 mt-1 text-sm bg-slate-50" />
                </div>
              </div>

              {/* Submissions */}
              <div className="mb-3 font-medium">Đề cương — Số lần nộp: {versionCount}</div>

              <div className="space-y-4">
                {displayProposals.map((sub: any, idx: number) => (
                  <div key={idx} className="border rounded flex">
                    <div className={`w-2 ${isApproved(sub.trangThai) ? 'bg-emerald-500' : isRejected(sub.trangThai) ? 'bg-rose-600' : 'bg-sky-600'}`} />
                    <div className="p-4 flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="font-medium">{sub.tenDeTai ?? sub.title ?? `Nộp đề cương lần ${idx + 1}`}</div>
                          <div className="text-xs text-slate-500">Ngày nộp: {sub.ngayNop ?? ''} {sub.phienBan != null ? `· Phiên bản: ${sub.phienBan}` : ''}</div>
                        </div>
                        <div className="text-right">
                          {isPending(sub.trangThai) ? (
                            <div className="flex flex-col items-end gap-2">
                              <button
                                disabled={loadingId === sub.id}
                                onClick={() => {
                                  const ok = window.confirm('Xác nhận duyệt đề cương này?')
                                  if (!ok) return
                                  const note = window.prompt('Ghi chú (tuỳ chọn):', '')
                                  approveMut.mutate({ id: sub.id, phienBan: sub.phienBan, nhanXet: note ?? '' })
                                }}
                                  className="inline-flex items-center justify-center w-28 h-8 rounded-full bg-emerald-500 text-white text-sm"
                              >Duyệt</button>
                              <button
                                disabled={loadingId === sub.id}
                                onClick={() => {
                                  // ask for reason (simple prompt). Could be replaced with a modal for better UX.
                                  const reason = window.prompt('Lý do từ chối (tùy chọn):', '')
                                  // pass phienBan when available so backend can target specific version
                                  rejectMut.mutate({ id: sub.id, nhanXet: reason ?? '', phienBan: sub.phienBan })
                                }}
                                className="inline-flex items-center justify-center w-28 h-8 rounded-full bg-rose-600 text-white text-sm"
                              >Từ chối</button>
                            </div>
                          ) : (
                            <div className={`inline-block px-3 py-1 rounded-full text-xs ${isApproved(sub.trangThai) ? 'bg-emerald-100 text-emerald-800' : isRejected(sub.trangThai) ? 'bg-rose-600 text-white' : 'bg-slate-100 text-slate-700'}`}>
                              {isApproved(sub.trangThai) ? 'đã duyệt' : isRejected(sub.trangThai) ? 'Từ chối' : 'chờ xét' }
                            </div>
                          )}
                        </div>
                      </div>

                      <div className="mt-2">
                        {sub.fileUrl ? (
                          <a href={sub.fileUrl} target="_blank" rel="noreferrer" className="text-sky-600 hover:underline">{sub.fileName ?? 'File đính kèm'}</a>
                        ) : (
                          <div className="text-sm text-slate-500">Không có file</div>
                        )}
                      </div>

                      {/* Hiển thị nhận xét / lý do cho cả trạng thái (đã duyệt, từ chối, ...)
                          - Nếu có mảng nhanXets: hiển thị danh sách
                          - Nếu có nhanXet (chuỗi): hiển thị trực tiếp
                          Style khác nhau dựa trên trạng thái */}
                      {( (isRejected(sub.trangThai) || isApproved(sub.trangThai)) && ((Array.isArray(sub.nhanXets) && sub.nhanXets.length > 0) || sub.nhanXet) ) ? (
                        <div
                          className={
                            `mt-2 p-3 rounded text-sm ` +
                            (isRejected(sub.trangThai)
                              ? 'bg-rose-50 border border-rose-100 text-rose-700'
                              : isApproved(sub.trangThai)
                              ? 'bg-emerald-50 border border-emerald-100 text-emerald-700'
                              : 'bg-slate-50 border border-slate-100 text-slate-700')
                          }
                        >
                          <div className="font-medium text-sm">{isRejected(sub.trangThai) ? 'Lý do từ chối' : 'Nhận xét'}</div>
                          {Array.isArray(sub.nhanXets) && sub.nhanXets.length > 0 ? (
                            // show only the latest comment from the array
                            (() => {
                              const items = sub.nhanXets as any[]
                              const latest = items[items.length - 1]
                              const text = latest?.nhanXet ?? latest ?? ''
                              const meta = latest ? (latest.hoTenGiangVien ? ` — ${latest.hoTenGiangVien}` : '') : ''
                              return (
                                <div className="mt-2">
                                  <div className="mt-1">{text || sub.nhanXet || 'Không có nội dung'}{meta}</div>
                                </div>
                              )
                            })()
                          ) : (
                            <div className="mt-1">{sub.nhanXet ?? 'Không có nội dung'}</div>
                          )}
                        </div>
                      ) : null}
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 flex justify-end">
                <button onClick={onClose} className="px-4 py-2 border rounded text-slate-600">Đóng</button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
