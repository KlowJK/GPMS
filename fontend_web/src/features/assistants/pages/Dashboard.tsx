// src/features/assistants/pages/Dashboard.tsx
import { NavLink } from 'react-router-dom';

const Card = ({ to, label }: { to: string; label: string }) => (
  <NavLink to={to} className="block">
    <div className="bg-[#1861B2] text-white rounded-xl h-[180px] grid place-items-center hover:opacity-95">
      <div className="text-center">
        <div className="text-lg font-semibold">{label}</div>
      </div>
    </div>
  </NavLink>
);

export default function Dashboard() {
  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-semibold">Trang trợ lý khoa</h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-2 gap-8 max-w-4xl">
        <Card to="/assistant/staff" label="Quản lý giảng viên" />
        <Card to="/assistant/subjects" label="Danh mục bộ môn" />
        <Card to="/assistant/majors" label="Danh mục ngành" />
        <Card to="/assistant/staff" label="Gán quyền trưởng bộ môn" />
      </div>
    </div>
  );
}
