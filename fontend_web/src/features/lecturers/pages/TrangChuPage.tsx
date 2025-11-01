import { FileText, CalendarCheck, ClipboardCheck, Building, MessageSquare } from "lucide-react";
import { Link } from "react-router-dom";
import type { ReactNode } from "react";

function Card({
  to,
  title,
  icon,
  color = "#0071C6",
}: {
  to: string;
  title: string;
  icon: ReactNode;
  color?: string;
}) {
  return (
    <Link
      to={to}
      aria-label={`Đi tới ${title}`}
      className="relative block w-full max-w-xs sm:w-80 md:w-96 h-40 sm:h-44 md:h-[240px] rounded-xl overflow-hidden shadow-lg transform transition-transform hover:-translate-y-1 focus:outline-none focus:ring-4 focus:ring-white/30"
      style={{ background: color }}
    >
      {/* decorative top-left translucent shape */}
      <div className="absolute left-6 top-6 w-32 h-32 rounded-sm opacity-40" style={{ background: 'rgba(255,255,255,0.12)' }} />

      {/* main centered column */}
      <div className="absolute inset-0 flex flex-col items-center justify-center text-white px-6">
        <div className="flex items-center justify-center w-full h-28 sm:h-32 md:h-36">
          <div className="w-20 h-20 sm:w-24 sm:h-24 md:w-28 md:h-32 flex items-center justify-center rounded-md border border-white/80">
            <div className="text-white flex items-center justify-center">{icon}</div>
          </div>
        </div>

        <div className="mt-6 text-center">
          <div className="text-white text-base font-semibold">{title}</div>
        </div>
      </div>

      {/* subtle bottom-left accent */}
      <div className="absolute right-4 bottom-4 opacity-10 w-16 h-16 rounded-full bg-white" />
    </Link>
  );
}

export default function Dashboard() {
  return (
    <div className="max-w-7xl mx-auto px-12 py-10">
  <div className="grid gap-10 grid-cols-1 sm:grid-cols-3 md:grid-cols-3 lg:grid-cols-3 xl:grid-cols-3 justify-center items-start place-items-center">
  <Card to="/lecturers/do-an/duyet" title="Duyệt đề tài" icon={<FileText className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />
  <Card to="/lecturers/do-an/list" title="Danh sách đồ án" icon={<FileText className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />
  <Card to="/lecturers/nhat-ky" title="Nhật ký tiến độ" icon={<CalendarCheck className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />
  <Card to="/lecturers/bao-cao" title="Báo cáo" icon={<ClipboardCheck className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />
    <Card to="/lecturers/phan-bien" title="Phản biện" icon={<MessageSquare className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />
  <Card to="/lecturers/hoi-dong" title="Hội đồng" icon={<Building className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />} color="#0071C6" />

      </div>

      {/* optional small helper row under the cards (matches Figma spacing) */}
    </div>
  );
}
