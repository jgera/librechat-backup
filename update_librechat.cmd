rem Stop the running container(s)
docker compose down

rem Pull latest project changes
git pull

rem Pull the latest LibreChat image (default setup)
docker compose pull

rem If building the LibreChat image Locally, build without cache (legacy setup)
rem docker compose build --no-cache

rem Start LibreChat
docker compose up