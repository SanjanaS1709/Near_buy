from app.db.session import engine, Base
from app.models.models import User, Shop, Product, Order, OrderItem, Rating

def init_db():
    print("Creating tables in MySQL...")
    Base.metadata.create_all(bind=engine)
    print("Tables created successfully!")

if __name__ == "__main__":
    init_db()
