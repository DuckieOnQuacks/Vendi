@echo off
echo Building VendiServer executable...
echo Build started at %DATE% %TIME% > build_log.txt
echo ---------------------------------------- >> build_log.txt
pyinstaller app.spec >> build_log.txt 2>&1
echo ---------------------------------------- >> build_log.txt
if %ERRORLEVEL% NEQ 0 (
    echo Error occurred during build! Error code: %ERRORLEVEL%
    echo Build failed with error code: %ERRORLEVEL% >> build_log.txt
    echo Check build_log.txt for details.
) else (
    echo Build completed successfully!
    echo Build completed successfully! >> build_log.txt
)
echo.
echo Press any key to close this window...
pause > nul 