
import { Link } from "react-router-dom";
import { useState, useEffect } from "react";
import { formatDateTime } from '@shared/utils/format'
import useDiaryViewModel from '../viewmodels/NhatKyViewmodels'
import DiaryProgressModal from '../components/NhatKyChiTiet'
import useDiaryDetailViewModel from '../viewmodels/NhatKyChiTietViewmodels'

export default function NhatKy() {
  // use viewmodel for weeks, diary entries and helpers
  const diaryVm = useDiaryViewModel()
  const detailVm = useDiaryDetailViewModel()
  const [openDetail, setOpenDetail] = useState(false)
  // client-side pagination state (match DoAnListPage behaviour)
  const [page, setPage] = useState<number>(0)
  const [pageSize, setPageSize] = useState<number>(10)
  // client-side search query for student code
  const [query, setQuery] = useState<string>('')

  useEffect(() => {
    if (!openDetail) detailVm.setProposalId(null)
  }, [openDetail, detailVm])

  // reset to first page when diary data or pageSize or query changes
  useEffect(() => { setPage(0) }, [diaryVm.data, pageSize, query])

  // pagination and status helpers are provided by the viewmodel (diaryVm.getPagination, diaryVm.getStatusInfo)

  return (
    <div className="min-h-[calc(100vh-80px)] flex flex-col items-stretch">
      <div className="w-full max-w-full mx-auto px-0">
        <div className="bg-white shadow rounded-md p-8 border-10 border-[#2F7CD3] w-full max-w-full">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-semibold text-[#222]">Nhật ký tiến độ</h1>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <label htmlFor="week" className="font-medium text-[#222]"></label>
                <select
                  id="week"
                  className="border border-[#B5D6F6] rounded px-2 py-1 min-w-[80px] focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
                  value={diaryVm.week}
                  onChange={e => diaryVm.setWeek(Number(e.target.value))}
                >
                  {Array.isArray(diaryVm.weeks) ? diaryVm.weeks.map((w: any) => (
                    <option key={w} value={w}>Tuần {w}</option>
                  )) : null}
                </select>
              </div>

              <div className="w-56">
                <input
                  value={query}
                  onChange={e => setQuery(e.target.value)}
                  placeholder="Tìm theo mã sinh viên"
                  className="w-full border rounded px-3 py-2 text-sm"
                />
              </div>
            </div>
          </div>

          <div className="flex flex-wrap gap-8 mb-6 text-sm">
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Ngày bắt đầu : <span className="font-medium">{formatDateTime(diaryVm.currentWeekEntry?.ngayBatDau)}</span>
            </div>
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Ngày kết thúc : <span className="font-medium">{formatDateTime(diaryVm.currentWeekEntry?.ngayKetThuc)}</span>
            </div>
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Thời hạn nộp nhật ký tuần <span className="font-medium">{diaryVm.currentWeekEntry?.tuan}</span> :
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="min-w-full text-sm bg-white border border-[#E0E0E0]">
              <thead>
                <tr className="bg-[#F2F8FC] text-[#222]">
                  <th className="px-4 py-2 font-semibold border-b border-[#E0E0E0]">Mã sinh viên</th>
                  <th className="px-4 py-2 font-semibold border-b border-[#E0E0E0]">Họ và tên</th>
                  <th className="px-4 py-2 font-semibold border-b border-[#E0E0E0]">Tên đề tài</th>
                  <th className="px-4 py-2 font-semibold border-b border-[#E0E0E0]">Trạng Thái</th>
                  <th className="px-4 py-2 font-semibold border-b border-[#E0E0E0]">Hoạt động</th>
                </tr>
              </thead>
              <tbody>
                {diaryVm.isLoading ? (
                  <tr><td colSpan={5} className="p-6 text-center">Đang tải...</td></tr>
                ) : diaryVm.isError ? (
                  <tr><td colSpan={5} className="p-6 text-center text-red-600">Lỗi khi tải dữ liệu</td></tr>
                ) : (() => {
                  const allRows = Array.isArray(diaryVm.data) ? diaryVm.data : []
                  const filteredRows = query ? allRows.filter((r: any) => ((r.maSV ?? r.maSinhVien ?? '') + '').toLowerCase().includes(query.toLowerCase())) : allRows
                  if (allRows.length === 0) return (<tr><td colSpan={5} className="p-6 text-center">Không có nhật ký cho tuần này</td></tr>)
                  if (filteredRows.length === 0) return (<tr><td colSpan={5} className="p-6 text-center">Không có kết quả phù hợp với tìm kiếm</td></tr>)
                  const totalElements = filteredRows.length
                  const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
                  const pagedRows = filteredRows.slice(page * pageSize, (page + 1) * pageSize)
                  return pagedRows.map((s: any) => (
                    <tr key={s.id} className="border-b border-[#E0E0E0] hover:bg-[#F2F8FC]">
                      <td className="px-4 py-2 text-center">{s.maSV}</td>
                      <td className="px-4 py-2 text-center">{s.hoTen}</td>
                      <td className="px-4 py-2 text-center">{s.tenDeTai}</td>
                      {(() => {
                        const info = diaryVm.getStatusInfo(s.trangThaiNhatKy)
                        return <td className={`px-4 py-2 text-center ${info.className}`}>{info.label}</td>
                      })()}
                      <td className="px-4 py-2 text-center">
                        <button
                          className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                          onClick={() => { detailVm.setProposalId(s.idDeTai ?? s.id); detailVm.setStudentId(s.maSV); setOpenDetail(true) }}
                          title="Xem chi tiết"
                        >
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#2F7CD3"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  ))
                })()}
              </tbody>
            </table>
          </div>
          <DiaryProgressModal open={openDetail} onClose={() => { setOpenDetail(false); detailVm.setProposalId(null); detailVm.setStudentId(null) }} data={detailVm.data} />
          {/* Pagination controls (client-side, similar to DoAnListPage) */}
          {(() => {
            const allRows = Array.isArray(diaryVm.data) ? diaryVm.data : []
            const filteredRows = query ? allRows.filter((r: any) => ((r.maSV ?? r.maSinhVien ?? '') + '').toLowerCase().includes(query.toLowerCase())) : allRows
            const totalElements = filteredRows.length
            const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
            if (!totalPages || totalPages <= 1) return null
            const showPageButtons = totalPages <= 10
            const pages = showPageButtons ? Array.from({ length: totalPages }).map((_, i) => i) : []
            return (
              <div className="p-4 border-t flex items-center justify-between">
                <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {page + 1} / {totalPages}</div>
                <div className="flex items-center gap-2">
                  <button aria-label="previous page" disabled={page <= 0} onClick={() => setPage(Math.max(0, page - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                  {showPageButtons ? (
                    pages.map(p => (
                      <button key={p} onClick={() => setPage(p)} className={[(p === page ? 'bg-sky-600 text-white' : 'bg-white border'), 'px-3 py-1 rounded'].join(' ')}>{p + 1}</button>
                    ))
                  ) : null}
                  <button aria-label="next page" disabled={page >= totalPages - 1} onClick={() => setPage(Math.min(totalPages - 1, page + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
                </div>
              </div>
            )
          })()}
        </div>
      </div>
    </div>
  );
}
