const mongoose = require('mongoose');

/**
 * Validate that a string is a valid MongoDB ObjectId.
 * Returns a controlled 400 instead of letting Mongoose throw CastError internally.
 */
const isValidObjectId = (id) => mongoose.Types.ObjectId.isValid(id);

/**
 * Express middleware to validate :id param as a valid ObjectId.
 */
const validateObjectIdParam = (paramName = 'id') => (req, res, next) => {
  const value = req.params[paramName];
  if (!value || !isValidObjectId(value)) {
    return res.status(400).json({
      success: false,
      error: {
        code: 'INVALID_ID_FORMAT',
        message: `Parameter '${paramName}' is not a valid identifier`
      },
      requestId: req.requestId
    });
  }
  next();
};

module.exports = { isValidObjectId, validateObjectIdParam };
