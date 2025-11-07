import React from 'react'
import { DownloadCloud } from 'lucide-react'
import ReportHeader from './ThongTinSinhVien'

type Props = {
    open: boolean
    item?: any
    approvalFile: File | null
    setApprovalFile: (f: File | null) => void
    dragActive: boolean
    setDragActive: (v: boolean) => void
    fileInputRef: React.RefObject<HTMLInputElement | null>
    onClose: () => void
    onApprove: () => Promise<void>
    approveMut: any
}

export default function ApproveModal({ open, item, approvalFile, setApprovalFile, dragActive, setDragActive, fileInputRef, onClose, onApprove, approveMut }: Props) {
    if (!open) return null

    return (
        <div className="fixed inset-0 z-60 grid place-items-center bg-black/40">
            <div className="w-[820px] max-h-[88vh] overflow-auto bg-white rounded-md shadow-lg">
                <div className="bg-blue-600 text-white px-4 py-3 rounded-t-md flex items-center justify-between">
                    <div className="font-semibold">Duyệt đơn hoãn đồ án</div>
                    <button onClick={onClose} className="text-white text-xl leading-none">×</button>
                </div>
                <div className="p-6">
                    <div className="mb-3">
                        <ReportHeader student={{
                            hoTen: item?.hoTenSinhVien ?? item?.hoTen ?? item?.hoTenSV ?? '',
                            maSV: item?.maSinhVien ?? item?.maSV ?? item?.sinhVienId ?? '',
                            email: item?.email ?? '',
                            soDienThoai: item?.soDienThoai ?? item?.soDienThoai ?? '',
                            ngaySinh: item?.ngaySinh ?? '',
                            tenNganh: item?.nganhSinhVien ?? item?.tenNganh ?? '',
                            raw: item,
                        }} />
                    </div>

                    <div className="mb-3">
                        <label className="block text-sm text-slate-600 mb-1">Biên bản họp phê duyệt (tùy chọn)</label>

                        <div
                            onDragOver={(e) => { e.preventDefault(); }}
                            onDragEnter={() => setDragActive(true)}
                            onDragLeave={() => setDragActive(false)}
                            onDrop={(e) => {
                                e.preventDefault()
                                setDragActive(false)
                                const f = e.dataTransfer?.files && e.dataTransfer.files.length ? e.dataTransfer.files[0] : null
                                if (f) setApprovalFile(f)
                            }}
                            onClick={() => fileInputRef.current?.click()}
                            className={"flex items-center justify-between gap-3 p-3 border rounded-md cursor-pointer " + (dragActive ? 'border-sky-400 bg-sky-50' : 'border-slate-200 bg-white')}
                        >
                            <div className="flex items-center gap-3">
                                <DownloadCloud size={18} className="text-sky-500" />
                                <div>
                                    <div className="text-sm font-medium">Kéo & thả file ở đây hoặc click để chọn</div>
                                    <div className="text-xs text-slate-500">Chỉ chấp nhận file PDF</div>
                                </div>
                            </div>
                            <div className="text-sm text-slate-600">{approvalFile ? approvalFile.name : 'Chưa có file'}</div>
                        </div>

                        <input
                            ref={fileInputRef}
                            type="file"
                            accept="application/pdf"
                            className="hidden"
                            onChange={e => setApprovalFile(e.target.files && e.target.files.length ? e.target.files[0] : null)}
                        />

                        {approvalFile && (
                            <div className="mt-2 flex items-center gap-3">
                                <div className="text-sm text-slate-700">{approvalFile.name}</div>
                                <button type="button" className="text-sm text-rose-600" onClick={() => setApprovalFile(null)}>Xóa</button>
                            </div>
                        )}
                    </div>

                    <div className="flex justify-end gap-3">
                        <button onClick={onClose} className="px-4 py-2 rounded-md bg-gray-100 text-slate-700">Hủy</button>
                        <button
                            onClick={async () => { try { await onApprove() } catch (e) { /* handled in viewmodel */ } }}
                            className="px-4 py-2 rounded-md bg-sky-600 hover:bg-sky-700 text-white"
                        >{approveMut.status === 'pending' ? 'Đang xử lý...' : 'Duyệt'}</button>
                    </div>
                </div>
            </div>
        </div>
    )
}
