import React from 'react'
import { useQuery } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'

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

  if (!open) return null

  const data = query.data

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
              <div className="space-y-4">
                {(data.deCuongNopList || []).map((sub: any, idx: number) => (
                  <div key={idx} className="border rounded flex">
                    <div className="w-2 bg-blue-600" />
                    <div className="p-4 flex-1">
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="font-medium">{sub.title ?? `Nộp đề cương lần ${idx + 1}`}</div>
                          <div className="text-xs text-slate-500">Ngày nộp: {sub.ngayNop ?? ''}</div>
                        </div>
                        <div className="text-right">
                          <div className={`inline-block px-3 py-1 rounded-full text-xs ${sub.trangThai === 'DA_DUYET' ? 'bg-green-100 text-green-800' : sub.trangThai === 'TU_CHOI' ? 'bg-red-100 text-red-800' : 'bg-slate-100 text-slate-700'}`}>
                            {sub.trangThai === 'DA_DUYET' ? 'đã duyệt' : sub.trangThai === 'TU_CHOI' ? 'Từ chối' : 'chờ xét' }
                          </div>
                        </div>
                      </div>

                      <div className="mt-2">
                        {sub.fileUrl ? (
                          <a href={sub.fileUrl} target="_blank" rel="noreferrer" className="text-sky-600 hover:underline">{sub.fileName ?? 'File đính kèm'}</a>
                        ) : (
                          <div className="text-sm text-slate-500">Không có file</div>
                        )}
                      </div>
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
