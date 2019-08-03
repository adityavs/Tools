@echo off

echo.
echo **** README ****
echo This script is part of a suite of scripts for managing the FPK files. They are designed to 
echo make modifying FPK file contents as simple as possible.
echo [Author @billw on discord / @billw2015 on the forums]
echo.
echo This script will:
echo   1. (optional) Give you a directory browser to select a directory to unpack the FPKs into.
echo   2. Unpack all FPKs into a directory called unpacked under the directory you selected.
echo.
echo After it is complete you can perform alterations to the files in the unpacked directory, 
echo then when you are happy with them run PackFPKs.bat to repack that directory into FPK files
echo in your SVN workspace.
echo.
echo IMPORTANT:
echo     Choose somewhere OUTSIDE of the Mod folder, or you WILL experience performance problems 
echo     starting the Mod as it traverses all the loose files.
echo NOTE:
echo     If you previously used this script then it should have saved the directory from last time.
echo     If you want to reset the saved directory then delete Tools\unpack_directory.txt
echo.
pause

setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
PUSHD "%~dp0"
set "ASSETS_DIR=%~dp0..\Assets"

:: This is only used in the if block below, but needs to be here because otherwise it is a syntax error!
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'Please select a directory to unpack FPKs into **OUTSIDE** of the SVN repository (it will be saved for future operations, delete unpack_directory.txt to reset it)',0,0).self.path""

echo 1. Locate unpacked directory ...
:: Unpack dir not set, ask the user for it
if not exist unpack_directory.txt (
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
)


:: Read in the saved unpack directory and check it still exists
set /p UNPACK_DIR=<unpack_directory.txt
if exist "%UNPACK_DIR%\unpacked" (
    call :dir_exists_warning
)

echo 2. Unpacking FPKs ...
echo From: %ASSETS_DIR%
echo To:   %UNPACK_DIR%\unpacked
echo ...
PakBuild /I="%ASSETS_DIR%" /O="%UNPACK_DIR%\unpacked" /U

endlocal

POPD

exit /B %errorlevel%

:dir_exists_warning

echo.
echo *************************************************************************
echo *** Previous unpack directory already exists! Did you already unpack? ***
echo *************************************************************************
echo.
echo Previous directory: %UNPACK_DIR%\unpacked
echo.
echo If you want to continue with unpack anyway, DELETING what is already 
echo there then press any key.
echo.
echo Otherwise close this window or press Ctrl+C to abort.
pause

echo Deleting old unpack directory %UNPACK_DIR%\unpacked
rmdir /Q /S "%UNPACK_DIR%\unpacked"

exit /B 0