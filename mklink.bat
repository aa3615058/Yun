::该文件与QSanguosha-v2-20150504\mklink.bat为硬链接
::运行QSanguosha-v2-20150504\mklink.bat一次，可提供开发环境支持。同步Yun\image、Yun\extensions、Yun\lua\ai、Yun\audio到QSanguosha-v2-20150504中的对应目录
::如果Yun\中有新文件被添加，请再次运行QSanguosha-v2-20150504\mklink.bat
::使用了windows系统的符号链接
@echo off
for %%a in (cd .) do (
set yun_dir=%%~dpayun\
)
set q_dir=%~dp0

::extensions
set yun_s=%yun_dir%extensions
set q_t=%q_dir%extensions
mklink /D %q_t% %yun_s%

::lua\ai
set yun_s=%yun_dir%lua\ai\
set q_t=%q_dir%lua\ai\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

::image\generals\card
set yun_s=%yun_dir%image\generals\card\
set q_t=%q_dir%image\generals\card\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

::image\generals\avatar
set yun_s=%yun_dir%image\generals\avatar\
set q_t=%q_dir%image\generals\avatar\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

::image\fullskin\generals\full
set yun_s=%yun_dir%image\fullskin\generals\full\
set q_t=%q_dir%image\fullskin\generals\full\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

::audio\skill
set yun_s=%yun_dir%audio\skill\
set q_t=%q_dir%audio\skill\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

::audio\death
set yun_s=%yun_dir%audio\death\
set q_t=%q_dir%audio\death\
for /f %%i in ('dir /b %yun_s%') do (
mklink %q_t%%%i %yun_s%%%i
)

pause