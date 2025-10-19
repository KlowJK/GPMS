// src/app/routes/index.tsx
import { createBrowserRouter, Navigate } from 'react-router-dom';
import App from '../../App';
import ProtectedRoute from './ProtectedRoute';
import RoleGuard from './RoleGuard';

export const router = createBrowserRouter([
    {
        path: '/',
        element: <App />,
        children: [
            // → Vào app là chuyển thẳng sang /login
            { index: true, element: <Navigate to="/login" replace /> },

            // Public
            {
                path: 'login',
                lazy: () =>
                    import('@features/auth/pages/LoginPage').then(m => ({ Component: m.default })),
            },

            // Authenticated area
            {
                element: <ProtectedRoute />,
                children: [
                    // Trang chủ sau đăng nhập
                    {
                        path: 'topics',
                        lazy: () =>
                            import('@features/topics/pages/TopicsPage').then(m => ({ Component: m.default })),
                    },
                    {
                        path: 'profile',
                        lazy: () =>
                            import('@features/auth/pages/ProfilePage').then(m => ({ Component: m.default })),
                    },
                    // Common authenticated
                    {
                        path: 'outlines',
                        lazy: () =>
                            import('@features/outlines/pages/OutlinesPage').then(m => ({ Component: m.default })),
                    },
                    {
                        path: 'reports',
                        lazy: () =>
                            import('@features/reports/pages/ReportsPage').then(m => ({ Component: m.default })),
                    },

                    // Admin/Assistant
                    {
                        element: <RoleGuard allow={['QUAN_TRI_VIEN', 'TRO_LY_KHOA']} />,
                        children: [
                             {
                              path: 'admin',
                              lazy: () => import('@features/admin/routes/AdminApp').then(m => ({ Component: m.default })),
                              children: [
                              { index: true, lazy: () => import('@features/admin/pages/Dashboard').then(m => ({ Component: m.default })) },
                              { path: 'departments', lazy: () => import('@features/admin/pages/Department').then(m => ({ Component: m.default })) },
                              { path: 'majors', lazy: () => import('@features/admin/pages/Major').then(m => ({ Component: m.default })) },
                              { path: 'subjects', lazy: () => import('@features/admin/pages/Subject').then(m => ({ Component: m.default })) },
                              { path: 'classes', lazy: () => import('@features/admin/pages/Class').then(m => ({ Component: m.default })) },
                              { path: 'lecturers', lazy: () => import('@features/admin/pages/LecturerAccounts').then(m => ({ Component: m.default })) },
                              ]
                            },
                            {
                                path: 'accounts',
                                lazy: () =>
                                    import('@features/accounts/pages/AccountsListPage').then(m => ({ Component: m.default })),
                            },
                            {
                                path: 'departments',
                                lazy: () =>
                                    import('@features/departments/pages/DepartmentsListPage').then(m => ({ Component: m.default })),
                            },
                        ],
                    },

                    // Student
                    {
                        element: <RoleGuard allow={['SINH_VIEN']} />,
                        children: [
                            {
                                path: 'students',
                                lazy: () =>
                                    import('@features/students/pages/StudentsListPage').then(m => ({ Component: m.default })),
                            },
                        ],
                    },

                    // Lecturer
                    {
                        element: <RoleGuard allow={['GIANG_VIEN', 'TRUONG_BO_MON']} />,
                        children: [
                            {
                                path: 'lecturers',
                                // Lecturer area layout (topbar + sidebar). Children routes are nested.
                                lazy: () => import('@features/lecturers/src/routes/LecturersApp').then(m => ({ Component: m.default })),
                                children: [
                                    { index: true, lazy: () => import('@features/lecturers/pages/Dashboard').then(m => ({ Component: m.default })) },
                                    { path: 'do-an/list', lazy: () => import('../../features/lecturers/pages/DoAnListPage').then(m => ({ Component: m.default })) },
                                    { path: 'do-an/duyet', lazy: () => import('../../features/lecturers/pages/DuyetDeTaiPage').then(m => ({ Component: m.default })) },
                                    { path: 'nhat-ky', lazy: () => import('@features/lecturers/pages/NhatKy').then(m => ({ Component: m.default })) },
                                    { path: 'bao-cao', lazy: () => import('@features/lecturers/pages/BaoCao').then(m => ({ Component: m.default })) },
                                    { path: 'hoi-dong', lazy: () => import('@features/lecturers/pages/HoiDong').then(m => ({ Component: m.default })) },
                                ],
                            },
                        ],
                    },
                ],
            },

            { path: '403', element: <div className="p-6">Forbidden</div> },
            { path: '*', element: <div className="p-6">Not Found</div> },
        ],
    },
]);
