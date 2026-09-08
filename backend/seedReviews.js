const mongoose = require("mongoose");
const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });

const Product = require("./src/models/Product");
const User = require("./src/models/User");
const Review = require("./src/models/Review");

const MONGODB_URI = process.env.MONGO_URI || "mongodb://localhost:27017/nilara";

const dummyReviews = [
  { rating: 5, comment: "Outstanding quality! The packaging was perfect and delivery was on time. Highly recommended." },
  { rating: 5, comment: "Very fresh and exactly as described. Will definitely order again." },
  { rating: 4, comment: "Good product, reasonable price." },
  { rating: 5, comment: "Absolutely loved it, fresh and clean." },
  { rating: 4, comment: "Pretty good overall." }
];

async function seedReviews() {
  try {
    await mongoose.connect(MONGODB_URI);
    console.log("Connected to MongoDB.");

    const products = await Product.find({});
    const users = await User.find({}).limit(5);

    if (users.length === 0 || products.length === 0) {
      console.log("No users or products found.");
      return;
    }

    // Clear existing reviews
    await Review.deleteMany({});
    console.log("Cleared existing reviews.");

    for (const product of products) {
      let totalRating = 0;
      let reviewCount = 0;

      // add 3 random reviews for each product
      for (let i = 0; i < 3; i++) {
        if (i >= users.length) break;
        const user = users[i];
        
        const reviewTemplate = dummyReviews[Math.floor(Math.random() * dummyReviews.length)];
        
        const newReview = new Review({
          user: user._id,
          product: product._id,
          order: new mongoose.Types.ObjectId(), // Dummy order ID
          rating: reviewTemplate.rating,
          comment: reviewTemplate.comment,
          status: "approved"
        });
        
        await newReview.save();
        totalRating += newReview.rating;
        reviewCount++;
      }
      
      // Update product stats
      product.averageRating = totalRating / reviewCount;
      product.totalReviews = reviewCount;
      await product.save();
      console.log(`Seeded reviews for product: ${product.name}`);
    }

    console.log("Seeding complete!");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding reviews:", error);
    process.exit(1);
  }
}

seedReviews();
