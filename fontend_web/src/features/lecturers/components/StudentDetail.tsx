import React from 'react'
import { useQuery } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { approveProposal, rejectProposal, fetchStudentProposals } from '../services/api'

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
  const displayProposals = proposalsQuery.data ?? []
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
  const approveMut = useMutation<any, Error, string | number>({
    mutationFn: id => approveProposal(id),
    onMutate: (id) => setLoadingId(id),
    onSettled: () => { setLoadingId(null); qc.invalidateQueries({ queryKey: ['sinh-vien-proposals', maSV] }); qc.invalidateQueries({ queryKey: ['sinh-vien', maSV] }) },
  })
  const rejectMut = useMutation<any, Error, { id: string | number; nhanXet?: string }>({
    mutationFn: ({ id, nhanXet }) => rejectProposal(id, nhanXet),
    onMutate: ({ id }) => setLoadingId(id),
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
                    <div className="w-2 bg-blue-600" />
                    <div className="p-4 flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="font-medium">{sub.tenDeTai ?? sub.title ?? `Nộp đề cương lần ${idx + 1}`}</div>
                          <div className="text-xs text-slate-500">Ngày nộp: {sub.ngayNop ?? ''} {sub.phienBan != null ? `· Phiên bản: ${sub.phienBan}` : ''}</div>
                        </div>
                        <div className="text-right">
                          {isPending(sub.trangThai) ? (
                            <div className="flex flex-col items-end gap-2">
                              <button disabled={loadingId === sub.id} onClick={() => approveMut.mutate(sub.id)} className="px-3 py-1 rounded-full bg-green-500 text-white text-sm">Duyệt</button>
                              <button disabled={loadingId === sub.id} onClick={() => rejectMut.mutate({ id: sub.id })} className="px-3 py-1 rounded-full bg-red-500 text-white text-sm">Từ chối</button>
                            </div>
                          ) : (
                            <div className={`inline-block px-3 py-1 rounded-full text-xs ${isApproved(sub.trangThai) ? 'bg-green-100 text-green-800' : isRejected(sub.trangThai) ? 'bg-red-600 text-white' : 'bg-slate-100 text-slate-700'}`}>
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

                      {/* Nếu bị từ chối, hiển thị lý do (nhanXets hoặc nhanXet) */}
                      {isRejected(sub.trangThai) && (
                        <div className="mt-2 p-3 bg-red-50 border border-red-100 rounded text-sm text-red-700">
                          <div className="font-medium text-sm">Lý do từ chối</div>
                          {Array.isArray(sub.nhanXets) && sub.nhanXets.length > 0 ? (
                            <ul className="list-disc pl-5 mt-1">
                              {sub.nhanXets.map((nx: any, i: number) => (
                                <li key={i}>{nx.nhanXet ?? nx}</li>
                              ))}
                            </ul>
                          ) : (
                            <div className="mt-1">{sub.nhanXet ?? 'Không có lý do cụ thể'}</div>
                          )}
                        </div>
                      )}
                    </div>
                  </div>
                ))}
              </div>

              <div className="mt-6 flex justify-end gap-3">
                <button onClick={onClose} className="px-4 py-2 border rounded text-slate-600">Quay lại</button>
                <button className="px-4 py-2 bg-blue-600 text-white rounded">Lưu</button>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  )
}
