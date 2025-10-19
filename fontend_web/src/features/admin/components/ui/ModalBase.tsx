// src/features/admin/components/ui/ModalBase.tsx
import { useEffect } from "react";

type ModalBaseProps = {
  open: boolean;
  title: string;
  children: React.ReactNode;
  onClose: () => void;
};

export default function ModalBase({ open, title, children, onClose }: ModalBaseProps) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && onClose();
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [open, onClose]);

  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-[100] flex items-center justify-center bg-black/50 p-4"
      onMouseDown={onClose}
    >
      <div
        className="w-full max-w-md rounded-2xl bg-white p-6 shadow-xl"
        onMouseDown={(e) => e.stopPropagation()}
      >
        <h3 className="text-center text-xl font-semibold mb-4">{title}</h3>
        {children}
      </div>
    </div>
  );
}
