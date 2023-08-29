import os
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends
from model.user import User, UserData, UserBase
from pydantic import ValidationError
from fastapi.encoders import jsonable_encoder

from devtools import debug
from database.db import init_db, get_session
from sqlmodel import select
from sqlmodel.ext.asyncio.session import AsyncSession
from sqlalchemy.exc import NoResultFound
router = APIRouter()


# @router.on_event("startup")
# async def on_startup():
#     await init_db()

@router.get("/")
def root():
    return {"message": "Hello World"}


@router.get("/hello/{username}")
async def get_user(username: str, session: AsyncSession = Depends(get_session)):
    try:
        user_base = UserBase(username=username)
        statement = select(User).where(User.username == user_base.username)
        result = await session.exec(statement)
        user = result.one()
        today = datetime.now().date()
        next_birthday = datetime(today.year, user.dateOfBirth.month, user.dateOfBirth.day).date()
        if today > next_birthday:
            next_birthday = datetime(today.year + 1, user.dateOfBirth.month, user.dateOfBirth.day).date()

        days_to_birthday = (next_birthday - today).days

        if days_to_birthday == 0:
            return {"message": f"Hello, {username}! Happy birthday!"}
        else:
            return {"message": f"Hello, {username}! Your birthday is in {days_to_birthday} day(s)"}

    except ValidationError as err:
        raise HTTPException(status_code=422, detail=jsonable_encoder(err.errors()))
    except NoResultFound as err:
        raise HTTPException(status_code=404, detail=f"Username - {username} not found")


@router.put("/hello/{username}", status_code=204)
async def create_user(username: str, data: UserData, session: AsyncSession = Depends(get_session)):
    try:
        user_base = UserBase(username=username)
        statement = select(User).where(User.username == user_base.username)
        result = await session.exec(statement)
        user = result.one_or_none()

        if not user:
            user = User(username=user_base.username, dateOfBirth=data.dateOfBirth)
        else:
            user.dateOfBirth = data.dateOfBirth

        session.add(user)
        await session.commit()
        await session.refresh(user)

    except ValidationError as err:
        raise HTTPException(status_code=422, detail=jsonable_encoder(err.errors()))
