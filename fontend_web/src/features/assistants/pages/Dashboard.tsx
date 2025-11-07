// src/features/assistants/pages/Dashboard.tsx
import { Link } from "react-router-dom";
import type { ReactNode } from "react";
import {
  Home,
  Users,
  Building2,
  ShieldCheck,
  Building,
  Megaphone,
} from "lucide-react";

const PRIMARY = "#0B5ED7"; // cùng màu với mục "Đồ án"

function Card({
  to,
  title,
  icon,
  color = PRIMARY,
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
      className="relative block w-full max-w-xs sm:w-80 md:w-96 h-40 sm:h-44 md:h-[220px]
                 rounded-xl overflow-hidden shadow-lg transform transition-transform
                 hover:-translate-y-1 focus:outline-none focus:ring-4 focus:ring-white/30"
      style={{ background: color }}
    >
      <div
        className="absolute left-6 top-6 w-32 h-32 rounded-sm opacity-40"
        style={{ background: "rgba(255,255,255,0.12)" }}
      />
      <div className="absolute inset-0 flex flex-col items-center justify-center text-white px-6">
        <div className="flex items-center justify-center w-full h-28 sm:h-32 md:h-36">
          <div className="w-20 h-20 sm:w-24 sm:h-24 md:w-28 md:h-28 flex items-center justify-center rounded-md border border-white/80">
            {icon}
          </div>
        </div>
        <div className="mt-4 text-center text-white text-base font-semibold">
          {title}
        </div>
      </div>
      <div className="absolute right-4 bottom-4 opacity-10 w-16 h-16 rounded-full bg-white" />
    </Link>
  );
}

export default function AssistantDashboard() {
  return (
    <div className="max-w-7xl mx-auto px-6 sm:px-10 md:px-12 py-10">
      <h1 className="text-3xl font-bold text-center mb-10">Trang trợ lý</h1>

      <div className="grid gap-8 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 place-items-center">
        <Card
          to="/assistant"
          title="Trang chủ"
          icon={<Home className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
        <Card
          to="/assistant/staff"
          title="Quản lý tài khoản"
          icon={<Users className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
        <Card
          to="/assistant/subjects"
          title="Quản lý tổ chức"
          icon={<Building2 className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
        <Card
          to="/assistant/defense-rounds"
          title="Đồ án"
          icon={<ShieldCheck className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
        <Card
          to="/assistant/councils"
          title="Hội đồng"
          icon={<Building className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
        <Card
          to="/assistant/notifications"
          title="Thông báo"
          icon={<Megaphone className="w-14 h-14 sm:w-16 sm:h-16 md:w-20 md:h-20" />}
        />
      </div>
    </div>
  );
}
