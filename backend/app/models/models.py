from sqlalchemy import Column, Integer, String, Float, ForeignKey, DateTime, Enum, Table, Boolean
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.db.session import Base
import enum

class UserRole(enum.Enum):
    CUSTOMER = "customer"
    SHOP_OWNER = "shop_owner"

class OrderStatus(enum.Enum):
    PENDING = "pending"
    PREPARING = "preparing"
    READY = "ready"
    COMPLETED = "completed"
    CANCELLED = "cancelled"

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(100), index=True)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.CUSTOMER)
    
    shop = relationship("Shop", back_populates="owner", uselist=False)
    orders = relationship("Order", back_populates="customer")

class Shop(Base):
    __tablename__ = "shops"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), index=True)
    description = Column(String(500), nullable=True)
    shop_type = Column(String(50)) # e.g., Grocery, Electronics
    image_url = Column(String(500), nullable=True)
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    is_trusted = Column(Boolean, default=False)
    
    latitude = Column(Float)
    longitude = Column(Float)
    address = Column(String(255))
    opening_time = Column(String(20), default="09:00 AM")
    closing_time = Column(String(20), default="09:00 PM")
    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="shop")
    products = relationship("Product", back_populates="shop")
    orders = relationship("Order", back_populates="shop")

class Product(Base):
    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), index=True)
    description = Column(String(500))
    price = Column(Float)
    image_url = Column(String(500))
    category = Column(String(50), default="All") # Vegetables, Fruits, etc.
    unit = Column(String(20), default="unit") # kg, dozen, g
    shop_id = Column(Integer, ForeignKey("shops.id"))

    shop = relationship("Shop", back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")

class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)
    customer_id = Column(Integer, ForeignKey("users.id"))
    shop_id = Column(Integer, ForeignKey("shops.id"))
    total_amount = Column(Float)
    status = Column(Enum(OrderStatus), default=OrderStatus.PENDING)
    order_type = Column(String(20)) # "delivery" or "takeaway"
    delivery_address = Column(String(255), nullable=True)
    special_instructions = Column(String(255), nullable=True)
    tracking_lat = Column(Float, nullable=True) # For tracking delivery partner
    tracking_lng = Column(Float, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    customer = relationship("User", back_populates="orders")
    shop = relationship("Shop", back_populates="orders")
    items = relationship("OrderItem", back_populates="order")
    rating = relationship("Rating", back_populates="order", uselist=False)

class Rating(Base):
    __tablename__ = "ratings"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"), unique=True)
    shop_id = Column(Integer, ForeignKey("shops.id"))
    customer_id = Column(Integer, ForeignKey("users.id"))
    stars = Column(Integer) # 1-5
    comment = Column(String(255), nullable=True)

    order = relationship("Order", back_populates="rating")

class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    product_id = Column(Integer, ForeignKey("products.id"))
    quantity = Column(Integer)
    price_at_order = Column(Float)

    order = relationship("Order", back_populates="items")
    product = relationship("Product", back_populates="order_items")
