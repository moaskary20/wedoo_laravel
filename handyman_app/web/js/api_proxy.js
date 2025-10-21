// JavaScript API Proxy for Flutter Web
window.apiProxy = {
  async post(url, data, headers = {}) {
    try {
      console.log('JS Proxy Request: POST', url);
      console.log('JS Proxy Headers:', headers);
      console.log('JS Proxy Data:', data);
      
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'WedooApp/1.0 (Flutter Web)',
          'Origin': 'https://free-styel.store',
          ...headers
        },
        body: JSON.stringify(data),
        mode: 'cors',
        credentials: 'include'
      });
      
      console.log('JS Proxy Response:', response.status);
      
      if (response.ok) {
        const result = await response.json();
        console.log('JS Proxy Response Body:', result);
        return result;
      } else {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
    } catch (error) {
      console.error('JS Proxy Error:', error);
      throw error;
    }
  },
  
  async get(url, headers = {}) {
    try {
      console.log('JS Proxy Request: GET', url);
      console.log('JS Proxy Headers:', headers);
      
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'WedooApp/1.0 (Flutter Web)',
          'Origin': 'https://free-styel.store',
          ...headers
        },
        mode: 'cors',
        credentials: 'include'
      });
      
      console.log('JS Proxy Response:', response.status);
      
      if (response.ok) {
        const result = await response.json();
        console.log('JS Proxy Response Body:', result);
        return result;
      } else {
        const errorText = await response.text();
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
    } catch (error) {
      console.error('JS Proxy Error:', error);
      throw error;
    }
  }
};
