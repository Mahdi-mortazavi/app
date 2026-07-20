# QA Checklist — دفترچه تست دستی (برای علی 😄)

Automated tests cover logic (streaks, persistence ordering, notification-ID
mapping, widget smoke). The scenarios below **require a physical device** and
must be walked through before calling a release device-verified.

## 🔔 Notifications

| # | سناریو | مراحل | انتظار |
|---|---|---|---|
| N1 | اولین اجرا (Android 13+) | اپ تازه‌نصب → افزودن یادآور | اول شیت توضیح Nava، بعد دیالوگ سیستم |
| N2 | رد کردن Permission | در دیالوگ سیستم Deny بزن → دوباره یادآور بگذار | کرش نکند؛ شیت priming دوباره بیاید؛ یادآور بدون اجازه ذخیره نشود |
| N3 | اپ kill شده | یادآور برای ۲ دقیقه بعد → اپ را از Recents ببند | نوتیف سر وقت برسد (exact) |
| N4 | Reboot | یادآور برای ۱۰ دقیقه بعد → ریبوت کن | بعد از بوت، نوتیف سر وقت برسد (boot receiver) |
| N5 | Doze | یادآور ۱ ساعت بعد → گوشی را شارژ نزن و تکان نده | نوتیف با exactAllowWhileIdle برسد |
| N6 | تایمر در بک‌گراند | تایمر ۱ دقیقه‌ای → Home → صفحه قفل | نوتیف «پایان تمرکز» سر وقت + الگوی هپتیک مخصوص |
| N7 | بازگشت قبل از پایان | تایمر → Home → قبل از صفر برگرد | نوتیف زمان‌بندی‌شده cancel شود؛ زمان درست (بدون drift) |
| N8 | تغییر ساعت سیستم | وسط تایمر ساعت را جلو بکش | رفتار مستند: شمارش جابه‌جا می‌شود (DECISIONS D-2) — کرش ممنوع |
| N9 | کانال‌ها | Settings → App notifications | دو کانال مجزا: «یادآورها» (high) و «جلسه تمرکز» |
| N10 | OEM battery killer (شیائومی/سامسونگ) | اپ را در MIUI/OneUI بدون exemption بگذار | یادآور دیر/نرسید → کاربر را راهنمای exemption کن (v3.x در اپ) |

## 🎨 UI/UX

| # | سناریو | انتظار |
|---|---|---|
| U1 | متن بلند فارسی/انگلیسی در عنوان تسک | ellipsis؛ بدون overflow زرد |
| U2 | بزرگ‌ترین فونت سیستم (Accessibility) | مقیاس تا سقف 1.35؛ چیدمان سالم |
| U3 | Reduce Motion روشن | بدون گلو/باونس/انیمیشن ورود |
| U4 | TalkBack | همه‌ی کنترل‌ها label فارسی معنادار دارند |
| U5 | اسکرول لیست بلند (۵۰+ تسک) | 60fps؛ بدون jank محسوس (RepaintBoundary) |
| U6 | RTL | آیکن‌ها و چیدمان آینه‌ی درست |

## 📦 Release

| # | سناریو | انتظار |
|---|---|---|
| R1 | sha256sum -c SHA256SUMS.txt | هر سه APK match |
| R2 | نصب arm64 روی گوشی ۲۰۱۸+ | نصب و اجرای سالم |
| R3 | نصب universal روی هر دستگاه | نصب و اجرای سالم |
| R4 | ارتقا از نسخه قبلی (بدون uninstall) | داده‌ها (تسک‌ها/زنجیره) حفظ شوند — فقط با امضای یکسان ممکن است |
