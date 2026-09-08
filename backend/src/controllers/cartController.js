const Cart = require('../models/Cart');

exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.auth.userId });
    if (!cart) {
      cart = new Cart({ user: req.auth.userId, items: [] });
      await cart.save();
    }
    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ success: false, message: 'Server error fetching cart' });
  }
};

exports.syncCart = async (req, res) => {
  try {
    const { items } = req.body;
    let cart = await Cart.findOne({ user: req.auth.userId });
    
    if (!cart) {
      cart = new Cart({ user: req.auth.userId, items: items || [] });
    } else {
      cart.items = items || [];
    }
    
    await cart.save();
    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    console.error('Sync cart error:', error);
    res.status(500).json({ success: false, message: 'Server error syncing cart' });
  }
};

exports.addItem = async (req, res) => {
  try {
    const { productId, variantId, title, imagePath, price, originalPrice, unit } = req.body;
    
    if (!productId || !variantId || !title || !imagePath || !price) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    let cart = await Cart.findOne({ user: req.auth.userId });
    if (!cart) {
      cart = new Cart({ user: req.auth.userId, items: [] });
    }

    const existingItemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId && item.variantId === variantId
    );

    if (existingItemIndex > -1) {
      cart.items[existingItemIndex].quantity += 1;
    } else {
      cart.items.push({
        productId,
        variantId,
        title,
        imagePath,
        price,
        originalPrice,
        unit,
        quantity: 1
      });
    }

    await cart.save();
    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    console.error('Add cart item error:', error);
    res.status(500).json({ success: false, message: 'Server error adding item to cart' });
  }
};

exports.removeItem = async (req, res) => {
  try {
    const { productId, variantId } = req.params;
    
    let cart = await Cart.findOne({ user: req.auth.userId });
    if (!cart) {
      return res.status(404).json({ success: false, message: 'Cart not found' });
    }

    const existingItemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId && item.variantId === variantId
    );

    if (existingItemIndex > -1) {
      if (cart.items[existingItemIndex].quantity > 1) {
        cart.items[existingItemIndex].quantity -= 1;
      } else {
        cart.items.splice(existingItemIndex, 1);
      }
      await cart.save();
    }

    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    console.error('Remove cart item error:', error);
    res.status(500).json({ success: false, message: 'Server error removing item from cart' });
  }
};

exports.clearCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.auth.userId });
    if (cart) {
      cart.items = [];
      await cart.save();
    }
    res.status(200).json({ success: true, data: cart });
  } catch (error) {
    console.error('Clear cart error:', error);
    res.status(500).json({ success: false, message: 'Server error clearing cart' });
  }
};
