const axios = require('axios');

async function test() {
  try {
    const loginRes = await axios.post('http://localhost:5000/api/v1/auth/login', {
      phone: '1234567890'
    });
    console.log('Login:', loginRes.data);
    const token = loginRes.data.token; // assuming this is how we login, wait Firebase is used?
  } catch (err) {
    console.error(err.response ? err.response.data : err.message);
  }
}
test();
