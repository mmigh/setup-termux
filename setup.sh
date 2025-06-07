#!/bin/bash

# Xóa storage nếu đã được mount
if [ -e "/data/data/com.termux/files/home/storage" ]; then
	rm -rf /data/data/com.termux/files/home/storage
fi

termux-setup-storage

yes | pkg update

. <(curl -s https://raw.githubusercontent.com/u400822/setup-termux/refs/heads/main/termux-change-repo.sh)

yes | pkg upgrade
yes | pkg install python
yes | pkg install android-tools
yes | pkg install python-pip
yes | pkg install tsu libexpat openssl

pip install --upgrade pip
yes | pip install --no-input requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio prettytable

echo -e "\n✅ Đã hoàn tất cài đặt toàn bộ môi trường!"
