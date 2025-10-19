// src/App.tsx
import { Outlet, Link, useLocation } from 'react-router-dom';

export default function App() {
    const { pathname } = useLocation();
    // Don't show the global nav on login or inside lecturer area (lecturer area has its own Topbar)
    const showNav = pathname !== '/login' && !pathname.startsWith('/lecturers') && !pathname.startsWith('/admin');;

    return (
        <div className="min-h-screen">
            {showNav && (
                <nav className="p-4 bg-white shadow flex gap-4">
                    <Link to="/lecturers">Home</Link>
                    <Link to="/topics">Topics</Link>
                </nav>
            )}
            <main>
                <Outlet />
            </main>
        </div>
    );
}
