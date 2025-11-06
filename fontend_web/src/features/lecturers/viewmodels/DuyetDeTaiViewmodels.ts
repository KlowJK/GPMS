import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchReviewList, rejectDeTai, approveDeTai } from '../services'
import type { XetDuyetItem } from '../models/DanhSachDuyetModels'
import type { PhanTrang } from '../models/PhanTrang'

export function useReviewsViewModel(initialPage = 0, initialSize = 1000) {
  const [page, setPage] = useState(initialPage)
  const [size] = useState(initialSize)
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined)
  // search used for client-side filtering (moved from page)
  const [search, setSearch] = useState('')
  // client-side pagination over the visible list
  const [clientPage, setClientPage] = useState<number>(0)
  const [clientSize, setClientSize] = useState<number>(10)
  const queryClient = useQueryClient()

  const query = useQuery<PhanTrang<XetDuyetItem>, Error>({
    queryKey: ['lecturers-reviews', page, size, statusFilter],
    queryFn: () => fetchReviewList({ status: statusFilter, page, size, sort: [] }),
    staleTime: 1000 * 60, // 1 minute
  })

  const [approvingId, setApprovingId] = useState<string | null>(null)

  const approveMutation = useMutation<any, Error, string>({
    mutationFn: (idDeTai: string) => approveDeTai(idDeTai, { approved: true, nhanXet: '' }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['lecturers-reviews'] as any }),
  })

  const rejectMutation = useMutation<any, Error, { id: string; nhanXet: string }>({
    mutationFn: ({ id, nhanXet }) => rejectDeTai(id, nhanXet),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['lecturers-reviews'] as any }),
  })

  function openPdf(url?: string | null) {
    if (!url) return
    window.open(url, '_blank')
  }

  return {
    page,
    setPage,
    size,
    statusFilter,
    setStatusFilter,
    search,
    setSearch,
    // client-side paging controls
    clientPage,
    setClientPage,
    clientSize,
    setClientSize,
    // derived client-side rows
    sourceRows: query.data?.content ?? [],
    filteredRows: ((query.data?.content ?? []) as any[]).filter((r: any) => {
      const q = String(search ?? '').trim()
      if (!q) return true
      const lower = q.toLowerCase()
      const code = String(r.maSV ?? r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    }),
    totalElements: (((query.data?.content ?? []) as any[]).filter((r: any) => {
      const q = String(search ?? '').trim()
      if (!q) return true
      const lower = q.toLowerCase()
      const code = String(r.maSV ?? r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    })).length,
    totalPages: Math.max(1, Math.ceil(((((query.data?.content ?? []) as any[]).filter((r: any) => {
      const q = String(search ?? '').trim()
      if (!q) return true
      const lower = q.toLowerCase()
      const code = String(r.maSV ?? r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    })).length) / clientSize)),
    pagedRows: (((query.data?.content ?? []) as any[]).filter((r: any) => {
      const q = String(search ?? '').trim()
      if (!q) return true
      const lower = q.toLowerCase()
      const code = String(r.maSV ?? r.maSinhVien ?? r.maSV ?? '')
      return code.toLowerCase().includes(lower)
    })).slice(clientPage * clientSize, (clientPage + 1) * clientSize),
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    approve: (id: string) => {
      setApprovingId(id)
      approveMutation.mutate(id, {
        onSettled: () => setApprovingId(null),
      })
    },
    reject: (id: string) => rejectMutation.mutate({ id, nhanXet: '' }),
    rejectWithReason: (id: string, nhanXet: string) => rejectMutation.mutate({ id, nhanXet }),
    approvingId,
    openPdf,
  }
}
