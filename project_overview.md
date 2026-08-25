# NILARA Platform Overview

## 1. Project Purpose & Problem Solved
**NILARA** is a comprehensive hyper-local e-commerce and logistics platform designed for businesses that handle both standard product sales and recurring deliveries. 

**The Problem:** Traditional e-commerce platforms (like Shopify) are excellent for shipping boxes across the country but struggle with hyper-local operations that require:
- **Recurring Deliveries:** Managing daily or weekly drop-offs (e.g., water jars, milk, meal preps).
- **Logistics & Dispatch:** Managing a fleet of delivery partners and assigning them specific daily routes.
- **Bulk Orders:** Handling B2B or event-based large volume requests.

**The Solution:** NILARA bridges the gap between a storefront and a logistics manager. It allows customers to buy products, subscribe to recurring deliveries, and place bulk orders, while giving the business a powerful admin panel to monitor revenue, dispatch drivers, and track deliveries in real-time.

---

## 2. High-Level Architecture & Tech Stack
The platform is built as a **Monorepo** (or a closely coupled multi-repo structure) consisting of three core pillars:

1. **Backend API (`backend/`)**
   - **Tech Stack:** Node.js, Express, MongoDB (Mongoose).
   - **Role:** The central brain. It exposes RESTful APIs for all CRUD operations and business logic.
   - **Real-Time:** Uses `Socket.io` to track live deliveries and location updates of delivery partners.
   - **Integrations:** Firebase (Auth, Push Notifications via FCM), Cloudinary (Image uploads), and integrated Payment Gateways.

2. **Customer App (`apps/user-app/`)**
   - **Tech Stack:** Flutter, Dart.
   - **Role:** The cross-platform mobile application (iOS & Android) for end-users.
   - **Key Features:** Browsing categories, standard cart checkout, managing wallets, subscribing to products, tracking active orders, and managing saved addresses.

3. **Admin Dashboard (`apps/admin-web/`)**
   - **Tech Stack:** Next.js (React), Tailwind CSS.
   - **Role:** The control center for the business owners and dispatchers.
   - **Key Features:** KPI Dashboards, managing catalogs (Products & Categories), reviewing Bulk Orders, Subscription management, a Delivery Calendar for route planning, and Live Delivery tracking.

---

## 3. Data Flow & User Journeys

### A. The Standard E-Commerce Flow
1. **Discovery:** A user opens the Flutter app, logs in via OTP (Firebase Auth), and browses products.
2. **Checkout:** User adds items to their Cart and proceeds to checkout, optionally applying Wallet balances or Coupons.
3. **Processing:** The Node.js backend verifies the order and saves it to MongoDB.
4. **Fulfillment:** The Admin sees the order on the Next.js dashboard, prepares the item, and assigns a Delivery Partner.
5. **Delivery:** The Delivery Partner picks up the order and delivers it, updating the status to "Delivered", which notifies the user via FCM (Firebase Cloud Messaging).

### B. The Subscription Flow (The Differentiator)
1. **Setup:** A user browses "Plans" (e.g., 20L Water Jar delivered every alternate day).
2. **Subscription Creation:** The user sets their preferred schedule and delivery time. The backend creates a `Subscription` record.
3. **Automated Dispatch:** The system or the Admin uses the **Delivery Calendar** to see what needs to be delivered on any given day, generating tasks for delivery partners without the user having to re-order manually.

### C. The Logistics & Real-Time Flow
1. **Assignment:** Delivery Partners are assigned batches of orders or subscriptions.
2. **Tracking:** As the partner moves, their app sends location coordinates to the backend via WebSockets (`Socket.io`).
3. **Monitoring:** The Admin uses the "Live Deliveries" tab in the Next.js dashboard to see the real-time location of their fleet on a map, ensuring SLAs are met.

---

## 4. Key Data Models (MongoDB)
- **User:** Stores Customers, Admins, and Delivery Partners. Includes wallet balances and FCM tokens.
- **Product & Category:** The standard catalog hierarchy.
- **Order:** Tracks one-off purchases, pricing (stored in paise to avoid floating-point errors), and delivery status.
- **Subscription:** Tracks recurring delivery schedules and linked products.
- **BulkOrder:** A specialized schema for large volume inquiries that require manual quotes or admin approval.
- **Settings:** Global app settings (e.g., delivery fees, business toggles) controlled from the Admin dashboard.
