<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Quản trị tài khoản</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=4" rel="stylesheet">
    <style>
        /* Modern UI Style additions for Account Management */
        .alert-info-box {
            background-color: #eff6ff;
            border: 1px solid #bfdbfe;
            color: #1e3a8a;
            padding: 12px 16px;
            border-radius: 6px;
            font-size: 13px;
            line-height: 1.5;
            margin-bottom: 16px;
            display: flex;
            align-items: flex-start;
            gap: 10px;
        }
        .alert-info-box i {
            color: #2563eb;
            font-size: 16px;
            margin-top: 2px;
        }
        .stat-cards-container {
            display: flex;
            gap: 12px;
            margin-bottom: 16px;
        }
        .stat-card {
            flex: 1;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 12px 16px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            display: flex;
            flex-direction: column;
            justify-content: center;
        }
        .stat-card .label {
            font-size: 11px;
            color: #64748b;
            text-transform: uppercase;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .stat-card .value {
            font-size: 22px;
            font-weight: 700;
            color: #1e293b;
        }
        .stat-card.blue .value { color: #2563eb; }
        .stat-card.green .value { color: #16a34a; }
        .stat-card.orange .value { color: #ea580c; }
        .stat-card.purple .value { color: #9333ea; }

        /* Tri-pane Layout styling */
        .form-split-container {
            display: flex;
            gap: 16px;
            align-items: stretch;
            height: calc(100vh - 210px);
            min-height: 480px;
        }
        .form-pane {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 16px;
            display: flex;
            flex-direction: column;
            box-shadow: 0 1px 3px rgba(0,0,0,0.02);
        }
        .pane-header {
            font-size: 14px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 14px;
            padding-bottom: 8px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        
        /* Left Pane inputs */
        .pane-form-group {
            margin-bottom: 12px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .pane-form-group label {
            font-size: 12px;
            font-weight: 600;
            color: #475569;
        }
        .pane-form-control {
            width: 100%;
            padding: 6px 10px;
            font-size: 13px;
            border: 1px solid #cbd5e1;
            border-radius: 4px;
            background-color: #ffffff;
            color: #1e293b;
            outline: none;
            transition: border-color 0.15s;
        }
        .pane-form-control:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.15);
        }
        .pane-form-control[readonly], .pane-form-control:disabled {
            background-color: #f1f5f9;
            color: #64748b;
            cursor: not-allowed;
        }

        /* Middle Pane Privileges Preview */
        .preview-role-badge {
            display: inline-block;
            padding: 3px 8px;
            font-size: 11px;
            font-weight: 700;
            border-radius: 4px;
            text-transform: uppercase;
            margin-bottom: 12px;
        }
        .preview-role-badge.pgv { background-color: #dbeafe; color: #1e40af; }
        .preview-role-badge.khoa { background-color: #ffedd5; color: #9a3412; }
        .preview-role-badge.sv { background-color: #f3e8ff; color: #6b21a8; }

        .privilege-list {
            list-style: none;
            padding: 0;
            margin: 0 0 16px 0;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
        .privilege-item {
            font-size: 12.5px;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .privilege-item.allow { color: #1e293b; }
        .privilege-item.allow i { color: #16a34a; }
        .privilege-item.deny { color: #94a3b8; text-decoration: line-through; }
        .privilege-item.deny i { color: #ef4444; }

        .linked-info-block {
            margin-top: auto;
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            padding: 10px 12px;
            font-size: 12px;
        }
        .linked-info-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 4px;
        }
        .linked-info-row:last-child { margin-bottom: 0; }
        .linked-info-row span.label { color: #64748b; }
        .linked-info-row span.val { font-weight: 600; color: #334155; }

        /* Right Pane Filter tabs */
        .tab-filter-container {
            display: flex;
            border-bottom: 1px solid #e2e8f0;
            margin-bottom: 10px;
            gap: 4px;
        }
        .tab-filter-btn {
            padding: 6px 12px;
            font-size: 12.5px;
            font-weight: 600;
            color: #64748b;
            background: none;
            border: none;
            border-bottom: 2px solid transparent;
            cursor: pointer;
            outline: none;
            transition: all 0.15s;
        }
        .tab-filter-btn:hover {
            color: #1e293b;
        }
        .tab-filter-btn.active {
            color: #2563eb;
            border-bottom-color: #2563eb;
        }

        /* Status Badge */
        .status-badge {
            display: inline-block;
            padding: 2px 6px;
            font-size: 11px;
            font-weight: 600;
            border-radius: 4px;
            text-align: center;
        }
        .status-badge.active { background-color: #dcfce7; color: #166534; }
        .status-badge.locked { background-color: #fee2e2; color: #991b1b; }
    </style>
</head>
<body>
<%@ include file="layout/header.jsp" %>
<div class="d-flex">
    <%@ include file="layout/sidebar.jsp" %>
    <main class="content-area">
        <c:if test="${not empty success}">
            <div style="background:#d1e7dd; color:#0f5132; border:1px solid #badbcc; padding:8px 12px; border-radius:4px; margin-bottom:12px; font-size:12.5px;">
                <i class="fas fa-check-circle"></i> ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div style="background:#f8d7da; color:#842029; border:1px solid #f5c2c7; padding:8px 12px; border-radius:4px; margin-bottom:12px; font-size:12.5px;">
                <i class="fas fa-exclamation-triangle"></i> <strong>LỖI:</strong> ${error}
            </div>
        </c:if>

        <!-- Alert Bar -->
        <div class="alert-info-box">
            <i class="fas fa-info-circle"></i>
            <div>
                Chỉ có 3 role đăng nhập: <strong>PGV, KHOA, SV</strong>. Bảng Giảng viên là danh mục phân công giảng dạy; không tạo role GV riêng. Nếu cấp tài khoản cho một giảng viên/cán bộ, tài khoản đó được gán role KHOA hoặc PGV.
            </div>
        </div>

        <!-- Count Account Stats -->
        <c:set var="countPgv" value="0"/>
        <c:set var="countKhoa" value="0"/>
        <c:set var="countSv" value="0"/>
        <c:forEach items="${dsTaiKhoan}" var="tk">
            <c:if test="${tk.NhomQuyen == 'PGV'}"><c:set var="countPgv" value="${countPgv + 1}"/></c:if>
            <c:if test="${tk.NhomQuyen == 'KHOA'}"><c:set var="countKhoa" value="${countKhoa + 1}"/></c:if>
            <c:if test="${tk.NhomQuyen == 'SV'}"><c:set var="countSv" value="${countSv + 1}"/></c:if>
        </c:forEach>

        <!-- Stat Cards -->
        <div class="stat-cards-container">
            <div class="stat-card blue">
                <span class="label">Tổng tài khoản</span>
                <span class="value">${fn:length(dsTaiKhoan)}</span>
            </div>
            <div class="stat-card green">
                <span class="label">PGV</span>
                <span class="value">${countPgv}</span>
            </div>
            <div class="stat-card orange">
                <span class="label">KHOA</span>
                <span class="value">${countKhoa}</span>
            </div>
            <div class="stat-card purple">
                <span class="label">SV</span>
                <span class="value">${countSv}</span>
            </div>
        </div>

        <div class="desktop-form-window" style="margin-top: 0; box-shadow: none;">
            <!-- Form Titlebar -->
            <div class="form-window-titlebar">
                <div class="title-left">
                    <i class="fas fa-user-shield"></i> Form: Quản trị tài khoản
                </div>
                <div class="title-right">
                    <span class="window-btn green"></span>
                    <span class="window-btn yellow"></span>
                    <span class="window-btn red"></span>
                </div>
            </div>

            <!-- Form Body containing 3 Panes -->
            <div class="form-window-body" style="padding: 12px; background-color: #f1f5f9;">
                <form id="tkForm" action="${pageContext.request.contextPath}/taikhoan/save" method="post">
                    <input type="hidden" id="inputMaGV" name="magv">
                    <input type="hidden" id="inputMaSV" name="masv">
                    
                    <div class="form-split-container">
                        
                        <!-- Panel 1: Tạo / Cập nhật tài khoản -->
                        <div class="form-pane" style="flex: 1 1 32%; min-width: 290px;">
                            <div class="pane-header">
                                <i class="fas fa-user-plus"></i> Tạo / cập nhật tài khoản
                            </div>
                            
                            <div class="pane-form-group">
                                <label>Nhóm quyền:</label>
                                <select id="inputQuyen" name="nhomQuyen" class="pane-form-control" onchange="onQuyenChange()" required>
                                    <option value="PGV">PGV - Phòng Giáo vụ</option>
                                    <option value="KHOA">KHOA - Khoa</option>
                                    <option value="SV">SV - Sinh viên</option>
                                </select>
                            </div>

                            <div class="pane-form-group">
                                <label>Login:</label>
                                <input type="text" id="inputLogin" name="login" class="pane-form-control" placeholder="Tên đăng nhập" required>
                            </div>

                            <div class="pane-form-group">
                                <label>Password:</label>
                                <input type="password" id="inputMatKhau" name="matkhau" class="pane-form-control" placeholder="Để trống nếu không đổi">
                            </div>

                            <div class="pane-form-group">
                                <label>Confirm:</label>
                                <input type="password" id="inputConfirm" class="pane-form-control" placeholder="Nhập lại password">
                            </div>

                            <!-- Họ tên & Linking elements -->
                            <div class="pane-form-group" id="divHoTenPGV">
                                <label>Họ tên:</label>
                                <input type="text" id="inputHoTenPGV" name="hoten" class="pane-form-control" placeholder="Tên cán bộ PGV" value="Phòng Giáo vụ">
                            </div>

                            <div class="pane-form-group" id="divSelectGV" style="display: none;">
                                <label>Giảng viên đại diện:</label>
                                <select id="selectGv" class="pane-form-control" onchange="onGvChange()">
                                    <option value="">-- Chọn Giảng viên --</option>
                                    <c:forEach items="${dsgv}" var="gv">
                                        <option value="${gv.MAGV}" data-khoa="${gv.MAKHOA}">${gv.MAGV} - ${gv.HOTEN}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="pane-form-group" id="divSelectSV" style="display: none;">
                                <label>Sinh viên đại diện:</label>
                                <select id="selectSv" class="pane-form-control" onchange="onSvChange()">
                                    <option value="">-- Chọn Sinh viên --</option>
                                    <c:forEach items="${dssv}" var="sv">
                                        <option value="${sv.MASV}" data-khoa="${sv.MAKHOA}">${sv.MASV} - ${sv.HOTEN}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <!-- Khoa (for KHOA role only) -->
                            <div class="pane-form-group" id="divKhoa" style="display: none;">
                                <label>Khoa phụ trách:</label>
                                <select id="inputKhoa" name="maKhoa" class="pane-form-control" onchange="onKhoaChange()">
                                    <option value="">-- Chọn Khoa --</option>
                                    <c:forEach items="${khoaList}" var="k">
                                        <option value="${k.MAKHOA}">${k.TENKHOA}</option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="pane-form-group">
                                <label>Trạng thái:</label>
                                <select id="selectTrangThai" name="trangthai" class="pane-form-control">
                                    <option value="Active">Active</option>
                                    <option value="Locked">Locked</option>
                                </select>
                            </div>

                            <div style="margin-top: auto; padding-top: 10px; font-size: 11px; color: #64748b; border-top: 1px dashed #e2e8f0; display: flex; align-items: center; gap: 4px;">
                                <i class="fas fa-database"></i> Backend thật gọi: <code>sp_TaoTaiKhoan</code>
                            </div>
                        </div>

                        <!-- Panel 2: Preview quyền đăng nhập -->
                        <div class="form-pane" style="flex: 1 1 25%; min-width: 240px; background-color: #fafafa;">
                            <div class="pane-header">
                                <i class="fas fa-shield-alt"></i> Preview quyền đăng nhập
                            </div>

                            <div style="margin-bottom: 8px;">
                                <span id="previewRoleBadge" class="preview-role-badge pgv">Role: PGV</span>
                            </div>

                            <ul class="privilege-list" id="previewPrivilegeList">
                                <!-- Will be rendered dynamically via JS -->
                            </ul>

                            <div class="linked-info-block">
                                <div class="linked-info-row">
                                    <span class="label">Đối tượng gắn:</span>
                                    <span class="val" id="previewDoiTuong">Phòng Giáo vụ</span>
                                </div>
                                <div class="linked-info-row">
                                    <span class="label">Khoa:</span>
                                    <span class="val" id="previewKhoa">—</span>
                                </div>
                            </div>
                        </div>

                        <!-- Panel 3: Danh sách tài khoản -->
                        <div class="form-pane" style="flex: 1 1 43%; min-width: 380px;">
                            <div class="pane-header" style="margin-bottom: 6px; border-bottom: none; padding-bottom: 0;">
                                <i class="fas fa-users-cog"></i> Danh sách tài khoản
                            </div>

                            <!-- Tabs filters -->
                            <div class="tab-filter-container">
                                <button type="button" class="tab-filter-btn active" id="tabAll" onclick="setRoleFilter('ALL')">ALL</button>
                                <button type="button" class="tab-filter-btn" id="tabPgv" onclick="setRoleFilter('PGV')">PGV</button>
                                <button type="button" class="tab-filter-btn" id="tabKhoa" onclick="setRoleFilter('KHOA')">KHOA</button>
                                <button type="button" class="tab-filter-btn" id="tabSv" onclick="setRoleFilter('SV')">SV</button>
                            </div>

                            <!-- Search -->
                            <div class="table-search-box" style="margin-bottom: 10px; display: flex; align-items: center; border: 1px solid #cbd5e1; padding: 4px 10px; border-radius: 4px;">
                                <i class="fas fa-search" style="color: #64748b; margin-right: 6px;"></i>
                                <input type="text" id="tkSearch" placeholder="Tìm kiếm..." oninput="filterTableRows()" style="border:none; outline:none; font-size:12.5px; width:100%;">
                            </div>

                            <!-- Data Grid Table -->
                            <div class="win-table-container" style="flex: 1; overflow-y: auto; border: 1px solid #cbd5e1; border-radius: 4px;">
                                <table id="tkTable" class="win-table" style="width: 100%;">
                                    <thead>
                                        <tr>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">Login</th>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">Họ tên</th>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">Role</th>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">Đối tượng</th>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">Khoa</th>
                                            <th style="font-size: 11.5px; padding: 6px 8px;">TT</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${dsTaiKhoan}" var="tk">
                                            <tr onclick="selectTkRow(this)" style="cursor: pointer;"
                                                data-login="${tk.Login}" 
                                                data-magv="${tk.MAGV}" 
                                                data-quyen="${tk.NhomQuyen}" 
                                                data-makhoa="${tk.MAKHOA}" 
                                                data-hoten="${tk.HOTEN}" 
                                                data-mk="${tk.MatKhau}"
                                                data-doituong="${tk.DOITUONG}"
                                                data-trangthai="${not empty tk.TrangThai ? tk.TrangThai : 'Active'}">
                                                <td style="font-size: 12px; padding: 6px 8px;">${tk.Login}</td>
                                                <td style="font-size: 12px; padding: 6px 8px;">${tk.HOTEN}</td>
                                                <td style="font-size: 12px; padding: 6px 8px;">${tk.NhomQuyen}</td>
                                                <td style="font-size: 12px; padding: 6px 8px;">${tk.DOITUONG}</td>
                                                <td style="font-size: 12px; padding: 6px 8px;">${not empty tk.MAKHOA ? tk.MAKHOA : '—'}</td>
                                                <td style="font-size: 12px; padding: 6px 8px; text-align: center;">
                                                    <span class="status-badge ${fn:toLowerCase(tk.TrangThai == 'Locked' ? 'locked' : 'active')}">
                                                        ${tk.TrangThai == 'Locked' ? 'Locked' : 'Active'}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="tkTableFilterCount" class="table-filter-count" style="font-size: 11px; color:#64748b; margin-top: 4px; display:block;"></span>
                        </div>

                    </div>

                    <!-- Form Buttons -->
                    <div class="form-buttons-row" style="margin-top: 12px; background: #e2e8f0; padding: 8px 12px; border-radius: 4px; display: flex; justify-content: flex-end; gap: 8px;">
                        <button type="button" class="win-form-btn" onclick="btnThemTk()" style="background:#ffffff; border:1px solid #cbd5e1; color:#334155;">
                            <i class="fas fa-plus"></i> Thêm
                        </button>
                        <button type="button" class="win-form-btn btn-delete" onclick="btnXoaTk()" style="background:#fee2e2; border:1px solid #fecaca; color:#991b1b;">
                            <i class="fas fa-trash"></i> Xóa
                        </button>
                        <button type="submit" class="win-form-btn btn-save" style="background:#2563eb; border:1px solid #2563eb; color:#ffffff;">
                            <i class="fas fa-save"></i> Ghi
                        </button>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')" style="background:#64748b; border:1px solid #64748b; color:#ffffff;">
                            <i class="fas fa-sign-out-alt"></i> Thoát
                        </button>
                    </div>
                </form>
            </div>

            <!-- Form Status bar -->
            <div class="form-window-status" style="background: #f1f5f9; padding: 6px 12px; border-top: 1px solid #e2e8f0; font-size: 11.5px; display:flex; justify-content:space-between; color:#475569;">
                <span>Tổng tài khoản: ${fn:length(dsTaiKhoan)} | Không có role GV riêng</span>
                <span id="selectedTkStatus">Đã chọn: Chưa chọn</span>
            </div>
        </div>
    </main>
</div>
</div><%-- close app-window-container --%>

<script>
    var currentRoleFilter = 'ALL';
    var currentSelectedRow = null;

    // Initialize checkboxes on page load
    window.addEventListener('load', function() {
        onQuyenChange();
        filterTableRows();
    });

    // Handle Nhóm quyền selector changes
    function onQuyenChange() {
        var quyen = document.getElementById('inputQuyen').value;
        
        // Hide all conditional wrappers
        document.getElementById('divHoTenPGV').style.display = 'none';
        document.getElementById('divSelectGV').style.display = 'none';
        document.getElementById('divSelectSV').style.display = 'none';
        document.getElementById('divKhoa').style.display = 'none';
        
        // Enable or read-only login input
        var loginInput = document.getElementById('inputLogin');
        loginInput.readOnly = false;
        loginInput.placeholder = 'Tên đăng nhập';

        if (quyen === 'PGV') {
            document.getElementById('divHoTenPGV').style.display = 'flex';
            document.getElementById('inputMaGV').value = '';
            document.getElementById('inputMaSV').value = '';
        } 
        else if (quyen === 'KHOA') {
            document.getElementById('divSelectGV').style.display = 'flex';
            document.getElementById('divKhoa').style.display = 'flex';
            document.getElementById('inputMaSV').value = '';
            onGvChange();
        } 
        else if (quyen === 'SV') {
            document.getElementById('divSelectSV').style.display = 'flex';
            document.getElementById('inputMaGV').value = '';
            loginInput.readOnly = true;
            loginInput.placeholder = 'Tự động lấy theo MASV';
            onSvChange();
        }
        
        updateQuyenPreview();
    }

    // Handle Lecturer select change
    function onGvChange() {
        var selectGv = document.getElementById('selectGv');
        var magv = selectGv.value;
        document.getElementById('inputMaGV').value = magv;

        // Auto select department matching selected lecturer
        if (magv) {
            var selectedOpt = selectGv.options[selectGv.selectedIndex];
            var dept = selectedOpt.getAttribute('data-khoa');
            if (dept) {
                document.getElementById('inputKhoa').value = dept;
            }
        }
        updateQuyenPreview();
    }

    // Handle Student select change
    function onSvChange() {
        var selectSv = document.getElementById('selectSv');
        var masv = selectSv.value;
        document.getElementById('inputMaSV').value = masv;
        
        // Set login name to MASV automatically
        var loginInput = document.getElementById('inputLogin');
        if (masv) {
            loginInput.value = masv;
        } else {
            loginInput.value = '';
        }
        
        updateQuyenPreview();
    }

    function onKhoaChange() {
        updateQuyenPreview();
    }

    // Update Privilege List and metadata Preview on the fly
    function updateQuyenPreview() {
        var quyen = document.getElementById('inputQuyen').value;
        var badge = document.getElementById('previewRoleBadge');
        var list = document.getElementById('previewPrivilegeList');
        
        badge.className = 'preview-role-badge ' + quyen.toLowerCase();
        badge.textContent = 'Role: ' + quyen;
        
        var listHtml = '';
        var doiTuongText = 'Phòng Giáo vụ';
        var khoaText = '—';
        
        if (quyen === 'PGV') {
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Toàn quyền danh mục</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Mở LTC, đăng ký/hủy LTC</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Nhập/sửa điểm</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> In báo cáo</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Tạo tài khoản</li>';
            
            var nameInput = document.getElementById('inputHoTenPGV').value;
            doiTuongText = nameInput ? nameInput : 'Phòng Giáo vụ';
        } 
        else if (quyen === 'KHOA') {
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Xem danh mục lớp/SV/MH/GV</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Xem lớp tín chỉ</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Xem báo cáo & In ấn</li>';
            listHtml += '<li class="privilege-item deny"><i class="fas fa-times-circle"></i> Thêm/Sửa/Xóa dữ liệu</li>';
            listHtml += '<li class="privilege-item deny"><i class="fas fa-times-circle"></i> Đăng ký thay sinh viên</li>';
            
            var selectGv = document.getElementById('selectGv');
            if (selectGv.value) {
                var selectedOpt = selectGv.options[selectGv.selectedIndex];
                doiTuongText = selectedOpt.text;
            } else {
                doiTuongText = 'Chưa chọn Giảng viên';
            }
            
            var inputKhoa = document.getElementById('inputKhoa');
            if (inputKhoa.value) {
                khoaText = inputKhoa.options[inputKhoa.selectedIndex].text;
            } else {
                khoaText = 'Chưa chọn Khoa';
            }
        } 
        else if (quyen === 'SV') {
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Đăng ký/hủy LTC (chính mình)</li>';
            listHtml += '<li class="privilege-item allow"><i class="fas fa-check-circle"></i> Xem/In phiếu điểm cá nhân</li>';
            listHtml += '<li class="privilege-item deny"><i class="fas fa-times-circle"></i> Xem sinh viên khác</li>';
            listHtml += '<li class="privilege-item deny"><i class="fas fa-times-circle"></i> Nhập điểm</li>';
            listHtml += '<li class="privilege-item deny"><i class="fas fa-times-circle"></i> Quản trị tài khoản</li>';
            
            var selectSv = document.getElementById('selectSv');
            if (selectSv.value) {
                var selectedOpt = selectSv.options[selectSv.selectedIndex];
                doiTuongText = selectedOpt.text;
                
                var dept = selectedOpt.getAttribute('data-khoa');
                khoaText = dept ? dept : '—';
            } else {
                doiTuongText = 'Chưa chọn Sinh viên';
            }
        }
        
        list.innerHTML = listHtml;
        document.getElementById('previewDoiTuong').textContent = doiTuongText;
        document.getElementById('previewKhoa').textContent = khoaText;
    }

    // Set Role tabs filter
    function setRoleFilter(role) {
        currentRoleFilter = role;
        
        // Update active class on tab buttons
        document.querySelectorAll('.tab-filter-btn').forEach(function(btn) {
            btn.classList.remove('active');
        });
        
        if (role === 'ALL') document.getElementById('tabAll').classList.add('active');
        else if (role === 'PGV') document.getElementById('tabPgv').classList.add('active');
        else if (role === 'KHOA') document.getElementById('tabKhoa').classList.add('active');
        else if (role === 'SV') document.getElementById('tabSv').classList.add('active');
        
        filterTableRows();
    }

    // Live search and tab filters
    function filterTableRows() {
        var query = document.getElementById('tkSearch').value.toLowerCase().trim();
        var rows = document.querySelectorAll('#tkTable tbody tr');
        var visibleCount = 0;
        
        rows.forEach(function(row) {
            var login = row.getAttribute('data-login').toLowerCase();
            var hoten = row.getAttribute('data-hoten').toLowerCase();
            var quyen = row.getAttribute('data-quyen');
            var doituong = row.getAttribute('data-doituong').toLowerCase();
            var makhoa = (row.getAttribute('data-makhoa') || '').toLowerCase();
            
            var matchesRole = (currentRoleFilter === 'ALL' || quyen === currentRoleFilter);
            var matchesQuery = (!query || login.indexOf(query) !== -1 || hoten.indexOf(query) !== -1 || doituong.indexOf(query) !== -1 || makhoa.indexOf(query) !== -1);
            
            if (matchesRole && matchesQuery) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        document.getElementById('tkTableFilterCount').textContent = 'Hiển thị: ' + visibleCount + ' / ' + rows.length + ' tài khoản';
    }

    // Handle row selection
    function selectTkRow(row) {
        var rows = document.querySelectorAll('#tkTable tbody tr');
        rows.forEach(function(r) { r.classList.remove('selected'); });
        row.classList.add('selected');
        currentSelectedRow = row;

        var login = row.getAttribute('data-login');
        var magv = row.getAttribute('data-magv');
        var quyen = row.getAttribute('data-quyen');
        var makhoa = row.getAttribute('data-makhoa');
        var hoten = row.getAttribute('data-hoten');
        var mk = row.getAttribute('data-mk');
        var trangthai = row.getAttribute('data-trangthai');

        document.getElementById('inputLogin').value = login;
        document.getElementById('inputMatKhau').value = mk;
        document.getElementById('inputConfirm').value = mk;
        document.getElementById('inputQuyen').value = quyen;
        document.getElementById('selectTrangThai').value = trangthai;
        document.getElementById('selectedTkStatus').textContent = 'Đã chọn: ' + login;

        // Reset and show/hide corresponding wrappers
        onQuyenChange();
        
        if (quyen === 'PGV') {
            document.getElementById('inputHoTenPGV').value = hoten;
        } 
        else if (quyen === 'KHOA') {
            document.getElementById('selectGv').value = magv || '';
            document.getElementById('inputMaGV').value = magv || '';
            document.getElementById('inputKhoa').value = makhoa || '';
        } 
        else if (quyen === 'SV') {
            document.getElementById('selectSv').value = magv || '';
            document.getElementById('inputMaSV').value = magv || '';
        }
        
        updateQuyenPreview();
    }

    function btnThemTk() {
        currentSelectedRow = null;
        document.getElementById('inputLogin').value = '';
        document.getElementById('inputMatKhau').value = '';
        document.getElementById('inputConfirm').value = '';
        document.getElementById('inputQuyen').value = 'PGV';
        document.getElementById('selectTrangThai').value = 'Active';
        
        document.getElementById('selectGv').value = '';
        document.getElementById('selectSv').value = '';
        document.getElementById('inputMaGV').value = '';
        document.getElementById('inputMaSV').value = '';
        document.getElementById('inputHoTenPGV').value = 'Phòng Giáo vụ';
        
        document.getElementById('selectedTkStatus').textContent = 'Đã chọn: Chưa chọn';

        var rows = document.querySelectorAll('#tkTable tbody tr');
        rows.forEach(function(r) { r.classList.remove('selected'); });
        
        onQuyenChange();
    }

    // Submit validations
    document.getElementById('tkForm').addEventListener('submit', function(e) {
        var login = document.getElementById('inputLogin').value.trim();
        var quyen = document.getElementById('inputQuyen').value;
        var pass = document.getElementById('inputMatKhau').value;
        var confirmPass = document.getElementById('inputConfirm').value;

        if (!login) {
            alert('Vui lòng nhập tên đăng nhập!');
            e.preventDefault();
            return;
        }

        // Validate password and match
        if (!currentSelectedRow && !pass) {
            alert('Vui lòng nhập mật khẩu cho tài khoản mới!');
            e.preventDefault();
            return;
        }

        if (pass !== confirmPass) {
            alert('Xác nhận mật khẩu không khớp!');
            e.preventDefault();
            return;
        }

        if (quyen === 'KHOA') {
            var magv = document.getElementById('inputMaGV').value;
            var khoa = document.getElementById('inputKhoa').value;
            if (!magv) {
                alert('Vui lòng chọn Giảng viên đại diện!');
                e.preventDefault();
                return;
            }
            if (!khoa) {
                alert('Vui lòng chọn Khoa phụ trách!');
                e.preventDefault();
                return;
            }
        } 
        else if (quyen === 'SV') {
            var masv = document.getElementById('inputMaSV').value;
            if (!masv) {
                alert('Vui lòng chọn Sinh viên đại diện!');
                e.preventDefault();
                return;
            }
        }
    });

    function btnThoat(url) {
        window.location.href = url;
    }
</script>
</body>
</html>
