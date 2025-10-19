import StatCard from "../components/StatCard";

export default function Dashboard() {
  const stats = [
    { title: "Số khoa", value: 5 },
    { title: "Số ngành", value: 12 },
    { title: "Số bộ môn", value: 22 },
    { title: "Số lớp", value: 56 },
  ];

  return (
    <div className="space-y-6">
      <h1 className="text-3xl font-semibold">Trang quản trị</h1>
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        {stats.map((s) => (
          <StatCard key={s.title} title={s.title} value={s.value} />
        ))}
      </div>
    </div>
  );
}
