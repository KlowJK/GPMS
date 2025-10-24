import { useState, useEffect } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { axios } from '@shared/libs/axios'
import { fetchReportsPage, approveDeCuong, rejectDeCuong } from '../services/api'

export default function useReportDetailViewModel(maSV?: string | null) {
  const qc = useQueryClient()

  const studentQuery = useQuery<any, Error>({
    queryKey: ['sinh-vien', maSV],
    queryFn: async () => {
      if (!maSV) return null
      const resp = await axios.get(`/api/sinh-vien/${encodeURIComponent(String(maSV))}`, { headers: { Accept: '*/*' }, timeout: 10000 })
      return resp.data?.result
    },
    enabled: !!maSV,
  })

  const reportsQuery = useQuery<any, Error>({
    queryKey: ['bao-cao-page', { maSV }],
    queryFn: () => fetchReportsPage({ page: 0, size: 100, sort: ['createdAt,DESC'], maSinhVien: String(maSV) }),
    enabled: !!maSV,
  })

  const displayProposalsFromApi = (reportsQuery.data?.content) ?? []
  const [displayProposals, setDisplayProposals] = useState<any[]>([])
  useEffect(() => {
    // initialize empty until data arrives
    if (!displayProposalsFromApi || displayProposalsFromApi.length === 0) return
    const mapped = displayProposalsFromApi.map((it: any) => {
      const fileUrl = it.fileUrl ?? it.duongDanFile ?? null
      const fileName = fileUrl ? String(fileUrl).split('/').pop() ?? '' : ''
      return {
        id: it.id,
        phienBan: it.phienBan,
        tenDeTai: it.tenDeTai ?? it.title ?? '',
        title: it.tenDeTai ?? it.title ?? '',
        ngayNop: it.ngayNop,
        fileUrl,
        fileName,
        trangThai: it.trangThai,
        diem: it.diemBaoCao ?? it.diem ?? null,
        nhanXets: it.nhanXet ? [{ nhanXet: it.nhanXet }] : (Array.isArray(it.nhanXets) ? it.nhanXets : []),
        maSV: it.maSinhVien ?? it.maSV ?? it.maSinhVien,
        raw: it,
      }
    })

    mapped.sort((a: any, b: any) => {
      const pa = a?.phienBan != null ? Number(a.phienBan) : Number.NEGATIVE_INFINITY
      const pb = b?.phienBan != null ? Number(b.phienBan) : Number.NEGATIVE_INFINITY
      return pb - pa
    })

    const filtered = String(maSV) ? mapped.filter((x: any) => String(x.maSV) === String(maSV)) : mapped
    setDisplayProposals(filtered)
  }, [displayProposalsFromApi, maSV])

  const versionSet = new Set(displayProposals.map((p: any) => (p?.phienBan != null ? String(p.phienBan) : null)).filter(Boolean))
  const versionCount = versionSet.size > 0 ? versionSet.size : displayProposals.length

  const [loadingId, setLoadingId] = useState<string | number | null>(null)

  // fallback manual approve/reject implementation using service calls + optimistic UI update
  const approve = async (id: string | number, phienBan?: number | string, nhanXet?: string) => {
    setLoadingId(id)
    // optimistic
    try {
      qc.setQueryData(['sinh-vien-proposals', maSV], (old: any[] | undefined) => {
        if (!Array.isArray(old)) return old
        return old.map(it => it.id === id ? { ...it, trangThai: 'DA_DUYET', nhanXets: Array.isArray(it.nhanXets) ? (nhanXet ? [...it.nhanXets, { nhanXet }] : it.nhanXets) : (nhanXet ? [{ nhanXet }] : []) } : it)
      })
    } catch (e) {}
    setDisplayProposals(prev => prev.map(item => item.id === id ? { ...item, trangThai: 'DA_DUYET', nhanXets: Array.isArray(item.nhanXets) ? (nhanXet ? [...item.nhanXets, { nhanXet }] : item.nhanXets) : (nhanXet ? [{ nhanXet }] : []) } : item))

    try {
      await approveDeCuong(id, phienBan, nhanXet)
    } catch (err: any) {
      try { alert('Lỗi khi duyệt: ' + (err?.message ?? err)) } catch (e) {}
    } finally {
      setLoadingId(null)
      qc.invalidateQueries({ queryKey: ['sinh-vien-proposals', maSV] })
      qc.invalidateQueries({ queryKey: ['sinh-vien', maSV] })
    }
  }

  const reject = async (id: string | number, phienBan?: number | string, nhanXet?: string) => {
    setLoadingId(id)
    try {
      qc.setQueryData(['sinh-vien-proposals', maSV], (old: any[] | undefined) => {
        if (!Array.isArray(old)) return old
        return old.map(it => it.id === id ? { ...it, trangThai: 'TU_CHOI', nhanXets: Array.isArray(it.nhanXets) ? (nhanXet ? [...it.nhanXets, { nhanXet }] : it.nhanXets) : (nhanXet ? [{ nhanXet }] : []) } : it)
      })
    } catch (e) {}
    setDisplayProposals(prev => prev.map(item => item.id === id ? { ...item, trangThai: 'TU_CHOI', nhanXets: Array.isArray(item.nhanXets) ? (nhanXet ? [...item.nhanXets, { nhanXet }] : item.nhanXets) : (nhanXet ? [{ nhanXet }] : []) } : item))

    try {
      await rejectDeCuong(id, phienBan, nhanXet)
    } catch (err: any) {
      try { alert('Lỗi khi từ chối: ' + (err?.message ?? err)) } catch (e) {}
    } finally {
      setLoadingId(null)
      qc.invalidateQueries({ queryKey: ['sinh-vien-proposals', maSV] })
      qc.invalidateQueries({ queryKey: ['sinh-vien', maSV] })
    }
  }

  return {
    student: studentQuery.data ?? null,
    displayProposals,
    versionCount,
    isLoading: studentQuery.isLoading || reportsQuery.isLoading,
    isError: studentQuery.isError || reportsQuery.isError,
    loadingId,
    approve,
    reject,
    refetch: () => { studentQuery.refetch(); reportsQuery.refetch() },
  }
}
