// src/features/assistants/pages/CouncilDetailPage.tsx
import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ChevronLeft, X } from 'lucide-react';
import { useToast } from '@/features/admin/components/ToastProvider';
import {
  getCouncilDetail,
  getCouncilStudentDetail,
  type CouncilDetail,
  type CouncilStudentDetail,
} from '@features/assistants/services/council/councilApi';

function fmt(d?: string) {
  if (!d) return '—';
  const [y, m, dd] = d.split('-');
  return `${dd}/${m}/${y}`;
}

export default function CouncilDetailPage() {
  const { id } = useParams();
  const nav = useNavigate();
  const { error } = useToast();

  const [data, setData] = useState<CouncilDetail | null>(null);
  const [loading, setLoading] = useState(false);

  // panel chi tiết SV/Đề tài
  const [open, setOpen] = useState(false);
  const [detailLoading, setDetailLoading] = useState(false);
  const [stu, setStu] = useState<CouncilStudentDetail | null>(null);

  useEffect(() => {
    if (!id) return;
    (async () => {
      try {
        setLoading(true);
        const detail = await getCouncilDetail(id);
        setData(detail);
      } catch (e: any) {
        error(e?.response?.data?.message || 'Không tải được chi tiết hội đồng.');
      } finally {
        setLoading(false);
      }
    })();
  }, [id]); // eslint-disable-line

  async function openStudentDetail(deTaiId: string) {
    try {
      setDetailLoading(true);
      setOpen(true);
      const d = await getCouncilStudentDetail(deTaiId);
      setStu(d);
    } catch (e: any) {
      setStu(null);
      error(e?.response?.data?.message || 'Không tải được chi tiết đề tài.');
    } finally {
      setDetailLoading(false);
    }
  }

  return (
    <div className="min-h-[calc(100vh-80px)]">
      {/* header: mũi tên quay lại */}
      <div className="flex items-center gap-2 mb-6">
        <button
          onClick={() => nav(-1)}
          className="h-9 w-9 inline-grid place-items-center rounded hover:bg-slate-100"
          title="Quay lại"
        >
          <ChevronLeft />
        </button>
        <h1 className="text-2xl font-semibold">Chi tiết hội đồng</h1>
      </div>

      <div className="bg-white shadow rounded-md p-6">
        {loading ? (
          <div className="p-6 text-center">Đang tải chi tiết...</div>
        ) : !data ? (
          <div className="p-4">Không có dữ liệu</div>
        ) : (
          <div className="space-y-6">
            {/* thông tin tổng quan */}
            <div className="grid grid-cols-3 gap-4">
              <div>
                <div className="text-sm text-slate-500">Tên hội đồng</div>
                <div className="font-medium text-slate-800">{data.tenHoiDong || '—'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Bắt đầu</div>
                <div className="text-slate-700">{fmt(data.thoiGianBatDau)}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Kết thúc</div>
                <div className="text-slate-700">{fmt(data.thoiGianKetThuc)}</div>
              </div>

              <div>
                <div className="text-sm text-slate-500">Địa điểm</div>
                <div className="mt-1 font-medium">
                  {data.diaDiem ? data.diaDiem : 'Chưa có địa điểm'}
                </div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Chủ tịch</div>
                <div className="mt-1 font-medium">{data.chuTich || '—'}</div>
              </div>
              <div>
                <div className="text-sm text-slate-500">Thư ký</div>
                <div className="mt-1 font-medium">{data.thuKy || '—'}</div>
              </div>
            </div>

            {/* các thành viên */}
            <div>
              <div className="text-sm text-slate-500 mb-2">Các thành viên</div>
              <div className="flex flex-wrap gap-2">
                {(data.giangVienPhanBien || []).length === 0 ? (
                  <span className="text-slate-500 text-sm">—</span>
                ) : (
                  data.giangVienPhanBien!.map((g, i) => (
                    <span key={i} className="px-3 py-1 bg-slate-100 text-slate-800 rounded-full text-sm">
                      {g}
                    </span>
                  ))
                )}
              </div>
            </div>

            {/* danh sách sinh viên */}
            <div>
              <div className="flex items-center justify-between">
                <div className="text-sm text-slate-500 mb-2">Danh sách sinh viên</div>
                <div className="text-sm text-slate-400">
                  Tổng: {(data.sinhVienList || []).length}
                </div>
              </div>

              <div className="overflow-x-auto border rounded">
                <table className="min-w-full table-auto text-sm">
                  <thead>
                    <tr className="bg-slate-50">
                      <th className="text-left px-3 py-2">Mã SV</th>
                      <th className="text-left px-3 py-2">Họ và tên</th>
                      <th className="text-left px-3 py-2">Lớp</th>
                      <th className="text-left px-3 py-2">Bộ môn</th>
                      <th className="text-left px-3 py-2">Tên đề tài</th>
                      <th className="text-left px-3 py-2">GVHD</th>
                      <th className="text-left px-3 py-2">Hoạt động</th>
                    </tr>
                  </thead>
                  <tbody>
                    {(data.sinhVienList || []).length === 0 ? (
                      <tr>
                        <td colSpan={7} className="p-6 text-center">Không có sinh viên</td>
                      </tr>
                    ) : (
                      data.sinhVienList!.map((s) => (
                        <tr key={s.idDeTai} className="border-b hover:bg-slate-50">
                          <td className="px-3 py-2">{s.maSV}</td>
                          <td className="px-3 py-2">{s.hoTen}</td>
                          <td className="px-3 py-2">{s.lop}</td>
                          <td className="px-3 py-2">{s.boMon ?? s.idBoMon ?? '—'}</td>
                          {/* CLICK vào tên đề tài để mở panel chi tiết */}
                          <td className="px-3 py-2">
                            <button
                              className="text-blue-600 hover:underline"
                              onClick={() => openStudentDetail(s.idDeTai)}
                              title="Xem chi tiết đề tài"
                            >
                              {s.tenDeTai}
                            </button>
                          </td>
                          <td className="px-3 py-2">{s.gvhd}</td>
                          <td className="px-3 py-2">—</td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* PANEL CHI TIẾT SV/ĐỀ TÀI (kéo từ phải) */}
      {open && (
        <div className="fixed inset-0 z-50">
          <div className="absolute inset-0 bg-black/40" onClick={() => setOpen(false)} />
          <div className="absolute right-0 top-0 h-full w-[540px] bg-white shadow-xl p-6 overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold">Chi tiết đề tài</h3>
              <button className="h-9 w-9 inline-grid place-items-center rounded hover:bg-slate-100"
                      onClick={() => setOpen(false)}>
                <X />
              </button>
            </div>

            {detailLoading ? (
              <div className="p-6 text-center">Đang tải…</div>
            ) : !stu ? (
              <div className="p-4">Không có dữ liệu</div>
            ) : (
              <div className="space-y-6">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-slate-500">Tên hội đồng</div>
                    <div className="font-medium">{stu.tenHoiDong || '—'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Khoảng thời gian</div>
                    <div>{fmt(stu.thoiGianBatDau)} — {fmt(stu.thoiGianKetThuc)}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Mã SV</div>
                    <div className="font-medium">{stu.maSinhVien}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Họ và tên</div>
                    <div className="font-medium">{stu.hoTen}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Lớp</div>
                    <div className="font-medium">{stu.lop}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Bộ môn</div>
                    <div className="font-medium">{stu.boMon ?? stu.idBoMon ?? '—'}</div>
                  </div>

                  <div className="col-span-2">
                    <div className="text-sm text-slate-500">Tên đề tài</div>
                    <div className="font-medium">{stu.tenDeTai}</div>
                  </div>

                  <div className="col-span-2">
                    <div className="text-sm text-slate-500">Đường dẫn báo cáo</div>
                    <div className="truncate">
                      {stu.duongDanBaoCao ? (
                        <a className="text-blue-600 underline" href={stu.duongDanBaoCao} target="_blank" rel="noreferrer">
                          {stu.duongDanBaoCao}
                        </a>
                      ) : '—'}
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <div className="text-sm text-slate-500">Điểm báo cáo</div>
                    <div className="font-medium">{stu.diemBaoCao ?? '—'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Điểm phản biện</div>
                    <div className="font-medium">{stu.diemPhanBien ?? '—'}</div>
                  </div>
                  <div>
                    <div className="text-sm text-slate-500">Điểm hội đồng</div>
                    <div className="font-medium">{stu.diemHoiDong ?? '—'}</div>
                  </div>
                </div>

                <div>
                  <div className="text-sm text-slate-500 mb-2">Giảng viên tham gia</div>
                  <div className="overflow-x-auto border rounded">
                    <table className="min-w-full table-auto text-sm">
                      <thead>
                        <tr className="bg-slate-50">
                          <th className="text-left px-3 py-2">Họ và tên</th>
                          <th className="text-left px-3 py-2">Mã GV</th>
                          <th className="text-left px-3 py-2">Vai trò</th>
                          <th className="text-left px-3 py-2">Bộ môn</th>
                          <th className="text-left px-3 py-2">Điểm</th>
                          <th className="text-left px-3 py-2">Nhận xét</th>
                          <th className="text-left px-3 py-2">Trạng thái</th>
                        </tr>
                      </thead>
                      <tbody>
                        {(stu.giangVien || []).length === 0 ? (
                          <tr><td colSpan={7} className="p-6 text-center">Không có dữ liệu</td></tr>
                        ) : (
                          stu.giangVien.map((g, i) => (
                            <tr key={i} className="border-b">
                              <td className="px-3 py-2">{g.hoTen}</td>
                              <td className="px-3 py-2">{g.maGiangVien}</td>
                              <td className="px-3 py-2">{g.vaiTro}</td>
                              <td className="px-3 py-2">{g.boMon ?? g.idBoMon ?? '—'}</td>
                              <td className="px-3 py-2">{g.diem ?? '—'}</td>
                              <td className="px-3 py-2">{g.nhanXet ?? '—'}</td>
                              <td className="px-3 py-2">{g.trangThai ?? '—'}</td>
                            </tr>
                          ))
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
