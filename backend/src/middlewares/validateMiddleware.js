const validate = (schema) => (req, res, next) => {
  try {
    if (schema.body) {
      req.body = schema.body.parse(req.body);
    }
    if (schema.query) {
      req.query = schema.query.parse(req.query);
    }
    if (schema.params) {
      req.params = schema.params.parse(req.params);
    }
    next();
  } catch (error) {
    // Use error.name check to avoid cross-module instanceof issues
    if (error.name === 'ZodError' || (error.issues && Array.isArray(error.issues))) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request data',
          details: (error.issues || error.errors || []).map(e => ({
            path: e.path,
            message: e.message
          }))
        },
        requestId: req.requestId
      });
    }
    next(error);
  }
};

module.exports = { validate };
