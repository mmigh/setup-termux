#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Bắt đầu thiết lập Termux..."

# Vá lỗi dpkg/apt lock, lỗi cấu hình, cài binutils
echo "[*] Xóa file lock dpkg/apt nếu có..."
rm -f $PREFIX/var/lib/dpkg/lock-frontend $PREFIX/var/lib/dpkg/lock $PREFIX/var/lib/apt/lists/lock $PREFIX/var/cache/apt/archives/lock

echo "[*] Sửa lỗi cấu hình dpkg nếu có..."
dpkg --configure -a || true

echo "[*] Dọn dẹp cache apt..."
apt clean || true

echo "[*] Cài đặt binutils để có lệnh 'ar' cần thiết cho dpkg..."
pkg install -y binutils

echo "[*] Cập nhật và nâng cấp hệ thống..."
pkg update -y
pkg upgrade -y

echo "[*] Kiểm tra ~/storage..."
if [ -e "$HOME/storage" ] && [ ! -L "$HOME/storage" ]; then
    echo "[!] ~/storage là thư mục thật. Đang xóa để tạo symlink chuẩn..."
    rm -rf "$HOME/storage"
else
    echo "[*] ~/storage là symlink hoặc không tồn tại. Bỏ qua."
fi

echo "[*] Thiết lập quyền truy cập bộ nhớ..."
termux-setup-storage

echo "[*] Cài đặt các gói cần thiết..."
pkg install -y python tsu libexpat openssl

echo "[*] Cài đặt các thư viện Python..."
pip install --no-cache-dir requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio

echo
read -p "[?] Nhập link MediaFire (.7z) để tải hoặc Enter để bỏ qua: " MEDIAFIRE_LINK

if [ -n "$MEDIAFIRE_LINK" ]; then
    DOWNLOAD_DIR="$HOME/storage/downloads"
    mkdir -p "$DOWNLOAD_DIR"
    FILE_NAME=$(basename "$MEDIAFIRE_LINK")
    DOWNLOAD_PATH="$DOWNLOAD_DIR/$FILE_NAME"

    echo "[*] Đang tải file từ MediaFire..."
    curl -L "$MEDIAFIRE_LINK" -o "$DOWNLOAD_PATH"
    echo "[*] Đã tải xong: $DOWNLOAD_PATH"

    if ! command -v 7z >/dev/null 2>&1; then
        echo "[*] Đang cài p7zip để giải nén..."
        pkg install -y p7zip
    fi

    echo "[*] Bắt đầu giải nén $FILE_NAME vào $DOWNLOAD_DIR ..."
    7z x "$DOWNLOAD_PATH" -o"$DOWNLOAD_DIR" -y &
fi

wait

if command -v su >/dev/null 2>&1; then
    echo "[*] Phát hiện thiết bị root. Tự động cài các file APK trong $DOWNLOAD_DIR ..."
    find "$DOWNLOAD_DIR" -type f -name "*.apk" | while read -r apk; do
        echo "[*] Cài đặt APK: $apk"
        su -c "pm install -r '$apk'"
    done
fi

echo
echo "[✔] Thiết lập Termux hoàn tất!"
