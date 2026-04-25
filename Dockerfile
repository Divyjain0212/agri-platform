# -------- BUILDER --------
FROM python:3.12-slim as builder

WORKDIR /build

RUN apt-get update && apt-get install -y gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# -------- RUNTIME --------
FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y postgresql-client \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 appuser

COPY --from=builder /root/.local /home/appuser/.local

COPY --chown=appuser:appuser . .

RUN mkdir -p /app/staticfiles /app/media && \
    chown -R appuser:appuser /app && \
    chmod +x /app/entrypoint.sh

ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER appuser

EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]