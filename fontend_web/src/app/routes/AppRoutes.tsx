import { Routes, Route, Navigate } from "react-router-dom";
import LecturersApp from "../../features/lecturers/src/routes/LecturersApp";
import Dashboard from "../../features/lecturers/pages/Dashboard";
import DoAn from "../../features/lecturers/pages/DoAn";
import NhatKy from "../../features/lecturers/pages/NhatKy";
import BaoCao from "../../features/lecturers/pages/BaoCao";
import HoiDong from "../../features/lecturers/pages/HoiDong";
import CommitteesPage from "../../features/committees/pages/CommitteesPage";

export default function AppRoutes() {
  return (
    <Routes>
      {/* Redirect trang gốc vào module giảng viên (tùy bạn) */}
      <Route path="/" element={<Navigate to="/lecturers" replace />} />

      {/* Lecturers module */}
      <Route path="/lecturers" element={<LecturersApp />}>
       <Route index element={<Dashboard />} />
       <Route path="do-an" element={<DoAn />} />
       <Route path="nhat-ky" element={<NhatKy />} />
       <Route path="bao-cao" element={<BaoCao />} />
       <Route path="hoi-dong" element={<HoiDong />} />
      </Route>

      {/* Committees (Hội đồng) — module riêng */}
       <Route path="/committees" element={<CommitteesPage />} />
     {/* 404 */}
      <Route path="*" element={<div className="p-8">Không tìm thấy trang</div>} />
    </Routes>
  );
}
