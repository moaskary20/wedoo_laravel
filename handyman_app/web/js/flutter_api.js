// Flutter API JavaScript Helper
window.flutterApi = {
  async post(url, data, headers = {}) {
    try {
      console.log('JS API Request:', url, data, headers);
      
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
      
      console.log('JS API Response Status:', response.status);
      
      if (response.ok) {
        const result = await response.json();
        console.log('JS API Response Data:', result);
        return result;
      } else {
        const errorText = await response.text();
        console.log('JS API Error Response:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
    } catch (error) {
      console.log('JS API Error:', error);
      throw error;
    }
  },
  
  async get(url, headers = {}) {
    try {
      console.log('JS API Request:', url, headers);
      
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
      
      console.log('JS API Response Status:', response.status);
      
      if (response.ok) {
        const result = await response.json();
        console.log('JS API Response Data:', result);
        return result;
      } else {
        const errorText = await response.text();
        console.log('JS API Error Response:', errorText);
        throw new Error(`HTTP ${response.status}: ${errorText}`);
      }
    } catch (error) {
      console.log('JS API Error:', error);
      throw error;
    }
  }
};
