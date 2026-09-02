const Settings = require('../models/Settings');

// @desc    Get global settings
// @route   GET /api/v1/settings
// @access  Public
exports.getSettings = async (req, res) => {
  try {
    let settings = await Settings.findOne();
    if (!settings) {
      // Create defaults if not exists
      settings = await Settings.create({});
    }
    
    // Seed homeBanners if they are empty
    if (!settings.homeBanners || settings.homeBanners.length === 0) {
      settings.homeBanners = [
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644337/nilara/ge7lwgtjgbytmg2ywx8y.png', actionType: 'category', searchQuery: 'bottle', tabName: 'Water' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644338/nilara/k4w90z2fsskhbeavssyz.png', actionType: 'bulk_order', tabName: 'Water' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644339/nilara/dld7bxebwtz86hmdhjzy.png', actionType: 'category', searchQuery: '20l|can', tabName: 'Water' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644340/nilara/nm3efvopmga3qcbvpztj.png', actionType: 'category', searchQuery: 'carton', tabName: 'Water' },
        
        { img: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'mustard', tabName: 'Oils' },
        { img: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'sunflower', tabName: 'Oils' },
        { img: 'https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'soybean', tabName: 'Oils' },
        { img: 'https://images.unsplash.com/photo-1589927986076-2558976b34f6?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'groundnut', tabName: 'Oils' },
        
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644783/nilara/pfoaa984o70ejuolmjkv.jpg', actionType: 'category', searchQuery: 'milk', tabName: 'Dairy' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644784/nilara/j7q1uc3kmnjipoouwexc.webp', actionType: 'category', searchQuery: 'paneer', tabName: 'Dairy' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644784/nilara/j7q1uc3kmnjipoouwexc.webp', actionType: 'category', searchQuery: 'curd', tabName: 'Dairy' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644785/nilara/efivl64tihiarhqxhoyg.jpg', actionType: 'category', searchQuery: 'butter', tabName: 'Dairy' },
        
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644787/nilara/s2pfcbkkaz6kikemjosg.jpg', actionType: 'category', searchQuery: 'rice', tabName: 'Grocery' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644784/nilara/j7q1uc3kmnjipoouwexc.webp', actionType: 'category', searchQuery: 'dals', tabName: 'Grocery' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644788/nilara/hstoeubdtddb5fczggfj.jpg', actionType: 'category', searchQuery: 'spices', tabName: 'Grocery' },
        { img: 'https://res.cloudinary.com/xkzptzzq/image/upload/v1787644790/nilara/flxlfutolmt1arbxqqvm.jpg', actionType: 'category', searchQuery: 'dry fruits', tabName: 'Grocery' }
      ];
      await settings.save();
    }
    // Seed categoryTabs if they are empty
    if (!settings.categoryTabs || settings.categoryTabs.length === 0) {
      settings.categoryTabs = [
        { name: "Water", iconName: "water_drop_outlined" },
        { name: "Oils", iconName: "opacity_outlined" },
        { name: "Dairy", iconName: "egg_alt_outlined" },
        { name: "Grocery", iconName: "shopping_basket_outlined" }
      ];
      await settings.save();
    }

    res.status(200).json({ success: true, data: settings });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};

// @desc    Update global settings
// @route   PUT /api/v1/settings
// @access  Private/Admin
exports.updateSettings = async (req, res) => {
  try {
    let settings = await Settings.findOne();
    
    if (!settings) {
      settings = await Settings.create(req.body);
    } else {
      settings = await Settings.findOneAndUpdate({}, req.body, {
        new: true,
        runValidators: true,
      });
    }

    res.status(200).json({ success: true, data: settings });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, message: 'Server Error' });
  }
};
