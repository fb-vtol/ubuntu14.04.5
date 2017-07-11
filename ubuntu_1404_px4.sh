#!/bin/bash
# Info   : install tools on ubuntu 64bit 14.04.5 for px4
# Author : wangbo                            
# CTime  : 2017.07.11 

#---------使用命令:sudo chmod a+x ubuntu_1404_px4.sh-----------------
#---------执行安装脚本程序命令为: sh ubuntu_1404_px4.sh 或者 ./ubuntu_1404_px4.sh ---------------------
#-------------------------------------------

#ubuntu由于使用了/bin/sh 导致找不到pushd命令
#切换回/bin/bash即可，但是我在shell中声明#!/bin/bash还是继续报错
sudo cp /bin/sh /bin/sh_backup
sudo rm -f /bin/sh
sudo ln -s /bin/bash /bin/sh

#设置github用户名，这个每个人需要修改
GIT_NAME=fb_vtol
GIT_EMAIL=fb_vtol@163.com

echo -e "Install ubuntu_1404_px4.sh Start\n\n"
echo "*************************************"
#设置用户名
USER_NAME=$USER

#更改镜像源
SOURCE_ADDRESS=http://mirror.bit.edu.cn
UBUNTU_VERSION=trusty
SOURCES_LIST=/etc/apt/sources.list

#备份旧的镜像源
sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup_$(date +%s)

sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-security main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-updates restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-proposed restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-backports restricted universe multiverse" >> $SOURCES_LIST

SOURCE_ADDRESS=http://mirrors.aliyun.com
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-security main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-updates restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-proposed restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-backports restricted universe multiverse" >> $SOURCES_LIST

SOURCE_ADDRESS=http://mirrors.163.com
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-security main restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-updates restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-proposed restricted universe multiverse" >> $SOURCES_LIST
sudo echo "deb $SOURCE_ADDRESS/ubuntu/ $UBUNTU_VERSION-backports restricted universe multiverse" >> $SOURCES_LIST

#更新镜像源
sudo apt-get update

#安装vim代替vi
echo -e "Start install vim\n\n"
sudo apt-get install vim -y

#安装编译工具 gcc g++ make等等
echo -e "Start install gcc g++\n\n"
sudo apt-get install gcc g++ -y
sudo apt-get install build-essential -y

#安装ssh服务器
#echo -e "Start install ssh\n\n"
#sudo apt-get install openssh-server -y

#安装samba服务器
echo -e "Start install samba\n\n"
sudo apt-get install samba -y

#-------------------------------------------
#---------     编译PX4相关软件     ---------------------
#-------------------------------------------
#安装git
sudo apt-get install git git-core  -y

#添加wangbo这个用户到dialout组
sudo usermod -a -G dialout $USER_NAME

#安装Ninja编译系统，编译速度比make更快，如果安装了Ninja，编译时会自动选择这个工具
echo -e "Start install Ninja\n\n"
sudo add-apt-repository ppa:george-edison55/cmake-3.x -y
sudo apt-get update
sudo apt-get install python-argparse git-core wget zip python-empy qtcreator cmake build-essential genromfs -y

#安装仿真工具simulation tools
echo -e "Start install simulation tools\n\n"
#sudo apt-get install ant protobuf-compiler libeigen3-dev libopencv-dev openjdk-8-jdk openjdk-8-jre clang-3.5 lldb-3.5 -y
sudo apt-get install ant protobuf-compiler libeigen3-dev libopencv-dev clang-3.5 lldb-3.5 -y
#官网的安装命令中openjdk-8-jdk openjdk-8-jre在Ubuntu14.10可以直接安装，但是在14.04不能直接安装，我的版本是14.04.5x64
#安装jdk，ubuntu16.04可以直接apt安装
#echo -e "Start install openjdk-8-jdk jre\n\n"
#sudo apt-get install openjdk-8-jdk openjdk-8-jre -y
#安装jdk 如果不可以直接通过apt-get安装
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update 
sudo apt-get install openjdk-8-jdk openjdk-8-jre -y

#删除掉Ubuntu自带的串口管理模块
sudo apt-get remove modemmanager -y
sudo apt-get autoremove

#删除ubuntu14.04本身自带的arm-none-eabi-gcc
sudo apt-get remove gcc-arm-none-eabi gdb-arm-none-eabi binutils-arm-none-eabi -y
sudo apt-get autoremove
sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa -y
sudo apt-get update

echo -e "Start install gcc-arm-none-eabi\n\n"
sudo apt-get install python-serial openocd \
    flex bison libncurses5-dev autoconf texinfo build-essential \
    libftdi-dev libtool zlib1g-dev \
    python-empy -y

pushd .
cd ~
wget https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q2-update/+download/gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2
tar -jxf gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2
exportline="export PATH=$HOME/gcc-arm-none-eabi-5_4-2016q2/bin:$PATH"
if grep -Fxq "$exportline" ~/.profile; then echo nothing to do ; else echo $exportline >> ~/.profile; fi
. ~/.profile
popd
#因为安装的是64位的Ubuntu，所以需要安装下面的lsb-core
sudo apt-get install lsb-core
arm-none-eabi-gcc --version
echo -e "Finish install gcc-arm-none-eabi"

#配置git，然后下载px4的Firmware，编译##########
#配置用户名  
git config --global user.name "$GIT_NAME"
# 配置邮件  
git config --global user.email "$GIT_EMAIL"
#解决git clone下载速度慢问题
sudo cp /etc/ssh/ssh_config /etc/ssh/ssh_config_backup_$(date +%s)
sudo sed 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' -i /etc/ssh/ssh_config

#sudo su -$USER_NAME
cd ~
mkdir -p ~/src
cd ~/src
#git clone https://github.com/PX4/Firmware.git
git clone https://github.com/fb-vtol/Firmware.git
cd Firmware
git submodule update --init --recursive
cd ../..
sudo chmod a+w -R src
sudo chmod a+x -R src

#安装qtcreator
echo -e "Start install qtcreator\n\n"
sudo apt-get install qtcreator
#配置qtcreator
cd ~/src/Firmware
mkdir ../Firmware-build
cd ../Firmware-build
cmake ../Firmware -G "CodeBlocks - Unix Makefiles"
#接下来就是把qtcreator快捷方式放到桌面，导入工程，见http://www.nephen.com/2015/12/env-build-of-px4

echo -e "All SoftWare have been Installed!!! You can just build px4 or ardupilot!!!\n\n"
echo "******************************************\n\n"
