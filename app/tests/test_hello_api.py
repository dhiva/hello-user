import pytest
from httpx import AsyncClient
from unittest.mock import AsyncMock, Mock
from datetime import datetime
from dateutil.relativedelta import relativedelta
from model import User
from main import api
from database.db import get_session
from sqlalchemy.exc import NoResultFound


@pytest.mark.asyncio
async def test_get_user_success_with_wishes():
    birthday = datetime.now() - relativedelta(years=1)
    mock_session = AsyncMock()
    mock_result = Mock()
    mock_result.one.return_value = User(username="john", dateOfBirth=birthday)
    mock_session.exec.return_value = mock_result

    api.dependency_overrides[get_session] = lambda: mock_session
    async with AsyncClient(app=api, base_url="http://test") as ac:
        response = await ac.get("/hello/john")
        assert response.status_code == 200
        assert response.json() == {'message': 'Hello, john! Happy birthday!'}
    del api.dependency_overrides[get_session]


@pytest.mark.asyncio
async def test_get_user_success_with_birthday_reminder():
    birthday = datetime.now() - relativedelta(days=30)
    mock_session = AsyncMock()
    mock_result = Mock()
    mock_result.one.return_value = User(username="john", dateOfBirth=birthday)
    mock_session.exec.return_value = mock_result

    api.dependency_overrides[get_session] = lambda: mock_session
    async with AsyncClient(app=api, base_url="http://test") as ac:
        response = await ac.get("/hello/john")
        assert response.status_code == 200
        assert response.json() == {'message': 'Hello, john! Your birthday is in 336 day(s)'}
    del api.dependency_overrides[get_session]


@pytest.mark.asyncio
async def test_get_user_not_found():
    mock_session = AsyncMock()
    mock_result = Mock()
    mock_result.one.side_effect = NoResultFound
    mock_session.exec.return_value = mock_result

    api.dependency_overrides[get_session] = lambda: mock_session
    async with AsyncClient(app=api, base_url="http://test") as ac:
        response = await ac.get("/hello/john")
        assert response.status_code == 404
        assert response.json() == {'detail': 'Username - john not found'}
    del api.dependency_overrides[get_session]

@pytest.mark.asyncio
async def test_get_user_invalid():
    async with AsyncClient(app=api, base_url="http://test") as ac:
        response = await ac.get("/hello/john123")
        assert response.status_code == 422
        assert response.json() == {'detail': [{'loc': ['username'], 'msg': 'username must contain only letters', 'type': 'value_error'}]}


@pytest.mark.asyncio
async def test_create_user_success():
    mock_session = AsyncMock()
    mock_session.add = Mock()
    mock_result = Mock()
    mock_result.one_or_none.return_value = None
    mock_session.exec.return_value = mock_result

    api.dependency_overrides[get_session] = lambda: mock_session
    async with AsyncClient(app=api, base_url="http://test") as ac:
        birthday = datetime.now() - relativedelta(years=1)
        response = await ac.put("/hello/john", json={"dateOfBirth": str(birthday.date())})
        assert response.status_code == 204
    del api.dependency_overrides[get_session]


@pytest.mark.asyncio
async def test_update_existing_user():
    mock_session = AsyncMock()
    mock_session.add = Mock()
    mock_result = Mock()
    birthday = datetime.now() - relativedelta(years=1)
    existing_user = User(username="john", dateOfBirth=birthday)
    mock_result.one_or_none.return_value = existing_user  # Existing user
    mock_session.exec.return_value = mock_result

    api.dependency_overrides[get_session] = lambda: mock_session
    async with AsyncClient(app=api, base_url="http://test") as ac:
        new_birthday = datetime.now() - relativedelta(years=2)
        response = await ac.put("/hello/john", json={"dateOfBirth": str(new_birthday.date())})
        assert response.status_code == 204
    del api.dependency_overrides[get_session]


@pytest.mark.asyncio
async def test_create_user_invalid_username():
    async with AsyncClient(app=api, base_url="http://test") as ac:
        birthday = datetime.now() - relativedelta(years=1)
        response = await ac.put("/hello/john123", json={"dateOfBirth": str(birthday.date())})
        assert response.status_code == 422
        assert response.json() == {'detail': [{'loc': ['username'], 'msg': 'username must contain only letters', 'type': 'value_error'}]}


@pytest.mark.asyncio
async def test_create_user_invalid_date():
    async with AsyncClient(app=api, base_url="http://test") as ac:
        response = await ac.put("/hello/john", json={"dateOfBirth": str(datetime.now().date())})
        assert response.status_code == 422
        assert response.json() == {'detail': [{'loc': ['body', 'dateOfBirth'], 'msg': 'Date of Birth must be before today date', 'type': 'value_error'}]}