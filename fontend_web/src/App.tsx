// src/App.tsx
import { Outlet, Link, useLocation } from 'react-router-dom';

export default function App() {
    const { pathname } = useLocation();
    return (
        <div className="min-h-screen">
            <main>
                <Outlet />
            </main>
        </div>
    );
}
