#!/bin/bash

# رنگ‌ها برای پیام‌های کنسول
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# نمایش پیام با رنگ سبز
function print_success {
    echo -e "${GREEN}$1${NC}"
}

# نمایش پیام با رنگ قرمز
function print_error {
    echo -e "${RED}$1${NC}"
}

# بررسی و نصب پیش‌نیازها
echo "در حال بررسی پیش‌نیازها ..."
if ! command -v python3 &> /dev/null; then
    print_error "Python3 نصب نیست. در حال نصب ..."
    sudo apt update
    sudo apt install -y python3 python3-pip
fi

if ! command -v pip3 &> /dev/null; then
    print_error "pip3 نصب نیست. در حال نصب ..."
    sudo apt install -y python3-pip
fi

if ! command -v git &> /dev/null; then
    print_error "Git نصب نیست. در حال نصب ..."
    sudo apt install -y git
fi

print_success "پیش‌نیازها نصب شدند."

# دانلود یا کپی کد ربات
if [ ! -d "telegram-bot" ]; then
    print_success "در حال دانلود کد ربات ..."
    git clone https://github.com/Unknown-sir/botvalue/telegram-bot.git
fi

# رفتن به دایرکتوری پروژه
cd telegram-bot || { print_error "دایرکتوری ربات یافت نشد."; exit 1; }

# نصب وابستگی‌های پایتون
print_success "در حال نصب وابستگی‌ها ..."
pip3 install -r requirements.txt

# پیکربندی فایل .env برای توکن و آیدی ادمین
echo "لطفاً توکن ربات و آیدی ادمین را وارد کنید."

# توکن و آیدی ادمین را از کاربر بگیرید
read -p "توکن ربات: " TOKEN
read -p "آیدی ادمین: " ADMIN_ID

# ایجاد فایل .env برای ذخیره تنظیمات
echo "TOKEN_BOT=$TOKEN" > .env
echo "ADMIN_ID=$ADMIN_ID" >> .env

# ایجاد فایل سرویس systemd برای اجرای ربات در پس‌زمینه
echo "در حال ایجاد فایل سرویس systemd ..."
sudo bash -c 'cat > /etc/systemd/system/telegram_bot.service << EOF
[Unit]
Description=Telegram Bot
After=network.target

[Service]
WorkingDirectory=/home/$(whoami)/telegram-bot
ExecStart=/usr/bin/python3 /home/$(whoami)/telegram-bot/bot.py
Restart=always
User=$(whoami)
Group=$(whoami)
Environment=PATH=/usr/bin:/usr/local/bin
Environment=PYTHONUNBUFFERED=1
Environment=TOKEN_BOT='$TOKEN'
Environment=ADMIN_ID='$ADMIN_ID'

[Install]
WantedBy=multi-user.target
EOF'

# فعال‌سازی سرویس systemd
print_success "فعال‌سازی سرویس systemd ..."
sudo systemctl daemon-reload
sudo systemctl enable telegram_bot.service
sudo systemctl start telegram_bot.service

# بررسی وضعیت سرویس
print_success "بررسی وضعیت سرویس ..."
sudo systemctl status telegram_bot.service

# نمایش پیام موفقیت
print_success "ربات به طور موفقیت‌آمیز نصب و اجرا شد!"

# پایان
exit 0
