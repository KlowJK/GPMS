import { FileText, CalendarCheck, ClipboardCheck, Building } from "lucide-react";
import { Link } from "react-router-dom";
import type { ReactNode } from "react";

function Card({ to, title, icon }: { to: string; title: string; icon: ReactNode }) {
  return (
    <Link
      to={to}
      className="block rounded-2xl bg-[#2F7CD3] text-white p-8 text-center shadow transition-transform hover:-translate-y-0.5 hover:shadow-lg"
    >
      <div className="mx-auto h-16 w-16 grid place-items-center">{icon}</div>
      <div className="mt-4 font-semibold text-lg">{title}</div>
    </Link>
  );
}

export default function Dashboard() {
  return (
    <>
      <div className="text-xs text-slate-500 mb-4">Trang chủ</div>
      <div className="grid gap-6 grid-cols-1 sm:grid-cols-2 xl:grid-cols-2 max-w-5xl mx-auto mt-6">
        <Card to="/lecturers/do-an" title="Đồ án" icon={<FileText size={48} />} />
        <Card to="/lecturers/nhat-ky" title="Nhật ký tiến độ" icon={<CalendarCheck size={48} />} />
        <Card to="/lecturers/bao-cao" title="Báo cáo" icon={<ClipboardCheck size={48} />} />
        <Card to="/lecturers/hoi-dong" title="Hội đồng" icon={<Building size={48} />} />
      </div>
    </>
  );
}
