from fastapi import APIRouter
from app.api.v1 import auth_router, shop_router, customer_router

api_router = APIRouter()
api_router.include_router(auth_router.router, prefix="/auth", tags=["auth"])
api_router.include_router(shop_router.router, prefix="/shops", tags=["shops"])
api_router.include_router(customer_router.router, prefix="/customer", tags=["customer"])
