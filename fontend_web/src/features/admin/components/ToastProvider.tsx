import React, { createContext, useContext, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';

type ToastItem = { id: number; type: 'success' | 'error' | 'info'; message: string; };
type Ctx = { toast: (type: ToastItem['type'], message: string) => void; success: (m:string)=>void; error:(m:string)=>void; info:(m:string)=>void; };

const ToastCtx = createContext<Ctx | null>(null);
export const useToast = () => {
  const ctx = useContext(ToastCtx);
  if (!ctx) throw new Error('useToast must be used inside <ToastProvider/>');
  return ctx;
};

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [items, setItems] = useState<ToastItem[]>([]);

  const api = useMemo<Ctx>(() => {
    const push = (type: ToastItem['type'], message: string) => {
      const id = Date.now() + Math.random();
      setItems(prev => [...prev, { id, type, message }]);
      setTimeout(() => setItems(prev => prev.filter(x => x.id !== id)), 2500);
    };
    return {
      toast: push,
      success: (m) => push('success', m),
      error: (m) => push('error', m),
      info: (m) => push('info', m),
    };
  }, []);

  return (
    <ToastCtx.Provider value={api}>
      {children}
      {createPortal(
        <div className="fixed top-5 right-5 z-[10001] space-y-2">
          {items.map(t => (
            <div
              key={t.id}
              className={
                'min-w-[260px] max-w-[380px] rounded-xl px-4 py-3 shadow ' +
                (t.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' :
                 t.type === 'error'   ? 'bg-red-50 text-red-700 border border-red-200' :
                                        'bg-slate-50 text-slate-700 border')
              }
            >
              {t.message}
            </div>
          ))}
        </div>,
        document.body
      )}
    </ToastCtx.Provider>
  );
}
