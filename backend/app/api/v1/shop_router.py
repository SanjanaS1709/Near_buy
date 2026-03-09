from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.models.models import Shop, Product, User, Order, OrderStatus
from app.schemas.schemas import ShopCreate, Shop as ShopSchema, ProductCreate, Product as ProductSchema, ShopStats, Order as OrderSchema

router = APIRouter()

@router.post("/shops", response_model=ShopSchema)
def create_shop(shop_in: ShopCreate, owner_id: int, db: Session = Depends(get_db)):
    owner = db.query(User).filter(User.id == owner_id).first()
    if not owner or owner.role.value != "shop_owner":
        raise HTTPException(status_code=400, detail="Invalid owner ID or user is not a shop owner")
    
    new_shop = Shop(**shop_in.dict(), owner_id=owner_id)
    db.add(new_shop)
    db.commit()
    db.refresh(new_shop)
    return new_shop

@router.post("/products", response_model=ProductSchema)
def create_product(product_in: ProductCreate, shop_id: int, db: Session = Depends(get_db)):
    shop = db.query(Shop).filter(Shop.id == shop_id).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found")
    
    new_product = Product(**product_in.dict(), shop_id=shop_id)
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return new_product

@router.get("/my-shop/{owner_id}", response_model=ShopSchema)
def get_my_shop(owner_id: int, db: Session = Depends(get_db)):
    shop = db.query(Shop).filter(Shop.owner_id == owner_id).first()
    if not shop:
        raise HTTPException(status_code=404, detail="Shop not found for this owner")
    return shop

@router.get("/shop/{shop_id}/products", response_model=List[ProductSchema])
def get_shop_products(shop_id: int, db: Session = Depends(get_db)):
    products = db.query(Product).filter(Product.shop_id == shop_id).all()
    return products

@router.get("/shop/{shop_id}/orders", response_model=List[OrderSchema])
def get_shop_orders(shop_id: int, status: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Order).filter(Order.shop_id == shop_id)
    if status:
        query = query.filter(Order.status == status)
    return query.all()

@router.patch("/orders/{order_id}/status")
def update_order_status(order_id: int, status: OrderStatus, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    order.status = status
    db.commit()
    return {"message": "Order status updated", "new_status": status.value}

@router.get("/shop/{shop_id}/stats", response_model=ShopStats)
def get_shop_stats(shop_id: int, db: Session = Depends(get_db)):
    total_products = db.query(Product).filter(Product.shop_id == shop_id).count()
    active_orders = db.query(Order).filter(
        Order.shop_id == shop_id,
        Order.status.in_([OrderStatus.PENDING, OrderStatus.PREPARING, OrderStatus.READY])
    ).count()
    
    all_completed_orders = db.query(Order).filter(
        Order.shop_id == shop_id,
        Order.status == OrderStatus.COMPLETED
    ).all()
    
    total_earnings = sum(order.total_amount for order in all_completed_orders)
    total_orders_count = db.query(Order).filter(Order.shop_id == shop_id).count()
    
    # Placeholders for change percentage logic
    return {
        "total_products": total_products,
        "active_orders": active_orders,
        "total_earnings": total_earnings,
        "total_orders": total_orders_count,
        "earning_change_pct": 12.0, # Placeholder
        "order_change_pct": 5.0 # Placeholder
    }
