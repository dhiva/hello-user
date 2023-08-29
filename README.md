
```shell
docker-compose up --build 
```

```shell
docker-compose exec fastapi-app alembic upgrade head 
```

```shell
docker-compose exec fastapi-app pytest -s -v
```

```shell
docker-compose exec fastapi-app alembic revision --autogenerate -m "init" 
```