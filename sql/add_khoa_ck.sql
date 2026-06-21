-- =============================================
-- THÊM DỮ LIỆU KHOA CƠ KHÍ (CK)
-- Chạy script này sau khi đã có database QLDSV_HTC
-- =============================================
USE QLDSV_HTC;
GO

-- =============================================
-- 1. THÊM KHOA CƠ KHÍ (nếu chưa có)
-- =============================================
IF NOT EXISTS (SELECT * FROM KHOA WHERE MAKHOA = 'CK')
    INSERT INTO KHOA (MAKHOA, TENKHOA)
    VALUES ('CK', N'Cơ Khí');
GO
PRINT N'[OK] Khoa CK da duoc them';

-- =============================================
-- 2. THÊM LỚP CHO KHOA CK
-- =============================================
IF NOT EXISTS (SELECT * FROM LOP WHERE MALOP = 'CK01')
    INSERT INTO LOP (MALOP, TENLOP, KHOAHOC, MAKHOA)
    VALUES ('CK01', N'Cơ khí K22A', '2022-2026', 'CK');
GO
IF NOT EXISTS (SELECT * FROM LOP WHERE MALOP = 'CK02')
    INSERT INTO LOP (MALOP, TENLOP, KHOAHOC, MAKHOA)
    VALUES ('CK02', N'Cơ khí K23A', '2023-2027', 'CK');
GO
PRINT N'[OK] 2 lop CK da duoc them';

-- =============================================
-- 3. THÊM SINH VIÊN CHO KHOA CK
-- =============================================
IF NOT EXISTS (SELECT * FROM SINHVIEN WHERE MASV = 'SV007')
    INSERT INTO SINHVIEN (MASV, HO, TEN, NGAYSINH, PHAI, MALOP, PASSWORD)
    VALUES ('SV007', N'Trần', N'Văn An', '2004-05-12', 0, 'CK01', '123456');
GO
IF NOT EXISTS (SELECT * FROM SINHVIEN WHERE MASV = 'SV008')
    INSERT INTO SINHVIEN (MASV, HO, TEN, NGAYSINH, PHAI, MALOP, PASSWORD)
    VALUES ('SV008', N'Nguyễn', N'Thị Bình', '2004-08-25', 1, 'CK01', '123456');
GO
IF NOT EXISTS (SELECT * FROM SINHVIEN WHERE MASV = 'SV009')
    INSERT INTO SINHVIEN (MASV, HO, TEN, NGAYSINH, PHAI, MALOP, PASSWORD)
    VALUES ('SV009', N'Lê', N'Quang Cường', '2005-01-03', 0, 'CK02', '123456');
GO
PRINT N'[OK] 3 sinh vien CK da duoc them';

-- =============================================
-- 4. THÊM GIẢNG VIÊN KHOA CK
-- =============================================
IF NOT EXISTS (SELECT * FROM GIANGVIEN WHERE MAGV = 'GV05')
    INSERT INTO GIANGVIEN (MAGV, HO, TEN, NGAYSINH, PHAI, EMAIL, MAKHOA)
    VALUES ('GV05', N'Lưu Văn', N'Thắng', '1975-06-10', 0, 'gv05@ck.edu.vn', 'CK');
GO
IF NOT EXISTS (SELECT * FROM GIANGVIEN WHERE MAGV = 'GV06')
    INSERT INTO GIANGVIEN (MAGV, HO, TEN, NGAYSINH, PHAI, EMAIL, MAKHOA)
    VALUES ('GV06', N'Cao Thị', N'Hằng', '1980-11-20', 1, 'gv06@ck.edu.vn', 'CK');
GO
PRINT N'[OK] 2 giang vien CK da duoc them';

-- =============================================
-- 5. THÊM SQL SERVER LOGIN CHO KHOA CK
-- =============================================
USE master;
GO
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'khoa_ck')
    CREATE LOGIN khoa_ck WITH PASSWORD = 'khoa789', DEFAULT_DATABASE = QLDSV_HTC, CHECK_POLICY = OFF;
GO

USE QLDSV_HTC;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'khoa_ck')
    CREATE USER khoa_ck FOR LOGIN khoa_ck;
GO
ALTER ROLE KHOA ADD MEMBER khoa_ck;
GO

-- =============================================
-- 6. THÊM TÀI KHOẢN KHOA CK VÀO BẢNG TaiKhoan
-- =============================================
IF NOT EXISTS (SELECT * FROM TaiKhoan WHERE Login = 'khoa_ck')
    INSERT INTO TaiKhoan (Login, MatKhau, NhomQuyen, MAKHOA, TrangThai, NgayTao)
    VALUES ('khoa_ck', 'khoa789', 'KHOA', 'CK', 'Active', GETDATE());
GO

PRINT N'[OK] Login khoa_ck da duoc them (Password: khoa789)';
PRINT N'=== HOAN TAT THEM DU LIEU KHOA CK ===';
GO
