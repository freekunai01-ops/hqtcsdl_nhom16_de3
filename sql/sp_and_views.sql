-- ========================================================
-- QLDSV_HTC - STORED PROCEDURES FOR SECURITY AND LOGINS
-- ========================================================

USE QLDSV_HTC;
GO

-- 1. DROP EXISTING PROCEDURES IF THEY EXIST
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ThongTinDangNhap]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ThongTinDangNhap];
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_TaoTaiKhoan]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_TaoTaiKhoan];
GO

-- ========================================================
-- 2. CREATE PROCEDURE sp_ThongTinDangNhap
-- Returns USERNAME, HOTEN, ROLENAME of the input login
-- ========================================================
CREATE PROCEDURE [dbo].[sp_ThongTinDangNhap]
    @tenlogin NVARCHAR(50)
AS
BEGIN
    DECLARE @username NVARCHAR(50)
    DECLARE @hoten NVARCHAR(100)
    DECLARE @role NVARCHAR(50)

    -- A. Find the Database User (username) associated with the Server Login
    SELECT @username = name 
    FROM sys.database_principals 
    WHERE sid = SUSER_SID(@tenlogin)

    -- If no user is mapped (e.g. sa or system logins), fallback to login name
    IF @username IS NULL
    BEGIN
        IF @tenlogin = 'sa'
        BEGIN
            SELECT 'sa' AS USERNAME, N'Super Administrator' AS HOTEN, 'ADMIN' AS ROLENAME
            RETURN
        END
        SELECT @tenlogin AS USERNAME, @tenlogin AS HOTEN, 'GUEST' AS ROLENAME
        RETURN
    END

    -- B. Find Full Name (HOTEN)
    -- Case 1: Check if the user is a Lecturer (GIANGVIEN)
    IF EXISTS (SELECT 1 FROM GIANGVIEN WHERE MAGV = @username)
    BEGIN
        SELECT @hoten = HO + ' ' + TEN FROM GIANGVIEN WHERE MAGV = @username
    END
    -- Case 2: Check if the user is a Student (SINHVIEN)
    ELSE IF EXISTS (SELECT 1 FROM SINHVIEN WHERE MASV = @username)
    BEGIN
        SELECT @hoten = HO + ' ' + TEN FROM SINHVIEN WHERE MASV = @username
    END
    -- Case 3: Administrative / Generic Logins (pgv_admin, ql_khoa, khoa_cntt, khoa_vt, sv)
    ELSE
    BEGIN
        IF @username = 'pgv_admin'
            SET @hoten = N'Phòng Giáo Vụ'
        ELSE IF @username = 'ql_khoa'
            SET @hoten = N'Quản lý Khoa'
        ELSE IF @username = 'khoa_cntt'
            SET @hoten = N'Khoa Công Nghệ Thông Tin'
        ELSE IF @username = 'khoa_vt'
            SET @hoten = N'Khoa Viễn Thông'
        ELSE IF @username = 'sv'
            SET @hoten = N'Sinh Viên'
        ELSE
        BEGIN
            SET @hoten = @username
        END
    END

    -- C. Find Role Name (ROLENAME)
    -- Retrieve the database role the user belongs to
    SELECT TOP 1 @role = r.name 
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
    WHERE m.name = @username AND r.name IN ('PGV', 'KHOA', 'NHOM_SV')

    -- Fallback default roles if not explicitly set in database roles
    IF @role IS NULL
    BEGIN
        IF @username = 'pgv_admin' SET @role = 'PGV'
        ELSE IF @username IN ('ql_khoa', 'khoa_cntt', 'khoa_vt') SET @role = 'KHOA'
        ELSE IF @username = 'sv' SET @role = 'NHOM_SV'
        ELSE SET @role = 'GUEST'
    END

    -- Return the result set
    SELECT @username AS USERNAME, @hoten AS HOTEN, @role AS ROLENAME
END
GO

-- ========================================================
-- 3. CREATE PROCEDURE sp_TaoTaiKhoan
-- Creates a Server Login, Database User, and assigns to Role
-- ========================================================
CREATE PROCEDURE [dbo].[sp_TaoTaiKhoan]
    @LGNAME VARCHAR(50),
    @PASS VARCHAR(50),
    @USERNAME VARCHAR(50),
    @ROLE VARCHAR(50)
AS
BEGIN
    -- Check permissions: only PGV (or KHOA with permissions) can create accounts.
    -- Prevent creating duplicate logins
    IF EXISTS(SELECT * FROM sys.server_principals WHERE name = @LGNAME)
    BEGIN
        RAISERROR('Tên đăng nhập (Login name) đã tồn tại trên server!', 16, 1)
        RETURN 1
    END

    -- Prevent creating duplicate users for same lecturer
    IF EXISTS(SELECT * FROM sys.database_principals WHERE name = @USERNAME)
    BEGIN
        RAISERROR('Giảng viên/Username này đã được liên kết với một tài khoản khác!', 16, 2)
        RETURN 2
    END

    -- Ensure transaction safety
    BEGIN TRY
        BEGIN TRANSACTION;

        -- A. Create SQL Server Login
        DECLARE @sql NVARCHAR(MAX)
        SET @sql = 'CREATE LOGIN ' + QUOTENAME(@LGNAME) + ' WITH PASSWORD = ''' + REPLACE(@PASS, '''', '''''') + ''', DEFAULT_DATABASE = QLDSV_HTC, CHECK_POLICY = OFF'
        EXEC (@sql)

        -- B. Create Database User for that login
        SET @sql = 'CREATE USER ' + QUOTENAME(@USERNAME) + ' FOR LOGIN ' + QUOTENAME(@LGNAME)
        EXEC (@sql)

        -- C. Assign User to Role
        SET @sql = 'ALTER ROLE ' + QUOTENAME(@ROLE) + ' ADD MEMBER ' + QUOTENAME(@USERNAME)
        EXEC (@sql)

        COMMIT TRANSACTION;
        RETURN 0
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @errorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @errorSeverity INT = ERROR_SEVERITY()
        DECLARE @errorState INT = ERROR_STATE()

        RAISERROR(@errorMessage, @errorSeverity, @errorState)
        RETURN 3
    END CATCH
END
GO

IF OBJECT_ID('sp_SuaTaiKhoan', 'P') IS NOT NULL DROP PROCEDURE sp_SuaTaiKhoan;
GO
IF OBJECT_ID('sp_DanhSachTaiKhoan', 'P') IS NOT NULL DROP PROCEDURE sp_DanhSachTaiKhoan;
GO
CREATE PROCEDURE sp_DanhSachTaiKhoan
AS
BEGIN
    SELECT 
        COALESCE(sp.name, dp.name) AS Login,
        CASE r.name WHEN 'NHOM_SV' THEN 'SV' ELSE r.name END AS NhomQuyen,
        COALESCE(g.HO + ' ' + g.TEN, 
                 (SELECT HO + ' ' + TEN FROM SINHVIEN WHERE MASV = dp.name),
                 CASE COALESCE(sp.name, dp.name)
                      WHEN 'pgv_admin' THEN N'Phòng Giáo Vụ'
                      WHEN 'admin' THEN N'Quản trị PGV'
                      WHEN 'khoa_all'  THEN N'Quản lý Khoa (tất cả)'
                      WHEN 'sv'        THEN N'Sinh viên (chung)'
                      ELSE COALESCE(sp.name, dp.name)
                 END) AS HOTEN,
        g.MAGV,
        COALESCE(g.MAKHOA, (SELECT L.MAKHOA FROM SINHVIEN S JOIN LOP L ON S.MALOP = L.MALOP WHERE S.MASV = dp.name)) AS MAKHOA,
        CASE sp.is_disabled WHEN 1 THEN 'Locked' ELSE 'Active' END AS TrangThai,
        CASE 
             WHEN g.MAGV IS NOT NULL THEN N'GV - ' + g.HO + ' ' + g.TEN 
             WHEN EXISTS (SELECT 1 FROM SINHVIEN WHERE MASV = dp.name) THEN N'SV - ' + (SELECT HO + ' ' + TEN FROM SINHVIEN WHERE MASV = dp.name)
             ELSE N'Hệ thống' 
        END AS DOITUONG
    FROM sys.database_principals dp
    LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
    JOIN sys.database_role_members drm ON dp.principal_id = drm.member_principal_id
    JOIN sys.database_principals r     ON drm.role_principal_id = r.principal_id
    LEFT JOIN GIANGVIEN g ON dp.name = g.MAGV
    WHERE dp.type IN ('S','U')
      AND dp.name NOT LIKE '##%'
      AND r.name IN ('PGV','KHOA','NHOM_SV')
    ORDER BY r.name, dp.name;
END
GO

-- Grant execute permissions to roles
GRANT EXECUTE ON [dbo].[sp_ThongTinDangNhap] TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON [dbo].[sp_TaoTaiKhoan] TO PGV;
GRANT EXECUTE ON [dbo].[sp_DanhSachTaiKhoan] TO PGV;
GO

PRINT N'=== PROCEDURES CREATED SUCCESSFULLY ===';
GO

-- ========================================================
-- 4. TRIGGER KIỂM TRA ĐIỂM
-- ========================================================
-- Trigger kiểm tra điểm hợp lệ
IF OBJECT_ID('trg_KiemTraDiem', 'TR') IS NOT NULL DROP TRIGGER trg_KiemTraDiem;
GO
CREATE TRIGGER trg_KiemTraDiem ON DANGKY
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE (DIEM_CC IS NOT NULL AND (DIEM_CC < 0 OR DIEM_CC > 10))
           OR (DIEM_GK IS NOT NULL AND (DIEM_GK < 0 OR DIEM_GK > 10))
           OR (DIEM_CK IS NOT NULL AND (DIEM_CK < 0 OR DIEM_CK > 10))
    )
    BEGIN
        ROLLBACK
        RAISERROR(N'Điểm phải từ 0 đến 10!', 16, 1)
    END
END
GO

-- ========================================================
-- 5. FUNCTIONS TÍNH ĐIỂM VÀ XẾP LOẠI
-- ========================================================
IF OBJECT_ID('fn_DiemHetMon', 'FN') IS NOT NULL DROP FUNCTION fn_DiemHetMon;
GO
CREATE FUNCTION fn_DiemHetMon(@CC int, @GK float, @CK float)
RETURNS float
AS
BEGIN
    RETURN ISNULL(@CC,0)*0.1 + ISNULL(@GK,0)*0.3 + ISNULL(@CK,0)*0.6
END
GO

IF OBJECT_ID('fn_XepLoai', 'FN') IS NOT NULL DROP FUNCTION fn_XepLoai;
GO
CREATE FUNCTION fn_XepLoai(@Diem float)
RETURNS nvarchar(20)
AS
BEGIN
    RETURN CASE
        WHEN @Diem >= 8.5 THEN N'Giỏi'
        WHEN @Diem >= 7.0 THEN N'Khá'
        WHEN @Diem >= 5.0 THEN N'Trung bình'
        ELSE N'Yếu'
    END
END
GO

GRANT EXECUTE ON fn_DiemHetMon TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON fn_XepLoai TO PGV, KHOA, NHOM_SV;
GO



-- ========================================================
-- 7. LOP CRUD STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_ThemLop', 'P') IS NOT NULL DROP PROCEDURE sp_ThemLop;
GO
CREATE PROCEDURE sp_ThemLop
    @MALOP NCHAR(10),
    @TENLOP NVARCHAR(50),
    @KHOAHOC NCHAR(9),
    @MAKHOA NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR(N'Mã lớp đã tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM LOP WHERE TENLOP = @TENLOP)
    BEGIN
        RAISERROR(N'Tên lớp đã tồn tại!', 16, 2);
        RETURN;
    END
    INSERT INTO LOP (MALOP, TENLOP, KHOAHOC, MAKHOA)
    VALUES (@MALOP, @TENLOP, @KHOAHOC, @MAKHOA);
END
GO

IF OBJECT_ID('sp_SuaLop', 'P') IS NOT NULL DROP PROCEDURE sp_SuaLop;
GO
CREATE PROCEDURE sp_SuaLop
    @MALOP NCHAR(10),
    @TENLOP NVARCHAR(50),
    @KHOAHOC NCHAR(9),
    @MAKHOA NCHAR(10)
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM LOP WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR(N'Mã lớp không tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM LOP WHERE TENLOP = @TENLOP AND MALOP <> @MALOP)
    BEGIN
        RAISERROR(N'Tên lớp đã tồn tại ở lớp khác!', 16, 2);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM SINHVIEN WHERE MALOP = @MALOP)
    BEGIN
        DECLARE @curKhoa NCHAR(10), @curKH NCHAR(9);
        SELECT @curKhoa = MAKHOA, @curKH = KHOAHOC FROM LOP WHERE MALOP = @MALOP;
        IF @curKhoa <> @MAKHOA
        BEGIN
            RAISERROR(N'Không được đổi khoa cho lớp đã có sinh viên!', 16, 3);
            RETURN;
        END
        IF @curKH <> @KHOAHOC
        BEGIN
            RAISERROR(N'Không được đổi khóa học cho lớp đã có sinh viên!', 16, 4);
            RETURN;
        END
    END
    UPDATE LOP
    SET TENLOP = @TENLOP, KHOAHOC = @KHOAHOC, MAKHOA = @MAKHOA
    WHERE MALOP = @MALOP;
END
GO

IF OBJECT_ID('sp_XoaLop', 'P') IS NOT NULL DROP PROCEDURE sp_XoaLop;
GO
CREATE PROCEDURE sp_XoaLop
    @MALOP NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM SINHVIEN WHERE MALOP = @MALOP)
    BEGIN
        RAISERROR(N'Không thể xóa lớp vì đã có sinh viên!', 16, 1);
        RETURN;
    END
    DELETE FROM LOP WHERE MALOP = @MALOP;
END
GO

-- ========================================================
-- 8. SINHVIEN CRUD STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_ThemSinhVien', 'P') IS NOT NULL DROP PROCEDURE sp_ThemSinhVien;
GO
CREATE PROCEDURE sp_ThemSinhVien
    @MASV NCHAR(10),
    @HO NVARCHAR(50),
    @TEN NVARCHAR(10),
    @PHAI BIT,
    @DIACHI NVARCHAR(100),
    @NGAYSINH DATE,
    @MALOP NCHAR(10),
    @DANGHIHOC BIT,
    @PASSWORD NVARCHAR(40)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM SINHVIEN WHERE MASV = @MASV)
    BEGIN
        RAISERROR(N'Mã sinh viên đã tồn tại!', 16, 1);
        RETURN;
    END
    INSERT INTO SINHVIEN (MASV, HO, TEN, PHAI, DIACHI, NGAYSINH, MALOP, DANGHIHOC, PASSWORD)
    VALUES (@MASV, @HO, @TEN, @PHAI, @DIACHI, @NGAYSINH, @MALOP, @DANGHIHOC, @PASSWORD);
END
GO

IF OBJECT_ID('sp_SuaSinhVien', 'P') IS NOT NULL DROP PROCEDURE sp_SuaSinhVien;
GO
CREATE PROCEDURE sp_SuaSinhVien
    @MASV NCHAR(10),
    @HO NVARCHAR(50),
    @TEN NVARCHAR(10),
    @PHAI BIT,
    @DIACHI NVARCHAR(100),
    @NGAYSINH DATE,
    @MALOP NCHAR(10),
    @DANGHIHOC BIT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM SINHVIEN WHERE MASV = @MASV)
    BEGIN
        RAISERROR(N'Mã sinh viên không tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM DANGKY WHERE MASV = @MASV)
    BEGIN
        DECLARE @curLop NCHAR(10);
        SELECT @curLop = MALOP FROM SINHVIEN WHERE MASV = @MASV;
        IF @curLop <> @MALOP
        BEGIN
            RAISERROR(N'Không thể chuyển lớp cho sinh viên đã đăng ký học!', 16, 2);
            RETURN;
        END
    END
    UPDATE SINHVIEN
    SET HO = @HO, TEN = @TEN, PHAI = @PHAI, DIACHI = @DIACHI, NGAYSINH = @NGAYSINH, MALOP = @MALOP, DANGHIHOC = @DANGHIHOC
    WHERE MASV = @MASV;
END
GO

IF OBJECT_ID('sp_XoaSinhVien', 'P') IS NOT NULL DROP PROCEDURE sp_XoaSinhVien;
GO
CREATE PROCEDURE sp_XoaSinhVien
    @MASV NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM DANGKY WHERE MASV = @MASV)
    BEGIN
        RAISERROR(N'Không thể xóa sinh viên đã đăng ký học!', 16, 1);
        RETURN;
    END
    DELETE FROM SINHVIEN WHERE MASV = @MASV;
END
GO

-- ========================================================
-- 8.5. GIANGVIEN CRUD STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_ThemGiangVien', 'P') IS NOT NULL DROP PROCEDURE sp_ThemGiangVien;
GO
CREATE PROCEDURE sp_ThemGiangVien
    @MAGV NCHAR(10),
    @HO NVARCHAR(50),
    @TEN NVARCHAR(10),
    @HOCVI NVARCHAR(20),
    @HOCHAM NVARCHAR(20),
    @CHUYENMON NVARCHAR(40),
    @MAKHOA NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM GIANGVIEN WHERE MAGV = @MAGV)
    BEGIN
        RAISERROR(N'Mã giảng viên đã tồn tại!', 16, 1);
        RETURN;
    END
    INSERT INTO GIANGVIEN (MAGV, HO, TEN, HOCVI, HOCHAM, CHUYENMON, MAKHOA)
    VALUES (@MAGV, @HO, @TEN, @HOCVI, @HOCHAM, @CHUYENMON, @MAKHOA);
END
GO

IF OBJECT_ID('sp_SuaGiangVien', 'P') IS NOT NULL DROP PROCEDURE sp_SuaGiangVien;
GO
CREATE PROCEDURE sp_SuaGiangVien
    @MAGV NCHAR(10),
    @HO NVARCHAR(50),
    @TEN NVARCHAR(10),
    @HOCVI NVARCHAR(20),
    @HOCHAM NVARCHAR(20),
    @CHUYENMON NVARCHAR(40),
    @MAKHOA NCHAR(10)
AS
BEGIN
    UPDATE GIANGVIEN
    SET HO = @HO, TEN = @TEN, HOCVI = @HOCVI, HOCHAM = @HOCHAM, CHUYENMON = @CHUYENMON, MAKHOA = @MAKHOA
    WHERE MAGV = @MAGV;
END
GO

IF OBJECT_ID('sp_XoaGiangVien', 'P') IS NOT NULL DROP PROCEDURE sp_XoaGiangVien;
GO
CREATE PROCEDURE sp_XoaGiangVien
    @MAGV NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM LOPTINCHI WHERE MAGV = @MAGV)
    BEGIN
        RAISERROR(N'Không thể xóa giảng viên đã được phân công lớp tín chỉ!', 16, 1);
        RETURN;
    END
    DELETE FROM GIANGVIEN WHERE MAGV = @MAGV;
END
GO

-- ========================================================
-- 9. MONHOC CRUD STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_ThemMonHoc', 'P') IS NOT NULL DROP PROCEDURE sp_ThemMonHoc;
GO
CREATE PROCEDURE sp_ThemMonHoc
    @MAMH NCHAR(10),
    @TENMH NVARCHAR(50),
    @SOTIET_LT INT,
    @SOTIET_TH INT
AS
BEGIN
    IF EXISTS(SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        RAISERROR(N'Mã môn học đã tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM MONHOC WHERE TENMH = @TENMH)
    BEGIN
        RAISERROR(N'Tên môn học đã tồn tại!', 16, 2);
        RETURN;
    END
    INSERT INTO MONHOC (MAMH, TENMH, SOTIET_LT, SOTIET_TH)
    VALUES (@MAMH, @TENMH, @SOTIET_LT, @SOTIET_TH);
END
GO

IF OBJECT_ID('sp_SuaMonHoc', 'P') IS NOT NULL DROP PROCEDURE sp_SuaMonHoc;
GO
CREATE PROCEDURE sp_SuaMonHoc
    @MAMH NCHAR(10),
    @TENMH NVARCHAR(50),
    @SOTIET_LT INT,
    @SOTIET_TH INT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM MONHOC WHERE MAMH = @MAMH)
    BEGIN
        RAISERROR(N'Mã môn học không tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM MONHOC WHERE TENMH = @TENMH AND MAMH <> @MAMH)
    BEGIN
        RAISERROR(N'Tên môn học đã tồn tại ở môn học khác!', 16, 2);
        RETURN;
    END
    UPDATE MONHOC
    SET TENMH = @TENMH, SOTIET_LT = @SOTIET_LT, SOTIET_TH = @SOTIET_TH
    WHERE MAMH = @MAMH;
END
GO

IF OBJECT_ID('sp_XoaMonHoc', 'P') IS NOT NULL DROP PROCEDURE sp_XoaMonHoc;
GO
CREATE PROCEDURE sp_XoaMonHoc
    @MAMH NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM LOPTINCHI WHERE MAMH = @MAMH)
    BEGIN
        RAISERROR(N'Không thể xóa môn học đã mở lớp tín chỉ!', 16, 1);
        RETURN;
    END
    DELETE FROM MONHOC WHERE MAMH = @MAMH;
END
GO

-- ========================================================
-- 10. LOPTINCHI CRUD STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_ThemLopTinChi', 'P') IS NOT NULL DROP PROCEDURE sp_ThemLopTinChi;
GO
CREATE PROCEDURE sp_ThemLopTinChi
    @NIENKHOA NCHAR(9),
    @HOCKY INT,
    @MAMH NCHAR(10),
    @NHOM INT,
    @MAGV NCHAR(10),
    @MAKHOA NCHAR(10),
    @SOSVTOITHIEU INT,
    @HUYLOP BIT
AS
BEGIN
    IF EXISTS(SELECT 1 FROM LOPTINCHI WHERE NIENKHOA = @NIENKHOA AND HOCKY = @HOCKY AND MAMH = @MAMH AND NHOM = @NHOM)
    BEGIN
        RAISERROR(N'Nhóm lớp tín chỉ này đã tồn tại!', 16, 1);
        RETURN;
    END
    INSERT INTO LOPTINCHI (NIENKHOA, HOCKY, MAMH, NHOM, MAGV, MAKHOA, SOSVTOITHIEU, HUYLOP)
    VALUES (@NIENKHOA, @HOCKY, @MAMH, @NHOM, @MAGV, @MAKHOA, @SOSVTOITHIEU, @HUYLOP);
END
GO

IF OBJECT_ID('sp_SuaLopTinChi', 'P') IS NOT NULL DROP PROCEDURE sp_SuaLopTinChi;
GO
CREATE PROCEDURE sp_SuaLopTinChi
    @MALTC INT,
    @NIENKHOA NCHAR(9),
    @HOCKY INT,
    @MAMH NCHAR(10),
    @NHOM INT,
    @MAGV NCHAR(10),
    @SOSVTOITHIEU INT,
    @HUYLOP BIT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM LOPTINCHI WHERE MALTC = @MALTC)
    BEGIN
        RAISERROR(N'Lớp tín chỉ không tồn tại!', 16, 1);
        RETURN;
    END
    IF EXISTS(SELECT 1 FROM LOPTINCHI WHERE NIENKHOA = @NIENKHOA AND HOCKY = @HOCKY AND MAMH = @MAMH AND NHOM = @NHOM AND MALTC <> @MALTC)
    BEGIN
        RAISERROR(N'Nhóm lớp tín chỉ này đã tồn tại ở mã lớp khác!', 16, 2);
        RETURN;
    END
    
    IF @HUYLOP = 1
    BEGIN
        DECLARE @soSVDK INT, @soSVMin INT;
        SELECT @soSVDK = COUNT(*) FROM DANGKY WHERE MALTC = @MALTC AND (HUYDANGKY = 0 OR HUYDANGKY IS NULL);
        SELECT @soSVMin = @SOSVTOITHIEU;
        
        IF @soSVDK >= @soSVMin
        BEGIN
            RAISERROR(N'Không thể hủy lớp tín chỉ vì số sinh viên đăng ký (%d) đã đạt hoặc vượt mức tối thiểu (%d)!', 16, 3, @soSVDK, @soSVMin);
            RETURN;
        END
    END

    UPDATE LOPTINCHI
    SET NIENKHOA = @NIENKHOA, HOCKY = @HOCKY, MAMH = @MAMH, NHOM = @NHOM, MAGV = @MAGV, SOSVTOITHIEU = @SOSVTOITHIEU, HUYLOP = @HUYLOP
    WHERE MALTC = @MALTC;
END
GO

IF OBJECT_ID('sp_XoaLopTinChi', 'P') IS NOT NULL DROP PROCEDURE sp_XoaLopTinChi;
GO
CREATE PROCEDURE sp_XoaLopTinChi
    @MALTC INT
AS
BEGIN
    IF EXISTS(SELECT 1 FROM DANGKY WHERE MALTC = @MALTC)
    BEGIN
        RAISERROR(N'Không thể xóa lớp tín chỉ đã có sinh viên đăng ký!', 16, 1);
        RETURN;
    END
    DELETE FROM LOPTINCHI WHERE MALTC = @MALTC;
END
GO

-- ========================================================
-- 11. DANGKY STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_DangKyLTC', 'P') IS NOT NULL DROP PROCEDURE sp_DangKyLTC;
GO
CREATE PROCEDURE sp_DangKyLTC
    @MALTC INT,
    @MASV NCHAR(10)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM DANGKY WHERE MALTC = @MALTC AND MASV = @MASV)
    BEGIN
        UPDATE DANGKY SET HUYDANGKY = 0 WHERE MALTC = @MALTC AND MASV = @MASV;
        RETURN;
    END

    INSERT INTO DANGKY (MALTC, MASV, HUYDANGKY)
    VALUES (@MALTC, @MASV, 0);
END
GO

IF OBJECT_ID('sp_HuyDangKyLTC', 'P') IS NOT NULL DROP PROCEDURE sp_HuyDangKyLTC;
GO
CREATE PROCEDURE sp_HuyDangKyLTC
    @MALTC INT,
    @MASV NCHAR(10)
AS
BEGIN
    UPDATE DANGKY
    SET HUYDANGKY = 1
    WHERE MALTC = @MALTC AND MASV = @MASV;
END
GO

-- ========================================================
-- 12. DIEM STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_GhiDiem', 'P') IS NOT NULL DROP PROCEDURE sp_GhiDiem;
GO
CREATE PROCEDURE sp_GhiDiem
    @MALTC INT,
    @MASV NCHAR(10),
    @DIEM_CC INT,
    @DIEM_GK FLOAT,
    @DIEM_CK FLOAT
AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM DANGKY WHERE MALTC = @MALTC AND MASV = @MASV)
    BEGIN
        RAISERROR(N'Sinh viên chưa đăng ký lớp tín chỉ này!', 16, 1);
        RETURN;
    END

    UPDATE DANGKY
    SET DIEM_CC = @DIEM_CC, DIEM_GK = @DIEM_GK, DIEM_CK = @DIEM_CK
    WHERE MALTC = @MALTC AND MASV = @MASV;
END
GO

-- ========================================================
-- 13. REPORT STORED PROCEDURES
-- ========================================================
IF OBJECT_ID('sp_InDSLTC', 'P') IS NOT NULL DROP PROCEDURE sp_InDSLTC;
GO
CREATE PROCEDURE sp_InDSLTC
    @NIENKHOA NCHAR(9),
    @HOCKY INT,
    @MAKHOA NCHAR(10)
AS
BEGIN
    SELECT MH.TENMH, LTC.NHOM, GV.HO + ' ' + GV.TEN AS HOTENGV, LTC.SOSVTOITHIEU,
           (SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK
    FROM LOPTINCHI LTC
    JOIN MONHOC MH ON LTC.MAMH=MH.MAMH
    JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV
    WHERE LTC.NIENKHOA = @NIENKHOA AND LTC.HOCKY = @HOCKY AND (@MAKHOA = 'ALL' OR LTC.MAKHOA = @MAKHOA) AND LTC.HUYLOP = 0
    ORDER BY MH.TENMH, LTC.NHOM;
END
GO

IF OBJECT_ID('sp_InDSSVLTC', 'P') IS NOT NULL DROP PROCEDURE sp_InDSSVLTC;
GO
CREATE PROCEDURE sp_InDSSVLTC
    @MALTC INT
AS
BEGIN
    SELECT SV.MASV, SV.HO, SV.TEN, SV.PHAI, SV.MALOP
    FROM DANGKY DK JOIN SINHVIEN SV ON DK.MASV=SV.MASV
    WHERE DK.MALTC = @MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
    ORDER BY SV.MASV;
END
GO

IF OBJECT_ID('sp_InBangDiemLTC', 'P') IS NOT NULL DROP PROCEDURE sp_InBangDiemLTC;
GO
CREATE PROCEDURE sp_InBangDiemLTC
    @MALTC INT
AS
BEGIN
    SELECT SV.MASV, SV.HO, SV.TEN, SV.MALOP, DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK,
           dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK) AS DIEM_HM
    FROM DANGKY DK JOIN SINHVIEN SV ON DK.MASV=SV.MASV
    WHERE DK.MALTC = @MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
    ORDER BY SV.MASV;
END
GO

IF OBJECT_ID('sp_InPhieuDiem', 'P') IS NOT NULL DROP PROCEDURE sp_InPhieuDiem;
GO
CREATE PROCEDURE sp_InPhieuDiem
    @MASV NCHAR(10),
    @NIENKHOA NCHAR(9) = NULL,
    @HOCKY INT = NULL
AS
BEGIN
    IF @NIENKHOA IS NOT NULL AND @HOCKY IS NOT NULL
    BEGIN
        SELECT MH.TENMH,
               MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM
        FROM DANGKY DK
        JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC
        JOIN MONHOC MH ON LTC.MAMH=MH.MAMH
        WHERE DK.MASV=@MASV AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
          AND DK.DIEM_CK IS NOT NULL
          AND LTC.NIENKHOA=@NIENKHOA AND LTC.HOCKY=@HOCKY
        GROUP BY MH.TENMH ORDER BY MH.TENMH;
    END
    ELSE
    BEGIN
        SELECT MH.TENMH,
               MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM
        FROM DANGKY DK
        JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC
        JOIN MONHOC MH ON LTC.MAMH=MH.MAMH
        WHERE DK.MASV=@MASV AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
          AND DK.DIEM_CK IS NOT NULL
        GROUP BY MH.TENMH ORDER BY MH.TENMH;
    END
END
GO

IF OBJECT_ID('sp_BangDiemTongKet', 'P') IS NOT NULL DROP PROCEDURE sp_BangDiemTongKet;
GO
CREATE PROCEDURE sp_BangDiemTongKet
    @MALOP NCHAR(10)
AS
BEGIN
    -- 1. Create temporary table to store student grades
    CREATE TABLE #DiemLop (
        MASV NCHAR(10),
        HOTEN NVARCHAR(100),
        MAMH NCHAR(10),
        DIEM FLOAT
    );

    -- 2. Populate temporary table
    INSERT INTO #DiemLop (MASV, HOTEN, MAMH, DIEM)
    SELECT SV.MASV, SV.HO + ' ' + SV.TEN AS HOTEN, LTC.MAMH,
           dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK) AS DIEM
    FROM SINHVIEN SV
    JOIN DANGKY DK ON SV.MASV = DK.MASV
    JOIN LOPTINCHI LTC ON DK.MALTC = LTC.MALTC
    WHERE SV.MALOP = @MALOP AND (DK.HUYDANGKY = 0 OR DK.HUYDANGKY IS NULL) AND DK.DIEM_CK IS NOT NULL;

    -- 3. Get distinct subjects
    DECLARE @columns NVARCHAR(MAX) = '';
    SELECT @columns = @columns + ',' + QUOTENAME(RTRIM(MAMH))
    FROM (SELECT DISTINCT MAMH FROM #DiemLop) AS MH
    ORDER BY MAMH;

    IF @columns = ''
    BEGIN
        SELECT MASV, HO + ' ' + TEN AS HOTEN
        FROM SINHVIEN WHERE MALOP = @MALOP ORDER BY MASV;
        DROP TABLE #DiemLop;
        RETURN;
    END

    SET @columns = SUBSTRING(@columns, 2, LEN(@columns));

    -- 4. Dynamic pivot from temporary table
    DECLARE @sql NVARCHAR(MAX) = '';
    SET @sql = '
    SELECT MASV, HOTEN, ' + @columns + '
    FROM #DiemLop
    PIVOT (
        MAX(DIEM)
        FOR MAMH IN (' + @columns + ')
    ) AS PivotTable
    ORDER BY MASV;';

    EXEC sp_executesql @sql;

    -- 5. Drop temporary table
    DROP TABLE #DiemLop;
END
GO

IF OBJECT_ID('sp_GetMonHocCross', 'P') IS NOT NULL DROP PROCEDURE sp_GetMonHocCross;
GO
CREATE PROCEDURE sp_GetMonHocCross
    @MALOP NCHAR(10),
    @NIENKHOA NCHAR(9) = NULL,
    @HOCKY INT = NULL
AS
BEGIN
    SELECT DISTINCT MH.MAMH, MH.TENMH 
    FROM DANGKY DK
    JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC
    JOIN MONHOC MH ON LTC.MAMH=MH.MAMH
    JOIN SINHVIEN SV ON DK.MASV=SV.MASV
    WHERE SV.MALOP = @MALOP AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
      AND DK.DIEM_CK IS NOT NULL
      AND (@NIENKHOA IS NULL OR LTC.NIENKHOA = @NIENKHOA)
      AND (@HOCKY IS NULL OR LTC.HOCKY = @HOCKY)
    ORDER BY MH.TENMH;
END
GO

IF OBJECT_ID('sp_GetDiemDataCross', 'P') IS NOT NULL DROP PROCEDURE sp_GetDiemDataCross;
GO
CREATE PROCEDURE sp_GetDiemDataCross
    @MALOP NCHAR(10),
    @NIENKHOA NCHAR(9) = NULL,
    @HOCKY INT = NULL
AS
BEGIN
    SELECT DK.MASV, LTC.MAMH,
           MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM
    FROM DANGKY DK
    JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC
    JOIN SINHVIEN SV ON DK.MASV=SV.MASV
    WHERE SV.MALOP = @MALOP AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)
      AND DK.DIEM_CK IS NOT NULL
      AND (@NIENKHOA IS NULL OR LTC.NIENKHOA = @NIENKHOA)
      AND (@HOCKY IS NULL OR LTC.HOCKY = @HOCKY)
    GROUP BY DK.MASV, LTC.MAMH;
END
GO

-- Grant execute permissions to roles

GRANT EXECUTE ON sp_ThemLop TO PGV;
GRANT EXECUTE ON sp_SuaLop TO PGV;
GRANT EXECUTE ON sp_XoaLop TO PGV;
GRANT EXECUTE ON sp_ThemSinhVien TO PGV;
GRANT EXECUTE ON sp_SuaSinhVien TO PGV;
GRANT EXECUTE ON sp_XoaSinhVien TO PGV;
GRANT EXECUTE ON sp_ThemMonHoc TO PGV;
GRANT EXECUTE ON sp_SuaMonHoc TO PGV;
GRANT EXECUTE ON sp_XoaMonHoc TO PGV;
GRANT EXECUTE ON sp_ThemLopTinChi TO PGV;
GRANT EXECUTE ON sp_SuaLopTinChi TO PGV;
GRANT EXECUTE ON sp_XoaLopTinChi TO PGV;
GRANT EXECUTE ON sp_DangKyLTC TO PGV, NHOM_SV;
GRANT EXECUTE ON sp_HuyDangKyLTC TO PGV, NHOM_SV;
GRANT EXECUTE ON sp_GhiDiem TO PGV, KHOA;
GRANT EXECUTE ON sp_InDSLTC TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON sp_InDSSVLTC TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON sp_InBangDiemLTC TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON sp_InPhieuDiem TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON sp_BangDiemTongKet TO PGV, KHOA;
GRANT EXECUTE ON sp_GetMonHocCross TO PGV, KHOA;
GRANT EXECUTE ON sp_GetDiemDataCross TO PGV, KHOA;
GRANT EXECUTE ON sp_ThemGiangVien TO PGV;
GRANT EXECUTE ON sp_SuaGiangVien TO PGV;
GRANT EXECUTE ON sp_XoaGiangVien TO PGV;
GO

