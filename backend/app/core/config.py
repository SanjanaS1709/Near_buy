from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "NearBuy API"
    API_V1_STR: str = "/api/v1"
    
    MYSQL_SERVER: str = "localhost"
    MYSQL_USER: str = "root"
    MYSQL_PASSWORD: str = ""
    MYSQL_DB: str = "nearbuy_db"
    MYSQL_PORT: int = 3306
    
    SQLALCHEMY_DATABASE_URI: str = "sqlite:///./nearbuy.db"

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=True, extra="ignore")

settings = Settings()
