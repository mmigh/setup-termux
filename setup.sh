#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Bắt đầu thiết lập Termux..."

# ============================
# Mirror Setup
# ============================
MIRROR_BASE_DIR="/data/data/com.termux/files/usr/etc/termux/mirrors"
CHOSEN_LINK="/data/data/com.termux/files/usr/etc/termux/chosen_mirrors"

if [ -L "$CHOSEN_LINK" ]; then
    unlink "$CHOSEN_LINK"
fi
ln -s "${MIRROR_BASE_DIR}/all" "$CHOSEN_LINK"
echo "[*] Đã chọn mirror mặc định"

# ============================
# Update & Upgrade
# ============================
echo "[*] Cập nhật hệ thống..."
pkg update -y
pkg upgrade -y

# ============================
# Setup Storage
# ============================
echo "[*] Kiểm tra ~/storage..."

if [ -e "$HOME/storage" ] && [ ! -L "$HOME/storage" ]; then
    echo "[!] ~/storage là thư mục thật. Đang xóa để tạo symlink chuẩn..."
    rm -rf "$HOME/storage"
fi

echo "[*] Thiết lập quyền truy cập bộ nhớ..."
termux-setup-storage

# ============================
# Cài đặt gói và thư viện cần thiết
# ============================
echo "[*] Cài đặt gói..."
pkg install -y python tsu libexpat openssl
echo "[*] Cài pip packages..."
pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio

# ============================
# Tùy chọn: Tải file từ MediaFire
# ============================
echo
read -p "[?] Nhập link MediaFire (.7z chứa file apk/py...) hoặc nhấn Enter để bỏ qua: " MEDIAFIRE_LINK

if [ -n "$MEDIAFIRE_LINK" ]; then
    echo "[*] Đang tải file từ MediaFire..."
    
    FILE_NAME=$(basename "$MEDIAFIRE_LINK")
    DOWNLOAD_PATH="$HOME/storage/downloads/$FILE_NAME"

    curl -L "$MEDIAFIRE_LINK" -o "$DOWNLOAD_PATH"

    echo "[*] Đã tải xong: $DOWNLOAD_PATH"

    # ============================
    # Giải nén file .7z nếu có
    # ============================
    if command -v 7z >/dev/null 2>&1; then
        echo "[*] Giải nén $FILE_NAME..."
        7z x "$DOWNLOAD_PATH" -o"$HOME/storage/downloads" -y
    else
        echo "[!] Chưa cài đặt 7z, đang cài..."
        pkg install -y p7zip
        7z x "$DOWNLOAD_PATH" -o"$HOME/storage/downloads" -y
    fi
fi

# ============================
# Nếu máy đã root, cài .apk
# ============================
if command -v su >/dev/null 2>&1; then
    echo "[*] Thiết bị đã root. Đang tìm file APK trong Downloads..."

    find "$HOME/storage/downloads" -type f -name "*.apk" | while read apk; do
        echo "[*] Cài đặt APK: $apk"
        su -c "pm install -r '$apk'"
    done
fi

echo
echo "[✔] Thiết lập hoàn tất!"
