// src/App.tsx
import { Outlet, Link, useLocation } from 'react-router-dom';

export default function App() {
    const { pathname } = useLocation();
    const showNav = pathname !== '/login'; // ❗ không render nav ở trang login

    return (
        <div className="min-h-screen">
            {showNav && (
                <nav className="p-4 bg-white shadow flex gap-4">
                    <Link to="/">Home</Link>
                    <Link to="/topics">Topics</Link>
                </nav>
            )}
            <main>
                <Outlet />
            </main>
        </div>
    );
}
