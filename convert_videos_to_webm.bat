@echo off
REM سكريبت تحويل فيديوهات MP4 إلى WebM للويب
REM يجب تثبيت FFmpeg أولاً من: https://ffmpeg.org/download.html

echo ========================================
echo تحويل فيديوهات الحروف إلى WebM
echo ========================================
echo.

REM التحقق من وجود FFmpeg
where ffmpeg >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ FFmpeg غير مثبت!
    echo.
    echo الرجاء تثبيت FFmpeg من:
    echo https://ffmpeg.org/download.html
    echo.
    echo أو باستخدام Chocolatey:
    echo choco install ffmpeg
    echo.
    pause
    exit /b 1
)

echo ✅ FFmpeg موجود
echo.

REM المجلدات
set SOURCE_DIR=assets\videos\letters
set OUTPUT_DIR=assets\videos\letters_web

REM إنشاء مجلد الإخراج
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo 📁 المصدر: %SOURCE_DIR%
echo 📁 الوجهة: %OUTPUT_DIR%
echo.

REM عداد الملفات
set /a count=0
set /a total=0

REM حساب إجمالي الملفات
for %%f in ("%SOURCE_DIR%\*.mp4") do set /a total+=1

echo 🎬 عدد الفيديوهات: %total%
echo.
echo جاري التحويل...
echo.

REM تحويل كل ملف MP4 إلى WebM
for %%f in ("%SOURCE_DIR%\*.mp4") do (
    set /a count+=1
    echo [!count!/%total%] تحويل: %%~nxf
    
    ffmpeg -i "%%f" -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus "%OUTPUT_DIR%\%%~nf.webm" -y -loglevel error
    
    if !ERRORLEVEL! EQU 0 (
        echo     ✅ تم بنجاح
    ) else (
        echo     ❌ فشل التحويل
    )
    echo.
)

echo.
echo ========================================
echo ✅ اكتمل التحويل!
echo ========================================
echo.
echo تم تحويل %count% فيديو
echo الملفات موجودة في: %OUTPUT_DIR%
echo.
pause
