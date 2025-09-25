import React from 'react';

const ProfilePage: React.FC = () => {
  // Example user data
  const user = {
    name: 'John Doe',
    email: 'john.doe@example.com',
    avatar: 'https://i.pravatar.cc/150?img=3',
  };

  return (
    <div style={{ maxWidth: 400, margin: '0 auto', textAlign: 'center' }}>
      <img
        src={user.avatar}
        alt="Avatar"
        style={{ borderRadius: '50%', width: 120, height: 120, marginBottom: 16 }}
      />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
};

export default ProfilePage;