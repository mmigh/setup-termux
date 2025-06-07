#!/bin/bash

# Xóa liên kết bộ nhớ cũ nếu có
if [ -e "/data/data/com.termux/files/home/storage" ]; then
    rm -rf /data/data/com.termux/files/home/storage
fi

# Thiết lập quyền truy cập bộ nhớ
termux-setup-storage

# Cập nhật gói và thêm repo tránh lỗi mirror
yes | pkg update
yes | pkg install root-repo x11-repo -y

# Đổi repo Termux (dùng link mới)
. <(curl -fsSL https://raw.githubusercontent.com/mmigh/setup-termux/refs/heads/main/termux-change-repo.sh)

# Nâng cấp gói và cài công cụ cần thiết
yes | pkg upgrade
yes | pkg install python android-tools python-pip -y

# Cài thư viện Python cần thiết (không nâng pip để tránh lỗi Termux)
pip install requests psutil prettytable pytz pyjwt pycryptodome rich colorama flask discord python-socketio
