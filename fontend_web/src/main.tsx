import React from "react";
import ReactDOM from "react-dom/client";
import { RouterProvider } from "react-router-dom";
import { router } from "./app/routes"; // hoặc "@/app/routes" nếu có alias
import "./index.css";
import { AppQueryProvider } from './app/providers/QueryProvider'


ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <AppQueryProvider>
      <RouterProvider router={router} />
    </AppQueryProvider>
  </React.StrictMode>
);
