#!/bin/bash

# Xóa liên kết bộ nhớ cũ nếu có
if [ -e "/data/data/com.termux/files/home/storage" ]; then
    rm -rf /data/data/com.termux/files/home/storage
fi

# Thiết lập quyền truy cập bộ nhớ
termux-setup-storage

# Cập nhật gói và thêm root/x11 repo để tránh lỗi mirror
yes | pkg update
yes | pkg install root-repo x11-repo -y

# Tự động đổi repo thông qua script GitHub
. <(curl -fsSL https://raw.githubusercontent.com/mmigh/setup-termux/refs/heads/main/termux-change-repo.sh)

# Nâng cấp gói và cài đặt công cụ cần thiết
yes | pkg upgrade
yes | pkg install python android-tools python-pip -y

# Cài đặt các thư viện Python bạn cần
pip install --upgrade pip
pip install requests psutil prettytable pytz pyjwt pycryptodome rich colorama flask discord python-socketio
