FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create user with fixed UID
RUN useradd -u 1001 -m appuser

# Switch to numeric user
USER 1001

CMD ["python", "app.py"]
