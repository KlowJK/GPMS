import React from "react";

const mockDepartments = [
  { id: 1, name: "HR", manager: "Alice" },
  { id: 2, name: "Engineering", manager: "Bob" },
  { id: 3, name: "Marketing", manager: "Charlie" },
];

const DepartmentsListPage: React.FC = () => (
  <div>
    <h1>Departments</h1>
    <ul>
      {mockDepartments.map((dept) => (
        <li key={dept.id}>
          {dept.name} (Manager: {dept.manager})
        </li>
      ))}
    </ul>
  </div>
);

export default DepartmentsListPage;
