# Claude Remote Desktop

یک دسکتاپ Ubuntu XFCE که از طریق مرورگر قابل استفاده است و Claude Desktop و Claude Code را در اختیار می‌گذارد. این پروژه بر پایه‌ی [`linuxserver/webtop`](https://github.com/linuxserver/docker-webtop) ساخته شده و برای اجرای Docker و Railway طراحی شده است.

> **وضعیت پروژه:** در حال توسعه. قبل از انتشار عمومی، احراز هویت و HTTPS را تنظیم کنید.

## قابلیت‌ها

- دسکتاپ XFCE در مرورگر دسکتاپ و موبایل
- تمرکز اصلی روی گوشی‌های Android با لمس، trackpad مجازی و keyboard روی صفحه
- Claude Desktop از مخزن رسمی apt شرکت Anthropic
- Claude Code از npm (Node.js 24 LTS)
- ترمینال و `sudo` به‌صورت پیش‌فرض فعال‌اند تا Claude Code قابل استفاده باشد
- نگهداری تنظیمات و home در volume مسیر `/config`
- پروفایل کیفیت متعادل برای موبایل و امکان تغییر آن از `.env`

## معماری‌های پشتیبانی‌شده

مخزن رسمی Claude Desktop برای Linux هم `amd64` و هم `arm64` بسته منتشر می‌کند، بنابراین این image روی هر دو ساخته می‌شود و CI هر دو معماری را build می‌کند. نسخه‌ی Linux هنوز بتا است و برخی قابلیت‌ها (مثل Computer Use) در آن وجود ندارد.

## اجرای محلی امن

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

webtop یک متغیر `HARDEN_DESKTOP` دارد، ولی این پروژه **عمداً از آن استفاده نمی‌کند**: آن متغیر هم‌زمان `sudo` و ترمینال را غیرفعال می‌کند و Claude Code را بی‌فایده می‌سازد.

به‌جای آن:

- **همیشه فعال:** فرمان‌های command websocket و بخش Apps و file transfer و sharing غیرفعال‌اند (در Dockerfile).
- **ترمینال:** همیشه باز می‌ماند.
- **sudo:** به‌صورت پیش‌فرض باز است. برای بستن فقط `sudo`، overlay اختیاری را اجرا کنید:

  ```bash
  docker compose -f docker-compose.yml -f docker-compose.hardened.yml up -d
  ```

  با این حالت `sudo apt install` بعد از startup کار نمی‌کند؛ بسته‌های لازم را در Dockerfile نصب کنید.
- **`DISABLE_OPEN_TOOLS`** را قبل از ورود به حساب Claude روشن نکنید، چون `xdg-open` برای باز کردن مرورگر هنگام sign-in لازم است.

## Railway و انتشار عمومی

برای Railway، متغیرهای `CUSTOM_USER` و `PASSWORD` (معادل `WEBTOP_USER` و `WEBTOP_PASSWORD` در compose) و تنظیمات عملکرد را در بخش **Variables** وارد کنید؛ آن‌ها را داخل repository قرار ندهید.

پورت HTTPS داخلی سرویس `3001` است. اگر از دامنه‌ی عمومی استفاده می‌کنید:

1. احراز هویت را اجباری نگه دارید.
2. ترجیحاً سرویس را پشت Reverse Proxy با TLS معتبر قرار دهید.
3. پورت HTTP یعنی `3000` را مستقیماً عمومی نکنید.
4. WebSocket را فعال و proxy buffering را خاموش کنید.
5. قابلیت‌های غیرفعال‌شده مانند file transfer و sharing را فقط در صورت نیاز و با آگاهی از ریسک فعال کنید.
6. برای Railway سقف هزینه و resource limit تعیین کنید؛ این سرویس به‌دلیل encoding مداوم سبک نیست.

webtop یک محیط دسکتاپ کامل با terminal و `sudo` بدون رمز داخل کانتینر فراهم می‌کند. بنابراین انتشار بدون سخت‌سازی مناسب خطرناک است. جزئیات بیشتر در [SECURITY.md](SECURITY.md) آمده است.

## Claude Desktop و sandbox

Electron داخل Docker معمولاً sandbox کروم را ندارد (به user namespace نیاز دارد و seccomp پیش‌فرض Docker آن را می‌بندد). به همین دلیل Dockerfile به‌صورت پیش‌فرض Claude Desktop را با `--no-sandbox` اجرا می‌کند. اگر روی میزبان شما بدون آن هم کار می‌کند، با `--build-arg CLAUDE_NO_SANDBOX=false` بسازید.

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
