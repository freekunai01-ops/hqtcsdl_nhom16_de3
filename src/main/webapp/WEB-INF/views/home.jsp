<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Trang chủ</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=2" rel="stylesheet">
</head>
<body>
<%@ include file="layout/header.jsp" %>
<div class="d-flex">
    <%@ include file="layout/sidebar.jsp" %>
    <main class="content-area">
        <div class="home-container">
            <h4 class="home-welcome">Chào mừng, ${sessionScope.displayName}</h4>
            <p class="home-welcome-sub">Bạn đang đăng nhập với quyền <strong>${sessionScope.nhomQuyen}</strong>. Chọn một chức năng bên dưới hoặc từ menu trái.</p>

            <div class="home-grid">
                <!-- 1. Danh mục Lớp -->
                <a href="${pageContext.request.contextPath}/lop" class="home-card color-blue">
                    <div class="home-card-header">
                        <i class="fas fa-layer-group"></i> Danh mục Lớp
                    </div>
                    <div class="home-card-body">
                        Thêm/Xóa/Ghi/Phục hồi - chỉ PGV
                    </div>
                </a>

                <!-- 2. Sinh viên -->
                <a href="${pageContext.request.contextPath}/sinhvien" class="home-card color-green">
                    <div class="home-card-header">
                        <i class="fas fa-user-friends"></i> Sinh viên
                    </div>
                    <div class="home-card-body">
                        SubForm 2 cấp Lớp - SV
                    </div>
                </a>

                <!-- 3. Môn học -->
                <a href="${pageContext.request.contextPath}/monhoc" class="home-card color-purple">
                    <div class="home-card-header">
                        <i class="fas fa-book"></i> Môn học
                    </div>
                    <div class="home-card-body">
                        Quản lý môn học - chỉ PGV
                    </div>
                </a>

                <!-- 4. Giảng viên -->
                <a href="${pageContext.request.contextPath}/giangvien" class="home-card color-teal">
                    <div class="home-card-header">
                        <i class="fas fa-chalkboard-teacher"></i> Giảng viên
                    </div>
                    <div class="home-card-body">
                        Thêm/Xóa/Sửa giảng viên - chỉ PGV
                    </div>
                </a>

                <!-- 5. Mở Lớp tín chỉ -->
                <a href="${pageContext.request.contextPath}/loptinchi" class="home-card color-pink">
                    <div class="home-card-header">
                        <i class="fas fa-chalkboard"></i> Mở Lớp tín chỉ
                    </div>
                    <div class="home-card-body">
                        PGV mở LTC theo niên khóa, học kỳ
                    </div>
                </a>

                <!-- 6. Đăng ký LTC -->
                <a href="${pageContext.request.contextPath}/dangky" class="home-card color-orange">
                    <div class="home-card-header">
                        <i class="fas fa-clipboard-list"></i> Đăng ký LTC
                    </div>
                    <div class="home-card-body">
                        PGV và SV đăng ký / hủy đăng ký
                    </div>
                </a>

                <!-- 7. Nhập điểm -->
                <a href="${pageContext.request.contextPath}/diem" class="home-card color-cyan">
                    <div class="home-card-header">
                        <i class="fas fa-pencil-alt"></i> Nhập điểm
                    </div>
                    <div class="home-card-body">
                        CC*0.1 + GK*0.3 + CK*0.6
                    </div>
                </a>

                <!-- 8. Báo cáo & In ấn -->
                <a href="${pageContext.request.contextPath}/baocao" class="home-card color-indigo">
                    <div class="home-card-header">
                        <i class="fas fa-file-alt"></i> Báo cáo & In ấn
                    </div>
                    <div class="home-card-body">
                        DSLTC, DSSV, Bảng điểm, Cross-Tab
                    </div>
                </a>

                <!-- 9. Quản trị tài khoản -->
                <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                    <a href="${pageContext.request.contextPath}/taikhoan" class="home-card color-darkblue">
                        <div class="home-card-header">
                            <i class="fas fa-users-cog"></i> Quản trị tài khoản
                        </div>
                        <div class="home-card-body">
                            PGV/KHOA/SV - phân quyền
                        </div>
                    </a>
                </c:if>
            </div>

            <!-- Footer columns -->
            <div class="home-desc-container">
                <div class="home-desc-card pgv">
                    <div class="home-desc-header">Phòng Giáo vụ (PGV)</div>
                    <div class="home-desc-body">
                        Toàn quyền: nhập Khoa, Lớp, SV, GV, Môn học, mở LTC, nhập điểm, in báo cáo, tạo tài khoản.
                    </div>
                </div>
                <div class="home-desc-card khoa">
                    <div class="home-desc-header">Khoa</div>
                    <div class="home-desc-body">
                        Xem toàn bộ danh mục (Lớp, SV, GV, Môn học, LTC). Nhập điểm môn thuộc khoa, in báo cáo. Không được thêm/xóa/sửa.
                    </div>
                </div>
                <div class="home-desc-card sv">
                    <div class="home-desc-header">Sinh viên (SV)</div>
                    <div class="home-desc-body">
                        Đăng ký lớp tín chỉ và xem phiếu điểm cá nhân. Tất cả SV dùng chung login 'sv'.
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div><%-- close app-window-container --%>
</body>
</html>
