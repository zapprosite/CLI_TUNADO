// Minimal HTTP server without external deps
// Serves static index.html and a /healthz endpoint
// Usage: PORT=3000 node server.js
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT ? Number(process.env.PORT) : 3000;
const PUBLIC = path.join(__dirname, 'public');

function serveFile(res, filePath, contentType = 'text/html; charset=utf-8') {
  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('Not Found');
      return;
    }
    res.writeHead(200, { 'Content-Type': contentType });
    res.end(data);
  });
}

const server = http.createServer((req, res) => {
  if (req.url === '/healthz') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ ok: true }));
    return;
  }

  // Only one page for now
  const indexPath = path.join(PUBLIC, 'index.html');
  serveFile(res, indexPath);
});

server.listen(PORT, () => {
  console.log(`[hello-app] listening on http://localhost:${PORT}`);
});

