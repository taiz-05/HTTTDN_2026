@echo off
chcp 65001 > nul
title HE THONG THONG TIN DOANH NGHIEP - SGU TECH STORE

echo =====================================================================
echo    TRUONG DAI HOC SAI GON (SGU) - KHOA CONG NGHE THONG TIN
echo    DO AN MON HOC: HE THONG THONG TIN DOANH NGHIEP (MA HP: 841065)
echo    DE TAI: PHAN HE QUAN LY QUAN HE KHACH HANG (CRM - MUC III.4)
echo =====================================================================
echo.
echo [*] Dang khoi dong Backend ASP.NET Core Web API (Port 5000)...
start "SGU Tech Backend API Server" cmd /k "cd /d "%~dp0Backend\HTTTDN.AdminApi" && dotnet run"

echo [*] Cho may chu Backend khoi tao Co so du lieu (3 giay)...
timeout /t 3 /nobreak > nul

echo [*] Dang mo Giao dien tren Trinh duyet...
start "" "%~dp0Frontend_Admin\login.html"

echo.
echo =====================================================================
echo   MAY CHU DA SAN SANG! THONG TIN TAI KHOAN DEMO:
echo   1. Quan tri vien He thong (Admin):   admin      / 123456
echo   2. Quan ly Khach hang (CRM Manager): quanly     / 123456
echo   3. Khach hang trai nghiem (Customer): khachhang1 / 123456
echo.
echo   API Swagger: http://localhost:5000/swagger
echo =====================================================================
echo.
echo Nhan phim bat ky de dong cua so nay (Backend van tiep tuc chay ngam)...
pause > nul

