import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchReviewList, rejectReview, approveDeTai } from '../services/api'
import type { XetDuyetItem, PageXetDuyet } from '../models/danh_sach_duyet'

export function useReviewsViewModel(initialPage = 0, initialSize = 10) {
  const [page, setPage] = useState(initialPage)
  const [size] = useState(initialSize)
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined)
  const [search, setSearch] = useState('')
  const queryClient = useQueryClient()

  const query = useQuery<PageXetDuyet, Error>({
    queryKey: ['lecturers-reviews', page, size, statusFilter],
    queryFn: () => fetchReviewList({ status: statusFilter, page, size, sort: [] }),
    staleTime: 1000 * 60, // 1 minute
  })

  const [approvingId, setApprovingId] = useState<string | null>(null)

  const approveMutation = useMutation<any, Error, string>({
    mutationFn: (idDeTai: string) => approveDeTai(idDeTai, { approved: true, nhanXet: '' }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['lecturers-reviews'] as any }),
  })

  const rejectMutation = useMutation<any, Error, string>({
    mutationFn: (idDeTai: string) => rejectReview(idDeTai),
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
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    approve: (id: string) => {
      setApprovingId(id)
      approveMutation.mutate(id, {
        onSettled: () => setApprovingId(null),
      })
    },
    reject: (id: string) => rejectMutation.mutate(id),
    approvingId,
    openPdf,
  }
}
