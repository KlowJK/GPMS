import React, { useMemo, useState } from "react";
import {
  Search,
  Download,
  Eye,
  Check,
  Pencil,
  FileText,
  ChevronLeft,
  ChevronRight,
  X,
} from "lucide-react";
import { Link } from "react-router-dom";

type Status = "approved" | "pending";

type Row = {
  id: string;
  studentName: string;
  topic: string;
  diemPB?: number;         // Điểm phản biện (nếu cần)
  diemBV?: number;         // Điểm bảo vệ
  minutesText?: string;    // Nội dung biên bản (có text => coi như đã có biên bản)
  status: Status;          // pending | approved
};

const SESSIONS = [
  "Hội đồng bảo vệ 1 (16/09/2025 - 17/09/2025)",
  "Hội đồng bảo vệ 2 (23/09/2025 - 24/09/2025)",
  "Hội đồng bảo vệ 3 (30/09/2025 - 01/10/2025)",
];

// dữ liệu mẫu
const INIT_DATA: Row[] = [
  {
    id: "2251172xxx",
    studentName: "Nguyễn Văn A",
    topic: "Quản lý đề tài khoa CNTT",
    status: "pending",
  },
  {
    id: "2251172xxx",
    studentName: "Nguyễn Văn B",
    topic: "Nhận diện rác thải đô thị bằng CNN",
    diemPB: 8,
    diemBV: 8,
    minutesText: "Biên bản đã ghi.",
    status: "pending", // có đủ nhưng chưa duyệt -> chỉ hiện tick
  },
  {
    id: "2251172xxx",
    studentName: "Nguyễn Văn C",
    topic: "Drone kiểm tra nông trại tự hành",
    diemPB: 6.5,
    diemBV: 6,
    minutesText: "Đã ghi biên bản.",
    status: "pending",
  },
  {
    id: "2251172xxx",
    studentName: "Nguyễn Văn D",
    topic: "Gợi ý lộ trình học cá nhân hoá",
    diemPB: 9,
    diemBV: 8.8,
    minutesText: "Đã ghi biên bản.",
    status: "approved",
  },
];

// ====== Utilities ======
const fmt = (n?: number) => (typeof n === "number" ? n.toString() : "—");

const totalScore = (r: Row) =>
  typeof r.diemPB === "number" && typeof r.diemBV === "number"
    ? ((r.diemPB + r.diemBV) / 2).toFixed(1)
    : "—";

const hasMinutes = (r: Row) => Boolean(r.minutesText && r.minutesText.trim().length > 0);
const hasScore = (r: Row) => typeof r.diemBV === "number";

// ====== Tiny Toast ======
function Toast({
  open,
  type = "success",
  message,
  onClose,
}: {
  open: boolean;
  type?: "success" | "warning";
  message: string;
  onClose: () => void;
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-[60] pointer-events-none">
      <div className="absolute left-1/2 -translate-x-1/2 top-20">
        <div
          className={`pointer-events-auto rounded-2xl px-8 py-6 shadow-lg ${
            type === "success" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-800"
          }`}
        >
          <div className="flex items-center gap-3">
            <div
              className={`h-10 w-10 rounded-full grid place-items-center ${
                type === "success" ? "bg-emerald-100" : "bg-amber-100"
              }`}
            >
              <Check className="h-6 w-6" />
            </div>
            <div className="text-base font-semibold">{message}</div>
            <button
              className="ml-4 text-slate-500 hover:text-slate-700"
              onClick={onClose}
              aria-label="Đóng"
            >
              <X className="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

// ====== Modal khung dùng chung ======
function Modal({
  open,
  title,
  children,
  onClose,
  footer,
  maxWidth = "max-w-xl",
}: {
  open: boolean;
  title: string;
  children: React.ReactNode;
  footer?: React.ReactNode;
  onClose: () => void;
  maxWidth?: string;
}) {
  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/30" onClick={onClose} />
      <div className={`absolute left-1/2 top-24 -translate-x-1/2 w-[92vw] ${maxWidth}`}>
        <div className="rounded-2xl bg-white shadow-xl border border-slate-200">
          <div className="px-5 py-4 border-b">
            <div className="font-semibold">{title}</div>
          </div>
          <div className="p-5">{children}</div>
          {footer && <div className="px-5 py-4 border-t flex justify-end gap-2">{footer}</div>}
        </div>
      </div>
    </div>
  );
}

function StatusChip({ status }: { status: Status }) {
  const isOk = status === "approved";
  return (
    <span
      className={`inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium ${
        isOk
          ? "bg-emerald-50 text-emerald-700 border border-emerald-200"
          : "bg-amber-50 text-amber-700 border border-amber-200"
      }`}
    >
      {isOk ? "Đã phê duyệt" : "Chờ phê duyệt"}
    </span>
  );
}

export default function HoiDong() {
  const [session, setSession] = useState(SESSIONS[0]);
  const [q, setQ] = useState("");
  const [statusFilter, setStatusFilter] = useState<"all" | Status>("all");
  const [rows, setRows] = useState<Row[]>(INIT_DATA);
  const [page, setPage] = useState(1);
  const PAGE_SIZE = 4;

  // modal states
  const [editingRow, setEditingRow] = useState<Row | null>(null);
  const [scoringRow, setScoringRow] = useState<Row | null>(null);
  const [minutesDraft, setMinutesDraft] = useState("");
  const [diemBVDraft, setDiemBVDraft] = useState<string>("");

  // toast
  const [toast, setToast] = useState<{ open: boolean; type: "success" | "warning"; msg: string }>({
    open: false,
    type: "success",
    msg: "",
  });
  const showToast = (msg: string, type: "success" | "warning" = "success") => {
    setToast({ open: true, type, msg });
    setTimeout(() => setToast((t) => ({ ...t, open: false })), 1800);
  };

  const filtered = useMemo(() => {
    const k = q.trim().toLowerCase();
    return rows.filter((r) => {
      const okS = statusFilter === "all" ? true : r.status === statusFilter;
      const okQ =
        !k ||
        r.id.toLowerCase().includes(k) ||
        r.studentName.toLowerCase().includes(k) ||
        r.topic.toLowerCase().includes(k);
      return okS && okQ;
    });
  }, [rows, q, statusFilter]);

  const totalPages = Math.max(1, Math.ceil(filtered.length / PAGE_SIZE));
  const pageData = filtered.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

  const exportCSV = () => {
    const header = [
      "MSSV",
      "Sinh viên",
      "Đề tài",
      "Điểm PB",
      "Điểm BV",
      "Tổng",
      "Biên bản",
      "Trạng thái",
    ];
    const data = filtered.map((r) => [
      r.id,
      r.studentName,
      r.topic,
      fmt(r.diemPB),
      fmt(r.diemBV),
      totalScore(r),
      hasMinutes(r) ? "Có" : "Chưa có",
      r.status === "approved" ? "Đã phê duyệt" : "Chờ phê duyệt",
    ]);
    const csv =
      [header, ...data].map((arr) => arr.map((c) => `"${String(c)}"`).join(",")).join("\n");
    const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = "ds-hoi-dong.csv";
    a.click();
    URL.revokeObjectURL(url);
  };

  // ====== Actions ======
  const openMinutes = (r: Row) => {
    setEditingRow(r);
    setMinutesDraft(r.minutesText ?? "");
  };

  const saveMinutes = () => {
    if (!editingRow) return;
    setRows((prev) =>
      prev.map((r) => (r === editingRow ? { ...r, minutesText: minutesDraft } : r))
    );
    setEditingRow(null);
    showToast("Ghi biên bản thành công");
  };

  const openScore = (r: Row) => {
    setScoringRow(r);
    setDiemBVDraft(typeof r.diemBV === "number" ? String(r.diemBV) : "");
  };

  const saveScore = () => {
    if (!scoringRow) return;
    const val = Number(diemBVDraft);
    if (Number.isNaN(val) || val < 0 || val > 10) {
      showToast("Điểm BV phải là số từ 0–10", "warning");
      return;
    }
    setRows((prev) => prev.map((r) => (r === scoringRow ? { ...r, diemBV: val } : r)));
    setScoringRow(null);
    showToast("Nhập điểm thành công");
  };

  const approve = (r: Row) => {
    if (hasMinutes(r) && hasScore(r)) {
      setRows((prev) => prev.map((x) => (x === r ? { ...x, status: "approved" } : x)));
      showToast("Thành công");
    } else {
      showToast("Cần đủ Điểm BV và Biên bản trước khi duyệt", "warning");
    }
  };

  // ====== View ======
  return (
    <div className="max-w-6xl mx-auto">
      <Toast open={toast.open} type={toast.type} message={toast.msg} onClose={() => setToast({ ...toast, open: false })} />

      <div className="text-xs text-slate-500 mb-3">Hội đồng</div>
      <h1 className="text-3xl font-bold text-center mb-6">Danh sách sinh viên</h1>

      {/* filter top */}
      <div className="mb-4 flex items-center gap-3">
        <select
          value={session}
          onChange={(e) => setSession(e.target.value)}
          className="h-10 rounded-lg border border-slate-200 bg-white px-3 text-sm shadow-sm focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
        >
          {SESSIONS.map((s) => (
            <option key={s} value={s}>
              {s}
            </option>
          ))}
        </select>

        <div className="ml-auto flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-slate-400" />
            <input
              className="h-10 pl-9 pr-3 rounded-lg border border-slate-200 bg-white text-sm focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
              placeholder="Tìm theo tên SV/đề tài…"
              value={q}
              onChange={(e) => {
                setQ(e.target.value);
                setPage(1);
              }}
            />
          </div>
          <select
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value as any);
              setPage(1);
            }}
            className="h-10 min-w-28 rounded-lg border border-slate-200 bg-white px-3 text-sm focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
          >
            <option value="all">Tất cả</option>
            <option value="pending">Chờ phê duyệt</option>
            <option value="approved">Đã phê duyệt</option>
          </select>
          <button
            onClick={exportCSV}
            className="inline-flex items-center gap-2 h-10 rounded-lg bg-slate-900 text-white px-3 text-sm hover:opacity-95 active:opacity-90"
          >
            <Download className="h-4 w-4" />
            Xuất danh sách
          </button>
        </div>
      </div>

      {/* table card */}
      <div className="rounded-2xl bg-white shadow-[0_4px_24px_rgba(0,0,0,0.06)] border border-slate-100">
        <div className="overflow-x-auto">
          <table className="min-w-full">
            <thead>
              <tr className="text-left text-sm text-slate-500">
                <th className="px-5 py-3 font-medium">Sinh viên</th>
                <th className="px-5 py-3 font-medium">Đề tài</th>
                <th className="px-5 py-3 font-medium text-center">Điểm PB</th>
                <th className="px-5 py-3 font-medium text-center">Điểm BV</th>
                <th className="px-5 py-3 font-medium text-center">Tổng</th>
                <th className="px-5 py-3 font-medium text-center">Biên bản</th>
                <th className="px-5 py-3 font-medium text-center">Trạng thái</th>
                <th className="px-5 py-3 font-medium text-center">Thao tác</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {pageData.map((r, idx) => {
                const missingScore = !hasScore(r);
                const missingMinutes = !hasMinutes(r);
                const canApprove = !missingScore && !missingMinutes;

                return (
                  <tr key={`${r.id}-${idx}`} className="text-sm">
                    <td className="px-5 py-4">
                      <div className="leading-5">
                        <div className="font-medium">{r.id}</div>
                        <div className="text-slate-600">{r.studentName}</div>
                      </div>
                    </td>
                    <td className="px-5 py-4 max-w-[320px]">
                      <div className="text-slate-700 line-clamp-2">{r.topic}</div>
                    </td>
                    <td className="px-5 py-4 text-center">{fmt(r.diemPB)}</td>
                    <td className="px-5 py-4 text-center">{fmt(r.diemBV)}</td>
                    <td className="px-5 py-4 text-center">{totalScore(r)}</td>
                    <td className="px-5 py-4 text-center">
                      {hasMinutes(r) ? (
                        <Link
                          to="#"
                          className="inline-flex h-8 items-center justify-center rounded-lg border border-slate-200 px-3 hover:bg-slate-50"
                          title="Xem biên bản"
                        >
                          Xem
                        </Link>
                      ) : (
                        <span className="text-xs text-slate-400">Chưa có</span>
                      )}
                    </td>
                    <td className="px-5 py-4 text-center">
                      <StatusChip status={r.status} />
                    </td>
                    <td className="px-5 py-4">
                      <div className="flex justify-center gap-2">
                        {/* Quy tắc icon theo yêu cầu */}
                        {r.status === "pending" && missingMinutes && (
                          <button
                            title="Ghi biên bản"
                            className="inline-flex h-8 w-8 items-center justify-center rounded-md border border-slate-200 hover:bg-slate-50"
                            onClick={() => openMinutes(r)}
                          >
                            <Pencil className="h-4 w-4" />
                          </button>
                        )}
                        {r.status === "pending" && missingScore && (
                          <button
                            title="Nhập điểm"
                            className="inline-flex h-8 w-8 items-center justify-center rounded-md border border-slate-200 hover:bg-slate-50"
                            onClick={() => openScore(r)}
                          >
                            <FileText className="h-4 w-4" />
                          </button>
                        )}
                        {r.status === "pending" && (
                          <button
                            title="Phê duyệt"
                            className={`inline-flex h-8 w-8 items-center justify-center rounded-md border ${
                              canApprove
                                ? "border-emerald-200 text-emerald-600 hover:bg-emerald-50"
                                : "border-amber-200 text-amber-600 hover:bg-amber-50"
                            }`}
                            onClick={() => approve(r)}
                          >
                            <Check className="h-4 w-4" />
                          </button>
                        )}
                        {r.status === "approved" && (
                          <div
                            title="Đã phê duyệt"
                            className="inline-flex h-8 w-8 items-center justify-center rounded-md border border-slate-200 text-slate-400"
                          >
                            <Check className="h-4 w-4" />
                          </div>
                        )}
                      </div>
                    </td>
                  </tr>
                );
              })}

              {pageData.length === 0 && (
                <tr>
                  <td colSpan={8} className="px-5 py-10 text-center text-slate-500">
                    Không có bản ghi phù hợp.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        <div className="flex items-center justify-center gap-1 py-4">
          <button
            className="h-8 w-8 rounded-full border border-slate-200 grid place-items-center hover:bg-slate-50 disabled:opacity-40"
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            aria-label="Trang trước"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>

          {Array.from({ length: totalPages }).map((_, i) => {
            const n = i + 1;
            const active = n === page;
            return (
              <button
                key={n}
                onClick={() => setPage(n)}
                className={`h-8 w-8 rounded-full text-sm grid place-items-center ${
                  active
                    ? "bg-[#2F7CD3] text-white"
                    : "border border-slate-200 hover:bg-slate-50"
                }`}
              >
                {n}
              </button>
            );
          })}

          <button
            className="h-8 w-8 rounded-full border border-slate-200 grid place-items-center hover:bg-slate-50 disabled:opacity-40"
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            aria-label="Trang sau"
          >
            <ChevronRight className="h-4 w-4" />
          </button>
        </div>
      </div>

      {/* Modal Ghi biên bản */}
      <Modal
        open={!!editingRow}
        onClose={() => setEditingRow(null)}
        title="Ghi biên bản"
        maxWidth="max-w-2xl"
        footer={
          <>
            <button
              className="h-10 px-4 rounded-lg border border-slate-200 hover:bg-slate-50"
              onClick={() => setEditingRow(null)}
            >
              Hủy
            </button>
            <button
              className="h-10 px-4 rounded-lg bg-[#2F7CD3] text-white hover:opacity-95"
              onClick={saveMinutes}
            >
              Lưu
            </button>
          </>
        }
      >
        {editingRow && (
          <div className="space-y-4 text-sm">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-slate-500">Sinh viên</div>
                <div className="font-medium">{editingRow.studentName}</div>
              </div>
              <div>
                <div className="text-slate-500">Mã sinh viên</div>
                <div className="font-medium">{editingRow.id}</div>
              </div>
            </div>
            <div>
              <div className="text-slate-500">Đề tài</div>
              <div className="font-medium">{editingRow.topic}</div>
            </div>
            <div>
              <div className="text-slate-500 mb-1">Biên bản (ghi chép)</div>
              <textarea
                rows={6}
                value={minutesDraft}
                onChange={(e) => setMinutesDraft(e.target.value)}
                placeholder="Vui lòng nhập biên bản…"
                className="w-full rounded-xl border border-slate-200 p-3 focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
              />
            </div>
          </div>
        )}
      </Modal>

      {/* Modal Nhập điểm */}
      <Modal
        open={!!scoringRow}
        onClose={() => setScoringRow(null)}
        title="Nhập điểm"
        footer={
          <>
            <button
              className="h-10 px-4 rounded-lg border border-slate-200 hover:bg-slate-50"
              onClick={() => setScoringRow(null)}
            >
              Hủy
            </button>
            <button
              className="h-10 px-4 rounded-lg bg-[#2F7CD3] text-white hover:opacity-95"
              onClick={saveScore}
            >
              Xác nhận
            </button>
          </>
        }
      >
        {scoringRow && (
          <div className="space-y-4 text-sm">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <div className="text-slate-500">Sinh viên</div>
                <div className="font-medium">{scoringRow.studentName}</div>
              </div>
              <div>
                <div className="text-slate-500">Mã sinh viên</div>
                <div className="font-medium">{scoringRow.id}</div>
              </div>
            </div>
            <div>
              <div className="text-slate-500">Đề tài</div>
              <div className="font-medium">{scoringRow.topic}</div>
            </div>
            <div>
              <div className="text-slate-500 mb-1">Nhập điểm BV</div>
              <input
                inputMode="decimal"
                placeholder="0 - 10"
                value={diemBVDraft}
                onChange={(e) => setDiemBVDraft(e.target.value)}
                className="h-10 w-full rounded-xl border border-slate-200 px-3 focus:outline-none focus:ring-2 focus:ring-[#2F7CD3]"
              />
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
