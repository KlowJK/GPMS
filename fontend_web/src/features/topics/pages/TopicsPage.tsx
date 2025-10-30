// src/features/topics/pages/topicspage.tsx
import { useLocation } from "react-router-dom";

export default function TopicsPage() {
    const location = useLocation();
    const fullUrl = `${window.location.origin}${location.pathname}`;

    return (
        <div className="p-6 space-y-4">
            <h1 className="text-2xl font-bold">Topics Page</h1>

            <p>
                <strong>Alias:</strong> <code>@features/topics/pages/topicspage.tsx</code>
            </p>

            <p>
                <strong>URL thực tế:</strong>{" "}
                <a href={fullUrl} className="text-blue-600 underline">
                    {fullUrl}
                </a>
            </p>


        </div>
    );
}