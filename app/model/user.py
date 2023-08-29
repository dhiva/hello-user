from datetime import date, datetime
from sqlmodel import SQLModel, Field
from typing import Optional
from pydantic import validator


class Base(SQLModel):
    pass


class UserBase(Base):
    username: str = Field(unique=True, default=None )

    @validator('username')
    def validate_username(cls, v):
        if not v.isalpha():
            raise ValueError("username must contain only letters")
        return v


class UserData(Base):
    dateOfBirth: date

    @validator('dateOfBirth')
    def validate_dob(cls, v):
        today = datetime.now().date()
        if v >= today:
            raise ValueError("Date of Birth must be before today date")
        return v


class User(UserBase, UserData, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
