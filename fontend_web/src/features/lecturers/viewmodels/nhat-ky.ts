import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDiaryListByWeek } from '../services/api'

export function useDiaryViewModel(initialWeek = 1) {
  const [week, setWeek] = useState<number>(initialWeek)
  const queryClient = useQueryClient()

  const diaryQuery = useQuery<any[], Error>({
    queryKey: ['diary-list', week],
    queryFn: () => fetchDiaryListByWeek(week),
    enabled: !!week,
    staleTime: 1000 * 60,
  })

  function refresh() {
    queryClient.invalidateQueries({ queryKey: ['diary-list'] as any })
  }

  return {
    week,
    setWeek,
    data: diaryQuery.data ?? [],
    isLoading: diaryQuery.isLoading,
    isError: diaryQuery.isError,
    refresh,
  }
}

export default useDiaryViewModel
