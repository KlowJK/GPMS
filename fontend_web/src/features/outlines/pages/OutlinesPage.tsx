import React from 'react';

const mockOutlines = [
  { id: 1, title: 'Outline 1', description: 'Description for outline 1' },
  { id: 2, title: 'Outline 2', description: 'Description for outline 2' },
  { id: 3, title: 'Outline 3', description: 'Description for outline 3' },
];

const OutlinesPage: React.FC = () => {
  return (
    <div>
      <h1>Outlines</h1>
      <ul>
        {mockOutlines.map(outline => (
          <li key={outline.id}>
            <h2>{outline.title}</h2>
            <p>{outline.description}</p>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default OutlinesPage;