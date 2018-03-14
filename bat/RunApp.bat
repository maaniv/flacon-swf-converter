@echo off

:: Set working dir
cd %~dp0 & cd ..

set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApp.bat

echo.
echo Starting AIR Debug Launcher...
echo.

adl "%APP_XML%" "%APP_DIR%" -- --swf "w:\swf-parser\test\test.swf" --atlas "w:\swf-parser\test\test.json" --out "w:\swf-parser\test\out" --scale 1
if errorlevel 1 goto error
goto end

:error
pause

:end
