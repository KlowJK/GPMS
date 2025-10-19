// src/App.tsx
import { Outlet, Link, useLocation } from 'react-router-dom';

export default function App() {
    const { pathname } = useLocation();
    // Don't show the global nav on login or inside lecturer area (lecturer area has its own Topbar)
    const showNav = pathname !== '/login' && !pathname.startsWith('/lecturers') && !pathname.startsWith('/admin');;

    return (
        <div className="min-h-screen">
            <main>
                <Outlet />
            </main>
        </div>
    );
}
