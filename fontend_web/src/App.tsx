import { Outlet, Link } from 'react-router-dom';

export default function App() {
    return (
        <div className="min-h-screen bg-gray-50 text-gray-900">
            <nav className="p-4 bg-white shadow flex gap-4">
                <Link to="/">Home</Link>
                <Link to="/login">Login</Link>
            </nav>
            <Outlet />
        </div>
    );
}
