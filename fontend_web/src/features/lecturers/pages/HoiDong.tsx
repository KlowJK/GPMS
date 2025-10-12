import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'
import HoiDongDetail from '../components/HoiDongDetail'
import { Eye } from 'lucide-react'


async function fetchHoiDong(params: { idGiangVien?: number; page?: number; size?: number; sort?: string }) {
  const resp = await axios.get('/api/hoi-dong', {
    params: {
      idGiangVien: params.idGiangVien,
      page: params.page,
      size: params.size,
      sort: params.sort,
    },
    headers: { Accept: '*/*' },
    timeout: 10000,
  })
  return resp.data?.result
}

function Inner() {
  const [page, setPage] = useState(0)
  const size = 10
  const idGiangVien = 5

  const { data, isLoading, isError } = useQuery<any, Error>({
    queryKey: ['hoi-dong', idGiangVien, page, size],
    queryFn: () => fetchHoiDong({ idGiangVien, page, size, sort: 'thoiGianBatDau,DESC' }),
  })

  const [detailId, setDetailId] = useState<number | null>(null)
  const detailQuery = useQuery<any, Error>({
    queryKey: ['hoi-dong-detail', detailId],
    queryFn: async () => {
      if (!detailId) return null
      const resp = await axios.get(`/api/hoi-dong/${detailId}`, { headers: { Accept: '*/*' }, timeout: 10000 })
      return resp.data?.result
    },
    enabled: !!detailId,
  })

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Hội đồng</h1>
        <Link to="/lecturers" className="inline-block text-[#2F7CD3] hover:underline">← Về trang chủ</Link>
      </div>

      <div className="bg-white shadow rounded p-4">
        {isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : isError ? (
          <div className="p-6 text-center text-red-600">Lỗi khi tải dữ liệu</div>
        ) : (
          <>
            <table className="min-w-full table-auto">
              <thead>
                <tr className="border-b">
                  <th className="text-left px-6 py-4">ID</th>
                  <th className="text-left px-6 py-4">Tên hội đồng</th>
                  <th className="text-left px-6 py-4">Thời gian bắt đầu</th>
                  <th className="text-left px-6 py-4">Thời gian kết thúc</th>
                </tr>
              </thead>
              <tbody>
                {(((data as any)?.content) ?? []).map((h: any) => (
                  <tr key={h.id} className="border-b hover:bg-slate-50">
                    <td className="px-6 py-4">{h.id}</td>
                    <td className="px-6 py-4">{h.tenHoiDong}</td>
                    <td className="px-6 py-4">{h.thoiGianBatDau}</td>
                    <td className="px-6 py-4">{h.thoiGianKetThuc}</td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 flex items-center justify-center">
                          <button title="Xem" onClick={() => setDetailId(h.id)} className="p-2 bg-slate-50 text-sky-600 rounded-full flex items-center justify-center"><Eye size={16} /></button>
                        </div>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>

            {/* <div className="p-4 border-t flex items-center justify-center">
              <div className="flex items-center gap-3">
                <button disabled={page === 0} onClick={() => setPage(p => Math.max(0, p - 1))} className="px-3 py-1 border rounded">«</button>
                <span className="px-3 py-1">Trang {(((data as any)?.pageable?.pageNumber ?? (data as any)?.number ?? page) as number) + 1} / {(data as any)?.totalPages ?? 1}</span>
                <button disabled={!!(data as any)?.last} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded">»</button>
              </div>
            </div> */}
          </>
        )}
      </div>
      <HoiDongDetail open={!!detailId} onClose={() => setDetailId(null)} data={detailQuery.data} isLoading={detailQuery.isLoading} isError={detailQuery.isError} />
    </div>
  )
}

export default function HoiDong() {
  return <Inner />
}
