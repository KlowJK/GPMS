import { useEffect, useRef, useState } from 'react';

type Props = {
  open: boolean;
  title: string;
  description?: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm?: () => void | Promise<void>;
  onClose: () => void;
};

export default function ConfirmDialog({
  open,
  title,
  description,
  confirmText = 'Xác nhận',
  cancelText = 'Hủy',
  onConfirm,
  onClose,
}: Props) {
  const [loading, setLoading] = useState(false);
  const ref = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === 'Escape') onClose();
    }
    if (open) document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  if (!open) return null;

  async function handleConfirm() {
    if (!onConfirm) return onClose();
    try {
      setLoading(true);
      await onConfirm();
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="fixed inset-0 z-[9999] grid place-items-center bg-black/40" role="dialog" aria-modal="true">
      <div ref={ref} className="bg-white rounded-2xl shadow-xl w-[420px] p-6">
        <h3 className="text-lg font-semibold">{title}</h3>
        {description && <p className="text-sm text-slate-600 mt-2">{description}</p>}

        <div className="flex justify-end gap-3 mt-6">
          {/* Confirm on the left, Cancel on the right (swapped) - both buttons same size */}
          <button
            className="px-4 h-10 rounded bg-sky-600 text-white disabled:opacity-50"
            disabled={loading}
            onClick={handleConfirm}
          >
            {confirmText}
          </button>
          <button className="px-4 h-10 rounded border" disabled={loading} onClick={onClose}>{cancelText}</button>
        </div>
      </div>
    </div>
  );
}
