from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.models.models import Shop, Product, Order, OrderItem, Rating, User
from app.schemas.schemas import Shop as ShopSchema, OrderCreate, Order as OrderSchema, Product as ProductSchema

router = APIRouter()

@router.get("/shops", response_model=List[ShopSchema])
def get_nearby_shops(shop_type: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(Shop)
    if shop_type:
        query = query.filter(Shop.shop_type == shop_type)
    return query.all()

@router.post("/orders", response_model=OrderSchema)
def place_order(order_in: OrderCreate, customer_id: int, db: Session = Depends(get_db)):
    # Calculate total amount and verify items
    calculated_total = 0.0
    order_items_to_create = []
    
    for item_in in order_in.items:
        product = db.query(Product).filter(Product.id == item_in.product_id).first()
        if not product:
            raise HTTPException(status_code=404, detail=f"Product with id {item_in.product_id} not found")
        
        item_total = product.price * item_in.quantity
        calculated_total += item_total
        
        order_items_to_create.append(OrderItem(
            product_id=item_in.product_id,
            quantity=item_in.quantity,
            price_at_order=product.price
        ))

    new_order = Order(
        customer_id=customer_id,
        shop_id=order_in.shop_id,
        total_amount=calculated_total,
        status=OrderStatus.PENDING,
        order_type=order_in.order_type,
        delivery_address=order_in.delivery_address
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)

    for item in order_items_to_create:
        item.order_id = new_order.id
        db.add(item)
    
    db.commit()
    db.refresh(new_order)
    return new_order

@router.post("/ratings")
def rate_shop(order_id: int, stars: int, comment: str, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    new_rating = Rating(
        order_id=order_id,
        shop_id=order.shop_id,
        customer_id=order.customer_id,
        stars=stars,
        comment=comment
    )
    db.add(new_rating)
    db.commit()
    return {"message": "Rating submitted successfully"}
