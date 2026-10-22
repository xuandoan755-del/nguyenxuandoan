@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0frontend"

echo ==============================================================
echo   BẢO AN - HỆ THỐNG QUẢN LÝ AN TOÀN TRẺ EM
echo   Sinh viên: Nguyễn Xuân Đoàn - MSV: 238600510 - Nhóm DA
echo ==============================================================
echo.
echo [1/4] Đang biên dịch ứng dụng Flutter (debug APK)...
call "C:\Users\doan\Downloads\flutter\bin\flutter.bat" build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo [LỖI] Quá trình biên dịch APK thất bại!
    pause
    exit /b %ERRORLEVEL%
)

set ADB="C:\Users\doan\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo.
echo [2/4] Đang chuyển file APK vào điện thoại Xiaomi...
%ADB% push "build\app\outputs\flutter-apk\app-debug.apk" /data/local/tmp/app-debug.apk
if %ERRORLEVEL% NEQ 0 (
    echo [LỖI] Không thể kết nối hoặc copy file vào thiết bị!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] Đang cài đặt trực tiếp vào điện thoại (bỏ qua chặn cài đặt Xiaomi)...
%ADB% shell pm install -r -d /data/local/tmp/app-debug.apk
%ADB% shell rm /data/local/tmp/app-debug.apk

echo.
echo [4/4] Đang khởi chạy ứng dụng Bảo An trên điện thoại...
%ADB% shell am start -n com.example.nguyenxuandoan.nguyenxuandoan/.MainActivity

echo.
echo ==============================================================
echo   [HOÀN TẤT] Ứng dụng đã chạy thành công trên điện thoại Xiaomi!
echo ==============================================================
pause
