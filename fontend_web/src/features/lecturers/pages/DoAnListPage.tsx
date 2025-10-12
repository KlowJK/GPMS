import React from 'react';
import { Link } from "react-router-dom";
export default function DoAnListPage() {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4">Danh sách sinh viên hướng dẫn</h2>
      <div className="bg-white p-6 rounded shadow">
        <p className="text-sm text-slate-600">Chưa có dữ liệu. Đây là trang placeholder cho danh sách sinh viên hướng dẫn.</p>
          <Link to="/lecturers" className="inline-block mt-4 text-[#2F7CD3] hover:underline">← Về trang chủ</Link>
      </div>
    </div>
  );
}
