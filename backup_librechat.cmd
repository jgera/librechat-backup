@echo off
mkdir backup
set LIBRECHAT_LOCATION=..
set MONGO_CONTAINER_NAME=chat-mongodb
set VECTORDB_VOLUME_NAME=vectordb
set BACKUP_DIR=backup
set TIMESTAMP=%date:~10,4%-%date:~4,2%-%date:~7,2%_%time:~0,2%
set MONGO_BACKUP=%BACKUP_DIR%\mongo_backup_%TIMESTAMP%.gz
set VECTORDB_BACKUP=%BACKUP_DIR%\vectordb_backup_%TIMESTAMP%.tar.gz

REM Step 1: Backup .env file

copy %LIBRECHAT_LOCATION%\.env %BACKUP_DIR%\

REM Step 2: Backup MongoDB
echo Backing up MongoDB from container: %MONGO_CONTAINER_NAME%...
docker exec %MONGO_CONTAINER_NAME% bash -c "mkdir -p /data/backup && mongodump --archive=/data/backup/mongo_backup.gz --gzip"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] MongoDB backup failed.
    exit /b 1
)
docker cp %MONGO_CONTAINER_NAME%:/data/backup/mongo_backup.gz %MONGO_BACKUP%
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy MongoDB backup to host.
    exit /b 1
)
echo MongoDB backup completed successfully.

REM Step 3: Backup VectorDB
echo Backing up VectorDB volume: %VECTORDB_VOLUME_NAME%...
docker run --rm -v %VECTORDB_VOLUME_NAME%:/data -v %BACKUP_DIR%:/backup busybox tar -czf /backup/vectordb_backup_%TIMESTAMP%.tar.gz /data
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to back up VectorDB.
    exit /b 1
)
echo VectorDB backup completed successfully.

REM Step 4: Delete old backups (older than 7 days)
echo Deleting backups older than 7 days in %BACKUP_DIR%...
forfiles /P %BACKUP_DIR% /S /D -7 /C "cmd /c del @path"
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Failed to delete old backups. Continuing...
) else (
    echo Old backups deleted successfully.
)

REM Step 5: Completion message
echo Backup completed successfully. Files saved to %BACKUP_DIR%.
exit /b 0
