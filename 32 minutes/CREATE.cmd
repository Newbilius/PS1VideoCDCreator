@echo off
pushd %~dp0

rem clearing
del MOVIE.bin
del MOVIE.cue

rem split video to uncompressed AVI files
ffmpeg\ffmpeg -ss 00:00:00.00 -i %1 -t 00:08:00.00 -vcodec rawvideo -s 320x240 -filter:v "pad=iw:iw*3/4:(ow-iw)/2:(oh-ih)/2:black" -r 15 -acodec pcm_s16le -ar 37.8k -ac 1 1.AVI

ffmpeg\ffmpeg -ss 00:08:00.01 -i %1  -t 00:08:00.00 -vcodec rawvideo -s 320x240 -filter:v "pad=iw:iw*3/4:(ow-iw)/2:(oh-ih)/2:black" -r 15 -acodec pcm_s16le -ar 37.8k -ac 1 2.AVI

ffmpeg\ffmpeg -ss 00:16:00.01 -i %1 -t 00:08:00.00 -vcodec rawvideo -s 320x240 -filter:v "pad=iw:iw*3/4:(ow-iw)/2:(oh-ih)/2:black" -r 15 -acodec pcm_s16le -ar 37.8k -ac 1 3.AVI

ffmpeg\ffmpeg -ss 00:24:00.01 -i %1 -t 00:08:00.00 -vcodec rawvideo -s 320x240 -filter:v "pad=iw:iw*3/4:(ow-iw)/2:(oh-ih)/2:black" -r 15 -acodec pcm_s16le -ar 37.8k -ac 1 4.AVI

rem prepare empty PS1-video stubs
copy mkpsxiso-1.23\PSPLAYER\VIDEO\*.str . /Y

rem delete empty AVI files (<1000 kb)
for /f "tokens=*" %%a in ('dir /b *.avi') do (
	If %%~za LSS 1024000 del "%%~fa"
)

rem create PS1-video files
move *.avi avi2str\
avi2str\MC32.exe avi2str\encode.scr

rem delete temporary AVI files
del avi2str\*.avi

rem create CD image
cd mkpsxiso-1.23
mkpsxiso.exe data.xml
cd ..

rem delete temporary STR videos
del *.str

rem BEEP :)
rundll32 user32.dll,MessageBeep