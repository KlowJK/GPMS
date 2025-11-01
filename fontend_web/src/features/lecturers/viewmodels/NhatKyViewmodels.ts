import { useState, useMemo } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDiaryListByWeek, fetchTuansByLecturer } from '../services/api'
import { parseISOToDate } from '@shared/utils/format'

// fallback week entries used only when API data missing
const FALLBACK_WEEKS = Array.from({ length: 11 }, (_, i) => ({ tuan: i + 1, ngayBatDau: null, ngayKetThuc: null }))

export function useDiaryViewModel(initialWeek = 1) {
  const [week, setWeek] = useState<number>(initialWeek)
  const [page, setPage] = useState<number>(1)
  const pageSize = 6
  const total = 12 // demo fallback (kept for parity with previous UI)
  const totalPages = Math.ceil(total / pageSize)

  const queryClient = useQueryClient()

  const diaryQuery = useQuery<any[], Error>({
    queryKey: ['diary-list', week],
    queryFn: () => fetchDiaryListByWeek(week),
    enabled: !!week,
    staleTime: 1000 * 60,
  })

  const tuansQuery = useQuery<any[], Error>({
    queryKey: ['tuans-by-lecturer'],
    queryFn: () => fetchTuansByLecturer(false),
    staleTime: 1000 * 60,
  })

  // keep raw tuan entries from API (may contain date ranges); fall back to empty entries
  const tuanEntries = Array.isArray(tuansQuery.data) && tuansQuery.data.length > 0 ? tuansQuery.data : FALLBACK_WEEKS

  // always expose week numbers 1..11 for the select control so UI is consistent
  const weeks = Array.from({ length: 11 }, (_, i) => i + 1)

  // Determine the current submission week based on today's date.
  const now = new Date()
  const currentWeekEntry = useMemo(() => {
    return (
      tuanEntries.find((w: any) => {
        const s = parseISOToDate(w.ngayBatDau)
        const e = parseISOToDate(w.ngayKetThuc)
        if (s && e) return now >= s && now <= e
        return false
      }) || tuanEntries[0]
    )
  }, [tuanEntries])

  const selectedWeekEntry = useMemo(() => tuanEntries.find((w: any) => w.tuan === week) || tuanEntries[0], [tuanEntries, week])

  function refresh() {
    queryClient.invalidateQueries({ queryKey: ['diary-list'] as any })
  }

  // Pagination helper (kept similar to original demo code)
  function getPagination() {
    const pages: Array<number | string> = []
    if (totalPages <= 7) {
      for (let i = 1; i <= totalPages; i++) pages.push(i)
    } else {
      if (page <= 4) {
        pages.push(1, 2, 3, 4, 5, '...', totalPages)
      } else if (page >= totalPages - 3) {
        pages.push(1, '...', totalPages - 4, totalPages - 3, totalPages - 2, totalPages - 1, totalPages)
      } else {
        pages.push(1, '...', page - 1, page, page + 1, '...', totalPages)
      }
    }
    return pages
  }

  // Normalize backend status codes to a display label + color class
  function getStatusInfo(raw?: any) {
    if (raw == null) return { label: '', className: '' }
    const s = String(raw).toUpperCase().replace(/\s+|_|-|\./g, '')
    if (s.includes('HOANTHANH') || s.includes('HOANTHAN') || s.includes('COMPLETED') || s.includes('FINISHED')) {
      return { label: 'Hoàn thành', className: 'text-emerald-700 font-semibold' }
    }
    if (s.includes('DANOP') || s === 'DA' || s.includes('DADUYET')) {
      return { label: 'Đã nộp', className: 'text-green-500 font-semibold' }
    }
    if (s.includes('CHOXET') || s.includes('CHODUYET') || s === 'CHO') {
      return { label: 'Chờ duyệt', className: 'text-sky-600 font-semibold' }
    }
    if (s.includes('CHUA') || s.includes('CHUANOP')) {
      return { label: 'Chưa nộp', className: 'text-yellow-500 font-semibold' }
    }
    if (s.includes('TUCHOI') || s.includes('REJECT')) {
      return { label: 'Từ chối', className: 'text-red-600 font-semibold' }
    }
    return { label: String(raw), className: '' }
  }

  return {
    // week selection
    week,
    setWeek,
    weeks,
    isTuansLoading: tuansQuery.isLoading,
    isTuansError: tuansQuery.isError,
    currentWeekEntry,
    selectedWeekEntry,

    // diary list (by week)
    data: diaryQuery.data ?? [],
    isLoading: diaryQuery.isLoading,
    isError: diaryQuery.isError,

    // pagination
    page,
    setPage,
    pageSize,
    total,
    totalPages,
    getPagination,

    // helpers
    getStatusInfo,
    refresh,
  }
}

export default useDiaryViewModel
