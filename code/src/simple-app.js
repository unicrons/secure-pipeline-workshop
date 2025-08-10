# comment added
const http = require('http');

const AWS_ACCESS_KEY_ID = ''
const AWS_SECRET_ACCESS_KEY = ''

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  const url = req.url;
  const method = req.method;

  // Security headers
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');

  if (url === '/health' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      version: '1.0.0',
    }));
  } else if (url === '/' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Workshop App</title>
      </head>
      <body>
        <h1>Simple Workshop Application</h1>
        <p>This is a simple application for security scanning workshop.</p>
      </body>
      </html>
    `);
  } else if (url === '/data' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      message: 'Sample data endpoint',
      data: ['item1', 'item2', 'item3']
    }));
  } else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`Simple server running on port ${PORT}`);
  console.log(`Visit: http://localhost:${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
});
