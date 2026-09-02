const fs = require('fs');
const http = require('http');

const boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
const payload = '--' + boundary + '\r\n' +
                'Content-Disposition: form-data; name="images"; filename="test.png"\r\n' +
                'Content-Type: image/png\r\n\r\n';
const endBoundary = '\r\n--' + boundary + '--\r\n';

const fileData = fs.readFileSync('C:\\\\Users\\\\kdev7\\\\Downloads\\\\nilara user and delivery\\\\apps\\\\user-app\\\\assets\\\\images\\\\milk.png');

const req = http.request('http://localhost:5000/api/v1/upload/images', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2YTg4ODYwYTI3ZDdkMWI4MWQ2YThhODEiLCJlbWFpbCI6ImFkbWluQG5pbGFyYS5jb20iLCJyb2xlIjoiYWRtaW4iLCJuYW1lIjoiU3VwZXIgQWRtaW4iLCJwZXJtaXNzaW9ucyI6WyJhbGwiXSwiaWF0IjoxNzg3NjQ1NTQ3LCJleHAiOjE3ODc3MzE5NDd9.yhfbQCz2AY5pHUPDf3Amm5_k-Q0hj_jej6_7X4M3tuo',
    'Content-Type': 'multipart/form-data; boundary=' + boundary
  }
}, (res) => {
  let body = '';
  res.on('data', chunk => body += chunk);
  res.on('end', () => console.log(res.statusCode, body));
});

req.write(payload);
req.write(fileData);
req.write(endBoundary);
req.end();
