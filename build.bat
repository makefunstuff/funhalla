@echo off
setlocal

:: Define the compiler and flags
set ODIN=odin
set SRC_DIR=src
set OUT_DIR_DEBUG=out\debug
set OUT_DIR_RELEASE=out\release
set PROGRAM_NAME=funhalla.exe

:: Define the build targets
call :build_debug
call :build_release
goto :eof

:build_debug
echo Building debug version...
if not exist "%OUT_DIR_DEBUG%" mkdir "%OUT_DIR_DEBUG%"
%ODIN% build %SRC_DIR% -out:%OUT_DIR_DEBUG%\%PROGRAM_NAME% --debug -define:GL_DEBUG=true
goto :eof

:build_release
echo Building release version...
if not exist "%OUT_DIR_RELEASE%" mkdir "%OUT_DIR_RELEASE%"
%ODIN% build %SRC_DIR% -out:%OUT_DIR_RELEASE%\%PROGRAM_NAME%
goto :eof

:: Clean up build artifacts
clean:
echo Cleaning up build artifacts...
rd /s /q "%OUT_DIR_DEBUG%"
rd /s /q "%OUT_DIR_RELEASE%"

:: Command to execute clean (optional, uncomment if needed)
:: call :clean

endlocal
