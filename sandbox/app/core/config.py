from typing import List, Optional, Union
from pydantic import field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    ORIGINS: List[str] = ["*"]
    
    # Service timeout settings (minutes)
    SERVICE_TIMEOUT_MINUTES: Optional[int] = None
    
    # Log configuration
    LOG_LEVEL: str = "INFO"
    
    @field_validator("ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    class Config:
        case_sensitive = True
        env_file = ".env"


settings = Settings() 