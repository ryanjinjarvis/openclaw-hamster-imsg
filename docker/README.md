# Hamster Pipeline Docker

## Run once
```bash
cd apps/openclaw-hamster-imsg/docker
docker compose run --rm -e RUN_MODE=once hamster-pipeline
```

## Run daily loop (every 24h)
```bash
cd apps/openclaw-hamster-imsg/docker
docker compose up -d
```

## Logs
```bash
docker logs -f hamster-pipeline
```

## Stop
```bash
cd apps/openclaw-hamster-imsg/docker
docker compose down
```

Notes:
- Data persists in your mounted workspace (`artifacts/hamster/...`).
- iMessage/TestFlight build still must be done natively in Xcode on macOS.
