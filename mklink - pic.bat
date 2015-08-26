::运行本文件一次，可提供与制图环境连接。将制图环境对应目录同步到Yun\Qsanguosha-v2\image\generals\card、Yun\Qsanguosha-v2\image\generals\avatar、Yun\Qsanguosha-v2\image\fullskin\generals\full
@echo off
for %%a in (cd .) do (
set pic_dir="%%~dpa制图中心\"
)
set yun_dir=%~dp0

::Qsanguosha-v2\image\generals\card
set pic_s=%pic_dir%card
set yun_d=%yun_dir%Qsanguosha-v2\image\generals\card
mklink /H /J %yun_d% %pic_s%

::Qsanguosha-v2\image\generals\avatar
set pic_s=%pic_dir%avatar
set yun_d=%yun_dir%Qsanguosha-v2\image\generals\avatar
mklink /H /J %yun_d% %pic_s%

::Qsanguosha-v2\image\fullskin\generals\full
set pic_s=%pic_dir%full
set yun_d=%yun_dir%Qsanguosha-v2\image\fullskin\generals\full
mklink /H /J %yun_d% %pic_s%