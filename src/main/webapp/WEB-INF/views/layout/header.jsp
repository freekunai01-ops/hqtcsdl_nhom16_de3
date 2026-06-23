<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="app-window-container">
    <!-- Window Title Bar -->
    <div class="app-window-titlebar">
        <div class="titlebar-left">
            <i class="fas fa-graduation-cap"></i>&nbsp;QLSV_HTC - Quản lý Sinh viên Hệ Tín chỉ
        </div>
        <div class="titlebar-right">
            <span class="window-btn green"></span>
            <span class="window-btn yellow"></span>
            <span class="window-btn red"></span>
        </div>
    </div>

    <!-- Window Menu Bar -->
    <div class="app-window-menubar">

        <%-- ===== FILE ===== --%>
        <div class="menu-item" id="menuFile">
            <span class="menu-label">File</span>
            <div class="menu-dropdown">
                <a href="${pageContext.request.contextPath}/home">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
                <div class="menu-dd-sep"></div>
                <a href="${pageContext.request.contextPath}/logout">
                    <i class="fas fa-sign-out-alt"></i> Đăng xuất
                </a>
            </div>
        </div>

        <%-- ===== NHẬP LIỆU ===== --%>
        <div class="menu-item" id="menuNhapLieu">
            <span class="menu-label">Nhập liệu</span>
            <div class="menu-dropdown">
                <c:choose>
                    <c:when test="${sessionScope.nhomQuyen == 'PGV' || sessionScope.nhomQuyen == 'KHOA'}">
                        <a href="${pageContext.request.contextPath}/lop">
                            <i class="fas fa-layer-group"></i> Danh mục Lớp
                        </a>
                        <a href="${pageContext.request.contextPath}/sinhvien">
                            <i class="fas fa-user-friends"></i> Sinh viên (SubForm)
                        </a>
                        <a href="${pageContext.request.contextPath}/monhoc">
                            <i class="fas fa-book"></i> Môn học
                        </a>
                        <a href="${pageContext.request.contextPath}/giangvien">
                            <i class="fas fa-chalkboard-teacher"></i> Giảng viên
                        </a>
                        <div class="menu-dd-sep"></div>
                        <a href="${pageContext.request.contextPath}/loptinchi">
                            <i class="fas fa-chalkboard"></i> Mở Lớp tín chỉ
                        </a>
                        <a href="${pageContext.request.contextPath}/dangky">
                            <i class="fas fa-clipboard-list"></i> Đăng ký LTC
                        </a>
                        <a href="${pageContext.request.contextPath}/diem">
                            <i class="fas fa-pencil-alt"></i> Nhập điểm
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Danh mục Lớp</span>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Sinh viên</span>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Môn học</span>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Giảng viên</span>
                        <div class="menu-dd-sep"></div>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Mở Lớp tín chỉ</span>
                        <a href="${pageContext.request.contextPath}/dangky">
                            <i class="fas fa-clipboard-list"></i> Đăng ký LTC
                        </a>
                        <span class="menu-dd-disabled"><i class="fas fa-lock"></i> Nhập điểm</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <%-- ===== BÁO CÁO ===== --%>
        <div class="menu-item" id="menuBaoCao">
            <span class="menu-label">Báo cáo</span>
            <div class="menu-dropdown">
                <a href="${pageContext.request.contextPath}/baocao">
                    <i class="fas fa-file-alt"></i> In ấn / Báo cáo
                </a>
            </div>
        </div>

        <%-- ===== QUẢN TRỊ (chỉ PGV) ===== --%>
        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
            <div class="menu-item" id="menuQuanTri">
                <span class="menu-label">Quản trị</span>
                <div class="menu-dropdown">
                    <a href="${pageContext.request.contextPath}/taikhoan">
                        <i class="fas fa-users-cog"></i> Tạo tài khoản
                    </a>
                </div>
            </div>
        </c:if>

        <%-- ===== TRỢ GIÚP ===== --%>
        <div class="menu-item" id="menuTroGiup">
            <span class="menu-label">Trợ giúp</span>
            <div class="menu-dropdown">
                <a href="#" onclick="return false;">
                    <i class="fas fa-info-circle"></i> Về chương trình
                </a>
                <div class="menu-dd-sep"></div>
                <div class="menu-dd-info">
                    <strong>QLSV_HTC v1.0</strong><br>
                    Nhóm 16 &mdash; Đề tài 3<br>
                    Hệ Quản Trị CSDL &mdash; PTIT HCM
                </div>
            </div>
        </div>

    </div>

    <!-- Window Sub Bar (Khoa selector & User Info) -->
    <div class="app-window-subbar">
        <div class="subbar-left">
            <label for="khoaSelector">Khoa đang xem:</label>
            <c:choose>
                <c:when test="${sessionScope.nhomQuyen == 'PGV' || sessionScope.nhomQuyen == 'KHOA'}">
                    <form id="changeKhoaForm" action="${pageContext.request.contextPath}/change-khoa" method="post" style="display:inline;">
                        <select name="maKhoa" id="khoaSelector" onchange="document.getElementById('changeKhoaForm').submit();">
                            <option value="ALL" ${sessionScope.maKhoa == 'ALL' ? 'selected' : ''}>Tất cả</option>
                            <c:forEach items="${sessionScope.khoaList}" var="k">
                                <option value="${k.MAKHOA}" ${sessionScope.maKhoa == k.MAKHOA ? 'selected' : ''}>${k.MAKHOA} - ${k.TENKHOA}</option>
                            </c:forEach>
                        </select>
                    </form>
                </c:when>
                <c:otherwise>
                    <select id="khoaSelector" disabled>
                        <option selected>${sessionScope.maKhoa}</option>
                    </select>
                </c:otherwise>
            </c:choose>
        </div>
        <div class="subbar-right">
            <span class="user-display">
                <i class="fas fa-user"></i>&nbsp;${sessionScope.displayName} (${sessionScope.nhomQuyen})
            </span>
            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
                <i class="fas fa-sign-out-alt"></i> Đăng xuất
            </a>
        </div>
    </div>
<%-- app-window-container stays open - closed by each page after </main> --%>
