import React from 'react';

type Props = {
  open: boolean;
  title?: string;
  description?: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm?: () => void | Promise<void>;
  onClose: () => void;
};

export default function ConfirmDialog({
  open,
  title = 'Xác nhận',
  description = 'Bạn chắc chắn muốn thực hiện thao tác này?',
  confirmText = 'OK',
  cancelText = 'Hủy',
  onConfirm,
  onClose,
}: Props) {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-[10000] grid place-items-center bg-black/40">
      <div className="bg-white w-[420px] rounded-2xl shadow-xl p-6">
        <div className="text-lg font-semibold mb-2">{title}</div>
        <div className="text-slate-600 text-sm mb-5">{description}</div>
        <div className="flex justify-end gap-3">
          <button onClick={onClose} className="px-4 h-10 rounded-lg border bg-white">
            {cancelText}
          </button>
          <button
            onClick={async () => { await onConfirm?.(); onClose(); }}
            className="px-4 h-10 rounded-lg bg-blue-600 text-white"
          >
            {confirmText}
          </button>
        </div>
      </div>
    </div>
  );
}
