<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<nav class="sidebar">
    <div>
        <div class="sidebar-header-title">CHỨC NĂNG</div>
        <ul class="nav">
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/home">
                    <i class="fas fa-home"></i> Trang chủ
                </a>
            </li>
            <c:if test="${sessionScope.nhomQuyen == 'PGV' || sessionScope.nhomQuyen == 'KHOA'}">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/khoa">
                        <i class="fas fa-university"></i> Danh mục Khoa
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/lop">
                        <i class="fas fa-layer-group"></i> Danh mục Lớp
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/sinhvien">
                        <i class="fas fa-user-friends"></i> Sinh viên (SubForm)
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/monhoc">
                        <i class="fas fa-book"></i> Môn học
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/giangvien">
                        <i class="fas fa-chalkboard-teacher"></i> Giảng viên
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/loptinchi">
                        <i class="fas fa-chalkboard"></i> Mở Lớp tín chỉ
                    </a>
                </li>
            </c:if>
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/dangky">
                    <i class="fas fa-clipboard-list"></i> Đăng ký LTC
                </a>
            </li>
            <c:if test="${sessionScope.nhomQuyen == 'PGV' || sessionScope.nhomQuyen == 'KHOA'}">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/diem">
                        <i class="fas fa-pencil-alt"></i> Nhập điểm
                    </a>
                </li>
            </c:if>
            <li class="nav-item">
                <a class="nav-link" href="${pageContext.request.contextPath}/baocao">
                    <i class="fas fa-file-alt"></i> In ấn / Báo cáo
                </a>
            </li>
            <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/taikhoan">
                        <i class="fas fa-users-cog"></i> Quản trị tài khoản
                    </a>
                </li>
            </c:if>
        </ul>
    </div>

    <!-- Connection Info at the bottom of sidebar -->
    <div class="sidebar-connection-info">
        <div><i class="fas fa-database"></i> CSDL: QLDSV_HTC</div>
        <div><i class="fas fa-server"></i> Server: SQL Server</div>
        <div>
            <i class="fas fa-shield-alt"></i> Quyền ${sessionScope.nhomQuyen}: 
            <c:choose>
                <c:when test="${sessionScope.nhomQuyen == 'PGV'}">Toàn quyền</c:when>
                <c:when test="${sessionScope.nhomQuyen == 'KHOA'}">Hạn chế</c:when>
                <c:otherwise>Cá nhân</c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>

<!-- Global bottom status bar, placed here so it injects into every view containing sidebar -->
<div class="global-status-bar">
    <span>Sẵn sàng | Connected: localhost\SQLEXPRESS</span>
    <span id="statusBarTime"></span>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        var currentPath = window.location.pathname;
        var links = document.querySelectorAll(".sidebar .nav-link");
        links.forEach(function(link) {
            var href = link.getAttribute("href");
            if (href && currentPath.indexOf(href) !== -1) {
                link.classList.add("active");
            }
        });

        // Setup clock for global status bar
        function updateClock() {
            var now = new Date();
            var hours = String(now.getHours()).padStart(2, '0');
            var mins = String(now.getMinutes()).padStart(2, '0');
            var secs = String(now.getSeconds()).padStart(2, '0');
            var day = now.getDate();
            var month = now.getMonth() + 1;
            var year = now.getFullYear();
            var timeStr = hours + ":" + mins + ":" + secs + " " + day + "/" + month + "/" + year;
            var clockEl = document.getElementById("statusBarTime");
            if (clockEl) {
                clockEl.textContent = timeStr;
            }
        }
        setInterval(updateClock, 1000);
        updateClock();
    });
</script>
