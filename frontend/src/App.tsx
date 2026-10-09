import { RouterProvider, createBrowserRouter, Navigate, Outlet } from 'react-router-dom';
import { lazy, Suspense } from 'react';
import { MainLayout } from '@/components/layout/main-layout';
import { AuthProvider, useAuth } from '@/contexts/AuthContext';
import { Toaster } from '@/components/ui/sonner';

const Dashboard = lazy(() => import("@/pages/Dashboard"));
const Books = lazy(() => import("@/pages/Books"));
const Readers = lazy(() => import("@/pages/Readers"));
const Transactions = lazy(() => import("@/pages/Transactions"));
const Reports = lazy(() => import("@/pages/Reports"));
const Settings = lazy(() => import("@/pages/Settings"));
const Accounts = lazy(() => import("@/pages/Accounts"));
const Login = lazy(() => import("@/pages/Login"));
const Categories = lazy(() => import("@/pages/Categories"));
const Authors = lazy(() => import("@/pages/Authors"));
const Publishers = lazy(() => import("@/pages/Publishers"));
const BookDetails = lazy(() => import("@/pages/BookDetails"));

const ProtectedRoute = () => {
  const { user } = useAuth();
  if (!user) {
    return <Navigate to="/login" replace />;
  }
  return <Outlet />;
};

const router = createBrowserRouter([
  {
    path: "/login",
    element: <Login />,
  },
  {
    element: <ProtectedRoute />,
    children: [
      {
        element: <MainLayout />,
        children: [
          { path: "/", element: <Dashboard /> },
          { path: "/books", element: <Books /> },
          { path: "/books/:id", element: <BookDetails /> },
          { path: "/readers", element: <Readers /> },
          { path: "/transactions", element: <Transactions /> },
          { path: "/reports", element: <Reports /> },
          { path: "/settings", element: <Settings /> },
          { path: "/accounts", element: <Accounts /> },
          { path: "/categories", element: <Categories /> },
          { path: "/authors", element: <Authors /> },
          { path: "/publishers", element: <Publishers /> },
                  ],
      },
    ],
  },
]);

const App = () => {
  return (
    <AuthProvider>
      <Suspense fallback={<div>Loading...</div>}>
        <RouterProvider router={router} />
      </Suspense>
      <Toaster />
    </AuthProvider>
  );
};

export default App;

