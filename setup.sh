#!/data/data/com.termux/files/usr/bin/env bash

set -e  # Dừng ngay nếu có lỗi

# Kiểm tra apt có tồn tại không
if ! command -v apt >/dev/null 2>&1; then
    echo "Error: apt không được cài đặt. Thoát."
    exit 1
fi

# Cập nhật và nâng cấp hệ thống
echo "[*] Cập nhật và nâng cấp gói hệ thống..."
pkg update -y
pkg upgrade -y

# Cấp quyền truy cập bộ nhớ
echo "[*] Yêu cầu quyền truy cập bộ nhớ..."
termux-setup-storage || {
    echo "[!] Không thể chạy termux-setup-storage. Hãy đảm bảo bạn xác nhận popup nếu có.";
}

# Cài đặt các gói hệ thống cần thiết
echo "[*] Cài đặt các gói cần thiết..."
pkg install -y python tsu libexpat openssl termux-tools

# Đảm bảo pip được cài
if ! command -v pip >/dev/null 2>&1; then
    echo "[*] pip chưa có, đang cài..."
    pkg install -y python-pip
fi

# Cài thư viện Python
echo "[*] Cài thư viện Python cần thiết..."
pip install --no-cache-dir requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio

echo "[✔] Hoàn tất setup Termux."
