::该文件与QSanguosha-v2-20150504\mklink.bat为硬链接
::只需运行一次，可提供开发环境支持
::同步Yun\image、Yun\extensions到QSanguosha-v2-20150504中的对应目录
::使用了windows系统的符号链接
@echo off
for %%a in (cd .) do (
set yun_dir=%%~dpayun\
)
set q_dir=%~dp0

::lua code
set yun_s=%yun_dir%extensions
set q_t=%q_dir%extensions
mklink /D %q_t% %yun_s%

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

pause