@echo off
pushd %~dp0

if "%~1" == "" (
    echo Usage: %~nx0 VIDEO
    pause
    exit /b
)

rem clearing
del MOVIE.bin
del MOVIE.cue
del *.avi
del *.str

rem create uncompressed AVI video
set "COLOR_MATRIX="
rem colormatrix BT.709 > BT.601. Add "rem " to beginning of next line if you convert low-resolution video already with bt 601 color space.
set "COLOR_MATRIX=,colormatrix=bt709:bt601"

for /F "delims=" %%I in ('ffmpeg\ffprobe.exe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 %1 2^>^&1') do set /a "duration=%%I"

if %duration% GTR 595 (
	set "SEGMENT_TIME=00:08:00"
) else (
	set "SEGMENT_TIME=00:09:54"
)

ffmpeg\ffmpeg -i %1 -y -vf "scale=320:240:force_original_aspect_ratio=decrease,pad=320:240:(ow-iw)/2:(oh-ih)/2:black%COLOR_MATRIX%" -r 15 -vcodec rawvideo -acodec pcm_s16le -ar 37.8k -ac 1 -segment_time %SEGMENT_TIME% -f segment -reset_timestamps 1 -segment_start_number 1 %%d.avi

if exist "2.avi" (
    echo ### Long video
	rem prepare empty PS1-video stubs
    echo. 2>3.str
    echo. 2>4.str
    set "mkpsxiso_xml=data_psplayer.xml"
) else (
    echo ### Short video
    set "mkpsxiso_xml=data_player.xml"
)

echo. 2>"encode.scr"
for %%i in (*.avi) do (
    (
        echo Avi2strMdecAv(
        echo   %%~ni.avi, # Input file name
        echo   %%~ni.str, # Output file name
        echo   x2,        # CD-ROM speed
        echo   15fps,     # Frame rate
        echo   1,         # Number of channels
        echo   2,         # MDEC version
        echo   FALSE,     # LeapSector
        echo   37.8KHz,   # Frequency of audio
        echo   Mono       # Stereo or Mono
        echo ^);
    ) >> "encode.scr"
)

rem create PS1-video files
echo ### Wait (Movie Converter)
avi2str\MC32.exe -s encode.scr

rem delete temporary AVI files
del *.avi

rem create CD image
cd mkpsxiso-1.23
mkpsxiso.exe %mkpsxiso_xml%
cd ..

rem delete temporary STR videos
del *.str

rem delete temporary script for Movie Converter
del encode.scr

rem BEEP :)
rundll32 user32.dll,MessageBeep