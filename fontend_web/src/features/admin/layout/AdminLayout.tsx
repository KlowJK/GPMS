import { Outlet } from "react-router-dom";
import Topbar from "../components/Topbar";
import Sidebar from "../components/Sidebar";

export default function AdminLayout() {
  return (
    <div className="h-screen w-full bg-[#F5F7FB] text-slate-800 overflow-hidden">
      <Topbar />
      <div className="flex h-[calc(100%-64px)]">
        <Sidebar />
        <main className="flex-1 overflow-y-auto p-10 bg-[#F8FAFC]">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
