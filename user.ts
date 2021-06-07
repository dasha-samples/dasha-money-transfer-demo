
export interface Account {
    name: string;
    num: string;
    balance: number;
}

export interface User {
    id: string;
    phone: string;
    userAccounts: Account[];
    bankAccounts: Account[]
  }