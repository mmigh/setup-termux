#!/bin/bash

# Xóa storage nếu có
if [ -e "/data/data/com.termux/files/home/storage" ]; then
    rm -rf /data/data/com.termux/files/home/storage
fi

# Cấp quyền storage
termux-setup-storage

# Cập nhật repo và tool cơ bản
yes | pkg update
yes | pkg install root-repo x11-repo -y
. <(curl -fsSL https://raw.githubusercontent.com/mmigh/setup-termux/refs/heads/main/termux-change-repo.sh)
yes | pkg upgrade

# Cài Python và công cụ build
yes | pkg install python android-tools python-pip git clang make libffi openssl -y

# Clone psutil source
cd $HOME
rm -rf psutil
git clone https://github.com/giampaolo/psutil.git
cd psutil

# Sửa lỗi getifaddrs để tương thích Android
sed -i '/getifaddrs/d' psutil/_psutil_posix.c
sed -i '/freeifaddrs/d' psutil/_psutil_posix.c

# Build & install psutil thủ công
python setup.py build
python setup.py install

# Cài thêm thư viện Python khác
pip install requests prettytable pytz pyjwt pycryptodome rich colorama flask discord python-socketio

# Tải script chính về máy
curl -Ls "https://raw.githubusercontent.com/mmigh/ROKID-OPENSOURCE/main/main.py" -o /sdcard/Download/shouko.py

echo -e "\n✅ Cài đặt hoàn tất. Chạy tool bằng:\n\nsu -c 'cd /sdcard/Download && python shouko.py'"