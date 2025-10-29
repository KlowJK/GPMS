import React, { createContext, useCallback, useContext, useMemo, useRef, useState } from 'react';

type ToastKind = 'success' | 'error' | 'info';
type ToastItem = { id: string; kind: ToastKind; text: string; duration?: number };

type ToastCtx = {
  success: (text: string, durationMs?: number) => void;
  error:   (text: string, durationMs?: number) => void;
  info:    (text: string, durationMs?: number) => void;
};

const Ctx = createContext<ToastCtx | null>(null);

export function useToast() {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useToast must be used inside <ToastProvider>');
  return ctx;
}

export default function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);
  const timers = useRef<Record<string, any>>({});

  const remove = useCallback((id: string) => {
    setToasts(prev => prev.filter(t => t.id !== id));
    if (timers.current[id]) { clearTimeout(timers.current[id]); delete timers.current[id]; }
  }, []);

  const push = useCallback((kind: ToastKind, text: string, duration = 3000) => {
    const id = `${Date.now()}_${Math.random().toString(36).slice(2)}`;
    const t: ToastItem = { id, kind, text, duration };
    setToasts(prev => [t, ...prev]); // toast mới hiện trên cùng
    timers.current[id] = setTimeout(() => remove(id), duration);
  }, [remove]);

  const api = useMemo<ToastCtx>(() => ({
    success: (text, d) => push('success', text, d),
    error:   (text, d) => push('error', text, d),
    info:    (text, d) => push('info', text, d),
  }), [push]);

  return (
    <Ctx.Provider value={api}>
      {children}
      {/* Stack góc phải trên */}
      <div className="pointer-events-none fixed top-4 right-4 z-[9999] space-y-2 w-[320px]">
        {toasts.map(t => (
          <div
            key={t.id}
            className={[
              'pointer-events-auto rounded-lg shadow-lg border px-4 py-3 text-sm animate-fade-in',
              t.kind === 'success' ? 'bg-green-50 border-green-200 text-green-800' :
              t.kind === 'error'   ? 'bg-red-50 border-red-200 text-red-800' :
                                     'bg-slate-50 border-slate-200 text-slate-800'
            ].join(' ')}
            onClick={() => remove(t.id)}
            role="status"
          >
            {t.text}
          </div>
        ))}
      </div>
    </Ctx.Provider>
  );
}


