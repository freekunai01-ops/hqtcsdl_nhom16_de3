-- =============================================
-- QLDSV_HTC - PHÂN QUYỀN SQL SERVER
-- Script tạo Logins, Roles và phân quyền
-- =============================================

USE master;
GO

-- =============================================
-- 1. TẠO SQL SERVER LOGINS
-- =============================================

-- Login cho Phòng Giáo vụ (toàn quyền)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'pgv_admin')
    CREATE LOGIN pgv_admin WITH PASSWORD = '123456', DEFAULT_DATABASE = QLDSV_HTC, CHECK_POLICY = OFF;
GO

-- Login KHOA chung (đại diện nhóm quyền KHOA, xem tất cả read-only)
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'khoa_all')
    CREATE LOGIN khoa_all WITH PASSWORD = '123456', DEFAULT_DATABASE = QLDSV_HTC, CHECK_POLICY = OFF;
GO

-- Login chung cho tất cả Sinh viên
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'sv')
    CREATE LOGIN sv WITH PASSWORD = 'sv123', DEFAULT_DATABASE = QLDSV_HTC, CHECK_POLICY = OFF;
GO

-- =============================================
-- 2. TẠO DATABASE USERS
-- =============================================
USE QLDSV_HTC;
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'pgv_admin')
    CREATE USER pgv_admin FOR LOGIN pgv_admin;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'khoa_all')
    CREATE USER khoa_all FOR LOGIN khoa_all;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'sv')
    CREATE USER sv FOR LOGIN sv;
GO

-- =============================================
-- 3. TẠO DATABASE ROLES
-- =============================================
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'PGV' AND type = 'R')
    CREATE ROLE PGV;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'KHOA' AND type = 'R')
    CREATE ROLE KHOA;
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'NHOM_SV' AND type = 'R')
    CREATE ROLE NHOM_SV;
GO

-- =============================================
-- 4. GÁN USERS VÀO ROLES
-- =============================================
ALTER ROLE PGV ADD MEMBER pgv_admin;
GO
ALTER ROLE KHOA ADD MEMBER khoa_all;
GO
ALTER ROLE NHOM_SV ADD MEMBER sv;
GO

-- =============================================
-- 5. PHÂN QUYỀN CHO TỪNG NHÓM
-- =============================================

-- ===== PGV (Phòng Giáo vụ) - TOÀN QUYỀN =====
GRANT SELECT, INSERT, UPDATE, DELETE ON KHOA TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON LOP TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON SINHVIEN TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON MONHOC TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON GIANGVIEN TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON LOPTINCHI TO PGV;
GRANT SELECT, INSERT, UPDATE, DELETE ON DANGKY TO PGV;
GO

-- ===== KHOA - QUYỀN HẠN CHẾ =====
-- Chỉ được xem (SELECT) trên các bảng danh mục
GRANT SELECT ON KHOA TO KHOA;
GRANT SELECT ON LOP TO KHOA;
GRANT SELECT ON SINHVIEN TO KHOA;
GRANT SELECT ON MONHOC TO KHOA;
GRANT SELECT ON GIANGVIEN TO KHOA;
GRANT SELECT ON LOPTINCHI TO KHOA;
-- Được nhập điểm: SELECT + UPDATE trên bảng DANGKY
GRANT SELECT, UPDATE ON DANGKY TO KHOA;
GO
-- KHÔNG ĐƯỢC: INSERT/UPDATE/DELETE trên KHOA, LOP, GIANGVIEN, SINHVIEN, LOPTINCHI, MONHOC

-- ===== SV (Sinh viên) - QUYỀN TỐI THIỂU =====
GRANT SELECT ON KHOA TO NHOM_SV;
GRANT SELECT ON LOP TO NHOM_SV;
GRANT SELECT ON SINHVIEN TO NHOM_SV;
GRANT SELECT ON MONHOC TO NHOM_SV;
GRANT SELECT ON GIANGVIEN TO NHOM_SV;
GRANT SELECT ON LOPTINCHI TO NHOM_SV;
-- Được đăng ký lớp tín chỉ: SELECT + INSERT + UPDATE trên DANGKY
GRANT SELECT, INSERT, UPDATE ON DANGKY TO NHOM_SV;
GO

-- =============================================
-- 6. CẬP NHẬT PASSWORD MẶC ĐỊNH CHO SINH VIÊN
-- =============================================
UPDATE SINHVIEN SET PASSWORD = '123456' WHERE PASSWORD IS NULL OR PASSWORD = '';
GO

-- ===== CẤP QUYỀN THỰC THI STORED PROCEDURES =====
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ThongTinDangNhap]') AND type in (N'P', N'PC'))
    GRANT EXECUTE ON [dbo].[sp_ThongTinDangNhap] TO PGV, KHOA, NHOM_SV;
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaoTaiKhoan]') AND type in (N'P', N'PC'))
    GRANT EXECUTE ON [dbo].[sp_TaoTaiKhoan] TO PGV;
GO

PRINT N'=== PHÂN QUYỀN SQL SERVER HOÀN TẤT ==='
PRINT N'Logins: pgv_admin, khoa_all, sv'
PRINT N'Roles: PGV (toàn quyền), KHOA (hạn chế read-only), NHOM_SV (tối thiểu)'
PRINT N'Tài khoản KHOA chung: khoa_all/123456 → xem tất cả, lọc theo khoa'
GO