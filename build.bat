@echo off
echo Building VendiServer executable...
pyinstaller app.spec
echo.
if %ERRORLEVEL% NEQ 0 (
    echo Error occurred during build! Error code: %ERRORLEVEL%
) else (
    echo Build completed successfully!
)
echo.
echo Press any key to close this window...
pause > nul 