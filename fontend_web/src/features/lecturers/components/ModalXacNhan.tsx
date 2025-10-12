import React, { useState } from 'react'

export default function ModalXacNhan({ open, title, message, onConfirm, onCancel }: { open: boolean; title: string; message: string; onConfirm: (nhanXet: string) => void; onCancel: () => void }) {
  const [text, setText] = useState('')
  if (!open) return null
  const canConfirm = text.trim().length >= 5
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md p-6 w-96">
        <h3 className="text-lg font-semibold mb-2">{title}</h3>
        <p className="text-sm text-slate-600 mb-4">{message}</p>
        <textarea value={text} onChange={e => setText(e.target.value)} placeholder="Nhập lý do (tối thiểu 5 ký tự)" className="w-full border rounded p-2 mb-4 h-24 text-sm" />
        <div className="flex justify-end gap-2">
          <button className="px-3 py-1 border rounded" onClick={() => { setText(''); onCancel() }}>Hủy</button>
          <button disabled={!canConfirm} className="px-3 py-1 bg-red-600 text-white rounded disabled:opacity-50" onClick={() => { onConfirm(text.trim()); setText('') }}>Xác nhận</button>
        </div>
      </div>
    </div>
  )
}
