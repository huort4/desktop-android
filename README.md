# Android Remote Desktop

یک دسکتاپ واقعی Ubuntu XFCE که از مرورگر گوشی Android باز می‌شود. سنگینی کار روی سرور است و گوشی فقط تصویر را نشان می‌دهد. این پروژه بر پایه‌ی [`linuxserver/webtop`](https://github.com/linuxserver/docker-webtop) ساخته شده و روی GitHub Codespaces (رایگان)، Docker و Railway اجرا می‌شود.

## قابلیت‌ها

- دسکتاپ کامل XFCE با Chromium، ترمینال، مدیر فایل Thunar و ویرایشگر Mousepad
- `git`، `nano`، `htop` و فونت فارسی Vazirmatn از پیش نصب‌شده
- تمرکز روی Android: لمس، trackpad مجازی، keyboard روی صفحه و fullscreen
- ترمینال و `sudo` فعال برای نصب هر برنامه‌ای که لازم دارید
- پروفایل کیفیت متعادل برای اینترنت موبایل و امکان تغییر آن
- Claude Desktop به‌صورت اختیاری (پیش‌فرض نصب نمی‌شود)

## اجرای رایگان روی GitHub Codespaces (پیشنهادی)

اکانت رایگان GitHub هر ماه ۱۲۰ ساعت-هسته Codespaces دارد؛ یعنی حدود ۶۰ ساعت روی ماشین ۲ هسته‌ای / ۸ گیگ. نیازی به کارت بانکی، سرور یا Docker روی گوشی نیست.

1. در مرورگر گوشی وارد github.com شوید و این مخزن را باز کنید (در صورت نیاز با گزینه‌ی **Desktop site**).
2. دکمه‌ی سبز **Code** ← تب **Codespaces** ← **Create codespace on main**.
3. اولین ساخت چند دقیقه طول می‌کشد. بعد از باز شدن VS Code، تب **Ports** را باز کنید.
4. روی آدرس پورت **Desktop (3000)** بزنید (آیکون کره). دسکتاپ در یک تب جدید باز می‌شود.
5. برای بهترین حالت، از منوی مرورگر **Add to Home screen** را بزنید تا مثل یک اپ تمام‌صفحه باز شود.

نکات مهم برای هدر نرفتن سهمیه:

- وقتی کارتان تمام شد از github.com/codespaces گزینه‌ی **Stop codespace** را بزنید. فایل‌ها می‌مانند و فقط زمان روشن بودن حساب می‌شود.
- کار با دسکتاپ از طریق پورت، برای Codespaces «فعالیت» حساب نمی‌شود؛ پس با timeout پیش‌فرض ۳۰ دقیقه، وسط کار خاموش می‌شود. در github.com/settings/codespaces مقدار **Default idle timeout** را تا سقف ۲۴۰ دقیقه (۴ ساعت) بالا ببرید و آخر کار حتماً خودتان Stop کنید؛ اگر فراموش کنید، تا ۴ ساعت از سهمیه‌ی ۶۰ ساعته هدر می‌رود. اگر خاموش شد، از github.com/codespaces دوباره Start کنید؛ تنظیمات و فایل‌های home حفظ می‌شوند.
- در همان صفحه **Default retention period** را کوتاه کنید تا codespaceهای فراموش‌شده حذف شوند و ۱۵ گیگ فضای رایگان پر نشود.
- ماشین ۴ هسته‌ای نسازید؛ سهمیه را دو برابر سریع‌تر مصرف می‌کند.
- **هرگز** visibility پورت را Public نکنید. حالت Private یعنی فقط اکانت GitHub خودتان به دسکتاپ دسترسی دارد.
- اگر صفحه‌ی دسکتاپ بالا نیامد، یک دقیقه صبر کنید و صفحه را refresh کنید؛ سرویس‌های دسکتاپ بعد از container بالا می‌آیند.

## اجرا روی گوشی بدون سرور (آفلاین)

اگر اینترنت ضعیف است یا سهمیه تمام شده، می‌توانید XFCE را مستقیماً روی گوشی با Termux و Termux:X11 اجرا کنید. این روش جزو این مخزن نیست ولی رایگان و آفلاین است:

```bash
pkg update && pkg upgrade -y
pkg i x11-repo
pkg i termux-x11-nightly xfce git
termux-x11 :1 -xstartup "dbus-launch --exit-with-session xfce4-session"
```

سپس اپ Termux:X11 را باز کنید (APK آن فقط در GitHub releases پروژه‌ی termux/termux-x11 منتشر می‌شود).

## معماری‌های پشتیبانی‌شده

image روی `amd64` و `arm64` ساخته می‌شود و CI هر دو معماری را build می‌کند. Codespaces از `amd64` استفاده می‌کند.

## اجرای محلی با Docker

```bash
cp .env.example .env
# مقدار WEBTOP_PASSWORD را در .env به یک رمز طولانی و تصادفی تغییر دهید.
docker compose up -d --build
```

برای محیط توسعه با پورت‌های فقط-localhost (نیازمند Docker Compose نسخه‌ی 2.24 یا بالاتر):

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
```

- حالت عادی: `https://<host>:3001`
- حالت توسعه: `https://localhost:3001` و در صورت نیاز `http://localhost:3000`
- گواهی HTTPS پیش‌فرض self-signed است و ممکن است مرورگر هشدار نشان دهد.

فایل `.env` و مسیر `config/` نباید commit شوند.

## تنظیمات اصلی

مقادیر پیش‌فرض در `Dockerfile` (بخش `ENV`) تعریف شده‌اند و `docker-compose.yml` همان‌ها را برای override از `.env` در دسترس می‌گذارد. Railway فقط Dockerfile را build می‌کند، پس همین مقادیر آنجا هم اعمال می‌شوند.

| متغیر | مقدار پیش‌فرض | توضیح |
|---|---:|---|
| `WEBTOP_USER` | اجباری | نام کاربر webtop (در compose) |
| `WEBTOP_PASSWORD` | اجباری | رمز ورود؛ در Git قرار نگیرد |
| `MAX_RES` | `1280x720` | حداکثر رزولوشن دسکتاپ |
| `SELKIES_FRAMERATE` | `24` | تعداد فریم برای stream |
| `SELKIES_H264_CRF` | `30` | مقدار بیشتر یعنی حجم کمتر و کیفیت پایین‌تر |
| `SELKIES_ENCODER` | `x264enc-striped` | انکودر ویدیو |
| `SELKIES_AUDIO_ENABLED` | `false\|locked` | ضبط صدا؛ برای فعال‌سازی `true` بگذارید |
| `PIXELFLUX_WAYLAND` | `false` | `false` یعنی X11 (توصیه‌شده)؛ `true` یعنی Wayland |
| `CPU_LIMIT` | `4` | سقف CPU کانتینر (compose) |
| `MEMORY_LIMIT` | `4G` | سقف RAM کانتینر (compose) |

تنظیمات قفل‌شده‌ی دیگر (مثل `SELKIES_FILE_TRANSFERS` و `SELKIES_ENABLE_SHARING`) فقط در `Dockerfile` هستند. برای تغییر آن‌ها، متغیر را در بخش `environment` سرویس در compose اضافه کنید یا در Railway به Variables بدهید.

> پسوند `|locked` یعنی کاربر نمی‌تواند آن گزینه را از داخل رابط تغییر دهد.

## تنظیمات Android

در webtop/Selkies این امکانات برای گوشی نگه داشته شده‌اند:

- **Trackpad mode** برای حرکت نرم‌تر و نسبی موس با یک انگشت
- **Direct touch mode** برای برنامه‌های لمسی
- **On-screen keyboard** برای تایپ بدون کیبورد فیزیکی
- **Fullscreen** برای بیشترین فضای قابل استفاده
- clipboard متنی برای کپی و paste بین گوشی و دسکتاپ

برای کاهش شلوغی، مصرف اینترنت و سطح حمله، این موارد به‌صورت پیش‌فرض غیرفعال و قفل‌اند: صدا و میکروفون، gamepad، file upload/download، session sharing، binary clipboard، نمایشگر دوم، فرمان‌های command websocket، بخش Apps و بخش‌های غیرضروری sidebar.

برای حرکت نرم‌تر موس، ابتدا در sidebar حالت **Trackpad** را انتخاب کنید. برای برنامه‌های touch-friendly، **Direct touch** مناسب‌تر است. اگر متن تار بود، در بخش Screen settings گزینه‌ی CSS scaling را خاموش کنید (این گزینه قفل نیست). خاموش‌کردن آن کیفیت متن را بالا می‌برد ولی مصرف دیتا را زیاد می‌کند.

سه پروفایل آماده در `.env.example` هست: Speed (`960x540`، ۲۰ فریم، CRF 32)، Balanced (پیش‌فرض) و Quality (`1920x1080`، ۳۰ فریم، CRF 28). فقط یک بلوک را فعال نگه دارید. افزایش هم‌زمان رزولوشن و frame rate روی اینترنت موبایل، latency و مصرف دیتا را زیاد می‌کند.

> اسکریپت `bin/android-perf.sh` تنظیمات XFCE روی X11 را سبک می‌کند (compositing، انیمیشن، wallpaper، screensaver). با `PIXELFLUX_WAYLAND=true` اثر آن محدود می‌شود.

## ترمینال و sudo (سخت‌سازی)

webtop یک متغیر `HARDEN_DESKTOP` دارد، ولی این پروژه **عمداً از آن استفاده نمی‌کند**: آن متغیر هم‌زمان `sudo` و ترمینال را غیرفعال می‌کند و دسکتاپ بدون ترمینال کاربرد چندانی ندارد.

به‌جای آن:

- **همیشه فعال:** فرمان‌های command websocket و بخش Apps و file transfer و sharing غیرفعال‌اند (در Dockerfile).
- **ترمینال:** همیشه باز می‌ماند.
- **sudo:** به‌صورت پیش‌فرض باز است. برای بستن فقط `sudo`، overlay اختیاری را اجرا کنید:

  ```bash
  docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d
  ```

  با این حالت `sudo apt install` بعد از startup کار نمی‌کند؛ بسته‌های لازم را در Dockerfile نصب کنید.
- **`DISABLE_OPEN_TOOLS`** باز کردن لینک‌ها در مرورگر را می‌بندد؛ اگر Claude Desktop را نصب کرده‌اید، آن را قبل از sign-in روشن نکنید.

## Railway (پولی)

> **هزینه:** پلن رایگان Railway فقط ۱ دلار اعتبار ماهانه و حداکثر ۰.۵ گیگ RAM برای هر سرویس می‌دهد؛ این دسکتاپ با آن بالا نمی‌آید. پلن Hobby ماهی ۵ دلار است و مصرف اضافه جداگانه حساب می‌شود. برای استفاده‌ی رایگان از Codespaces استفاده کنید.

اگر Railway را انتخاب کردید، متغیرهای `CUSTOM_USER` و `PASSWORD` و تنظیمات عملکرد را در بخش **Variables** وارد کنید؛ آن‌ها را داخل repository قرار ندهید.

Railway خودش HTTPS معتبر می‌دهد و به سرویس با HTTP وصل می‌شود؛ بنابراین **target port** دامنه‌ی عمومی را `3000` بگذارید (پورت `3001` گواهی self-signed دارد و پشت پراکسی Railway مناسب نیست). همچنین:

1. احراز هویت را اجباری نگه دارید (`CUSTOM_USER` و `PASSWORD`).
2. WebSocket را فعال و proxy buffering را خاموش نگه دارید.
3. قابلیت‌های غیرفعال‌شده مانند file transfer و sharing را فقط در صورت نیاز و با آگاهی از ریسک فعال کنید.
4. سقف هزینه (usage limit) و resource limit تعیین کنید؛ این سرویس به‌دلیل encoding مداوم سبک نیست.

webtop یک محیط دسکتاپ کامل با terminal و `sudo` بدون رمز داخل کانتینر فراهم می‌کند. بنابراین انتشار بدون احراز هویت خطرناک است. جزئیات بیشتر در [SECURITY.md](SECURITY.md) آمده است.

## Claude Desktop (اختیاری)

به‌صورت پیش‌فرض نصب نمی‌شود. برای نصب، image را با این build arg بسازید (یا در Railway به Variables بدهید):

```bash
docker compose build --build-arg INSTALL_CLAUDE_DESKTOP=true
```

Electron داخل Docker معمولاً sandbox کروم را ندارد، بنابراین Claude Desktop با `--no-sandbox` اجرا می‌شود. برای غیرفعال کردن این رفتار `--build-arg CLAUDE_NO_SANDBOX=false` بدهید.

## توسعه و CI

فایل `.github/workflows/ci.yml` در هر push و pull request این کارها را انجام می‌دهد:

- validate کردن هر سه ترکیب Compose و اطمینان از اینکه override توسعه پورت را دوبار bind نمی‌کند
- shellcheck روی `bin/android-perf.sh`
- build کردن image برای `amd64` و `arm64` (runner بومی؛ برای repository خصوصی ممکن است runner ARM در دسترس نباشد)
- اسکن کل تاریخچه برای secretهای accidentally committed

لاگ‌ها و توقف سرویس:

```bash
docker compose logs -f desktop
docker compose down
```

## ساختار پروژه

```text
.
├── .devcontainer/devcontainer.json
├── Dockerfile
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.hardened.yml
├── .env.example
├── .dockerignore
├── bin/android-perf.sh
├── autostart/android-perf.desktop
├── SECURITY.md
├── LICENSE
├── README.md
└── .github/workflows/ci.yml
```

## مجوز

این پروژه تحت مجوز MIT منتشر می‌شود. متن کامل در [LICENSE](LICENSE) قرار دارد.
