from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime
from app.models.models import UserRole, OrderStatus

# User Schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    role: UserRole

class UserCreate(UserBase):
    password: str

class User(UserBase):
    id: int
    class Config:
        from_attributes = True

# Shop Schemas
class ShopBase(BaseModel):
    name: str
    description: Optional[str] = None
    shop_type: str
    image_url: Optional[str] = None
    rating: float = 0.0
    review_count: int = 0
    is_trusted: bool = False
    latitude: float
    longitude: float
    address: str
    opening_time: str = "09:00 AM"
    closing_time: str = "09:00 PM"

class ShopCreate(ShopBase):
    pass

class Shop(ShopBase):
    id: int
    owner_id: int
    class Config:
        from_attributes = True

# Product Schemas
class ProductBase(BaseModel):
    name: str
    description: str
    price: float
    image_url: Optional[str] = None
    category: str = "All"
    unit: str = "unit"

class ProductCreate(ProductBase):
    pass

class Product(ProductBase):
    id: int
    shop_id: int
    class Config:
        from_attributes = True

# Order Schemas
class OrderItemBase(BaseModel):
    product_id: int
    quantity: int

class OrderItem(OrderItemBase):
    id: int
    price_at_order: float
    class Config:
        from_attributes = True

class OrderBase(BaseModel):
    total_amount: float
    status: OrderStatus
    order_type: str

class OrderCreate(OrderBase):
    shop_id: int
    items: List[OrderItemBase]
    delivery_address: Optional[str] = None
    special_instructions: Optional[str] = None

class Order(OrderBase):
    id: int
    customer_id: int
    shop_id: int
    created_at: datetime
    items: List[OrderItem]
    special_instructions: Optional[str] = None
    customer: Optional[User] = None
    class Config:
        from_attributes = True

# Shopkeeper Stats Schema
class ShopStats(BaseModel):
    total_products: int
    active_orders: int
    total_earnings: float
    total_orders: int
    earning_change_pct: float
    order_change_pct: float

# Auth Schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None
