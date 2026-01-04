import React from 'react';

const mockAccounts = [
  { id: 1, name: 'Account A', balance: 1000 },
  { id: 2, name: 'Account B', balance: 2500 },
  { id: 3, name: 'Account C', balance: 500 },
];

const AccountsListPage: React.FC = () => (
  <div>
    <h2>Accounts List</h2>
    <ul>
      {mockAccounts.map(account => (
        <li key={account.id}>
          {account.name} - Balance: ${account.balance}
        </li>
      ))}
    </ul>
  </div>
);

export default AccountsListPage;