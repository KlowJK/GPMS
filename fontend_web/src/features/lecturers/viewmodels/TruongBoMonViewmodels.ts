import { useState } from 'react'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { fetchDeCuongPage, getLecturersByBoMon } from '../services'
import { listLecturersNormalized } from '@/features/assistants/services/user/userApi'

function normalizeName(x: any) {
  if (!x) return ''
  try {
    const s = String(x).toLowerCase()
    const noTitle = s.replace(/\b(pg?s|p\.?g\.?s|ths|th\.?s|ts|dr)\.?\b\s*/gi, '')
    try {
      return noTitle.normalize('NFKD').replace(/\p{M}/gu, '').replace(/\s+/g, ' ').trim()
    } catch {
      return noTitle.replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, ' ').trim()
    }
  } catch {
    return String(x)
  }
}

export function useTruongBoMonViewModel(initialName?: string, initialPage = 0, initialSize = 1000) {
  const [page, setPage] = useState<number>(initialPage)
  const [size, setSize] = useState<number>(initialSize)
  const [clientPage, setClientPage] = useState<number>(0)
  const [clientSize, setClientSize] = useState<number>(1000)
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined)
  const [search, setSearch] = useState<string>('')
  const qc = useQueryClient()

  const query = useQuery<any, Error>({
    queryKey: ['de-cuong-page-tbm', page, size, statusFilter, search],
    queryFn: () => fetchDeCuongPage({ page, size, sort: ['updatedAt,DESC'], status: statusFilter }),
    staleTime: 1000 * 60,
  })

  const rawItems = query.data?.content ?? []

  // dedupe by student+title keeping highest phienBan
  const items = (() => {
    if (!Array.isArray(rawItems) || rawItems.length === 0) return []
    const sorted = [...rawItems].sort((a: any, b: any) => {
      const pa = a?.phienBan != null ? Number(a.phienBan) : Number.NEGATIVE_INFINITY
      const pb = b?.phienBan != null ? Number(b.phienBan) : Number.NEGATIVE_INFINITY
      return pb - pa
    })
    const seen = new Set<string>()
    const dedup: any[] = []
    for (const it of sorted) {
      const key = `${String(it.maSinhVien ?? it.maSV ?? '')}||${String(it.tenDeTai ?? it.title ?? '')}`
      if (seen.has(key)) continue
      seen.add(key)
      dedup.push(it)
    }
    return dedup
  })()

  function renderStatusBadge(raw: any) {
    const s = raw == null ? '' : String(raw)
    const key = s.toUpperCase().normalize('NFKD').replace(/\s+|_|-|\./g, '')
    if (!s) return { label: 'Chưa', variant: 'neutral' }
    if (key.includes('DADUYET') || key === 'DA' || key.includes('DA_DUYET') || key === 'TRUE') return { label: 'Đã duyệt', variant: 'success' }
    if (key.includes('CHOXET') || key.includes('CHODUYET') || key === 'CHO') return { label: 'Chờ duyệt', variant: 'warn' }
    if (key.includes('TUCHOI') || key.includes('TU_CHOI') || key === 'FALSE') return { label: 'Từ chối', variant: 'danger' }
    return { label: s, variant: 'neutral' }
  }

  function refresh() {
    qc.invalidateQueries({ queryKey: ['de-cuong-page-tbm'] as any })
  }

  // visible items for a given TBM name (caller should pass normalized name and do matching)
  function visibleForName(name?: string) {
    if (!name) return []
    const target = normalizeName(name)
    // Fuzzy match: consider exact equal or substring (to tolerate extra titles/ordering)
    return items.filter((it: any) => {
      const raw = it.truongBoMon ?? it.raw?.truongBoMon ?? ''
      const norm = normalizeName(raw)
      if (!norm) return false
      if (norm === target) return true
      if (norm.includes(target)) return true
      if (target.includes(norm)) return true
      // also compare token intersection (at least two tokens in common)
      const ta = norm.split(' ').filter(Boolean)
      const tb = target.split(' ').filter(Boolean)
      const common = ta.filter(t => tb.includes(t))
      return common.length >= Math.min(2, Math.min(ta.length, tb.length))
    })
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

    // client-side paging controls for visible lists
    clientPage,
    setClientPage,
    clientSize,
    setClientSize,

    // helpers
    renderStatusBadge,
    visibleForName,
  }
}

export default useTruongBoMonViewModel

// --- Helpers used by UI components ---
export function extractBoMonId(s: any) {
  if (!s) return null
  return s.idBoMon ?? s.boMonId ?? s.id_bm ?? s.id_bomon ?? s.boMon?.id ?? s.boMonId ?? null
}

/**
 * Load lecturers for a student: prefer GET /api/giang-vien/{boMonId} when boMon available,
 * otherwise fallback to the normalized lecturers list.
 */
export async function loadLecturersForStudent(student: any) {
  const boMonId = extractBoMonId(student)
  if (boMonId) {
    try {
      const arr = await getLecturersByBoMon(boMonId)
      if (Array.isArray(arr) && arr.length > 0) {
        return arr.map((x: any) => ({
          id: String(x.id ?? x.giangVienId ?? x.maGiangVien ?? x.maGV ?? x.hoTen ?? ''),
          maGiangVien: x.maGiangVien ?? x.maGV,
          hoTen: x.hoTen ?? x.hoVaTen ?? x.ten ?? '',
          raw: x,
        }))
      }
    } catch (e) {
      // ignore and fallback
      console.debug('loadLecturersForStudent: getLecturersByBoMon failed', e)
    }
  }

  // fallback: return the normalized lecturers list (first page large size)
  try {
    const res = await listLecturersNormalized({ page: 0, size: 1000 })
    return Array.isArray(res?.content) ? res.content : []
  } catch (e) {
    console.debug('loadLecturersForStudent: fallback list failed', e)
    return []
  }
}
