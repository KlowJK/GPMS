import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDeCuongPage } from '../services/api'

export function usePhanBienViewModel(initialPage = 0, initialSize = 10) {
  const [page, setPage] = useState<number>(initialPage)
  const [size, setSize] = useState<number>(initialSize)
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined)
  const [search, setSearch] = useState<string>('')
  const qc = useQueryClient()

  const query = useQuery<any, Error>({
    queryKey: ['de-cuong-page', page, size, statusFilter, search],
    queryFn: () => fetchDeCuongPage({ page, size, sort: ['updatedAt,DESC'], status: statusFilter }),
    staleTime: 1000 * 60,
  })

  // derived items
  const rawItems = (query.data?.content ?? [])

  // If multiple versions exist for the same proposal/student, keep only the largest phienBan.
  const items = (() => {
    if (!Array.isArray(rawItems) || rawItems.length === 0) return []

    // sort by phienBan desc so first encountered per key is the largest
    const sorted = [...rawItems].sort((a: any, b: any) => {
      const pa = a?.phienBan != null ? Number(a.phienBan) : Number.NEGATIVE_INFINITY
      const pb = b?.phienBan != null ? Number(b.phienBan) : Number.NEGATIVE_INFINITY
      return pb - pa
    })

    const seen = new Set<string>()
    const dedup: any[] = []

    for (const it of sorted) {
      // create a grouping key - prefer an explicit student id + title if available
      const key = `${String(it.maSinhVien ?? it.maSV ?? '')}||${String(it.tenDeTai ?? it.title ?? '')}`
      if (seen.has(key)) continue
      seen.add(key)
      dedup.push(it)
    }

    return dedup
  })()

  function refresh() {
    qc.invalidateQueries({ queryKey: ['de-cuong-page'] as any })
  }

  return {
    page,
    setPage,
    size,
    setSize,
    statusFilter,
    setStatusFilter,
    search,
    setSearch,
    data: query.data,
    items,
    isLoading: query.isLoading,
    isError: query.isError,
    refresh,
  }
}

export default usePhanBienViewModel
