import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import StatCard from '@features/admin/components/StatCard';
import adminService from '@features/admin/services/adminService';

export default function Dashboard() {
  const nav = useNavigate();
  const [loading, setLoading] = useState(true);
  const [khoaCount, setKhoaCount] = useState(0);
  const [assistantCount, setAssistantCount] = useState(0);

  useEffect(() => {
    (async () => {
      try {
        // gọi size=1 để BE trả về totalElements (nếu có)
        const [kRes, aRes] = await Promise.all([
          adminService.listDepartments({ page: 0, size: 1 }),
          adminService.listKhoaAssistants({ page: 0, size: 1 }),
        ]);
        const kPg = adminService.toPage<any>(kRes, { page: 0, size: 1 });
        const aPg = adminService.toPage<any>(aRes, { page: 0, size: 1 });

        setKhoaCount(kPg.totalElements ?? kPg.content.length ?? 0);
        setAssistantCount(aPg.totalElements ?? aPg.content.length ?? 0);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const cards = [
    { title: 'Số khoa', value: khoaCount, to: '/admin/departments' },
    { title: 'Số trợ lý khoa', value: assistantCount, to: '/admin/assistants' },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-semibold">Trang quản trị</h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {cards.map((c) => (
          <div
            key={c.title}
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
  );
}
