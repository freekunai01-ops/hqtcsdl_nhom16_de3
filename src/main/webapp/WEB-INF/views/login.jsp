<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>QLSV_HTC - Đăng nhập hệ thống</title>
    <!-- Font Awesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        /* CSS reset & styling */
        html, body {
            margin: 0;
            padding: 0;
            width: 100%;
            height: 100%;
            box-sizing: border-box;
        }

        body {
            background: radial-gradient(circle at center, #1b4f93 0%, #0d2c5c 100%) !important;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: Arial, sans-serif;
            overflow: hidden;
        }

        /* Desktop Window Simulation */
        .desktop-window {
            width: 440px;
            background: #f0f0f0;
            border: 1px solid #7a7a7a;
            border-radius: 5px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        /* Title Bar */
        .title-bar {
            background: #1976d2;
            background: linear-gradient(to bottom, #2196f3, #1565c0);
            color: #ffffff;
            padding: 6px 12px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
            font-weight: bold;
            user-select: none;
            border-bottom: 1px solid #0d47a1;
        }

        .title-left {
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .title-right {
            display: flex;
            gap: 4px;
        }

        .win-btn-indicator {
            width: 12px;
            height: 12px;
            border-radius: 2px;
            display: inline-block;
        }

        .win-btn-indicator.green { background: #4caf50; border: 1px solid #388e3c; }
        .win-btn-indicator.yellow { background: #ffeb3b; border: 1px solid #fbc02d; }
        .win-btn-indicator.red { background: #f44336; border: 1px solid #d32f2f; }

        /* Window Body Content */
        .window-body {
            background: #ffffff;
            padding: 20px;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        /* Application Identity Header */
        .app-header {
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-bottom: 15px;
        }

        .app-logo {
            width: 50px;
            height: 50px;
            background: #1976d2;
            border-radius: 50%;
            display: flex;
            justify-content: center;
            align-items: center;
            box-shadow: 0 3px 6px rgba(25, 118, 210, 0.3);
            margin-bottom: 10px;
        }

        .app-logo i {
            color: #ffffff;
            font-size: 22px;
        }

        .app-title {
            font-size: 14px;
            font-weight: bold;
            color: #0d47a1;
            margin: 4px 0 2px 0;
            text-align: center;
            letter-spacing: 0.3px;
        }

        .app-subtitle {
            font-size: 11px;
            color: #666666;
            margin: 0;
            text-align: center;
        }

        /* Tab Sheet Control */
        .tab-control {
            display: flex;
            border-bottom: 1px solid #c0c0c0;
            margin-bottom: 20px;
            margin-top: 5px;
        }

        .tab-btn {
            background: #e1e1e1;
            border: 1px solid #c0c0c0;
            border-bottom: none;
            padding: 6px 16px;
            font-size: 12px;
            font-weight: bold;
            color: #333333;
            cursor: pointer;
            margin-right: 3px;
            outline: none;
            border-top-left-radius: 3px;
            border-top-right-radius: 3px;
            transition: background 0.15s;
        }

        .tab-btn:hover {
            background: #d5d5d5;
        }

        .tab-btn.active {
            background: #ffffff;
            border-color: #c0c0c0;
            border-bottom: 1px solid #ffffff;
            margin-bottom: -1px;
            color: #0d47a1;
            position: relative;
            z-index: 2;
        }

        /* Error Message Alert */
        .error-alert {
            background-color: #ffebee;
            border: 1px solid #ffcdd2;
            color: #c62828;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 12px;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Form Grid Input Fields */
        .form-grid {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 20px;
        }

        .grid-row {
            display: flex;
            align-items: center;
        }

        .grid-label {
            width: 80px;
            font-size: 12px;
            font-weight: bold;
            color: #333333;
            text-align: right;
            margin-right: 12px;
        }

        .grid-input-container {
            flex-grow: 1;
            position: relative;
            display: flex;
            align-items: center;
        }

        .grid-input-icon {
            position: absolute;
            left: 8px;
            color: #888888;
            font-size: 13px;
            width: 14px;
            text-align: center;
        }

        .grid-input {
            width: 100%;
            padding: 6px 8px 6px 28px;
            font-size: 13px;
            border: 1px solid #ababab;
            border-radius: 3px;
            background: #ffffff;
            outline: none;
            box-sizing: border-box;
        }

        .grid-input:focus {
            border-color: #1565c0;
            box-shadow: 0 0 3px rgba(21, 101, 192, 0.3);
        }

        .grid-select {
            width: 100%;
            padding: 5px;
            font-size: 13px;
            border: 1px solid #ababab;
            border-radius: 3px;
            background: #ffffff;
            outline: none;
            box-sizing: border-box;
        }

        .grid-select:focus {
            border-color: #1565c0;
        }

        /* Buttons Control Panel */
        .button-panel {
            display: flex;
            justify-content: center;
            gap: 8px;
            margin-top: 5px;
            margin-bottom: 15px;
        }

        .win-action-btn {
            background: #e1e1e1;
            background: linear-gradient(to bottom, #fcfcfc, #e1e1e1);
            border: 1px solid #707070;
            border-radius: 3px;
            padding: 5px 14px;
            font-size: 12px;
            font-weight: bold;
            color: #222222;
            cursor: pointer;
            outline: none;
            display: flex;
            align-items: center;
            gap: 5px;
            min-width: 80px;
            justify-content: center;
        }

        .win-action-btn:hover {
            background: #d8d8d8;
            background: linear-gradient(to bottom, #f2f2f2, #d8d8d8);
            border-color: #505050;
        }

        .win-action-btn:active {
            background: #c5c5c5;
            box-shadow: inset 0 1px 3px rgba(0,0,0,0.15);
        }

        /* Bottom Notice Text */
        .help-text {
            font-size: 10.5px;
            color: #777777;
            text-align: center;
            margin: 0;
        }

        /* Window Status Bar */
        .status-bar {
            background: #e0e0e0;
            border-top: 1px solid #b0b0b0;
            padding: 4px 12px;
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            color: #555555;
            user-select: none;
        }
    </style>
</head>
<body>

<div class="desktop-window">
    <!-- Title Bar -->
    <div class="title-bar">
        <div class="title-left">
            <i class="fa fa-graduation-cap"></i> QLSV_HTC - Đăng nhập hệ thống
        </div>
        <div class="title-right">
            <span class="win-btn-indicator green"></span>
            <span class="win-btn-indicator yellow"></span>
            <span class="win-btn-indicator red"></span>
        </div>
    </div>

    <!-- Window Body Area -->
    <div class="window-body">
        <!-- Circular logo icon & school subtitle -->
        <div class="app-header">
            <div class="app-logo">
                <i class="fa fa-graduation-cap"></i>
            </div>
            <h3 class="app-title">QUẢN LÝ SINH VIÊN HỆ TÍN CHỈ</h3>
            <p class="app-subtitle">Trường Đại học - Phòng Giáo vụ</p>
        </div>

        <!-- Tab selection headers -->
        <div class="tab-control">
            <button type="button" class="tab-btn active" id="btnTabGV" onclick="selectLoginTab('GV')">CÁN BỘ</button>
            <button type="button" class="tab-btn" id="btnTabSV" onclick="selectLoginTab('SV')">SINH VIÊN</button>
        </div>

        <!-- Action feedback: error messages -->
        <c:if test="${not empty error}">
            <div class="error-alert">
                <i class="fa fa-exclamation-triangle"></i>
                <span>${error}</span>
            </div>
        </c:if>

        <!-- Dynamic form -->
        <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post">
            <input type="hidden" name="loginType" id="loginType" value="GV">

            <div class="form-grid">
                <!-- Username (Login / Student code) row -->
                <div class="grid-row">
                    <label class="grid-label" id="labelUsername">Login cán bộ:</label>
                    <div class="grid-input-container">
                        <span class="grid-input-icon"><i class="fa fa-user" id="iconUsername"></i></span>
                        <input type="text" name="username" id="username" class="grid-input" placeholder="Nhập login" required autocomplete="off">
                    </div>
                </div>

                <!-- Password row -->
                <div class="grid-row">
                    <label class="grid-label" id="labelPassword">Mật khẩu:</label>
                    <div class="grid-input-container">
                        <span class="grid-input-icon"><i class="fa fa-lock"></i></span>
                        <input type="password" name="password" id="password" class="grid-input" placeholder="......" required style="padding-right: 32px;">
                        <span id="togglePassword" style="position: absolute; right: 10px; cursor: pointer; color: #888888; display: flex; align-items: center; z-index: 10; height: 100%;">
                            <i class="fa fa-eye-slash" id="togglePasswordIcon"></i>
                        </span>
                    </div>
                </div>

                <!-- Quyền hạn (role selection) row (only for lecturer) -->
                <div class="grid-row" id="rowRole">
                    <label class="grid-label">Quyền hạn:</label>
                    <div class="grid-input-container">
                        <select name="selectedRole" id="selectedRole" class="grid-select">
                            <option value="PGV">PGV - Phòng Giáo vụ</option>
                            <option value="KHOA">KHOA - Quản lý Khoa</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Panel buttons -->
            <div class="button-panel">
                <button type="submit" class="win-action-btn">
                    <i class="fa fa-sign-in-alt"></i> Đăng nhập
                </button>
                <button type="button" class="win-action-btn" onclick="clearFields()">
                    Hủy
                </button>
                <button type="button" class="win-action-btn" onclick="exitLogin()">
                    Thoát
                </button>
            </div>

            <!-- Help tip -->
            <p class="help-text" id="helpText">Tài khoản giảng viên/PGV cần được đăng ký trước</p>
        </form>
    </div>

    <!-- Status Bar -->
    <div class="status-bar">
        <span>Server: SQL Server (local)</span>
        <span>v1.0</span>
    </div>
</div>

<script>
    // Handles changing tabs between Giảng viên and Sinh viên
    function selectLoginTab(tabType, isInit) {
        var btnGV = document.getElementById("btnTabGV");
        var btnSV = document.getElementById("btnTabSV");
        var inputType = document.getElementById("loginType");
        var labelUser = document.getElementById("labelUsername");
        var inputUser = document.getElementById("username");
        var iconUser = document.getElementById("iconUsername");
        var rowRole = document.getElementById("rowRole");
        var selectRole = document.getElementById("selectedRole");
        var helpText = document.getElementById("helpText");

        if (!isInit) {
            // Clear input values only on tab click
            inputUser.value = "";
            document.getElementById("password").value = "";
        }

        if (tabType === 'GV') {
            btnGV.classList.add("active");
            btnSV.classList.remove("active");
            inputType.value = "GV";
            labelUser.textContent = "Login cán bộ:";
            inputUser.placeholder = "Nhập login";
            iconUser.className = "fa fa-user";
            rowRole.style.display = "flex";
            selectRole.disabled = false;
            helpText.textContent = "Tài khoản giảng viên/PGV cần được đăng ký trước";
        } else {
            btnSV.classList.add("active");
            btnGV.classList.remove("active");
            inputType.value = "SV";
            labelUser.textContent = "Mã sinh viên:";
            inputUser.placeholder = "Nhập mã sinh viên";
            iconUser.className = "fa fa-id-card";
            rowRole.style.display = "none";
            selectRole.disabled = true;
            helpText.textContent = "Tài khoản sinh viên đăng nhập bằng mã số sinh viên";
        }
    }

    // Clears username and password fields
    function clearFields() {
        document.getElementById("username").value = "";
        document.getElementById("password").value = "";
    }

    // Closes / redirects from the system
    function exitLogin() {
        if (confirm("Bạn có chắc chắn muốn thoát khỏi hệ thống đăng nhập?")) {
            window.location.href = "https://google.com";
        }
    }

    // Toggle Password Visibility
    document.getElementById("togglePassword").addEventListener("click", function() {
        var pwd = document.getElementById("password");
        var icon = document.getElementById("togglePasswordIcon");
        if (pwd.type === "password") {
            pwd.type = "text";
            icon.classList.remove("fa-eye-slash");
            icon.classList.add("fa-eye");
        } else {
            pwd.type = "password";
            icon.classList.remove("fa-eye");
            icon.classList.add("fa-eye-slash");
        }
    });

    // Initialize or restore state on load
    window.addEventListener("load", function() {
        var prevLoginType = '${loginType}';
        var prevUsername = '${username}';
        var prevSelectedRole = '${selectedRole}';

        if (prevLoginType === 'SV') {
            selectLoginTab('SV', true);
        } else {
            selectLoginTab('GV', true);
            if (prevSelectedRole) {
                document.getElementById("selectedRole").value = prevSelectedRole;
            }
        }

        if (prevUsername) {
            document.getElementById("username").value = prevUsername;
        }
    });
</script>

</body>
</html>
