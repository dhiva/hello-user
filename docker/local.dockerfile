FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9

# Copy local code to the container image
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY ../app .

# Install dependencies
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# Use 8000 as a default port
EXPOSE 8000

# The command to run the application
CMD ["uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--reload"]