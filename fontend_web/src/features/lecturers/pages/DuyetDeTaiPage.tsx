import React from 'react';
import { Link } from "react-router-dom";
export default function DuyetDeTaiPage() {
  return (
    <div>
      <h2 className="text-2xl font-semibold mb-4">Duyệt đề tài</h2>
      <div className="bg-white p-6 rounded shadow">
        <p className="text-sm text-slate-600">Chưa có dữ liệu. Đây là trang placeholder cho chức năng duyệt đề tài.</p>
         <Link to="/lecturers" className="inline-block mt-4 text-[#2F7CD3] hover:underline">← Về trang chủ</Link>
      </div>
    </div>
  );
}
