#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "[*] Bắt đầu thiết lập Termux..."

MIRROR_BASE_DIR="/data/data/com.termux/files/usr/etc/termux/mirrors"
CHOSEN_LINK="/data/data/com.termux/files/usr/etc/termux/chosen_mirrors"

if [ -L "$CHOSEN_LINK" ]; then
    unlink "$CHOSEN_LINK"
fi
ln -s "${MIRROR_BASE_DIR}/all" "$CHOSEN_LINK"
echo "[*] Đã chọn mirror mặc định"

echo "[*] Cập nhật hệ thống..."
pkg update -y
pkg upgrade -y &

# xử lý ~/storage
echo "[*] Kiểm tra ~/storage..."
if [ -e "$HOME/storage" ] && [ ! -L "$HOME/storage" ]; then
    echo "[!] ~/storage là thư mục thật. Đang xóa để tạo symlink chuẩn..."
    rm -rf "$HOME/storage"
else
    echo "[*] ~/storage là symlink hoặc không tồn tại. Bỏ qua."
fi

echo "[*] Thiết lập quyền truy cập bộ nhớ..."
termux-setup-storage

# cài gói cần thiết (chạy song song với tải file)
pkg install -y python tsu libexpat openssl &

# cài pip package (chạy song song với tải file)
pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio &

# hỏi link mediafire
echo
read -p "[?] Nhập link MediaFire (.7z) hoặc Enter để bỏ qua: " MEDIAFIRE_LINK

DOWNLOAD_PATH=""
if [ -n "$MEDIAFIRE_LINK" ]; then
    FILE_NAME=$(basename "$MEDIAFIRE_LINK")
    DOWNLOAD_PATH="$HOME/storage/downloads/$FILE_NAME"
    echo "[*] Đang tải file từ MediaFire..."
    curl -L "$MEDIAFIRE_LINK" -o "$DOWNLOAD_PATH"
    echo "[*] Đã tải xong: $DOWNLOAD_PATH"

    # Kiểm tra 7z, cài nếu chưa có
    if ! command -v 7z >/dev/null 2>&1; then
        echo "[*] Đang cài p7zip để giải nén..."
        pkg install -y p7zip
    fi

    # Giải nén song song
    echo "[*] Bắt đầu giải nén $FILE_NAME vào ~/storage/downloads ..."
    7z x "$DOWNLOAD_PATH" -o"$HOME/storage/downloads" -y &
fi

# đợi các job background hoàn thành
wait

# nếu có root thì cài apk trong downloads
if command -v su >/dev/null 2>&1; then
    echo "[*] Thiết bị đã root. Tự động cài các file APK trong ~/storage/downloads..."
    find "$HOME/storage/downloads" -type f -name "*.apk" | while read -r apk; do
        echo "[*] Cài đặt APK: $apk"
        su -c "pm install -r '$apk'"
    done
fi

echo
echo "[✔] Thiết lập hoàn tất!"
