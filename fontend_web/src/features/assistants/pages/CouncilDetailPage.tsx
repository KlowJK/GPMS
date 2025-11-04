import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ChevronLeft, Eye, UserPlus } from 'lucide-react';
import { useToast } from '@features/admin/components/ToastProvider';

import {
  getCouncilDetail,
  type CouncilDetail,
  addTopicReviewLecturers,
  getCouncilStudentDetail,
  type CouncilStudentDetail,
} from '@features/assistants/services/council/councilApi';

import type { Lecturer } from '@features/assistants/services/user/userApi';
import { listLecturers } from '@features/assistants/services/user/userApi';
import { toPage } from '@features/assistants/services/base';

function fmtDate(d?: string) {
  if (!d) return '—';
  const [y, m, dd] = d.split('-');
  return `${dd}/${m}/${y}`;
}

/* ===================== Add Reviewer Modal ===================== */
function AddReviewerModal({
  deTaiId,
  onClose,
  onDone,
}: {
  deTaiId: string;
  onClose: () => void;
  onDone: () => void;
}) {
  const { error, success } = useToast();
  const [q, setQ] = useState('');
  const [rows, setRows] = useState<Lecturer[]>([]);
  const [sel, setSel] = useState<Set<number>>(new Set());
  const [saving, setSaving] = useState(false);

  // Fetch full list 1 lần; tìm kiếm lọc phía client theo tên hoặc email
  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const res = await listLecturers({ page: 0, size: 999 }); // lấy nhiều để client filter
        const pg = toPage<Lecturer>(res, { page: 0, size: 999 });
        if (alive) setRows(pg.content);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được danh sách giảng viên.');
      }
    })();
    return () => { alive = false; };
  }, [error]);

  // Lọc theo tên hoặc email (không phân biệt hoa thường)
  const filtered = useMemo(() => {
    const k = q.trim().toLowerCase();
    if (!k) return rows;
    return rows.filter(x =>
      (x.hoTen || '').toLowerCase().includes(k) ||
      (x.email || '').toLowerCase().includes(k)
    );
  }, [rows, q]);

  const toggle = (id: number) =>
    setSel(prev => {
      const s = new Set(prev);
      s.has(id) ? s.delete(id) : s.add(id);
      return s;
    });

  async function submit() {
    if (sel.size === 0) return;
    try {
      setSaving(true);
      await addTopicReviewLecturers({
        idDeTai: deTaiId,
        lecturers: Array.from(sel).map(id => ({ giangVienId: id })),
      });
      success('Đã thêm giảng viên phản biện cho đề tài.');
      onDone();
      onClose();
    } catch (e: any) {
      error(e?.response?.data?.message || 'Thêm giảng viên phản biện thất bại.');
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/40">
      <div className="h-full w-full overflow-y-auto">
        <div className="mx-auto my-10 w-[720px] max-w-[95vw]">
          <div className="bg-white rounded-2xl shadow-xl">
            <div className="px-6 py-4 border-b">
              <div className="text-lg font-semibold">Thêm giảng viên phản biện</div>
              <div className="text-sm text-slate-500 mt-1">Đề tài: {deTaiId}</div>
            </div>

            <div className="p-6">
              <input
                value={q}
                onChange={(e) => setQ(e.target.value)}
                placeholder="Tìm giảng viên theo tên hoặc email…"
                className="w-full h-10 px-3 border rounded mb-3"
              />
              <div className="max-h-72 overflow-y-auto border rounded">
                {filtered.length === 0 ? (
                  <div className="p-4 text-sm text-slate-500">Không có dữ liệu.</div>
                ) : filtered.map(x => {
                  const checked = sel.has(Number(x.id));
                  return (
                    <label key={`${x.id}`} className="flex items-center gap-2 px-3 py-2 border-b last:border-none">
                      <input
                        type="checkbox"
                        className="h-4 w-4"
                        checked={checked}
                        onChange={() => toggle(Number(x.id))}
                      />
                      <span className="text-sm">
                        {x.hoTen}{x.boMonTen ? ` — ${x.boMonTen}` : ''}{x.email ? ` — ${x.email}` : ''}
                      </span>
                    </label>
                  );
                })}
              </div>
            </div>

            <div className="px-6 py-4 border-t flex justify-end gap-3 rounded-b-2xl">
              <button className="px-4 h-10 rounded border" onClick={onClose}>Hủy</button>
              <button
                className="px-4 h-10 rounded bg-blue-600 text-white disabled:opacity-50"
                onClick={submit}
                disabled={sel.size === 0 || saving}
              >
                Thêm
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ===================== Student Detail Modal ===================== */
function StudentDetailModal({
  deTaiId,
  onClose,
}: {
  deTaiId: string;
  onClose: () => void;
}) {
  const { error } = useToast();
  const [data, setData] = useState<CouncilStudentDetail | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        setLoading(true);
        const d = await getCouncilStudentDetail(deTaiId);
        if (alive) setData(d);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được chi tiết sinh viên/đề tài.');
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => { alive = false; };
  }, [deTaiId, error]);

  return (
    <div className="fixed inset-0 z-50 bg-black/40">
      <div className="h-full w-full overflow-y-auto">
        <div className="mx-auto my-10 w-[880px] max-w-[95vw]">
          <div className="bg-white rounded-2xl shadow-xl">
            <div className="px-6 py-4 border-b flex items-center justify-between">
              <div className="text-lg font-semibold">Chi tiết sinh viên</div>
              <button className="px-3 py-1 border rounded" onClick={onClose}>Đóng</button>
            </div>

            {loading ? (
              <div className="p-6">Đang tải…</div>
            ) : !data ? (
              <div className="p-6">Không có dữ liệu.</div>
            ) : (
              <div className="p-6 space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div><div className="text-sm text-slate-500">Mã SV</div><div className="font-medium">{data.maSinhVien}</div></div>
                  <div><div className="text-sm text-slate-500">Họ tên</div><div className="font-medium">{data.hoTen}</div></div>
                  <div><div className="text-sm text-slate-500">Lớp</div><div className="font-medium">{data.lop}</div></div>
                  <div><div className="text-sm text-slate-500">Bộ môn</div><div className="font-medium">{data.boMon || '—'}</div></div>
                  <div className="col-span-2">
                    <div className="text-sm text-slate-500">Tên đề tài</div>
                    <div className="font-medium">{data.tenDeTai}</div>
                  </div>
                  <div><div className="text-sm text-slate-500">GVHD</div><div className="font-medium">{data.gvhd}</div></div>
                  <div><div className="text-sm text-slate-500">Đường dẫn báo cáo</div>
                    <div className="font-medium break-all">{data.duongDanBaoCao || '—'}</div></div>
                  <div><div className="text-sm text-slate-500">Điểm báo cáo</div><div className="font-medium">{data.diemBaoCao ?? '—'}</div></div>
                  <div><div className="text-sm text-slate-500">Điểm phản biện</div><div className="font-medium">{data.diemPhanBien ?? '—'}</div></div>
                  <div><div className="text-sm text-slate-500">Điểm hội đồng</div><div className="font-medium">{data.diemHoiDong ?? '—'}</div></div>
                </div>

                <div>
                  <div className="text-sm text-slate-500 mb-2">Giảng viên chấm/đánh giá</div>
                  <div className="rounded border overflow-hidden">
                    <table className="w-full text-sm">
                      <thead className="bg-slate-50">
                        <tr>
                          <th className="text-left px-3 py-2">Họ tên</th>
                          <th className="text-left px-3 py-2">Vai trò</th>
                          <th className="text-left px-3 py-2">Bộ môn</th>
                          <th className="text-left px-3 py-2">Điểm</th>
                          <th className="text-left px-3 py-2">Nhận xét</th>
                          <th className="text-left px-3 py-2">Trạng thái</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(data.giangVien || []).length === 0 ? (
                          <tr><td colSpan={6} className="px-3 py-4 text-center">—</td></tr>
                        ) : data.giangVien.map((g, i) => (
                          <tr key={i} className="border-t">
                            <td className="px-3 py-2">{g.hoTen}</td>
                            <td className="px-3 py-2">{g.vaiTro || '—'}</td>
                            <td className="px-3 py-2">{g.boMon || '—'}</td>
                            <td className="px-3 py-2">{g.diem ?? '—'}</td>
                            <td className="px-3 py-2">{g.nhanXet || '—'}</td>
                            <td className="px-3 py-2">{g.trangThai || '—'}</td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>

              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

/* ===================== Council Detail Page ===================== */
export default function CouncilDetailPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { error } = useToast();

  const [data, setData] = useState<CouncilDetail | null>(null);
  const [loading, setLoading] = useState(true);

  // modal states
  const [openAddPBFor, setOpenAddPBFor] = useState<string | null>(null);
  const [openViewStuFor, setOpenViewStuFor] = useState<string | null>(null);

  async function load() {
    if (!id) return;
    try {
      setLoading(true);
      const detail = await getCouncilDetail(id);
      setData(detail);
    } catch (e: any) {
      error(e?.response?.data?.message || 'Không tải được chi tiết hội đồng.');
      setData(null);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id]);

  const students = useMemo(() => data?.sinhVienList ?? [], [data]);

  return (
    <div className="max-w-6xl mx-auto space-y-4">
      <div className="flex items-center gap-3">
        <button onClick={() => navigate(-1)} className="h-9 w-9 grid place-items-center rounded hover:bg-slate-100">
          <ChevronLeft />
        </button>
        <h1 className="text-3xl font-semibold">Chi tiết hội đồng</h1>
      </div>

      <div className="bg-white rounded-xl border">
        {loading ? (
          <div className="p-8 text-center">Đang tải chi tiết…</div>
        ) : !data ? (
          <div className="p-8 text-center">Không có dữ liệu.</div>
        ) : (
          <>
            <div className="grid grid-cols-3 gap-6 p-6">
              <div>
                <div className="text-sm text-slate-500">Tên hội đồng</div>
                <div className="font-medium">{data.tenHoiDong || '—'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Thời gian bắt đầu</div>
                <div className="font-medium">{fmtDate(data.thoiGianBatDau)}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Thời gian kết thúc</div>
                <div className="font-medium">{fmtDate(data.thoiGianKetThuc)}</div>
              </div>

              <div>
                <div className="text-sm text-slate-500">Địa điểm</div>
                <div className="font-medium">{data.diaDiem || 'Chưa có địa điểm'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Chủ tịch</div>
                <div className="font-medium">{data.chuTich || '—'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Thư ký</div>
                <div className="font-medium">{data.thuKy || '—'}</div>
              </div>

              <div className="col-span-3">
                <div className="text-sm text-slate-500 mb-1">Giảng viên phản biện</div>
                {(!data.giangVienPhanBien || data.giangVienPhanBien.length === 0) ? (
                  <div className="text-sm text-slate-700">—</div>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {data.giangVienPhanBien.map((g, i) => (
                      <span key={i} className="px-3 py-1 rounded-full bg-slate-100 text-slate-800 text-sm">{g}</span>
                    ))}
                  </div>
                )}
              </div>
            </div>

            <div className="border-t">
              <div className="flex items-center justify-between px-6 py-4">
                <div className="text-sm text-slate-600">Danh sách sinh viên</div>
                <div className="text-sm text-slate-400">Tổng: {students.length}</div>
              </div>

              <div className="overflow-x-auto">
                <table className="min-w-full text-sm">
                  <thead className="bg-slate-50">
                    <tr>
                      <th className="text-left px-4 py-2">Mã SV</th>
                      <th className="text-left px-4 py-2">Họ và tên</th>
                      <th className="text-left px-4 py-2">Lớp</th>
                      <th className="text-left px-4 py-2">Bộ môn</th>
                      <th className="text-left px-4 py-2">Tên đề tài</th>
                      <th className="text-left px-4 py-2">GVHD</th>
                      <th className="text-left px-4 py-2">Hoạt động</th>
                    </tr>
                  </thead>
                  <tbody>
                    {students.length === 0 ? (
                      <tr><td colSpan={7} className="px-4 py-6 text-center">Không có sinh viên</td></tr>
                    ) : students.map((s, i) => (
                      <tr key={`${s.maSV}-${i}`} className="border-t hover:bg-slate-50">
                        <td className="px-4 py-2">{s.maSV}</td>
                        <td className="px-4 py-2">{s.hoTen}</td>
                        <td className="px-4 py-2">{s.lop}</td>
                        <td className="px-4 py-2">{s.boMon || '—'}</td>
                        <td className="px-4 py-2">{s.tenDeTai}</td>
                        <td className="px-4 py-2">{s.gvhd}</td>
                        <td className="px-4 py-2">
                          <div className="flex items-center gap-2">
                            <button
                              className="h-8 w-8 grid place-items-center rounded hover:bg-slate-100"
                              title="Xem chi tiết"
                              onClick={() => s.idDeTai && setOpenViewStuFor(String(s.idDeTai))}
                            >
                              <Eye size={16} />
                            </button>
                            <button
                              className="h-8 w-8 grid place-items-center rounded hover:bg-slate-100"
                              title="Thêm giảng viên phản biện"
                              onClick={() => s.idDeTai && setOpenAddPBFor(String(s.idDeTai))}
                            >
                              <UserPlus size={16} />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>

      {/* Modals */}
      {openAddPBFor && (
        <AddReviewerModal
          deTaiId={openAddPBFor}
          onClose={() => setOpenAddPBFor(null)}
          onDone={() => load()}
        />
      )}
      {openViewStuFor && (
        <StudentDetailModal
          deTaiId={openViewStuFor}
          onClose={() => setOpenViewStuFor(null)}
        />
      )}
    </div>
  );
}
