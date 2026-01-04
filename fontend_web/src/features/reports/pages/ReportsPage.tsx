import React from 'react';

const mockReports = [
  { id: 1, title: 'Sales Report', date: '2024-06-01' },
  { id: 2, title: 'Inventory Report', date: '2024-06-02' },
  { id: 3, title: 'Customer Report', date: '2024-06-03' },
];

const ReportsPage: React.FC = () => {
  return (
    <div>
      <h1>Reports</h1>
      <ul>
        {mockReports.map(report => (
          <li key={report.id}>
            <strong>{report.title}</strong> - {report.date}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default ReportsPage;