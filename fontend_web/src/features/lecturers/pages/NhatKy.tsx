
import { Link } from "react-router-dom";
import { useState } from "react";
import { useQuery } from '@tanstack/react-query'
import { fetchTuansByLecturer } from '../services/api'
import { formatDateTime, parseISOToDate } from '@shared/utils/format'
import useDiaryViewModel from '../viewmodels/useDiaryViewModel'
import DiaryProgressModal from '../components/Nhat_ky_chi_tiet'
import useDiaryDetailViewModel from '../viewmodels/useDiaryDetailViewModel'
import { useEffect } from 'react'

// static weeks for combobox (1..11)
const WEEKS = Array.from({ length: 11 }, (_, i) => i + 1)
// fallback week entries used only when API data missing
const FALLBACK_WEEKS = Array.from({ length: 11 }, (_, i) => ({ tuan: i + 1, ngayBatDau: null, ngayKetThuc: null }));


export default function NhatKy() {
  const [week, setWeek] = useState(1);
  const [page, setPage] = useState(1);
  const pageSize = 6;
  const total = 12;
  const totalPages = Math.ceil(total / pageSize);

  const { data: tuans, isLoading: isTuansLoading, isError: isTuansError } = useQuery<any[], Error>({
    queryKey: ['tuans-by-lecturer'],
    queryFn: () => fetchTuansByLecturer(false),
    staleTime: 1000 * 60,
  })
  const weeks = Array.isArray(tuans) && tuans.length > 0 ? tuans : FALLBACK_WEEKS

  // Determine the current submission week based on today's date.
  // This is independent from the select `week` value (combo box).
  const now = new Date()
  const currentWeekEntry =
    weeks.find((w: any) => {
      const s = parseISOToDate(w.ngayBatDau)
      const e = parseISOToDate(w.ngayKetThuc)
      if (s && e) return now >= s && now <= e
      return false
    }) || weeks[0]
  const selectedWeekEntry = weeks.find((w: any) => w.tuan === week) || weeks[0]

  // MVVM: use diary viewmodel to load entries for the selected week
  const diaryVm = useDiaryViewModel(week)
  // keep vm.week in sync with select control
  if (diaryVm.week !== week) diaryVm.setWeek(week)

  const detailVm = useDiaryDetailViewModel()
  const [openDetail, setOpenDetail] = useState(false)

  useEffect(() => {
    if (!openDetail) detailVm.setProposalId(null)
  }, [openDetail])

  // Pagination with ellipsis for demo
  const getPagination = () => {
    const pages = [];
    if (totalPages <= 7) {
      for (let i = 1; i <= totalPages; i++) pages.push(i);
    } else {
      if (page <= 4) {
        pages.push(1, 2, 3, 4, 5, '...', totalPages);
      } else if (page >= totalPages - 3) {
        pages.push(1, '...', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages);
      } else {
        pages.push(1, '...', page - 1, page, page + 1, '...', totalPages);
      }
    }
    return pages;
  };

  // Normalize backend status codes to a display label + color class
  const getStatusInfo = (raw?: any) => {
    if (raw == null) return { label: '', className: '' }
    const s = String(raw).toUpperCase().replace(/\s+|_|-|\./g, '')
    // completed / finished (Hoàn thành)
    if (s.includes('HOANTHANH') || s.includes('HOANTHAN') || s.includes('COMPLETED') || s.includes('FINISHED')) {
      return { label: 'Hoàn thành', className: 'text-emerald-700 font-semibold' }
    }
    // consider common variants: DA, DANOP, DADUYET => Đã nộp
    if (s.includes('DANOP') || s === 'DA' || s.includes('DADUYET') || s.includes('DANOP')) {
      return { label: 'Đã nộp', className: 'text-green-500 font-semibold' }
    }
    // pending review: CHO, CHODUYET, CHOXET => Chờ duyệt (blue)
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO') {
      return { label: 'Chờ duyệt', className: 'text-sky-600 font-semibold' }
    }
    // variants for not submitted: CHUA, CHUANOP, CHUA_NOP, CHO, CHODUYET => Chưa nộp
    if (s.includes('CHUA') || s.includes('CHUANOP') ) {
      return { label: 'Chưa nộp', className: 'text-yellow-500 font-semibold' }
    }
    // rejected
    if (s.includes('TUCHOI') || s.includes('TUCHOI') || s.includes('REJECT') ) {
      return { label: 'Từ chối', className: 'text-red-600 font-semibold' }
    }
    // fallback: return original
    return { label: String(raw), className: '' }
  }

  return (
    <div className="min-h-[calc(100vh-80px)] flex flex-col items-stretch">
      <div className="w-full max-w-full mx-auto px-0">
        <div className="bg-white shadow rounded-md p-8 border-10 border-[#2F7CD3] w-full max-w-full">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-semibold text-[#222]">Danh sách sinh viên:</h1>
            <div className="flex items-center gap-2">
              <label htmlFor="week" className="font-medium text-[#222]">Tuần:</label>
              <select
                id="week"
                className="border border-[#B5D6F6] rounded px-2 py-1 min-w-[80px] focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
                value={week}
                onChange={e => setWeek(Number(e.target.value))}
              >
                {WEEKS.map((w) => (
                  <option key={w} value={w}>Tuần {w}</option>
                ))}
              </select>
            </div>
          </div>

          <div className="flex flex-wrap gap-8 mb-6 text-sm">
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Ngày bắt đầu : <span className="font-medium">{formatDateTime(currentWeekEntry?.ngayBatDau)}</span>
            </div>
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Ngày kết thúc : <span className="font-medium">{formatDateTime(currentWeekEntry?.ngayKetThuc)}</span>
            </div>
            <div className="flex items-center gap-2 text-[#222]">
              <span className="inline-block w-2 h-2 rounded-full bg-yellow-400 mr-1" />
              Thời hạn nộp nhật ký tuần <span className="font-medium">{currentWeekEntry?.tuan}</span> :
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
                ) : diaryVm.data.length === 0 ? (
                  <tr><td colSpan={5} className="p-6 text-center">Không có nhật ký cho tuần này</td></tr>
                ) : (
                  diaryVm.data.map((s: any) => (
                    <tr key={s.id} className="border-b border-[#E0E0E0] hover:bg-[#F2F8FC]">
                      <td className="px-4 py-2 text-center">{s.maSV}</td>
                      <td className="px-4 py-2 text-center">{s.hoTen}</td>
                      <td className="px-4 py-2 text-center">{s.tenDeTai}</td>
                      {(() => {
                        const info = getStatusInfo(s.trangThaiNhatKy)
                        return <td className={`px-4 py-2 text-center ${info.className}`}>{info.label}</td>
                      })()}
                      <td className="px-4 py-2 text-center">
                        <button
                          className="inline-flex items-center gap-2 px-3 py-1 bg-sky-50 border rounded text-sky-700 hover:bg-sky-100"
                          onClick={() => { detailVm.setProposalId(s.idDeTai ?? s.id); detailVm.setStudentId(s.maSV ?? s.maSV ?? s.maSV); setOpenDetail(true) }}
                          title="Xem chi tiết"
                        >
                          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="none" viewBox="0 0 24 24" stroke="#2F7CD3"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" /></svg>
                          Xem chi tiết
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          <DiaryProgressModal open={openDetail} onClose={() => { setOpenDetail(false); detailVm.setProposalId(null); detailVm.setStudentId(null) }} data={detailVm.data} />

          {/* Phân trang giả lập */}
          {/* <div className="flex justify-center items-center gap-1 mt-6">
            <button className="px-2 py-1 text-[#2F7CD3] rounded-full disabled:text-gray-300" disabled={page === 1} onClick={() => setPage(1)}>&laquo;</button>
            <button className="px-2 py-1 text-[#2F7CD3] rounded-full disabled:text-gray-300" disabled={page === 1} onClick={() => setPage(page - 1)}>&lsaquo;</button>
            {getPagination().map((p, i) =>
              typeof p === 'string' ? (
                <span key={i} className="px-2 py-1 text-gray-400">{p}</span>
              ) : (
                <button
                  key={i}
                  className={`px-2 py-1 rounded-full ${page === p ? 'bg-[#2F7CD3] text-white' : 'text-[#222] hover:bg-[#E6F0FA]'}`}
                  onClick={() => setPage(Number(p))}
                >
                  {p}
                </button>
              )
            )}
            <button className="px-2 py-1 text-[#2F7CD3] rounded-full disabled:text-gray-300" disabled={page === totalPages} onClick={() => setPage(page + 1)}>&rsaquo;</button>
            <button className="px-2 py-1 text-[#2F7CD3] rounded-full disabled:text-gray-300" disabled={page === totalPages} onClick={() => setPage(totalPages)}>&raquo;</button>
          </div> */}
        </div>
      </div>
    </div>
  );
}
