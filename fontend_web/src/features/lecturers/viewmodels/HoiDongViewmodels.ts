import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { fetchHoiDongList, fetchHoiDongDetail } from '../services/api'

export function useHoiDongViewModel(initialIdGiangVien?: number) {
  const [idGiangVien, setIdGiangVien] = useState<number | undefined>(initialIdGiangVien)

  const query = useQuery<any, Error>({
    queryKey: ['hoi-dong', idGiangVien],
    queryFn: () => fetchHoiDongList(idGiangVien),
  })

  return {
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    refetch: query.refetch,
    setIdGiangVien,
  }
}

export function useHoiDongDetailViewModel() {
  const [detailId, setDetailId] = useState<number | null>(null)
  const query = useQuery<any, Error>({
    queryKey: ['hoi-dong-detail', detailId],
    queryFn: () => fetchHoiDongDetail(detailId),
    enabled: !!detailId,
  })

  return {
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    setDetailId,
    refetch: query.refetch,
  }
}

export default useHoiDongViewModel
