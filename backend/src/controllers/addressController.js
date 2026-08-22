const Address = require('../models/Address');

const createAddress = async (req, res, next) => {
  try {
    const { label, recipientName, phone, addressLine1, addressLine2, landmark, city, state, postalCode, coordinates, isDefault } = req.body;

    // If setting as default, unset other defaults for this user
    if (isDefault) {
      await Address.updateMany({ user: req.auth.userId, isDefault: true }, { $set: { isDefault: false } });
    }

    const address = await Address.create({
      user: req.auth.userId, // NEVER from req.body
      label,
      recipientName,
      phone,
      addressLine1,
      addressLine2,
      landmark,
      city,
      state,
      postalCode,
      location: { type: 'Point', coordinates },
      isDefault: isDefault || false,
    });

    res.status(201).json({ success: true, data: address, requestId: req.requestId });
  } catch (err) { next(err); }
};

const listAddresses = async (req, res, next) => {
  try {
    const addresses = await Address.find({ user: req.auth.userId }).sort({ isDefault: -1, createdAt: -1 });
    res.json({ success: true, data: addresses, requestId: req.requestId });
  } catch (err) { next(err); }
};

const updateAddress = async (req, res, next) => {
  try {
    const { label, recipientName, phone, addressLine1, addressLine2, landmark, city, state, postalCode, coordinates, isDefault } = req.body;

    const updateFields = {};
    if (label !== undefined) updateFields.label = label;
    if (recipientName !== undefined) updateFields.recipientName = recipientName;
    if (phone !== undefined) updateFields.phone = phone;
    if (addressLine1 !== undefined) updateFields.addressLine1 = addressLine1;
    if (addressLine2 !== undefined) updateFields.addressLine2 = addressLine2;
    if (landmark !== undefined) updateFields.landmark = landmark;
    if (city !== undefined) updateFields.city = city;
    if (state !== undefined) updateFields.state = state;
    if (postalCode !== undefined) updateFields.postalCode = postalCode;
    if (coordinates !== undefined) updateFields.location = { type: 'Point', coordinates };
    if (isDefault !== undefined) {
      updateFields.isDefault = isDefault;
      if (isDefault) {
        await Address.updateMany({ user: req.auth.userId, isDefault: true, _id: { $ne: req.params.id } }, { $set: { isDefault: false } });
      }
    }

    // Ownership enforced in query: user must match req.auth.userId
    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, user: req.auth.userId },
      { $set: updateFields },
      { new: true, runValidators: true }
    );

    if (!address) {
      return res.status(404).json({
        success: false,
        error: { code: 'ADDRESS_NOT_FOUND', message: 'Address not found' },
        requestId: req.requestId
      });
    }

    res.json({ success: true, data: address, requestId: req.requestId });
  } catch (err) { next(err); }
};

const deleteAddress = async (req, res, next) => {
  try {
    // Ownership enforced in query
    const address = await Address.findOneAndDelete({ _id: req.params.id, user: req.auth.userId });

    if (!address) {
      return res.status(404).json({
        success: false,
        error: { code: 'ADDRESS_NOT_FOUND', message: 'Address not found' },
        requestId: req.requestId
      });
    }

    res.json({ success: true, message: 'Address deleted', requestId: req.requestId });
  } catch (err) { next(err); }
};

module.exports = { createAddress, listAddresses, updateAddress, deleteAddress };
