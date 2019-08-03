@echo off

echo.
echo **** README ****
echo This script is part of a suite of scripts for managing the FPK files. They are designed to 
echo make modifying FPK file contents as simple as possible.
echo [Author @billw on discord / @billw2015 on the forums]
echo.
echo This script will:
echo   1. (optional) Locate the unpacked directory, or allow you to select it if it can't be found.
echo   2. Pack all files in the unpacked directory you select into FPKs in the unpacked directory.
echo   3. Move your existing SVN workspace FPKs into a temporary directory.
echo   4. Move the NEW FPKs into the SVN workspace.
echo   5. Remove the old FPKs
echo.
echo The unpacked directory will NOT be deleted after this operation, so you can continue to iterate 
echo on its contents and repack them again later.
echo.
pause

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
cd /d "%~dp0"
set "ASSETS_DIR=%~dp0..\Assets"

:: This is only used in the if block below, but needs to be here because otherwise it is a syntax error!
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please reselect the directory you unpacked FPKs into (it will be saved for future operations, delete unpack_directory.txt to reset it)',0,0).self.path""

echo 1. Locate unpacked directory ...
if not exist unpack_directory.txt (
    call :no_unpack_dir_found
)

:: Read in the saved unpack directory and check it still exists
set /p UNPACK_DIR=<unpack_directory.txt
set "FPK_IN_DIR=%UNPACK_DIR%\unpacked"
if not exist "%FPK_IN_DIR%" (
    echo *** Previous unpack directory does NOT exist! Did you unpack? ***
    echo This script will exit, run UnpackFPKs script first.
    pause
    exit /B 1
)

echo 2. Packing FPKs ...
echo From: %FPK_IN_DIR%
echo To:   %ASSETS_DIR%
echo ...
PakBuild /I="%FPK_IN_DIR%" /O="%FPK_IN_DIR%" /F /S=100 /R=C2C /X=bik

echo 3. Moving old FPKs to "%ASSETS_DIR%\oldfpks" ...
mkdir "%ASSETS_DIR%\oldfpks"
move /Y "%ASSETS_DIR%\*.fpk" "%ASSETS_DIR%\oldfpks"

echo 4. Moving new FPKs to "%ASSETS_DIR%" ...
move /Y "%FPK_IN_DIR%\*.fpk" "%ASSETS_DIR%"

echo 5. Removing old FPKs ...
rmdir /Q /S "%ASSETS_DIR%\oldfpks"

pause

exit /B 0

:no_unpack_dir_found
echo No saved unpack directory found, you have to run the UnpackFPKs script first!
echo If you already did then please press any key to continue and you will be able
echo to select it again (make sure to select the directory unpacked is in, not 
echo unpacked itself), otherwise close this window or press Ctrl+C and run the 
echo UnpackFPKs script first.
pause
:: from https://stackoverflow.com/a/15885133
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "folder=%%I"
setlocal enabledelayedexpansion
if "!folder!"=="" ( 
    echo No folder selected, unpack cancelled!
    pause
    exit /B 1 
)
:: Save the selected directory for use later!
echo !folder!>unpack_directory.txt

exit /B 0