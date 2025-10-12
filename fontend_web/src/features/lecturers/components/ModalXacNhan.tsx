import React from 'react'

export default function ModalXacNhan({ open, title, message, onConfirm, onCancel }: { open: boolean; title: string; message: string; onConfirm: () => void; onCancel: () => void }) {
  if (!open) return null
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-black/40">
      <div className="bg-white rounded-md p-6 w-96">
        <h3 className="text-lg font-semibold mb-2">{title}</h3>
        <p className="text-sm text-slate-600 mb-4">{message}</p>
        <div className="flex justify-end gap-2">
          <button className="px-3 py-1 border rounded" onClick={onCancel}>Hủy</button>
          <button className="px-3 py-1 bg-red-600 text-white rounded" onClick={onConfirm}>Xác nhận</button>
        </div>
      </div>
    </div>
  )
}
