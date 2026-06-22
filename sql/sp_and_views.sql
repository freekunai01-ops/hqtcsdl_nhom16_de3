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
            -- Fallback to look up TaiKhoan table
            DECLARE @magv VARCHAR(10)
            SELECT @magv = MAGV FROM TaiKhoan WHERE Login = @tenlogin
            IF @magv IS NOT NULL AND EXISTS (SELECT 1 FROM GIANGVIEN WHERE MAGV = @magv)
                SELECT @hoten = HO + ' ' + TEN FROM GIANGVIEN WHERE MAGV = @magv
            ELSE
                SET @hoten = @username
        END
    END

    -- C. Find Role Name (ROLENAME)
    -- Retrieve the database role the user belongs to
    SELECT @role = r.name 
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
    JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id
    WHERE m.name = @username

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

        -- D. Track in TaiKhoan table
        DECLARE @makhoa VARCHAR(10)
        SELECT @makhoa = MAKHOA FROM GIANGVIEN WHERE MAGV = @USERNAME
        IF @makhoa IS NULL
        BEGIN
            SELECT @makhoa = L.MAKHOA FROM SINHVIEN S JOIN LOP L ON S.MALOP = L.MALOP WHERE S.MASV = @USERNAME
        END
        
        -- Insert or Update TaiKhoan entry
        IF EXISTS (SELECT 1 FROM TaiKhoan WHERE Login = @LGNAME)
        BEGIN
            UPDATE TaiKhoan 
            SET MatKhau = @PASS, NhomQuyen = @ROLE, MAGV = @USERNAME, MAKHOA = @makhoa, TrangThai = 'Active'
            WHERE Login = @LGNAME
        END
        ELSE
        BEGIN
            INSERT INTO TaiKhoan (Login, MatKhau, NhomQuyen, MAGV, MAKHOA, TrangThai, NgayTao)
            VALUES (@LGNAME, @PASS, @ROLE, @USERNAME, @makhoa, 'Active', GETDATE())
        END

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

-- Grant execute permissions to roles
GRANT EXECUTE ON [dbo].[sp_ThongTinDangNhap] TO PGV, KHOA, NHOM_SV;
GRANT EXECUTE ON [dbo].[sp_TaoTaiKhoan] TO PGV;
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

