-- Script khởi tạo Database và cấu trúc các bảng cho QLDSV_HTC (Đề 3)
-- Chạy script này trên SQL Server instance (localhost\SQLEXPRESS) bằng sa login trước khi chạy ứng dụng.

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'QLDSV_HTC')
BEGIN
    CREATE DATABASE QLDSV_HTC;
    PRINT N'Đã tạo mới Database QLDSV_HTC';
END
ELSE
BEGIN
    PRINT N'Database QLDSV_HTC đã tồn tại';
END
GO

USE QLDSV_HTC;
GO

-- ==========================================
-- Xóa bảng cũ nếu tồn tại theo thứ tự ràng buộc
-- ==========================================
IF OBJECT_ID('DANGKY', 'U') IS NOT NULL DROP TABLE DANGKY;
IF OBJECT_ID('LOPTINCHI', 'U') IS NOT NULL DROP TABLE LOPTINCHI;
IF OBJECT_ID('TaiKhoan', 'U') IS NOT NULL DROP TABLE TaiKhoan;
IF OBJECT_ID('SINHVIEN', 'U') IS NOT NULL DROP TABLE SINHVIEN;
IF OBJECT_ID('LOP', 'U') IS NOT NULL DROP TABLE LOP;
IF OBJECT_ID('GIANGVIEN', 'U') IS NOT NULL DROP TABLE GIANGVIEN;
IF OBJECT_ID('MONHOC', 'U') IS NOT NULL DROP TABLE MONHOC;
IF OBJECT_ID('KHOA', 'U') IS NOT NULL DROP TABLE KHOA;
GO

-- ==========================================
-- 1. Bảng KHOA
-- ==========================================
CREATE TABLE KHOA (
    MAKHOA nchar(10) NOT NULL,
    TENKHOA nvarchar(50) NOT NULL,
    CONSTRAINT PK_KHOA PRIMARY KEY (MAKHOA)
);
GO

-- ==========================================
-- 2. Bảng LOP
-- ==========================================
CREATE TABLE LOP (
    MALOP nchar(10) NOT NULL,
    TENLOP nvarchar(50) NOT NULL,
    KHOAHOC nchar(9) NOT NULL,
    MAKHOA nchar(10) NOT NULL,
    CONSTRAINT PK_LOP PRIMARY KEY (MALOP),
    CONSTRAINT FK_LOP_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);
GO

-- ==========================================
-- 3. Bảng SINHVIEN
-- ==========================================
CREATE TABLE SINHVIEN (
    MASV nchar(10) NOT NULL,
    HO nvarchar(50) NOT NULL,
    TEN nvarchar(10) NOT NULL,
    PHAI bit NOT NULL,
    DIACHI nvarchar(100) NULL,
    NGAYSINH date NULL,
    MALOP nchar(10) NOT NULL,
    DANGHIHOC bit NOT NULL DEFAULT 0,
    PASSWORD nvarchar(40) NULL,
    CONSTRAINT PK_SINHVIEN PRIMARY KEY (MASV),
    CONSTRAINT FK_SINHVIEN_LOP FOREIGN KEY (MALOP) REFERENCES LOP(MALOP)
);
GO

-- ==========================================
-- 4. Bảng MONHOC
-- ==========================================
CREATE TABLE MONHOC (
    MAMH nchar(10) NOT NULL,
    TENMH nvarchar(50) NOT NULL,
    SOTIET_LT int NOT NULL,
    SOTIET_TH int NOT NULL,
    CONSTRAINT PK_MONHOC PRIMARY KEY (MAMH)
);
GO

-- ==========================================
-- 5. Bảng GIANGVIEN
-- ==========================================
CREATE TABLE GIANGVIEN (
    MAGV nchar(10) NOT NULL,
    MAKHOA nchar(10) NOT NULL,
    HO nvarchar(50) NOT NULL,
    TEN nvarchar(10) NOT NULL,
    HOCVI nvarchar(20) NULL,
    HOCHAM nvarchar(20) NULL,
    CHUYENMON nvarchar(50) NULL,
    CONSTRAINT PK_GIANGVIEN PRIMARY KEY (MAGV),
    CONSTRAINT FK_GIANGVIEN_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);
GO

-- ==========================================
-- 6. Bảng LOPTINCHI
-- ==========================================
CREATE TABLE LOPTINCHI (
    MALTC int IDENTITY(1,1) NOT NULL,
    NIENKHOA nchar(9) NOT NULL,
    HOCKY int NOT NULL,
    MAMH nchar(10) NOT NULL,
    NHOM int NOT NULL,
    MAGV nchar(10) NOT NULL,
    MAKHOA nchar(10) NOT NULL,
    SOSVTOITHIEU int NOT NULL,
    HUYLOP bit NOT NULL DEFAULT 0,
    SOSVTOIDA int NOT NULL DEFAULT 40,
    NGAYBATDAU_DK date NULL,
    NGAYKETTHUC_DK date NULL,
    NGAYHETHAN_HUY date NULL,
    LYDOHUY nvarchar(200) NULL,
    CONSTRAINT PK_LOPTINCHI PRIMARY KEY (MALTC),
    CONSTRAINT FK_LOPTINCHI_MONHOC FOREIGN KEY (MAMH) REFERENCES MONHOC(MAMH),
    CONSTRAINT FK_LOPTINCHI_GIANGVIEN FOREIGN KEY (MAGV) REFERENCES GIANGVIEN(MAGV),
    CONSTRAINT FK_LOPTINCHI_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);
GO

-- ==========================================
-- 7. Bảng DANGKY
-- ==========================================
CREATE TABLE DANGKY (
    MALTC int NOT NULL,
    MASV nchar(10) NOT NULL,
    DIEM_CC int NULL,
    DIEM_GK float NULL,
    DIEM_CK float NULL,
    HUYDANGKY bit NULL DEFAULT 0,
    CONSTRAINT PK_DANGKY PRIMARY KEY (MALTC, MASV),
    CONSTRAINT FK_DANGKY_LOPTINCHI FOREIGN KEY (MALTC) REFERENCES LOPTINCHI(MALTC),
    CONSTRAINT FK_DANGKY_SINHVIEN FOREIGN KEY (MASV) REFERENCES SINHVIEN(MASV)
);
GO

-- ==========================================
-- 8. Bảng TaiKhoan
-- ==========================================
CREATE TABLE TaiKhoan (
    Login nvarchar(50) NOT NULL,
    MatKhau nvarchar(50) NOT NULL,
    NhomQuyen nvarchar(20) NOT NULL,
    MAGV nchar(10) NULL,
    MAKHOA nchar(10) NULL,
    TrangThai nvarchar(20) NOT NULL DEFAULT 'Active',
    NgayTao datetime NOT NULL DEFAULT GETDATE(),
    CONSTRAINT PK_TaiKhoan PRIMARY KEY (Login),
    CONSTRAINT FK_TaiKhoan_GIANGVIEN FOREIGN KEY (MAGV) REFERENCES GIANGVIEN(MAGV),
    CONSTRAINT FK_TaiKhoan_KHOA FOREIGN KEY (MAKHOA) REFERENCES KHOA(MAKHOA)
);
GO

PRINT N'Khởi tạo cấu trúc bảng thành công!';
