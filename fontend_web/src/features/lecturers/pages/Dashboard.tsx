import { FileText, CalendarCheck, ClipboardCheck, Building } from "lucide-react";
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
      className="relative block w-96 h-[240px] rounded-xl overflow-hidden shadow-lg transform transition-transform hover:-translate-y-1 focus:outline-none focus:ring-4 focus:ring-white/30"
      style={{ background: color }}
    >
      {/* decorative top-left translucent shape */}
      <div className="absolute left-6 top-6 w-32 h-32 rounded-sm opacity-40" style={{ background: 'rgba(255,255,255,0.12)' }} />

      {/* main centered column */}
      <div className="absolute inset-0 flex flex-col items-center justify-center text-white px-6">
        <div className="flex items-center justify-center w-40 h-36">
          <div className="w-24 h-28 flex items-center justify-center rounded-md border border-white/80">
            <div className="text-white">{icon}</div>
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
      <div className="grid gap-10 grid-cols-1 sm:grid-cols-2 xl:grid-cols-2 justify-center items-start place-items-center">
        <Card to="/lecturers/do-an" title="Đồ án" icon={<FileText size={56} />} color="#0071C6" />
        <Card to="/lecturers/nhat-ky" title="Nhật ký tiến độ" icon={<CalendarCheck size={56} />} color="#0071C6" />
        <Card to="/lecturers/bao-cao" title="Báo cáo" icon={<ClipboardCheck size={56} />} color="#0071C6" />
        <Card to="/lecturers/hoi-dong" title="Hội đồng" icon={<Building size={56} />} color="#0071C6" />
      </div>

      {/* optional small helper row under the cards (matches Figma spacing) */}
    </div>
  );
}
