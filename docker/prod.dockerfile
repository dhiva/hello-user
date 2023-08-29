# pull official base image
FROM python:3.9-slim-bookworm

ENV BUILD_VERSION $BUILD_VERSION
ENV BUILD_DATE $BUILD_DATE
# Copy local code to the container image
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY ../app .

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install system dependencies
RUN apt-get update \
  && apt-get -y install gcc \
  && apt-get clean

# Install dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
