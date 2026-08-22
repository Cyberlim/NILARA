require('dotenv').config({ path: __dirname + '/../.env' });
const mongoose = require('mongoose');
const Category = require('../src/models/Category');
const Product = require('../src/models/Product');

const MONGO_URI = process.env.MONGO_URI;

if (!MONGO_URI) {
  console.error("Missing MONGO_URI in environment variables.");
  process.exit(1);
}

const rawCategories = [
  { name: "Water", slug: "water", imageUrl: "assets/images/1L.png", sortOrder: 1 },
  { name: "Oil", slug: "oil", imageUrl: "assets/images/nilara1lmustardoil.png", sortOrder: 2 },
  { name: "Dairy", slug: "dairy", imageUrl: "assets/images/milk.png", sortOrder: 3 },
  { name: "Grocery", slug: "grocery", imageUrl: "assets/images/bread.png", sortOrder: 4 }
];

const rawProducts = [
  // Water
  {
    name: "Nilara 250 ml",
    slug: "nilara-250-ml",
    categorySlug: "water",
    description: "Nilara Pure Water - Delivered in 8 mins.",
    images: ["assets/images/Nilara 250ml botle.png"],
    variants: [{
      sku: "NIL-250ML",
      pricePaise: 2000,
      discountPricePaise: 1500,
      stockQuantity: 500,
      unit: "ml",
      weightOrVolume: 250
    }]
  },
  {
    name: "Nilara 500 ml",
    slug: "nilara-500-ml",
    categorySlug: "water",
    description: "Nilara Pure Water - Delivered in 8 mins.",
    images: ["assets/images/500 ml.png"],
    variants: [{
      sku: "NIL-500ML",
      pricePaise: 2500,
      discountPricePaise: 2000,
      stockQuantity: 400,
      unit: "ml",
      weightOrVolume: 500
    }]
  },
  {
    name: "Nilara 1 Litre",
    slug: "nilara-1-litre",
    categorySlug: "water",
    description: "Nilara Pure Water - Delivered in 8 mins.",
    images: ["assets/images/1L.png"],
    variants: [{
      sku: "NIL-1L",
      pricePaise: 3500,
      discountPricePaise: 3000,
      stockQuantity: 300,
      unit: "l",
      weightOrVolume: 1
    }]
  },
  
  // Oil
  {
    name: "Nilara Mustard Oil 1 L",
    slug: "nilara-mustard-oil-1-l",
    categorySlug: "oil",
    description: "Pure and healthy mustard oil.",
    images: ["assets/images/nilara1lmustardoil.png"],
    variants: [{
      sku: "NIL-OIL-MST-1L",
      pricePaise: 19000,
      discountPricePaise: 16500,
      stockQuantity: 150,
      unit: "l",
      weightOrVolume: 1
    }]
  },
  {
    name: "Nilara Sunflower Oil 1 L",
    slug: "nilara-sunflower-oil-1-l",
    categorySlug: "oil",
    description: "Light and pure sunflower oil.",
    images: ["assets/images/1lsunfloweroil.png"],
    variants: [{
      sku: "NIL-OIL-SUN-1L",
      pricePaise: 17000,
      discountPricePaise: 14500,
      stockQuantity: 120,
      unit: "l",
      weightOrVolume: 1
    }]
  },
  {
    name: "Nilara Mustard Oil 5 L",
    slug: "nilara-mustard-oil-5-l",
    categorySlug: "oil",
    description: "Bulk mustard oil for cooking.",
    images: ["assets/images/5lmustardoil.png"],
    variants: [{
      sku: "NIL-OIL-MST-5L",
      pricePaise: 85000,
      discountPricePaise: 78000,
      stockQuantity: 50,
      unit: "l",
      weightOrVolume: 5
    }]
  },

  // Dairy
  {
    name: "Amul Taaza Toned Milk 1L",
    slug: "amul-taaza-toned-milk-1l",
    categorySlug: "dairy",
    description: "Fresh daily milk.",
    images: ["assets/images/milk.png"],
    variants: [{
      sku: "AMUL-MILK-1L",
      pricePaise: 5600,
      discountPricePaise: 5400,
      stockQuantity: 200,
      unit: "l",
      weightOrVolume: 1
    }]
  },
  {
    name: "Fresh Malai Paneer 200g",
    slug: "fresh-malai-paneer-200g",
    categorySlug: "dairy",
    description: "Soft and fresh paneer.",
    images: ["assets/images/pcard3.webp"],
    variants: [{
      sku: "PNR-200G",
      pricePaise: 9500,
      discountPricePaise: 8500,
      stockQuantity: 100,
      unit: "g",
      weightOrVolume: 200
    }]
  },
  {
    name: "Farm Fresh Curd 500g",
    slug: "farm-fresh-curd-500g",
    categorySlug: "dairy",
    description: "Thick and fresh curd.",
    images: ["assets/images/pcard3.webp"],
    variants: [{
      sku: "CRD-500G",
      pricePaise: 4000,
      discountPricePaise: 3500,
      stockQuantity: 120,
      unit: "g",
      weightOrVolume: 500
    }]
  },

  // Grocery
  {
    name: "India Gate Basmati Rice 5kg",
    slug: "india-gate-basmati-rice-5kg",
    categorySlug: "grocery",
    description: "Premium basmati rice.",
    images: ["assets/images/bread.png"],
    variants: [{
      sku: "RICE-BSM-5KG",
      pricePaise: 52000,
      discountPricePaise: 45000,
      stockQuantity: 40,
      unit: "kg",
      weightOrVolume: 5
    }]
  },
  {
    name: "Aashirvaad Chakki Atta 5kg",
    slug: "aashirvaad-chakki-atta-5kg",
    categorySlug: "grocery",
    description: "Whole wheat pure atta.",
    images: ["assets/images/bread.png"],
    variants: [{
      sku: "ATTA-5KG",
      pricePaise: 26000,
      discountPricePaise: 23000,
      stockQuantity: 80,
      unit: "kg",
      weightOrVolume: 5
    }]
  },
  {
    name: "Tata Sampann Toor Dal 1kg",
    slug: "tata-sampann-toor-dal-1kg",
    categorySlug: "grocery",
    description: "Unpolished toor dal.",
    images: ["assets/images/pcard3.webp"],
    variants: [{
      sku: "DAL-TOOR-1KG",
      pricePaise: 18000,
      discountPricePaise: 16000,
      stockQuantity: 100,
      unit: "kg",
      weightOrVolume: 1
    }]
  }
];

async function seed() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("Connected to MongoDB.");

    console.log("Clearing existing Categories and Products...");
    await Category.deleteMany({});
    await Product.deleteMany({});

    console.log("Inserting Categories...");
    const insertedCategories = await Category.insertMany(rawCategories);
    const catMap = {};
    insertedCategories.forEach(c => {
      catMap[c.slug] = c._id;
    });

    console.log("Inserting Products...");
    const productsToInsert = rawProducts.map(p => {
      const catId = catMap[p.categorySlug];
      if (!catId) throw new Error(`Category slug ${p.categorySlug} not found in map.`);
      const { categorySlug, ...productData } = p;
      return {
        ...productData,
        category: catId
      };
    });

    await Product.insertMany(productsToInsert);
    console.log(`Successfully seeded ${insertedCategories.length} categories and ${productsToInsert.length} products.`);

    process.exit(0);
  } catch (err) {
    console.error("Seeding error:", err);
    process.exit(1);
  }
}

seed();
