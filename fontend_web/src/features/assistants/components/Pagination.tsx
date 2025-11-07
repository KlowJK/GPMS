// src/features/assistants/components/Pagination.tsx
import React from 'react';

type Props = {
  /** 0-index */
  page: number;
  /** tổng số trang (>=1) */
  totalPages: number;
  /** đổi trang (nhận 0-index) */
  onChange: (p: number) => void;
  /** (tuỳ chọn) hiện “Trang X / Y” ở bên phải */
  showCounter?: boolean;
  /** (tuỳ chọn) disabled toàn bộ (đang tải…) */
  disabled?: boolean;
};

function makeWindow(page: number, total: number, radius = 1): (number | '…')[] {
  if (total <= 10) return Array.from({ length: total }, (_, i) => i);
  const left = Math.max(1, page - radius);
  const right = Math.min(total - 2, page + radius);

  const parts: (number | '…')[] = [0];
  if (left > 1) parts.push('…');
  for (let p = left; p <= right; p++) parts.push(p);
  if (right < total - 2) parts.push('…');
  parts.push(total - 1);
  return parts;
}

export default function Pagination({
  page,
  totalPages,
  onChange,
  showCounter = true,
  disabled = false,
}: Props) {
  if (!totalPages || totalPages <= 1) return null;
  const windowPages = makeWindow(page, totalPages);

  const canPrev = page > 0 && !disabled;
  const canNext = page < totalPages - 1 && !disabled;

  return (
    <div className="flex items-center justify-center p-3 border-t">
      <div className="flex items-center gap-2">
        <button
          className="px-3 py-1 rounded border disabled:opacity-40"
          onClick={() => onChange(0)}
          disabled={!canPrev}
          aria-label="Trang đầu"
        >
          «
        </button>
        <button
          className="px-3 py-1 rounded border disabled:opacity-40"
          onClick={() => onChange(Math.max(0, page - 1))}
          disabled={!canPrev}
          aria-label="Trước"
        >
          ‹
        </button>

        {windowPages.map((it, i) =>
          it === '…' ? (
            <span key={`d${i}`} className="px-2 select-none">…</span>
          ) : (
            <button
              key={it}
              onClick={() => onChange(it)}
              className={`px-3 py-1 rounded ${
                it === page ? 'bg-sky-600 text-white' : 'bg-white border'
              }`}
              aria-current={it === page ? 'page' : undefined}
            >
              {it + 1}
            </button>
          )
        )}

        <button
          className="px-3 py-1 rounded border disabled:opacity-40"
          onClick={() => onChange(Math.min(totalPages - 1, page + 1))}
          disabled={!canNext}
          aria-label="Sau"
        >
          ›
        </button>
        <button
          className="px-3 py-1 rounded border disabled:opacity-40"
          onClick={() => onChange(totalPages - 1)}
          disabled={!canNext}
          aria-label="Trang cuối"
        >
          »
        </button>

        {showCounter && (
          <span className="ml-2 text-sm text-slate-600 select-none">
            Trang {page + 1} / {totalPages}
          </span>
        )}
      </div>
    </div>
  );
}
