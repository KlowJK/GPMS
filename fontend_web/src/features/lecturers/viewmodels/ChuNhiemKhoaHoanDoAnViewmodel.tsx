import { useRef, useState } from 'react'
import { useMutation, useQueryClient } from '@tanstack/react-query'
import { duyetDonHoanDoAn } from '../services/deTaiApi'
import { toast } from 'sonner'

export function useChuNhiemKhoaHoanDoAnViewmodel() {
    const [approveModal, setApproveModal] = useState<{ open: boolean; item?: any }>({ open: false })
    const [approvalFile, setApprovalFile] = useState<File | null>(null)
    const [dragActive, setDragActive] = useState<boolean>(false)
    const fileInputRef = useRef<HTMLInputElement | null>(null)

    const qc = useQueryClient()
    const approveMut = useMutation({
        mutationFn: async (payload: { donHoanDoAnId: number | string; bienbanHopPheDuyetFile?: File | null }) => await duyetDonHoanDoAn(payload),
        onSuccess: () => {
            toast.success('Duyệt đơn thành công')
            setApproveModal({ open: false })
            setApprovalFile(null)
            qc.invalidateQueries({ queryKey: ['hoan-do-an-all'] })
        },
        onError: (err: any) => {
            const msg = String(err?.message ?? err)
            toast.error('Duyệt không thành công: ' + msg)
        }
    })

    function openApprove(item: any) {
        setApproveModal({ open: true, item })
    }

    function closeApprove() {
        setApproveModal({ open: false })
        setApprovalFile(null)
        setDragActive(false)
    }

    async function approveAsync() {
        if (!approveModal.item) return
        await approveMut.mutateAsync({ donHoanDoAnId: approveModal.item.id, bienbanHopPheDuyetFile: approvalFile ?? undefined })
    }

    return {
        approveModal,
        openApprove,
        closeApprove,
        approvalFile,
        setApprovalFile,
        dragActive,
        setDragActive,
        fileInputRef,
        approveAsync,
        approveMut,
    }
}

export default useChuNhiemKhoaHoanDoAnViewmodel
