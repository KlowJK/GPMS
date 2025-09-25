import React from 'react';

const mockLecturers = [
  { id: 1, name: 'Dr. John Doe', department: 'Computer Science' },
  { id: 2, name: 'Prof. Jane Smith', department: 'Mathematics' },
  { id: 3, name: 'Dr. Emily Johnson', department: 'Physics' },
];

const LecturersListPage: React.FC = () => {
  return (
    <div>
      <h1>Lecturers List</h1>
      <ul>
        {mockLecturers.map((lecturer) => (
          <li key={lecturer.id}>
            {lecturer.name} - {lecturer.department}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default LecturersListPage;