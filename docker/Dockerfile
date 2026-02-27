FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir instaloader pillow imagehash

COPY scripts/hamster_daily_update.py /app/hamster_daily_update.py
COPY docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV PYTHONUNBUFFERED=1
ENTRYPOINT ["/app/entrypoint.sh"]
