@echo off
REM Define variables
set MONGO_CONTAINER_NAME=mongo_container
set VECTORDB_VOLUME_NAME=vectordb_volume
set BACKUP_DIR=C:\path\to\backup
set MONGO_BACKUP_FILE=mongo_backup.gz
set VECTORDB_BACKUP_FILE=vectordb_backup.tar.gz

REM Step 1: Restore MongoDB
echo Restoring MongoDB backup from %BACKUP_DIR%\%MONGO_BACKUP_FILE%...
if not exist "%BACKUP_DIR%\%MONGO_BACKUP_FILE%" (
    echo [ERROR] MongoDB backup file not found: %BACKUP_DIR%\%MONGO_BACKUP_FILE%.
    exit /b 1
)
docker cp %BACKUP_DIR%\%MONGO_BACKUP_FILE% %MONGO_CONTAINER_NAME%:/data/backup/mongo_backup.gz
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to copy MongoDB backup to container.
    exit /b 1
)
docker exec %MONGO_CONTAINER_NAME% bash -c "mongorestore --archive=/data/backup/mongo_backup.gz --gzip --drop"
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] MongoDB restore failed.
    exit /b 1
)
echo MongoDB restore completed successfully.

REM Step 2: Restore VectorDB
echo Restoring VectorDB backup from %BACKUP_DIR%\%VECTORDB_BACKUP_FILE%...
if not exist "%BACKUP_DIR%\%VECTORDB_BACKUP_FILE%" (
    echo [ERROR] VectorDB backup file not found: %BACKUP_DIR%\%VECTORDB_BACKUP_FILE%.
    exit /b 1
)
docker run --rm -v %VECTORDB_VOLUME_NAME%:/data -v %BACKUP_DIR%:/backup busybox tar -xzf /backup/%VECTORDB_BACKUP_FILE% -C /
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] VectorDB restore failed.
    exit /b 1
)
echo VectorDB restore completed successfully.

REM Step 3: Completion message
echo Restore completed successfully. MongoDB and VectorDB have been restored.
exit /b 0
