// src/features/admin/pages/Dashboard.tsx
import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import StatCard from '@features/admin/components/StatCard';
import adminService from '@features/admin/services/adminService';
import { listNotificationsNormalized } from '@/features/assistants/services/notification/notificationApi';

export default function Dashboard() {
  const nav = useNavigate();
  const [loading, setLoading] = useState(true);
  const [deptCount, setDeptCount] = useState(0);
  const [assistantCount, setAssistantCount] = useState(0);
  const [notiCount, setNotiCount] = useState(0);

  useEffect(() => {
    (async () => {
      try {
        const [kRes, aRes, nPg] = await Promise.all([
          adminService.listDepartments({ page: 0, size: 1 }),
          adminService.listKhoaAssistants({ page: 0, size: 1 }),
          listNotificationsNormalized({ page: 0, size: 1, sort: ['updatedAt,DESC'] }),
        ]);
        const kPg = adminService.toPage<any>(kRes, { page: 0, size: 1 });
        const aPg = adminService.toPage<any>(aRes, { page: 0, size: 1 });

        setDeptCount(kPg.totalElements ?? kPg.content.length ?? 0);
        setAssistantCount(aPg.totalElements ?? aPg.content.length ?? 0);
        setNotiCount(nPg.totalElements ?? nPg.content.length ?? 0);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const cards = [
    { key: 'dept', title: 'Quản lý khoa', value: deptCount, to: '/admin/departments' },
    { key: 'assist', title: 'Quản lý trợ lý khoa', value: assistantCount, to: '/admin/assistants' },
    { key: 'noti', title: 'Quản lý thông báo', value: notiCount, to: '/admin/notifications' },
  ];

  return (
    <div className="w-full px-4 pt-6">
      <div className="mx-auto max-w-6xl space-y-6">
        {/* Tiêu đề giống dashboard Trợ lý */}
        <h1 className="text-3xl font-semibold">Trang chủ</h1>

        {/* Lưới 3 mục điều hướng */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {cards.map((c) => (
            <div
              key={c.key}
              role="button"
              onClick={() => nav(c.to)}
              className={`cursor-pointer transition-transform hover:scale-[1.01] ${
                loading ? 'pointer-events-none opacity-70' : ''
              }`}
            >
              <StatCard title={c.title} value={c.value} />
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
