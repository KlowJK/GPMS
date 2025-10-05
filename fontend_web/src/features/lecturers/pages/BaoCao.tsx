import { Link } from "react-router-dom";
export default function BaoCao() {
  return (
    <div>
      <h1 className="text-2xl font-semibold">Báo cáo</h1>
      <p className="text-slate-600 mt-2">Nội dung trang Báo cáo (placeholder).</p>
      <Link to="/lecturers" className="inline-block mt-4 text-[#2F7CD3] hover:underline">← Về trang chủ</Link>
    </div>
  );
}
