import { auth } from './firebase';

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1';

export async function fetchWithAuth(endpoint, options = {}) {
  const user = auth.currentUser;
  
  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (user) {
    const token = await user.getIdToken();
    headers['Authorization'] = `Bearer ${token}`;
  }

  // If uploading form data, browser sets Content-Type automatically with boundaries
  if (options.body instanceof FormData) {
    delete headers['Content-Type'];
  }

  const response = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers,
  });

  const data = await response.json();
  
  if (!response.ok) {
    throw new Error(data.message || data.error?.message || 'API Request Failed');
  }

  return data;
}
