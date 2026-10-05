import { RouterProvider, createBrowserRouter } from 'react-router-dom';
import { lazy } from 'react';
import { MainLayout } from '@/components/layout/main-layout';

const Dashboard = lazy(() => import("@/pages/Dashboard"));
const Books = lazy(() => import("@/pages/Books"));
const Readers = lazy(() => import("@/pages/Readers"));
const Transactions = lazy(() => import("@/pages/Transactions"));
const Reports = lazy(() => import("@/pages/Reports"));
const Settings = lazy(() => import("@/pages/Settings"));

const router = createBrowserRouter([
  {
    element: <MainLayout />,
    children: [
      { path: "/", element: <Dashboard /> },
      { path: "/books", element: <Books /> },
      { path: "/readers", element: <Readers /> },
      { path: "/transactions", element: <Transactions /> },
      { path: "/reports", element: <Reports /> },
      { path: "/settings", element: <Settings /> },
    ],
  },
]);

const App = () => {
  return (
    <RouterProvider router={router} />
  );
};

export default App;

