const { v4: uuidv4 } = require('uuid');

const requestLogger = (req, res, next) => {
  req.requestId = uuidv4();
  res.setHeader('X-Request-ID', req.requestId);
  
  // Basic logging
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} - ${res.statusCode} [${duration}ms] - reqId: ${req.requestId}`);
  });
  
  next();
};

module.exports = requestLogger;
