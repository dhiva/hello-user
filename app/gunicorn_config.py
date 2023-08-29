import multiprocessing

# Server Socket
bind = "0.0.0.0:8000"
backlog = 2048

# Worker Processes
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "uvicorn.workers.UvicornWorker"
worker_connections = 200
timeout = 30
keepalive = 2
threads = 8
max_requests = 2000
max_requests_jitter = 400

# Security
limit_request_line = 4094
limit_request_fields = 100
limit_request_field_size = 8190