<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Danh mục Môn học</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .stat-cards { display:flex; gap:10px; margin-bottom:12px; }
        .stat-card { flex:1; padding:10px 14px; border-radius:6px; border:1px solid #e2e8f0; background:#fff; }
        .stat-card .stat-label { font-size:11px; color:#64748b; margin-bottom:2px; }
        .stat-card .stat-value { font-size:22px; font-weight:bold; }
        .stat-card.blue .stat-value { color:#2563eb; }
        .stat-card.green .stat-value { color:#16a34a; }
        .stat-card.orange .stat-value { color:#d97706; }
        .stat-card.purple .stat-value { color:#7c3aed; }
        .filter-tabs { display:flex; gap:0; margin-bottom:8px; }
        .filter-tab { padding:5px 14px; font-size:12px; font-weight:bold; cursor:pointer; border:1px solid #cbd5e1; background:#f8fafc; color:#475569; transition:all 0.15s; }
        .filter-tab:first-child { border-radius:4px 0 0 4px; }
        .filter-tab:last-child { border-radius:0 4px 4px 0; }
        .filter-tab.active { background:#2563eb; color:#fff; border-color:#2563eb; }
        .filter-tab:hover:not(.active) { background:#e2e8f0; }
        .badge-status { display:inline-block; padding:2px 8px; border-radius:3px; font-size:10px; font-weight:bold; }
        .badge-damoltc { background:#dbeafe; color:#1d4ed8; border:1px solid #93c5fd; }
        .badge-chuamo { background:#f3f4f6; color:#6b7280; border:1px solid #d1d5db; }
        .filter-hint { font-size:11px; color:#94a3b8; margin-left:auto; display:flex; align-items:center; gap:4px; }
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
                <div class="title-left"><i class="fas fa-book"></i> Form: Danh mục Môn học</div>
                <div class="title-right">
                    <span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span>
                </div>
            </div>

            <div class="form-window-body">
                <div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
                    <i class="fas fa-info-circle"></i>
                    Môn học là danh mục nền để mở lớp tín chỉ và tính tín chỉ/GPA. Môn đã mở LTC <strong>không được xóa</strong> hoặc đổi mã môn; sửa số tiết cần cẩn nhắc vì ảnh hưởng tín chỉ quy đổi.
                </div>

                <!-- Stats -->
                <div class="stat-cards">
                    <div class="stat-card blue"><div class="stat-label">Tổng môn học</div><div class="stat-value">${totalMH}</div></div>
                    <div class="stat-card green"><div class="stat-label">Đã mở LTC</div><div class="stat-value">${daMoLTC}</div></div>
                    <div class="stat-card orange"><div class="stat-label">Tổng tiết LT</div><div class="stat-value">${totalLT}</div></div>
                    <div class="stat-card purple"><div class="stat-label">Tổng tiết TH</div><div class="stat-value">${totalTH}</div></div>
                </div>

                <form id="mhForm" action="${pageContext.request.contextPath}/monhoc/save" method="post">
                    <input type="hidden" id="mhAction" name="action" value="add">
                    <div class="form-split-container">
                        <!-- Left: Thông tin -->
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin môn học</div>
                            <div class="pane-grid">
                                <div class="pane-row">
                                    <span class="pane-label">Mã MH:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" id="mhPK" name="mamh" data-field="MAMH" class="pane-input" maxlength="10" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label">Tên môn học:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" name="tenmh" data-field="TENMH" class="pane-input" maxlength="50" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label">Số tiết LT:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" id="sotietLT" name="sotietLT" data-field="SOTIET_LT" class="pane-input" min="0" required oninput="tinhTongTiet()"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label">Số tiết TH:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" id="sotietTH" name="sotietTH" data-field="SOTIET_TH" class="pane-input" min="0" required oninput="tinhTongTiet()"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                            </div>
                            <!-- Info panel -->
                            <div class="info-panel" id="mhInfoPanel">
                                <div class="info-row"><span class="info-label">Tổng tiết:</span><span class="info-value" id="infoTongTiet">—</span></div>
                                <div class="info-row"><span class="info-label">Tín chỉ quy đổi:</span><span class="info-value" id="infoTinChi">—</span></div>
                                <div class="info-row"><span class="info-label">LTC đã mở:</span><span class="info-value" id="infoSoLTC">—</span></div>
                                <div class="info-row"><span class="info-label">Trạng thái:</span><span class="info-value" id="infoTrangThai">—</span></div>
                            </div>
                            <div style="margin-top:6px;padding:4px 8px;background:#f0fdf4;border:1px solid #bbf7d0;border-radius:3px;font-size:10px;color:#166534;">
                                <i class="fas fa-calculator"></i> Công thức: LT/15 + TH/30, làm tròn gần nhất.
                            </div>
                        </div>

                        <!-- Right: Danh sách -->
                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách môn học — tìm kiếm / sắp xếp / lọc sử dụng</div>
                            <div style="display:flex;align-items:center;margin-bottom:6px;">
                                <div class="filter-tabs">
                                    <div class="filter-tab active" onclick="filterMH('all',this)">Tất cả</div>
                                    <div class="filter-tab" onclick="filterMH('damoltc',this)">Đã mở LTC</div>
                                    <div class="filter-tab" onclick="filterMH('chuamo',this)">Chưa mở</div>
                                </div>
                                <div class="filter-hint"><i class="fas fa-info-circle"></i> Môn đã mở LTC: không xóa, không đổi mã</div>
                            </div>
                            <div class="table-search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="mhSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('mhTable','mhSearch')">
                            </div>
                            <div class="win-table-container">
                                <table id="mhTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MAMH" data-sort-col="0">Mã MH</th>
                                        <th data-sort-key="TENMH" data-sort-col="1">Tên môn học</th>
                                        <th data-sort-key="LT" data-sort-col="2">LT</th>
                                        <th data-sort-key="TH" data-sort-col="3">TH</th>
                                        <th data-sort-key="TONG" data-sort-col="4">Tổng</th>
                                        <th data-sort-key="TC" data-sort-col="5">TC</th>
                                        <th data-sort-key="SOLTC" data-sort-col="6">Số LTC</th>
                                        <th data-sort-key="TT" data-sort-col="7">Trạng thái</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dsmh}" var="mh">
                                            <tr data-mamh="${mh.MAMH}" data-soltc="${mh.SO_LTC}">
                                                <td data-col="MAMH">${mh.MAMH}</td>
                                                <td data-col="TENMH">${mh.TENMH}</td>
                                                <td data-col="SOTIET_LT">${mh.SOTIET_LT}</td>
                                                <td data-col="SOTIET_TH">${mh.SOTIET_TH}</td>
                                                <td style="font-weight:bold;">${mh.TONGTIET}</td>
                                                <td><c:choose><c:when test="${mh.TINCHI > 0}"><span style="color:#7c3aed;font-weight:bold;">${mh.TINCHI}</span></c:when><c:otherwise>0</c:otherwise></c:choose></td>
                                                <td style="text-align:center;"><c:choose><c:when test="${mh.SO_LTC > 0}"><span style="color:#2563eb;font-weight:bold;">${mh.SO_LTC}</span></c:when><c:otherwise><span style="color:#94a3b8">0</span></c:otherwise></c:choose></td>
                                                <td><c:choose><c:when test="${mh.SO_LTC > 0}"><span class="badge-status badge-damoltc">Đã mở LTC</span></c:when><c:otherwise><span class="badge-status badge-chuamo">Chưa mở</span></c:otherwise></c:choose></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="mhTableFilterCount" class="table-filter-count"></span>
                        </div>
                    </div>

                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemMH()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaMH()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="submit" class="win-form-btn btn-save"><i class="fas fa-save"></i> Ghi</button>
                            <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                        </c:if>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                    </div>
                </form>
            </div>

            <div class="form-window-status">
                <span>Tổng số môn: ${totalMH} | Đã mở LTC: ${daMoLTC} | Hiển thị: ${fn:length(dsmh)}</span>
                <span id="selectedMhStatus">Đã chọn: —</span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=3"></script>
<script>
function tinhTongTiet() {
    var lt = parseInt(document.getElementById('sotietLT').value) || 0;
    var th = parseInt(document.getElementById('sotietTH').value) || 0;
    var tong = lt + th;
    var tc = Math.round(lt / 15 + th / 30);
    if (tc < 1 && tong > 0) tc = 1;
    document.getElementById('infoTongTiet').textContent = tong;
    document.getElementById('infoTinChi').textContent = tc + ' TC';
}
document.addEventListener("DOMContentLoaded", function() {
    initTableSelection('mhTable', 'mh');
    var rows = document.querySelectorAll('#mhTable tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            var mamh = this.querySelector('[data-col="MAMH"]').textContent.trim();
            var soltc = this.getAttribute('data-soltc') || '0';
            document.getElementById('selectedMhStatus').textContent = 'Đã chọn: ' + mamh;
            document.getElementById('infoSoLTC').textContent = soltc;
            if (parseInt(soltc) > 0) {
                document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-damoltc">Đã mở LTC</span>';
            } else {
                document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-chuamo">Chưa mở</span>';
            }
            tinhTongTiet();
        });
    });
});
function btnThemMH() {
    btnThem('mh');
    document.getElementById('infoTongTiet').textContent = '0';
    document.getElementById('infoTinChi').textContent = '0 TC';
    document.getElementById('infoSoLTC').textContent = '0';
    document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-chuamo">Chưa mở</span>';
}
function btnXoaMH() {
    var pk = document.getElementById('mhPK');
    if (!pk || !pk.value.trim()) { alert('Chọn môn học cần xóa!'); return; }
    var row = document.querySelector('#mhTable tbody tr.selected');
    if (row) {
        var soltc = row.getAttribute('data-soltc');
        if (soltc && parseInt(soltc) > 0) {
            alert('Không thể xóa! Môn ' + pk.value + ' đã mở ' + soltc + ' lớp tín chỉ.');
            return;
        }
    }
    if (confirm('Xóa môn học ' + pk.value + '?')) {
        var f = document.createElement('form'); f.method='POST';
        f.action = '${pageContext.request.contextPath}/monhoc/delete';
        var i = document.createElement('input'); i.type='hidden'; i.name='mamh'; i.value=pk.value.trim();
        f.appendChild(i); document.body.appendChild(f); f.submit();
    }
}
function filterMH(type, el) {
    document.querySelectorAll('.filter-tab').forEach(function(t) { t.classList.remove('active'); });
    el.classList.add('active');
    document.querySelectorAll('#mhTable tbody tr').forEach(function(r) {
        var soltc = parseInt(r.getAttribute('data-soltc')) || 0;
        switch(type) {
            case 'damoltc': r.style.display = soltc > 0 ? '' : 'none'; break;
            case 'chuamo': r.style.display = soltc === 0 ? '' : 'none'; break;
            default: r.style.display = '';
        }
    });
}
</script>
</body>
</html>
