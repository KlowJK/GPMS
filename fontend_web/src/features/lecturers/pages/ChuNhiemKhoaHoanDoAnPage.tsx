import React, { useEffect, useState, useRef } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { fetchHoanDoAnByCnKhoa, duyetDonHoanDoAn } from '../services/deTaiApi'
import { formatDateTime } from '@shared/utils/format'
import { toast } from 'sonner'
import { DownloadCloud, Check } from 'lucide-react'
import ApproveModal from '../components/DuyetDonHoanDAModal'
import useChuNhiemKhoaHoanDoAnViewmodel from '../viewmodels/ChuNhiemKhoaHoanDoAnViewmodel'

// Map raw status keys to friendly label + color classes
function getStatusBadge(raw?: any) {
    const k = (String(raw ?? '') || '').normalize('NFD').replace(/\p{Diacritic}/gu, '').replace(/Đ/g, 'D').replace(/đ/g, 'd').toUpperCase().replace(/\s+|_|-|\./g, '')
    // default
    let label = String(raw ?? '')
    let classes = 'inline-block px-3 py-1 rounded-full text-xs bg-slate-100 text-slate-700'

    // standardized badge styles: compact, consistent sizing
    if (!k || k === '') {
        label = 'Chưa xử lý'
        classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-slate-100 text-slate-700'
        return { label, classes }
    }

    if (k.includes('TUCHOI') || k.includes('TUCH')) {
        label = 'Từ chối'
        classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-rose-50 text-rose-700'
        return { label, classes }
    }

    if (k.includes('DADUYET') || k === 'DA' || k.includes('DANOP')) {
        label = 'Đã duyệt'
        classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700'
        return { label, classes }
    }

    if (k.includes('NOP') || k.includes('DANOP') || k.includes('DANỘP')) {
        label = 'Đã nộp'
        classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-50 text-emerald-700'
        return { label, classes }
    }

    if (k.includes('CHO') || k.includes('CHOXET') || k.includes('CHODUYET')) {
        label = 'Chờ duyệt'
        classes = 'inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-amber-50 text-amber-700'
        return { label, classes }
    }

    // fallback show raw
    return { label, classes }
}

export default function ChuNhiemKhoaHoanDoAnPage() {
    // client-side pagination & search (like NhatKyPage)
    const [page, setPage] = useState<number>(0)
    const [pageSize, setPageSize] = useState<number>(10)
    const [queryText, setQueryText] = useState<string>('')

    // Fetch a large page to get all items for client-side filtering.
    // If dataset becomes large, consider server-side search/pagination instead.
    const allQuery = useQuery({
        queryKey: ['hoan-do-an-all'],
        queryFn: async () => await fetchHoanDoAnByCnKhoa({ page: 0, size: 10000, sort: ['updatedAt,DESC'] }),
    })

    useEffect(() => { setPage(0) }, [allQuery.data, pageSize, queryText])

    const data: any = allQuery.data ?? {}
    const allRows: any[] = Array.isArray(data?.content) ? data.content : []
    const filteredRows = queryText ? allRows.filter((r: any) => ((r.maSinhVien ?? r.sinhVienId ?? '') + '').toLowerCase().includes(queryText.toLowerCase())) : allRows

    const totalElements = filteredRows.length
    const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
    const pagedRows = filteredRows.slice(page * pageSize, (page + 1) * pageSize)

    // modal state for approving a request
    const [approveModal, setApproveModal] = useState<{ open: boolean; item?: any }>({ open: false })
    const [approvalFile, setApprovalFile] = useState<File | null>(null)
    const [dragActive, setDragActive] = useState<boolean>(false)
    const fileInputRef = useRef<HTMLInputElement | null>(null)

    // use central viewmodel for modal behavior & mutation
    const vm = useChuNhiemKhoaHoanDoAnViewmodel()

    return (
            <div>
                <div className="flex items-center justify-between mb-6">
                    <h2 className="text-2xl font-semibold">Danh sách đơn hoãn đồ án</h2>
                    <div className="flex items-center gap-4">
                        <div className="w-64">
                            <input value={queryText} onChange={e => setQueryText(e.target.value)} placeholder="Tìm theo mã sinh viên" className="w-full border rounded px-3 py-2 text-sm" />
                        </div>
                    </div>
                </div>

            {allQuery.isLoading ? (
                <div className="bg-white p-6 rounded shadow text-center">Đang tải...</div>
            ) : allQuery.isError ? (
                <div className="bg-white p-6 rounded shadow text-center text-red-600">Lỗi khi tải dữ liệu</div>
            ) : (
                        <div className="bg-white shadow rounded">
                            <table className="min-w-full table-auto">
                                <thead>
                                    <tr className="border-b">
                                        <th className="text-left px-6 py-4">Mã sinh viên</th>
                                        <th className="text-left px-6 py-4">Họ và tên</th>
                                        <th className="text-left px-6 py-4">Lớp</th>
                                        <th className="text-left px-6 py-4">Ngành</th>
                                        <th className="text-left px-6 py-4">Trạng thái</th>
                                        <th className="text-left px-6 py-4">Lý do</th>
                                        <th className="text-left px-6 py-4">Minh chứng</th>
                                        <th className="text-left px-6 py-4">Hoạt động</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {pagedRows.length === 0 ? (
                                        <tr><td colSpan={8} className="p-6 text-center">Không có kết quả</td></tr>
                                    ) : (
                                        pagedRows.map((row: any) => (
                                            <tr key={row.id} className="border-b hover:bg-slate-50">
                                                <td className="px-6 py-4 font-medium">{row.maSinhVien ?? row.sinhVienId}</td>
                                                <td className="px-6 py-4">{row.hoTenSinhVien}</td>
                                                <td className="px-6 py-4">{row.lopSinhVien}</td>
                                                <td className="px-6 py-4">{row.nganhSinhVien}</td>
                                                <td className="px-6 py-4">
                                                    {(() => {
                                                        const s = getStatusBadge(row.trangThai)
                                                        return <span className={s.classes}>{s.label}</span>
                                                    })()}
                                                </td>
                                                <td className="px-6 py-4 max-w-[40ch] break-words whitespace-normal">{row.lyDo}</td>
                                                <td className="px-6 py-4">{row.minhChungUrl ? <a className="text-sky-600 underline" href={row.minhChungUrl} target="_blank" rel="noreferrer">Xem</a> : '—'}</td>
                                                <td className="px-6 py-4">
                                                    {(() => {
                                                            const status = String(row.trangThai ?? '').toUpperCase()
                                                            const isPending = status.includes('CHO') || status.includes('CHOXET') || status.includes('CHODUYET')
                                                            // reuse the friendly label from getStatusBadge for approved detection
                                                            const s = getStatusBadge(row.trangThai)

                                                            if (isPending) {
                                                                return (
                                                                    <button
                                                                        type="button"
                                                                        disabled={vm.approveMut.status === 'pending'}
                                                                        onClick={() => { vm.openApprove(row) }}
                                                                        className="inline-flex items-center gap-2 px-3 py-1 rounded-md text-sm bg-sky-600 hover:bg-sky-700 text-white"
                                                                    >
                                                                        <Check size={14} />
                                                                        <span className="font-medium">Duyệt</span>
                                                                    </button>
                                                                )
                                                            }

                                                            // If already approved, show a link to the approval minutes if available
                                                            if (s.label === 'Đã duyệt') {
                                                                // include ghiChuQuyetDinh / ghiChuQuyetDinhUrl as candidate fields for the approval minutes URL
                                                                const fileUrl = row.ghiChuQuyetDinh ?? row.ghiChuQuyetDinhUrl ?? row.bienBanHopPheDuyetUrl ?? row.bienbanHopPheDuyetUrl ?? row.bienBanUrl ?? row.bienBan?.url ?? row.bienBanFileUrl ?? row.minhChungUrl ?? row.bienbanUrl
                                                                if (fileUrl) {
                                                                    return (
                                                                        <button
                                                                            type="button"
                                                                            onClick={() => window.open(String(fileUrl), '_blank', 'noopener')}
                                                                            className="inline-flex items-center gap-2 px-3 py-1 rounded-md text-sm bg-white border border-sky-100 text-sky-600 hover:bg-sky-50"
                                                                            aria-label="Xem biên bản"
                                                                        >
                                                                            <DownloadCloud size={16} />
                                                                            <span className="font-medium">Biên bản</span>
                                                                        </button>
                                                                    )
                                                                }
                                                                return <span className="text-slate-500">—</span>
                                                            }

                                                            return <span className="text-slate-500">—</span>
                                                        })()}
                                                </td>
                                            </tr>
                                        ))
                                    )}
                                </tbody>
                            </table>
                            <ApproveModal
                                open={vm.approveModal.open}
                                item={vm.approveModal.item}
                                approvalFile={vm.approvalFile}
                                setApprovalFile={vm.setApprovalFile}
                                dragActive={vm.dragActive}
                                setDragActive={vm.setDragActive}
                                fileInputRef={vm.fileInputRef}
                                onClose={vm.closeApprove}
                                onApprove={vm.approveAsync}
                                approveMut={vm.approveMut}
                            />

                    {/* Pagination controls (client-side, copy of NhatKyPage) */}
                    {(() => {
                        if (!totalPages || totalPages <= 1) return null
                        const showPageButtons = totalPages <= 10
                        const pages = showPageButtons ? Array.from({ length: totalPages }).map((_, i) => i) : []
                        return (
                            <div className="p-4 border-t flex items-center justify-between">
                                <div className="text-sm text-slate-600">Hiển thị {totalElements} kết quả — Trang {page + 1} / {totalPages}</div>
                                <div className="flex items-center gap-2">
                                    <button aria-label="previous page" disabled={page <= 0} onClick={() => setPage(Math.max(0, page - 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&lt;</button>
                                    {showPageButtons ? (
                                        pages.map(p => (
                                            <button key={p} onClick={() => setPage(p)} className={[(p === page ? 'bg-sky-600 text-white' : 'bg-white border'), 'px-3 py-1 rounded'].join(' ')}>{p + 1}</button>
                                        ))
                                    ) : null}
                                    <button aria-label="next page" disabled={page >= totalPages - 1} onClick={() => setPage(Math.min(totalPages - 1, page + 1))} className="px-3 py-1 rounded bg-gray-200 disabled:opacity-50">&gt;</button>
                                </div>
                            </div>
                        )
                    })()}
                </div>
            )}
        </div>
    )
}
