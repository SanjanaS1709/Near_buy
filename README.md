NearBuy – Hyperlocal Multi-Vendor Marketplace

NearBuy is a hyperlocal multi-vendor shopping platform that connects local store owners and nearby customers through a location-based digital marketplace.
The application allows local vendors to register their stores, upload product listings, and receive orders from nearby users, while customers can easily discover stores on a map and place orders for home delivery or store pickup.
The platform is designed to digitize small and neighborhood businesses, enabling them to compete with large corporate e-commerce platforms by providing a simple and accessible online marketplace.
NearBuy is built using Flutter for the frontend, Firebase services for backend infrastructure, and OpenStreetMap for map-based store discovery, ensuring a scalable and cost-efficient architecture.

Motivation

Local vendors and neighborhood stores often struggle to compete with large e-commerce corporations due to the lack of digital infrastructure and online visibility.
Many small businesses rely only on walk-in customers and cannot afford to build their own digital platforms. Meanwhile, consumers increasingly expect convenient online ordering and quick access to nearby products.
NearBuy aims to bridge this gap by creating a hyperlocal digital marketplace where small businesses can gain online presence without needing technical expertise or expensive infrastructure.

The primary motivations behind this project are:

• Enable small businesses to compete with large e-commerce platforms
• Provide digital storefronts for local vendors
• Allow customers to discover nearby stores quickly using maps
• Reduce waiting time through preorder and pickup options
• Support community-driven local commerce

By focusing on proximity and convenience, NearBuy creates a platform where local vendors can compete based on accessibility, speed, and community trust rather than marketing budgets.

Key Features

  * Multi-Vendor Marketplace
  * Multiple vendors can register and manage their own stores within the platform.
  * Location-Based Store Discovery
  * Customers can discover nearby stores using a map interface powered by OpenStreetMap.
  * Product Catalog Management
  * Store owners can add, edit, and manage their product listings.
  * Shopping Cart System
  * Customers can browse products, add items to a cart, and place orders.
  * Flexible Ordering Options
      Users can choose between:
      • Home Delivery
      • Store Pickup (Takeaway)
  * Real-Time Order Updates
  * Customers receive order status updates such as preparation progress and delivery notifications.
  * Vendor Order Dashboard
  * Store owners can view incoming orders and update order statuses.

Technology Stack
Frontend
    Flutter is used to build a cross-platform user interface.
    Main Flutter packages used:
        flutter_map – Map rendering using OpenStreetMap
        latlong2 – Geographic coordinate handling
        geolocator – User location detection
        provider – State management

Backend Services
    Firebase provides backend infrastructure for authentication, database, and notifications.
    Firebase Authentication – User login and registration
    Cloud Firestore – Database for stores, products, and orders
    Firebase Cloud Messaging – Real-time push notifications
    Firebase Storage – Product image storage

Map Integration
    The application uses OpenStreetMap (OSM) via the flutter_map package instead of Google Maps to avoid API costs and maintain open-source compatibility.
    Map tiles are loaded using:
      https://tile.openstreetmap.org/{z}/{x}/{y}.png
      
System Architecture
The NearBuy platform follows a client-cloud architecture where the Flutter application interacts with Firebase services and OpenStreetMap.
<img width="1366" height="598" alt="image" src="https://github.com/user-attachments/assets/bae6caf0-1103-4f20-84ca-44602e6be121" />


Application Architecture

The project uses a feature-based modular architecture to improve maintainability and scalability.

lib/
│
├ core
│
├ features
│   ├ auth
│   ├ user
│   ├ store_owner
│   ├ profile
│   └ orders
│
├ theme
│
├ widgets
│
└ main.dart
Core

Contains shared services such as:

location handling

Firebase configuration

notification management

Features

Each major functionality is separated into modules:

Auth – login and registration
User – customer interface
Store Owner – vendor management
Orders – order tracking
Profile – user account management

Widgets

Reusable UI components used throughout the application.

Theme

Centralized styling and UI configuration.

Database Structure

Firestore collections used by the platform:

Users
  userId
  name
  email
  role
  createdAt
Stores
  storeId
  storeName
  ownerId
  latitude
  longitude
  verified
  createdAt
Products
  productId
  storeId
  name
  description
  price
  imageUrl
  availability
Orders
  orderId
  userId
  storeId
  items
  orderType
  status
  timestamp

Order status values:

Pending
Accepted
Preparing
Ready
OutForDelivery
Delivered
Installation Guide
Prerequisites

Make sure the following tools are installed:

• Flutter SDK
• Android Studio or VS Code
• Git
• Firebase account

Check Flutter installation:

flutter doctor
Clone the Repository
git clone https://github.com/SanjanaS1709/Near_buy.git
cd Near_buy
Install Dependencies
flutter pub get
Run the Application
flutter run

The application can run on:

• Android Emulator
• Physical Android device
• Chrome (Web version)

Future Improvements

Several advanced features can be added in future versions:

• Real-time delivery tracking
• Vendor verification system
• Store ratings and reviews
• AI-based product recommendations
• Smart inventory management for vendors
• Route optimization for delivery agents
• Personalized offers and promotions
• Demand forecasting using machine learning

Potential Impact

NearBuy can help digitize local businesses and strengthen local economies by giving small vendors access to digital commerce tools.
The platform encourages consumers to support nearby businesses, reduces dependency on centralized marketplaces, and promotes community-driven commerce.

Author
Sanjana
GitHub
https://github.com/SanjanaS1709
