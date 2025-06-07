#!/data/data/com.termux/files/usr/bin/bash

set -e
set -x

echo "[*] Bắt đầu thiết lập Termux..."

termux-setup-storage

# Cài mediafire-dl nếu chưa có
pip show mediafire-dl >/dev/null 2>&1 || pip install mediafire-dl

# Nhập link MediaFire từ người dùng
read -p "[?] Nhập link MediaFire (.7z): " MF_LINK

# Thư mục lưu file
DEST_DIR=~/storage/downloads
extracted=0
ARCHIVE_PATH=""

# Bắt đầu tải file
echo "[*] Đang tải file .7z từ MediaFire..."
mediafire-dl "$MF_LINK" -o "$DEST_DIR" &

download_pid=$!

# Cài đặt các gói nền
(
  pkg update -y && pkg upgrade -y
  pkg install python tsu libexpat openssl p7zip -y
  pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio
) &

install_pid=$!

# Theo dõi file mới nhất trong downloads
echo "[*] Giám sát thư mục downloads để giải nén khi sẵn sàng..."

while kill -0 $download_pid 2>/dev/null; do
  # Tìm file .7z mới nhất
  ARCHIVE_PATH=$(find "$DEST_DIR" -maxdepth 1 -name "*.7z" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)
  
  # Nếu file tồn tại và đủ lớn thì giải nén
  if [ -n "$ARCHIVE_PATH" ] && [ -f "$ARCHIVE_PATH" ] && [ $(stat -c%s "$ARCHIVE_PATH") -gt 100000 ]; then
    if [ $extracted -eq 0 ]; then
      echo "[*] Đang giải nén: $ARCHIVE_PATH"
      7z x "$ARCHIVE_PATH" -o"$DEST_DIR"
      echo "[✓] Giải nén xong!"
      extracted=1
    fi
  fi
  sleep 3
done

# Nếu tải xong mà chưa giải nén thì làm ngay
if [ $extracted -eq 0 ]; then
  echo "[*] Tải xong, giải nén ngay..."
  ARCHIVE_PATH=$(find "$DEST_DIR" -maxdepth 1 -name "*.7z" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)
  7z x "$ARCHIVE_PATH" -o"$DEST_DIR"
  echo "[✓] Giải nén hoàn tất!"
fi

wait $install_pid

echo "[✓] Tất cả đã hoàn tất!"
