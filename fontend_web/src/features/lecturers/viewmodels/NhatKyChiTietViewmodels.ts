import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchStudentDiaryByProposal, reviewDiaryEntry } from '../services/api'

export function useDiaryDetailViewModel() {
  const [proposalId, setProposalId] = useState<string | number | null>(null)
  const [studentId, setStudentId] = useState<string | number | null>(null)

  const query = useQuery<any[], Error>({
    queryKey: ['diary-student', studentId, proposalId],
    queryFn: () => fetchStudentDiaryByProposal(proposalId as any, studentId as any),
    enabled: !!proposalId && !!studentId,
    staleTime: 1000 * 60,
  })

  const qc = useQueryClient()

  const mutation = useMutation({
    mutationFn: ({ entryId, payload }: { entryId: string | number; payload: { id: number | string; nhanXet: string } }) =>
      reviewDiaryEntry(entryId, payload),
    onSuccess: (res) => {
      // invalidate the diary-student query so UI refreshes
      if (studentId && proposalId) qc.invalidateQueries({ queryKey: ['diary-student', studentId, proposalId] })
      else qc.invalidateQueries({ predicate: (query) => String(query.queryKey?.[0]) === 'diary-student' })
    },
  })

  return {
    proposalId,
    setProposalId,
    studentId,
    setStudentId,
    data: query.data ?? [],
    isLoading: query.isLoading,
    isError: query.isError,
    review: mutation,
  }
}

export default useDiaryDetailViewModel
