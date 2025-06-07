#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Bắt đầu thiết lập Termux..."

MIRROR_DIR="/data/data/com.termux/files/usr/etc/termux"
MIRROR_BASE_DIR="$MIRROR_DIR/mirrors"
CHOSEN_LINK="$MIRROR_DIR/chosen_mirrors"

mkdir -p "$MIRROR_DIR"

if [ -L "$CHOSEN_LINK" ]; then
    unlink "$CHOSEN_LINK"
fi
ln -s "${MIRROR_BASE_DIR}/all" "$CHOSEN_LINK"
echo "[*] Đã chọn mirror mặc định"

echo "[*] Xóa các file lock apt/dpkg nếu có..."
rm -f $PREFIX/var/lib/dpkg/lock $PREFIX/var/lib/dpkg/lock-frontend $PREFIX/var/lib/apt/lists/lock $PREFIX/var/cache/apt/archives/lock

echo "[*] Cố gắng sửa lỗi dpkg nếu có..."
dpkg --configure -a || true

echo "[*] Làm sạch apt cache..."
apt clean || true

echo "[*] Cài đặt binutils để có lệnh 'ar' nếu thiếu..."
pkg install -y binutils

echo "[*] Cập nhật hệ thống..."
pkg update -y
pkg upgrade -y &

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
pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio &

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
else
    echo "[*] Bỏ qua bước tải file."
fi

wait

echo
echo "[✔] Thiết lập hoàn tất!"
