const isProduction = process.env.NODE_ENV === 'production';

const errorHandler = (err, req, res, next) => {
  // Log full error server-side. Never expose to client.
  if (!isProduction) {
    console.error(`[Error] reqId: ${req.requestId} - ${err.stack || err}`);
  } else {
    // In production, log only message + code, never full stack to external sinks
    console.error(`[Error] reqId: ${req.requestId} - ${err.message || 'Unknown error'}`);
  }

  const statusCode = err.statusCode || 500;

  // Zod validation error
  if (err.name === 'ZodError') {
    return res.status(400).json({
      success: false,
      error: {
        code: 'VALIDATION_ERROR',
        message: 'Invalid request data',
        details: err.errors.map(e => ({
          path: e.path,
          message: e.message
        }))
      },
      requestId: req.requestId
    });
  }

  // Mongoose CastError (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      error: {
        code: 'INVALID_ID_FORMAT',
        message: 'Invalid identifier format'
      },
      requestId: req.requestId
    });
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    return res.status(409).json({
      success: false,
      error: {
        code: 'DUPLICATE_RESOURCE',
        message: 'A resource with that identifier already exists'
      },
      requestId: req.requestId
    });
  }

  // Multer file size error
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({
      success: false,
      error: {
        code: 'FILE_TOO_LARGE',
        message: 'Uploaded file exceeds the maximum allowed size'
      },
      requestId: req.requestId
    });
  }

  // Generic safe response — never expose stack, paths, connection strings, or env vars
  res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_SERVER_ERROR',
      message: statusCode === 500 ? 'An unexpected error occurred' : err.message
    },
    requestId: req.requestId
  });
};

module.exports = errorHandler;
