@echo off
setlocal enabledelayedexpansion

REM Clear the screen before displaying progress
cls

REM Change the directories here
set "INPUT_DIR=F:\Mod Files\Cataclysm - The Last Generation\1 - Soundpacks\1 - CC Sounds - Original\CC-Sounds"
set "OUTPUT_DIR=F:\Mod Files\Cataclysm - The Last Generation\1 - Soundpacks\2 - CC Sounds - Compressed\CC-Sounds"
set "FFMPEG=C:\Scripts\Bat\0 - Modules\2 - ffmpeg\ffmpeg-2025-07-23-git-829680f96a-full_build\bin\ffmpeg.exe"
echo Preparing to run audio compression routine. Exit this window to cancel this operation.
echo Otherwise, press any key to continue...
call :InputAny
cd /d "%INPUT_DIR%"


REM Count total .wav, .ogg, and .mp3 files to process
set /a total=0
for /R %%F in (*.wav *.ogg *.mp3) do (
    set /a total+=1
)

set /a current=0
for /R %%F in (*.wav *.ogg *.mp3) do (
    set "REL_PATH=%%~dpF"
    set "REL_PATH=!REL_PATH:%INPUT_DIR%=!"

    mkdir "%OUTPUT_DIR%!REL_PATH!" 2>nul

    REM Construct the output file path with the same extension
    set "OUTPUT_FILE=%OUTPUT_DIR%!REL_PATH!%%~nxF"

    set "EXT=%%~xF"
    set "EXT=!EXT:~1!"  REM Remove the dot from the extension

    if /I "!EXT!"=="wav" (
        "%FFMPEG%" -i "%%F" -af "acrusher=level_in=1:level_out=1:bits=4:mode=log:aa=1,lowpass=f=8000" -ar 11025 -sample_fmt s16 "!OUTPUT_FILE!"
    ) else if /I "!EXT!"=="ogg" (
        "%FFMPEG%" -i "%%F" -af "acrusher=level_in=1:level_out=1:bits=4:mode=log:aa=1,lowpass=f=8000" -ar 11025 -c:a libvorbis "!OUTPUT_FILE!"
    ) else if /I "!EXT!"=="mp3" (
        "%FFMPEG%" -i "%%F" -af "acrusher=level_in=1:level_out=1:bits=4:mode=log:aa=1,lowpass=f=8000" -ar 11025 -c:a libmp3lame "!OUTPUT_FILE!"
    ) else (
		echo File Unsupported!
		call :InputAny
	)

    set /a current+=1
    set /a percent=!current!*100/%total%

    cls
    echo Processing: !current! of %total% files
    echo.

    set "bar="
    for /L %%i in (1,1,!percent!) do set "bar=!bar!#"
    echo !bar! !percent!%% completed
)

echo.
echo All files have been processed.
pause
exit


:InputAny
	pause >nul
	exit /B