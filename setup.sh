#!/data/data/com.termux/files/usr/bin/bash

set -e
set -x

echo "[*] Bắt đầu thiết lập Termux..."

# Xử lý ~/storage để không lỗi khi gọi termux-setup-storage
if [ -e ~/storage ] && [ ! -L ~/storage ]; then
    echo "[!] ~/storage là thư mục thật. Đang xóa để tạo symlink chuẩn..."
    rm -rf ~/storage
fi

# Gọi lại bình thường
termux-setup-storage

else
    echo "[*] ~/storage đã tồn tại và đúng định dạng, bỏ qua."
fi

# Cài Python để dùng pip
pkg install python -y

# Cài mediafire-dl nếu chưa
if ! pip show mediafire-dl >/dev/null 2>&1; then
    pip install mediafire-dl
fi

# Nhập link MediaFire (có thể bỏ qua)
read -p "[?] Nhập link MediaFire (.7z) hoặc nhấn Enter để bỏ qua: " MF_LINK

DEST_DIR=~/storage/downloads
ARCHIVE_PATH=""
extracted=0

# Cài các gói cần thiết song song
(
  pkg update -y && pkg upgrade -y
  pkg install tsu libexpat openssl p7zip -y
  pip install requests pytz pyjwt pycryptodome rich colorama flask psutil discord python-socketio
) &
install_pid=$!

# Tải và giải nén file nếu có link
if [ -n "$MF_LINK" ]; then
  echo "[*] Đang tải file .7z từ MediaFire..."
  mediafire-dl "$MF_LINK" -o "$DEST_DIR" &
  download_pid=$!

  while kill -0 $download_pid 2>/dev/null; do
    ARCHIVE_PATH=$(find "$DEST_DIR" -maxdepth 1 -name "*.7z" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

    if [ -n "$ARCHIVE_PATH" ] && [ -f "$ARCHIVE_PATH" ] && [ $(stat -c%s "$ARCHIVE_PATH") -gt 100000 ]; then
      if [ $extracted -eq 0 ]; then
        echo "[*] File đã sẵn sàng, giải nén..."
        7z x "$ARCHIVE_PATH" -o"$DEST_DIR"
        echo "[✓] Giải nén hoàn tất!"
        extracted=1
      fi
    fi
    sleep 3
  done

  if [ $extracted -eq 0 ]; then
    echo "[*] Tải xong, tiến hành giải nén..."
    ARCHIVE_PATH=$(find "$DEST_DIR" -maxdepth 1 -name "*.7z" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)
    7z x "$ARCHIVE_PATH" -o"$DEST_DIR"
    echo "[✓] Giải nén hoàn tất!"
  fi
else
  echo "[*] Bạn đã chọn bỏ qua bước tải & giải nén file .7z."
fi

wait $install_pid

# Tự động cài tất cả file .apk nếu máy đã root
if command -v tsu >/dev/null 2>&1; then
  echo "[*] Đang tìm và cài đặt file APK trong $DEST_DIR ..."
  for apk in "$DEST_DIR"/*.apk; do
    [ -f "$apk" ] || continue
    echo "[*] Cài đặt: $apk"
    tsu -c "pm install -r \"$apk\"" && echo "[✓] Cài xong $apk" || echo "[!] Cài thất bại $apk"
  done
else
  echo "[!] Máy bạn chưa root hoặc không có lệnh tsu, bỏ qua bước cài APK."
fi

echo "[✓] Thiết lập hoàn tất!"
