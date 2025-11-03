import React, { useEffect, useState } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import useHoiDongViewModel, { useHoiDongDetailViewModel } from '../viewmodels/HoiDongViewmodels'
import HoiDongScoreModal from '../components/HoiDongScoreModal'

export default function HoiDongDetailPage() {
    const { id } = useParams()
    const navigate = useNavigate()
    const detailVm = useHoiDongDetailViewModel()

    // client-side pagination + search (follow NhatKyPage pattern)
    const [page, setPage] = useState<number>(0)
    const [pageSize, setPageSize] = useState<number>(10)
    const [query, setQuery] = useState<string>('')

    useEffect(() => {
        if (!id) return
        const n = Number(id)
        if (!isNaN(n)) detailVm.setDetailId(n)
        return () => detailVm.setDetailId(null)
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [id])

    const fmt = (v?: string) => {
        if (!v) return '—'
        try {
            const d = new Date(v)
            return isNaN(d.getTime()) ? v : d.toLocaleString()
        } catch {
            return v
        }
    }

    const data = detailVm.data
    const [scoreOpen, setScoreOpen] = useState(false)
    const [selectedStudent, setSelectedStudent] = useState<any | null>(null)

    function openScore(s: any) {
        setSelectedStudent(s)
        setScoreOpen(true)
    }

    // reset to first page when data, pageSize or query changes
    useEffect(() => { setPage(0) }, [data, pageSize, query])

    return (
        <div className="min-h-[calc(100vh-80px)]">
            <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-4">
                    <h1 className="text-2xl font-semibold">Chi tiết hội đồng</h1>
                </div>
                <div className="w-56">
                    <input
                        value={query}
                        onChange={e => setQuery(e.target.value)}
                        placeholder="Tìm theo mã, tên, lớp, đề tài"
                        className="w-full border rounded px-3 py-2 text-sm"
                    />
                </div>
            </div>

            <div className="bg-white shadow rounded-md p-6">
                {detailVm.isLoading ? (
                    <div className="p-6 text-center">Đang tải chi tiết...</div>
                ) : detailVm.isError ? (
                    <div className="p-4 text-red-600">Lỗi khi tải chi tiết</div>
                ) : !data ? (
                    <div className="p-4">Không có dữ liệu</div>
                ) : (
                    <div className="space-y-6">
                        <div className="grid grid-cols-3 gap-4">
                            <div>
                                <div className="text-sm text-slate-500">Tên hội đồng</div>
                                <div className="font-medium text-slate-800">{data.tenHoiDong}</div>
                            </div>

                            <div>
                                <div className="text-sm text-slate-500">Thời gian bắt đầu</div>
                                <div className="text-slate-700">{fmt(data.thoiGianBatDau)}</div>
                            </div>

                            <div>
                                <div className="text-sm text-slate-500">Thời gian kết thúc</div>
                                <div className="text-slate-700">{fmt(data.thoiGianKetThuc)}</div>
                            </div>
                            <div>
                                <div className="text-sm text-slate-500">Địa chỉ</div>
                                <div className="mt-1 font-medium">{(data.diaChi ?? data.diaDiem) ? (data.diaChi ?? data.diaDiem) : 'Chưa có địa chỉ'}</div>
                            </div>
                            <div>
                                <div className="text-sm text-slate-500">Chủ tịch</div>
                                <div className="mt-1 font-medium">{data.chuTich ?? '—'}</div>
                            </div>
                            <div>
                                <div className="text-sm text-slate-500">Thư ký</div>
                                <div className="mt-1 font-medium">{data.thuKy ?? '—'}</div>
                            </div>
                        </div>
                        <div>
                            <div className="text-sm text-slate-500 mb-2">Các thành viên</div>
                            <div className="flex flex-wrap gap-2">
                                {(data.giangVienPhanBien || []).map((g: string, i: number) => (
                                    <span key={i} className="px-3 py-1 bg-slate-100 text-slate-800 rounded-full text-sm">{g}</span>
                                ))}
                            </div>
                        </div>

                        <div>
                            <div className="flex items-center justify-between">
                                <div className="text-sm text-slate-500 mb-2">Danh sách sinh viên</div>
                                <div className="flex items-center gap-4">
                                    <div className="text-sm text-slate-400">Tổng: {(data.sinhVienList || []).length}</div>
                                </div>
                            </div>

                            <div className="overflow-x-auto border rounded">
                                <table className="min-w-full table-auto text-sm">
                                    <thead>
                                        <tr className="bg-slate-50">
                                            <th className="text-left px-3 py-2">Mã SV</th>
                                            <th className="text-left px-3 py-2">Họ và tên</th>
                                            <th className="text-left px-3 py-2">Lớp</th>
                                            <th className="text-left px-3 py-2">Bộ môn</th>
                                            <th className="text-left px-3 py-2">Tên đề tài</th>
                                            <th className="text-left px-3 py-2">GVHD</th>
                                            <th className="text-left px-3 py-2">Hoạt động</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        {(() => {
                                            const allRows = Array.isArray(data.sinhVienList) ? data.sinhVienList : []
                                            const q = (query || '').toLowerCase().trim()
                                            const filteredRows = q
                                                ? allRows.filter((r: any) => {
                                                    const hay = (((r.maSV ?? '') + ' ' + (r.hoTen ?? '') + ' ' + (r.lop ?? '') + ' ' + (r.tenDeTai ?? '') + ' ' + (r.gvhd ?? '') + ' ' + (r.boMon ?? '')) + '').toLowerCase()
                                                    return hay.includes(q)
                                                })
                                                : allRows

                                            if (allRows.length === 0) return (<tr><td colSpan={7} className="p-6 text-center">Không có sinh viên</td></tr>)
                                            if (filteredRows.length === 0) return (<tr><td colSpan={7} className="p-6 text-center">Không có kết quả phù hợp với tìm kiếm</td></tr>)

                                            const totalElements = filteredRows.length
                                            const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
                                            const pagedRows = filteredRows.slice(page * pageSize, (page + 1) * pageSize)

                                            return pagedRows.map((s: any) => (
                                                <tr key={s.maSV ?? s.id ?? Math.random()} className="border-b hover:bg-slate-50">
                                                    <td className="px-3 py-2 align-top">{s.maSV}</td>
                                                    <td className="px-3 py-2 align-top">{s.hoTen}</td>
                                                    <td className="px-3 py-2 align-top">{s.lop}</td>
                                                    <td className="px-3 py-2 align-top">{s.boMon ?? s.idBoMon ?? '—'}</td>
                                                    <td className="px-3 py-2 align-top">{s.tenDeTai}</td>
                                                    <td className="px-3 py-2 align-top">{s.gvhd}</td>
                                                    <td className="px-3 py-2 align-top">
                                                        <button onClick={() => openScore(s)} className="px-2 py-1 text-sm border rounded text-sky-600">Chấm điểm</button>
                                                    </td>
                                                </tr>
                                            ))
                                        })()}
                                    </tbody>
                                </table>
                            </div>
                            {/* Pagination controls (client-side like NhatKyPage) */}
                            {(() => {
                                const allRows = Array.isArray(data.sinhVienList) ? data.sinhVienList : []
                                const q = (query || '').toLowerCase().trim()
                                const filteredRows = q
                                    ? allRows.filter((r: any) => (((r.maSV ?? '') + ' ' + (r.hoTen ?? '')).toLowerCase().includes(q)))
                                    : allRows
                                const totalElements = filteredRows.length
                                const totalPages = Math.max(1, Math.ceil(totalElements / pageSize))
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
                        <div className="flex justify-end">
                            <button onClick={() => navigate(-1)} className="flex items-center px-3 py-1 border rounded">Quay lại</button>
                        </div>
                    </div>
                )}
            </div>
            {/* Score modal for selected student */}
            <HoiDongScoreModal
                open={scoreOpen}
                onClose={() => { setScoreOpen(false); setSelectedStudent(null) }}
                student={selectedStudent || undefined}
                members={(() => {
                    if (!data) return []
                    const parents = [] as string[]
                    if (data.chuTich) parents.push(data.chuTich)
                    if (data.thuKy) parents.push(data.thuKy)
                    if (Array.isArray(data.giangVienPhanBien)) parents.push(...data.giangVienPhanBien)
                    // dedupe
                    return Array.from(new Set(parents))
                })()}
            />
        </div>
    )
}
