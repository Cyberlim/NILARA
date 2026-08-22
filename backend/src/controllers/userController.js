const cloudinary = require('../config/cloudinary');
const User = require('../models/User');

const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.auth.userId).select('-__v');
    if (!user) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'User not found' },
        requestId: req.requestId
      });
    }

    res.json({
      success: true,
      data: {
        id: user._id,
        email: user.email,
        phone: user.phone,
        displayName: user.displayName,
        role: user.role,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      requestId: req.requestId
    });
  } catch (err) { next(err); }
};

const updateMe = async (req, res, next) => {
  try {
    // req.body is already validated and stripped by Zod .strict()
    const { displayName, phone } = req.body;

    const updateFields = {};
    if (displayName !== undefined) updateFields.displayName = displayName;
    if (phone !== undefined) updateFields.phone = phone;

    const user = await User.findByIdAndUpdate(
      req.auth.userId,
      { $set: updateFields },
      { new: true, runValidators: true }
    ).select('-__v');

    if (!user) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'User not found' },
        requestId: req.requestId
      });
    }

    res.json({
      success: true,
      data: {
        id: user._id,
        email: user.email,
        phone: user.phone,
        displayName: user.displayName,
        role: user.role,
        isActive: user.isActive,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      },
      requestId: req.requestId
    });
  } catch (err) { next(err); }
};

const uploadAvatar = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: { code: 'NO_FILE', message: 'No image file provided' }
      });
    }
    const stream = cloudinary.uploader.upload_stream(
      { folder: 'nilara/avatars', resource_type: 'image' },
      async (error, result) => {
        if (error) return next(error);
        const user = await User.findByIdAndUpdate(
          req.auth.userId,
          { photoUrl: result.secure_url },
          { new: true }
        );
        res.status(200).json({
          success: true,
          data: { photoUrl: user.photoUrl }
        });
      }
    );
    stream.end(req.file.buffer);
  } catch (error) {
    next(error);
  }
};

const addFcmToken = async (req, res, next) => {
  try {
    const { token } = req.body;
    if (!token) {
      return res.status(400).json({ success: false, error: { message: "FCM token is required" } });
    }

    const user = await User.findByIdAndUpdate(
      req.auth.userId,
      { $addToSet: { fcmTokens: token } },
      { new: true }
    );

    res.json({
      success: true,
      data: { message: "FCM token registered successfully" },
      requestId: req.requestId
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  uploadAvatar, getMe, updateMe, addFcmToken 
};
