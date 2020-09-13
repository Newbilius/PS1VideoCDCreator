@echo off
pushd %~dp0

rem clearing
del MOVIE.bin
del MOVIE.cue

rem create uncompressed AVI video
ffmpeg\ffmpeg -i %1 -vcodec rawvideo -s 320x240 -filter:v "pad=iw:iw*3/4:(ow-iw)/2:(oh-ih)/2:black" -r 15 -acodec pcm_s16le -ar 37.8k -ac 1 RAW.AVI

rem create PS1-video file
move RAW.avi avi2str\
avi2str\MC32.exe avi2str\encode.scr

rem delete temporary AVI file
del avi2str\RAW.avi

rem create CD image
cd mkpsxiso-1.23
mkpsxiso.exe data.xml
cd ..

rem delete temporary STR video
del MOVIE.str

rem BEEP :)
rundll32 user32.dll,MessageBeep