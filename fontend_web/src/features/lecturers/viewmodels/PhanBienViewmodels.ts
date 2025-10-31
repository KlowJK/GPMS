import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDeCuongPage } from '../services/api'

export function usePhanBienViewModel(currentName?: string, initialPage = 0, initialSize = 10) {
  // server-side paging (used in query)
  const [page, setPage] = useState<number>(initialPage)
  const [size, setSize] = useState<number>(initialSize)
  // client-side paging for visible (filtered) items
  const [clientPage, setClientPage] = useState<number>(0)
  const [clientSize, setClientSize] = useState<number>(10)
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

  // compute visible items for the current reviewer name (if provided)
  const visibleItems = (() => {
    if (!currentName) return items
    const cn = currentName.toString()
    return items.filter((it: any) => {
      const gv = (it.giangVienPhanBien ?? '')
      if (!gv) return false
      return gv.toString().includes(cn)
    })
  })()

  // client-side pagination over visibleItems
  const totalElements = visibleItems.length
  const totalPages = Math.max(1, Math.ceil(totalElements / clientSize))
  const pagedItems = visibleItems.slice(clientPage * clientSize, (clientPage + 1) * clientSize)

  // helper to normalize and render status badge (moved from page)
  function renderStatusBadge(raw: any) {
    const s = raw == null ? '' : String(raw)
    const key = s.toUpperCase().normalize('NFKD').replace(/\s+|_|-|\./g, '')

    if (!s) {
      return { label: 'Chưa phản biện', variant: 'neutral' }
    }

    if (key.includes('DADUYET') || key === 'DA' || key.includes('DA_DUYET') || key === 'TRUE') {
      return { label: 'Đã duyệt', variant: 'success' }
    }

    if (key.includes('CHOXET') || key.includes('CHODUYET') || key === 'CHO') {
      return { label: 'Chờ duyệt', variant: 'warn' }
    }

    if (key.includes('TUCHOI') || key.includes('TUCHỐI') || key.includes('TU_CHOI') || key.includes('TUCHOI') || key === 'FALSE') {
      return { label: 'Từ chối', variant: 'danger' }
    }

    return { label: s, variant: 'neutral' }
  }

  function refresh() {
    qc.invalidateQueries({ queryKey: ['de-cuong-page'] as any })
  }

  return {
    // server-side query controls
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

    // visible + client-side paging for the current reviewer
    visibleItems,
    pagedItems,
    totalElements,
    totalPages,
    clientPage,
    setClientPage,
    clientSize,
    setClientSize,

    // helpers
    renderStatusBadge,
  }
}

export default usePhanBienViewModel
