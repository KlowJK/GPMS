import React from "react";
import ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import { router } from "./app/routes";
import "./index.css";
import { AppQueryProvider } from './app/providers/QueryProvider'
import { Toaster } from 'sonner'


ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <AppQueryProvider>
      <RouterProvider router={router} />
        <Toaster
            position="top-right"
            toastOptions={{
                style: { fontSize: '14px' },
                classNames: {
                    error: 'bg-red-50 border-red-200 text-red-800',
                    success: 'bg-green-50 border-green-200 text-green-800',
                },
            }}
        />
    </AppQueryProvider>
  </React.StrictMode>
);
