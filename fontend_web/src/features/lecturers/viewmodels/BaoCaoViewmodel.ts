import { useState, useEffect } from 'react'
import { useQuery } from '@tanstack/react-query'
import { fetchReportsPage } from '../services'
import type { PhanTrang } from '../models/PhanTrang'
import type { ReportVersion } from '../models/DanhSachBaoCaoModels'

export function useReportsViewModel(initialPage = 0, initialSize = 10) {
  const [page, setPage] = useState<number>(initialPage)
  const [size, setSize] = useState<number>(initialSize)
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined)
  const [search, setSearch] = useState<string>('')

  const query = useQuery<PhanTrang<ReportVersion>, Error>({
    queryKey: ['bao-cao-page', page, size, statusFilter],
    queryFn: () => fetchReportsPage({ page, size, sort: ['createdAt,DESC'], status: statusFilter }),
    staleTime: 1000 * 30,
  })

  // derived client-side filtering over the server page
  const source = query.data?.content ?? []
  const filtered = String(search ?? '').trim()
    ? (source as any[]).filter((r: any) => {
        const q = String(search ?? '').trim().toLowerCase()
        const code = String(r.maSinhVien ?? r.maSV ?? r.maSV ?? '')
        return code.toLowerCase().includes(q)
      })
    : source

  // if search reduces items to 0 on current page, reset to first page
  useEffect(() => {
    if (!search) return
    if ((filtered ?? []).length === 0) setPage(0)
  }, [search])

  return {
    page,
    setPage,
    size,
    setSize,
    statusFilter,
    setStatusFilter,
    search,
    setSearch,
    // rows for display on this page (after optional client-side filter)
    pagedRows: filtered,
    totalElements: query.data?.totalElements ?? 0,
    totalPages: query.data?.totalPages ?? 1,
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    refetch: () => query.refetch(),
  }
}

export default useReportsViewModel
