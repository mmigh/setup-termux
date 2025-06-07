#!/data/data/com.termux/files/usr/bin/bash

set -e  # Nếu có lỗi script sẽ dừng ngay

# Hàm chọn mirror mặc định (tương tự script bạn gửi)
select_default_mirror() {
    MIRROR_BASE_DIR="/data/data/com.termux/files/usr/etc/termux/mirrors"
    local chosen_link="/data/data/com.termux/files/usr/etc/termux/chosen_mirrors"

    if [ -L "$chosen_link" ]; then
        unlink "$chosen_link"
    fi
    ln -s "${MIRROR_BASE_DIR}/all" "$chosen_link"
    echo "[*] Mirror set to 'all'"
}

# Kiểm tra apt có tồn tại không
if ! command -v apt >/dev/null 2>&1; then
    echo "Error: apt không được cài đặt. Thoát."
    exit 1
fi

# Thực hiện chọn mirror
select_default_mirror

# Cập nhật repo của pkg với mirror mới
echo "[*] Cập nhật repo với mirror mới"
TERMUX_APP_PACKAGE_MANAGER=apt pkg --check-mirror update

# Cập nhật và nâng cấp gói
echo "[*] Cập nhật và nâng cấp gói hệ thống"
pkg update -y
pkg upgrade -y

# Cấp quyền truy cập bộ nhớ
echo "[*] Cấp quyền truy cập bộ nhớ (termux-setup-storage)"
echo "y" | termux-setup-storage

# Cài đặt các gói cần thiết
echo "[*] Cài đặt các gói cần thiết"
pkg install -y python tsu libexpat openssl

# Cài đặt các thư viện Python cần thiết
echo "[*] Cài đặt các thư viện Python qua pip"
pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio

echo "[*] Hoàn thành setup Termux tự động."
