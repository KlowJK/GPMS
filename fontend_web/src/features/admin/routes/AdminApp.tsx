import { Outlet } from "react-router-dom";
import Topbar from "../components/Topbar";
import Sidebar from "../components/Sidebar";

export default function AdminApp() {
  return (
    <div className="h-screen w-full bg-[#F5F7FB] text-slate-800">
      <Topbar />
      <div className="flex h-[calc(100%-64px)]">
        <div className="hidden lg:block">
          <Sidebar />
        </div>
        <main className="flex-1 overflow-y-auto px-12 sm:px-16 py-8">
          <Outlet />
        </main>
      </div>
    </div>
  );
}
