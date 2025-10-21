import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { fetchStudentDiaryByProposal } from '../services/api'

export function useDiaryDetailViewModel() {
  const [proposalId, setProposalId] = useState<string | number | null>(null)
  const [studentId, setStudentId] = useState<string | number | null>(null)

  const query = useQuery<any[], Error>({
    queryKey: ['diary-student', studentId, proposalId],
    queryFn: () => fetchStudentDiaryByProposal(proposalId as any, studentId as any),
    enabled: !!proposalId && !!studentId,
    staleTime: 1000 * 60,
  })

  return {
    proposalId,
    setProposalId,
    studentId,
    setStudentId,
    data: query.data ?? [],
    isLoading: query.isLoading,
    isError: query.isError,
  }
}

export default useDiaryDetailViewModel
