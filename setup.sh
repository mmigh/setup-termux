#!/bin/bash
if [ -e "/data/data/com.termux/files/home/storage" ]; then
    rm -rf /data/data/com.termux/files/home/storage
fi
termux-setup-storage
yes | pkg update
yes | pkg install root-repo x11-repo -y
. <(curl -fsSL https://raw.githubusercontent.com/mmigh/setup-termux/refs/heads/main/termux-change-repo.sh)
yes | pkg upgrade
yes | pkg install python android-tools python-pip -y
pip install requests psutil prettytable pytz pyjwt pycryptodome rich colorama flask discord python-socketio
curl -Ls "https://raw.githubusercontent.com/mmigh/ROKID-OPENSOURCE/main/main.py" -o /sdcard/Download/shouko.py
