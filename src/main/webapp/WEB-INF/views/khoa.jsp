<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Danh mục Khoa</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .stat-cards { display:flex; gap:10px; margin-bottom:12px; }
        .stat-card { flex:1; padding:10px 14px; border-radius:6px; border:1px solid #e2e8f0; background:#fff; }
        .stat-card .stat-label { font-size:11px; color:#64748b; margin-bottom:2px; }
        .stat-card .stat-value { font-size:22px; font-weight:bold; }
        .stat-card.blue .stat-value { color:#2563eb; }
        .info-panel { margin-top:10px; padding:10px 14px; background:#f8fafc; border:1px solid #e2e8f0; border-radius:4px; font-size:12px; }
        .info-panel .info-row { display:flex; justify-content:space-between; margin-bottom:4px; }
        .info-panel .info-label { color:#64748b; }
        .info-panel .info-value { font-weight:bold; color:#1e293b; }
    </style>
</head>
<body>
<%@ include file="layout/header.jsp" %>
<div class="d-flex">
    <%@ include file="layout/sidebar.jsp" %>
    <main class="content-area">
        <c:if test="${not empty success}">
            <div style="background:#d1e7dd;color:#0f5132;border:1px solid #badbcc;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12.5px;">
                <i class="fas fa-check-circle"></i> ${success}
            </div>
        </c:if>
        <c:if test="${not empty error}">
            <div style="background:#f8d7da;color:#842029;border:1px solid #f5c2c7;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12.5px;">
                <i class="fas fa-exclamation-triangle"></i> <strong>LỖI:</strong> ${error}
            </div>
        </c:if>

        <div class="desktop-form-window">
            <div class="form-window-titlebar">
                <div class="title-left"><i class="fas fa-university"></i> Form: Danh mục Khoa</div>
                <div class="title-right">
                    <span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span>
                </div>
            </div>

            <div class="form-window-body">
                <div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
                    <i class="fas fa-info-circle"></i>
                    Khoa là đơn vị quản lý lớp hành chính, giảng viên và lớp tín chỉ.
                    Khoa đã có lớp hành chính hoặc giảng viên thì <strong>không được xóa</strong>.
                </div>

                <!-- Stats -->
                <div class="stat-cards">
                    <div class="stat-card blue"><div class="stat-label">Tổng số khoa</div><div class="stat-value">${totalKhoa}</div></div>
                </div>

                <form id="khoaForm" action="${pageContext.request.contextPath}/khoa/save" method="post">
                    <input type="hidden" id="khoaAction" name="action" value="add">
                    <div class="form-split-container">
                        <!-- Left: Thông tin -->
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin khoa</div>
                            <div class="pane-grid">
                                <div class="pane-row">
                                    <span class="pane-label">Mã khoa:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" id="khoaPK" name="makhoa" data-field="MAKHOA" class="pane-input" value="${not empty error ? failedMakhoa : ''}" maxlength="10" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label">Tên khoa:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" name="tenkhoa" data-field="TENKHOA" class="pane-input" value="${not empty error ? failedTenkhoa : ''}" maxlength="50" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                            </div>
                            <!-- Info panel -->
                            <div class="info-panel" id="khoaInfoPanel">
                                <div class="info-row"><span class="info-label">Số lớp hành chính:</span><span class="info-value" id="infoLopCount">—</span></div>
                                <div class="info-row"><span class="info-label">Số giảng viên:</span><span class="info-value" id="infoGvCount">—</span></div>
                            </div>
                        </div>

                        <!-- Right: Danh sách -->
                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách khoa</div>
                            <div class="table-search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="khoaSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('khoaTable','khoaSearch')">
                            </div>
                            <div class="win-table-container">
                                <table id="khoaTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MAKHOA" data-sort-col="0">Mã Khoa</th>
                                        <th data-sort-key="TENKHOA" data-sort-col="1">Tên Khoa</th>
                                        <th data-sort-key="LOP" data-sort-col="2">Số Lớp</th>
                                        <th data-sort-key="GV" data-sort-col="3">Số GV</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${khoaList}" var="k">
                                            <tr data-makhoa="${k.MAKHOA}" data-lop="${k.LOP_COUNT}" data-gv="${k.GV_COUNT}"
                                                class="${k.MAKHOA == selectedMakhoa ? 'selected' : ''}">
                                                <td data-col="MAKHOA">${k.MAKHOA}</td>
                                                <td data-col="TENKHOA">${k.TENKHOA}</td>
                                                <td>${k.LOP_COUNT}</td>
                                                <td>${k.GV_COUNT}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemKhoa()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaKhoa()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="submit" class="win-form-btn btn-save"><i class="fas fa-save"></i> Ghi</button>
                            <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                        </c:if>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                    </div>
                </form>
            </div>

            <div class="form-window-status">
                <span>Tổng số khoa: ${totalKhoa} | Hiển thị: ${fn:length(khoaList)}</span>
                <span id="selectedKhoaStatus">Đã chọn: —</span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    initTableSelection('khoaTable', 'khoa');
    var rows = document.querySelectorAll('#khoaTable tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            var makhoa = this.querySelector('[data-col="MAKHOA"]').textContent.trim();
            var lopCount = parseInt(this.getAttribute('data-lop') || '0');
            var gvCount = parseInt(this.getAttribute('data-gv') || '0');
            
            var pk = document.getElementById('khoaPK');
            if (pk) { pk.readOnly = true; pk.style.background = '#f1f5f9'; }
            document.getElementById('selectedKhoaStatus').textContent = 'Đã chọn: ' + makhoa;
            document.getElementById('infoLopCount').textContent = lopCount;
            document.getElementById('infoGvCount').textContent = gvCount;
        });
    });

    var activeMakhoa = '${selectedMakhoa}';
    if (activeMakhoa) {
        rows.forEach(function(row) {
            if (row.getAttribute('data-makhoa').trim() === activeMakhoa) {
                row.click();
                row.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        });
    }
});

function btnThemKhoa() {
    btnThem('khoa');
    var pk = document.getElementById('khoaPK');
    if (pk) { pk.readOnly = false; pk.style.background = ''; }
    document.getElementById('infoLopCount').textContent = '0';
    document.getElementById('infoGvCount').textContent = '0';
}

function btnXoaKhoa() {
    var pk = document.getElementById('khoaPK');
    if (!pk || !pk.value.trim()) { alert('Chọn khoa cần xóa!'); return; }
    var row = document.querySelector('#khoaTable tbody tr.selected');
    if (row) {
        var lopCount = parseInt(row.getAttribute('data-lop') || '0');
        var gvCount = parseInt(row.getAttribute('data-gv') || '0');
        if (lopCount > 0 || gvCount > 0) {
            alert('Không thể xóa khoa vì khoa đã có lớp hành chính hoặc giảng viên thuộc về!');
            return;
        }
    }
    if (confirm('Xóa khoa "' + pk.value + '"?\nHành động này không thể hoàn tác!')) {
        var nextMakhoa = '';
        if (row) {
            var nextRow = row.nextElementSibling;
            if (!nextRow) nextRow = row.previousElementSibling;
            if (nextRow) {
                var cell = nextRow.querySelector('[data-col="MAKHOA"]');
                if (cell) nextMakhoa = cell.textContent.trim();
            }
        }
        var f = document.createElement('form'); f.method='POST';
        f.action = '${pageContext.request.contextPath}/khoa/delete';
        var i = document.createElement('input'); i.type='hidden'; i.name='makhoa'; i.value=pk.value.trim(); f.appendChild(i);
        var i2 = document.createElement('input'); i2.type='hidden'; i2.name='nextMakhoa'; i2.value=nextMakhoa; f.appendChild(i2);
        document.body.appendChild(f); f.submit();
    }
}
</script>
</body>
</html>
