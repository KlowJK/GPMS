import React, { useState } from 'react'
import BangDuyetDeTai from '../components/BangDuyetDeTai'
import ModalXacNhan from '../components/ModalXacNhan'
import { useReviewsViewModel } from '../viewmodels/useReviewsViewModel'

export default function DuyetDeTaiPage() {
  return <Inner />
}

function Inner() {
  const vm = useReviewsViewModel()
  const [rejectingId, setRejectingId] = useState<string | null>(null)

  const onApprove = (id: string) => {
    vm.approve(id)
  }

  const onRejectConfirm = () => {
    // kept for old signature; not used now
  }

  const onRejectWithReason = (nhanXet: string) => {
    if (!rejectingId) return
    // call viewmodel method that accepts reason
    if ((vm as any).rejectWithReason) {
      ;(vm as any).rejectWithReason(rejectingId, nhanXet)
      // show a simple alert toast (replace with app toast lib if available)
      try { window.alert('Từ chối thành công') } catch {}
    } else {
      vm.reject(rejectingId)
    }
    setRejectingId(null)
  }

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-3xl font-semibold">Duyệt đề tài</h2>
        <div className="w-64">
          <input value={vm.search} onChange={e => vm.setSearch(e.target.value)} placeholder="Tìm theo mã sinh viên" className="w-full border rounded px-3 py-2 text-sm" />
        </div>
      </div>

      <div className="bg-white shadow rounded">
  <BangDuyetDeTai rows={(vm.data?.content ?? []) as any} isLoading={vm.isLoading} onApprove={onApprove} onReject={(id) => setRejectingId(id)} onView={(url) => vm.openPdf(url)} approvingId={vm.approvingId} />

        {/* <div className="p-4 border-t flex items-center justify-center">
          <div className="flex items-center gap-3">
            <button className="px-3 py-1 border rounded">«</button>
            <button className="px-3 py-1 border rounded bg-slate-200">1</button>
            <button className="px-3 py-1 border rounded">2</button>
            <button className="px-3 py-1 border rounded">3</button>
            <span className="px-3 py-1">...</span>
            <button className="px-3 py-1 border rounded">10</button>
            <button className="px-3 py-1 border rounded">»</button>
          </div>
        </div> */}
      </div>

  <ModalXacNhan open={!!rejectingId} title="Xác nhận từ chối" message="Bạn có chắc muốn từ chối đề tài này?" onConfirm={onRejectWithReason} onCancel={() => setRejectingId(null)} />
    </div>
  )
}
