const cloudinary = require('../config/cloudinary');

const uploadImages = async (req, res, next) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        error: { code: 'NO_FILES', message: 'No files were uploaded' },
        requestId: req.requestId
      });
    }

    const uploadPromises = req.files.map((file) => {
      return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          { folder: 'nilara', resource_type: 'image' },
          (error, result) => {
            if (error) reject(error);
            else resolve(result.secure_url);
          }
        );
        stream.end(file.buffer);
      });
    });

    const urls = await Promise.all(uploadPromises);

    res.status(201).json({
      success: true,
      data: urls,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

module.exports = { uploadImages };
