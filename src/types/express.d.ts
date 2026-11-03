declare global {
  namespace Express {
    interface User {
      id: number;
      username: string;
      password_hash: string;
    }
  }
}

export {};
