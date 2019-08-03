@echo off

echo.
echo **** README ****
echo This script is part of a suite of scripts for managing the FPK files. They are designed to 
echo make modifying FPK file contents as simple as possible.
echo [Author @billw on discord / @billw2015 on the forums]
echo.
echo WARNING: This script is a DESTRUCTIVE operation!
echo   You should run this script ONLY when you have no local art changes. If you do have art 
echo   changes then please commit them first in the art folder, and THEN run this script.
echo.
echo This script will:
echo   1. Unpack all FPKs into a temporary directory
echo   2. Copy all files from art into that directory over the top of the FPK files
echo   3. Repack the new set of files back to FPKs (excluding bik files)
echo   4. Delete the temp directory.
echo.
echo After it is complete you can then delete any files in the art directory (other than the biks)
echo.
pause

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
cd /d "%~dp0"
set "ASSETS_DIR=%~dp0..\Assets"
set "FPK_IN_DIR=%ASSETS_DIR%\temp"

if exist "%FPK_IN_DIR%" (
    echo Temp unpack directory already exists, were you part way through repacking?
    echo Clean everything up and try again, perhaps with SVN clean repo!
    exit /B 1
)

mkdir "%FPK_IN_DIR%"
echo 1. Unpacking existing FPKs into a temporary directory ...
PakBuild /I="%ASSETS_DIR%" /O="%FPK_IN_DIR%" /F /U

echo 2. Overlaying new art files ...
xcopy /Y/S/R "%ASSETS_DIR%\art" "%FPK_IN_DIR%"

echo 3. Repacking FPKs ...
PakBuild /I="%FPK_IN_DIR%" /O="%ASSETS_DIR%" /F /S=50 /R=C2C /X=bik

echo 4. Deleting temporary directory ...
rmdir /Q/S "%FPK_IN_DIR%"

echo You can cleanup the art directory now, everything except those .bik files should be in the FPKs!
pause
