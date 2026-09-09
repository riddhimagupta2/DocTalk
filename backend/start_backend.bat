@echo off
echo ========================================================
echo   DocTalk Central Backend - Development Server
echo ========================================================
echo.
echo Server starting at http://0.0.0.0:8000
echo.
echo For physical phone testing over USB:
echo   Run: adb reverse tcp:8000 tcp:8000
echo.
python manage.py runserver 0.0.0.0:8000 --settings=core.settings.development
pause
