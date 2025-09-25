import React from 'react';

const mockStudents = [
  { id: 1, name: 'Alice', age: 20 },
  { id: 2, name: 'Bob', age: 22 },
  { id: 3, name: 'Charlie', age: 21 },
];

const StudentsListPage: React.FC = () => (
  <div>
    <h2>Students List</h2>
    <ul>
      {mockStudents.map(student => (
        <li key={student.id}>
          {student.name} - Age: {student.age}
        </li>
      ))}
    </ul>
  </div>
);

export default StudentsListPage;