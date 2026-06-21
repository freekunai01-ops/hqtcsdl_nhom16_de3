<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Danh mục Giảng viên</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .stat-cards{display:flex;gap:10px;margin-bottom:12px}.stat-card{flex:1;padding:10px 14px;border-radius:6px;border:1px solid #e2e8f0;background:#fff}.stat-card .stat-label{font-size:11px;color:#64748b;margin-bottom:2px}.stat-card .stat-value{font-size:22px;font-weight:bold}.stat-card.blue .stat-value{color:#2563eb}.stat-card.green .stat-value{color:#16a34a}.stat-card.orange .stat-value{color:#d97706}.stat-card.gray .stat-value{color:#6b7280}
        .filter-tabs{display:flex;gap:0;margin-bottom:8px}.filter-tab{padding:5px 14px;font-size:12px;font-weight:bold;cursor:pointer;border:1px solid #cbd5e1;background:#f8fafc;color:#475569;transition:all .15s}.filter-tab:first-child{border-radius:4px 0 0 4px}.filter-tab:last-child{border-radius:0 4px 4px 0}.filter-tab.active{background:#2563eb;color:#fff;border-color:#2563eb}.filter-tab:hover:not(.active){background:#e2e8f0}
        .badge-status{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:bold}.badge-dangday{background:#dcfce7;color:#166534;border:1px solid #86efac}.badge-chuapc{background:#f3f4f6;color:#6b7280;border:1px solid #d1d5db}
        .filter-hint{font-size:11px;color:#94a3b8;margin-left:auto;display:flex;align-items:center;gap:4px}
        .info-panel{margin-top:10px;padding:10px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:4px;font-size:12px}.info-panel .info-row{display:flex;justify-content:space-between;margin-bottom:4px}.info-panel .info-label{color:#64748b}.info-panel .info-value{font-weight:bold;color:#1e293b}
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
                <div class="title-left"><i class="fas fa-chalkboard-teacher"></i> Form: Danh mục Giảng viên</div>
                <div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
            </div>
            <div class="form-window-body">
                <div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
                    <i class="fas fa-info-circle"></i>
                    Giảng viên dùng để phân công khi mở lớp tín chỉ. GV đã có phân công <strong>không được xóa</strong>, đổi mã hoặc đổi khoa; chỉ cập nhật thông tin học vị/học hàm/chuyên môn khi cần.
                </div>
                <div class="stat-cards">
                    <div class="stat-card blue"><div class="stat-label">Tổng GV</div><div class="stat-value">${totalGV}</div></div>
                    <div class="stat-card green"><div class="stat-label">Đang phụ trách LTC</div><div class="stat-value">${dangDay}</div></div>
                    <div class="stat-card orange"><div class="stat-label">GS/PGS/Tiến sĩ</div><div class="stat-value">${gsPgsTs}</div></div>
                    <div class="stat-card gray"><div class="stat-label">Chưa phân công</div><div class="stat-value">${chuaPC}</div></div>
                </div>

                <form id="gvForm" action="${pageContext.request.contextPath}/giangvien/save" method="post">
                    <input type="hidden" id="gvAction" name="action" value="add">
                    <div class="form-split-container">
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin giảng viên</div>
                            <div class="pane-grid">
                                <div class="pane-row"><span class="pane-label">Mã GV:</span><div class="pane-input-wrapper"><input type="text" id="gvPK" name="magv" data-field="MAGV" class="pane-input" maxlength="10" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Họ:</span><div class="pane-input-wrapper"><input type="text" name="ho" data-field="HO" class="pane-input" maxlength="50" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Tên:</span><div class="pane-input-wrapper"><input type="text" name="ten" data-field="TEN" class="pane-input" maxlength="10" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Học vị:</span><div class="pane-input-wrapper"><input type="text" name="hocvi" data-field="HOCVI" class="pane-input" maxlength="20" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Học hàm:</span><div class="pane-input-wrapper"><input type="text" name="hocham" data-field="HOCHAM" class="pane-input" maxlength="20" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Chuyên môn:</span><div class="pane-input-wrapper"><input type="text" name="chuyenmon" data-field="CHUYENMON" class="pane-input" maxlength="50" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Khoa:</span><div class="pane-input-wrapper"><c:choose><c:when test="${sessionScope.nhomQuyen == 'PGV'}"><select name="maKhoa" data-field="MAKHOA" class="pane-input" style="padding:4px 6px;" required><c:forEach items="${khoaList}" var="k"><option value="${k.MAKHOA}">${k.MAKHOA} - ${k.TENKHOA}</option></c:forEach></select></c:when><c:otherwise><input type="text" class="pane-input" value="${sessionScope.maKhoa}" disabled><input type="hidden" name="maKhoa" data-field="MAKHOA" value="${sessionScope.maKhoa}"></c:otherwise></c:choose></div></div>
                            </div>
                            <div class="info-panel" id="gvInfoPanel">
                                <div class="info-row"><span class="info-label">Số LTC phụ trách:</span><span class="info-value" id="infoSoLTC">—</span></div>
                                <div class="info-row"><span class="info-label">Cấp bậc:</span><span class="info-value" id="infoCapBac">—</span></div>
                                <div class="info-row"><span class="info-label">Trạng thái:</span><span class="info-value" id="infoTrangThai">—</span></div>
                            </div>
                        </div>

                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách giảng viên — tìm kiếm / sắp xếp / lọc phân công</div>
                            <div style="display:flex;align-items:center;margin-bottom:6px;">
                                <div class="filter-tabs">
                                    <div class="filter-tab active" onclick="filterGV('all',this)">Tất cả</div>
                                    <div class="filter-tab" onclick="filterGV('dangday',this)">Đang giảng dạy</div>
                                    <div class="filter-tab" onclick="filterGV('chuapc',this)">Chưa phân công</div>
                                    <div class="filter-tab" onclick="filterGV('gspgsts',this)">GS/PGS/TS</div>
                                </div>
                                <div class="filter-hint"><i class="fas fa-info-circle"></i> Đã phân công LTC: không xóa/đổi mã/đổi khoa</div>
                            </div>
                            <div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="gvSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('gvTable','gvSearch')"></div>
                            <div class="win-table-container">
                                <table id="gvTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MAGV" data-sort-col="0">Mã GV</th>
                                        <th data-sort-key="HOTEN" data-sort-col="1">Họ tên</th>
                                        <th data-sort-key="HOCVI" data-sort-col="2">Học vị</th>
                                        <th data-sort-key="HOCHAM" data-sort-col="3">Hàm</th>
                                        <th data-sort-key="CHUYENMON" data-sort-col="4">Chuyên môn</th>
                                        <th data-sort-key="MAKHOA" data-sort-col="5">Khoa</th>
                                        <th data-sort-key="SOLTC" data-sort-col="6">Số LTC</th>
                                        <th data-sort-key="TT" data-sort-col="7">Trạng thái</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dsgv}" var="g">
                                            <tr data-magv="${g.MAGV}" data-soltc="${g.SO_LTC}" data-hocvi="${g.HOCVI}" data-hocham="${g.HOCHAM}">
                                                <td data-col="MAGV">${g.MAGV}</td>
                                                <td>${g.HO} ${g.TEN}<span style="display:none" data-col="HO">${g.HO}</span><span style="display:none" data-col="TEN">${g.TEN}</span></td>
                                                <td data-col="HOCVI">${g.HOCVI}</td>
                                                <td data-col="HOCHAM">${g.HOCHAM}</td>
                                                <td data-col="CHUYENMON">${g.CHUYENMON}</td>
                                                <td data-col="MAKHOA">${g.MAKHOA}</td>
                                                <td style="text-align:center;font-weight:bold;"><c:choose><c:when test="${g.SO_LTC > 0}"><span style="color:#2563eb">${g.SO_LTC}</span></c:when><c:otherwise><span style="color:#94a3b8">0</span></c:otherwise></c:choose></td>
                                                <td><c:choose><c:when test="${g.SO_LTC > 0}"><span class="badge-status badge-dangday">Đang giảng dạy</span></c:when><c:otherwise><span class="badge-status badge-chuapc">Chưa phân công</span></c:otherwise></c:choose></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="gvTableFilterCount" class="table-filter-count"></span>
                        </div>
                    </div>
                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemGV()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaGV()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="submit" class="win-form-btn btn-save"><i class="fas fa-save"></i> Ghi</button>
                            <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                        </c:if>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                    </div>
                </form>
            </div>
            <div class="form-window-status">
                <span>Tổng số: ${totalGV} GV | Đang giảng dạy: ${dangDay} | Hiển thị: ${fn:length(dsgv)}</span>
                <span id="selectedGvStatus">Đã chọn: —</span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=3"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    initTableSelection('gvTable', 'gv');
    var rows = document.querySelectorAll('#gvTable tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            var magv = this.querySelector('[data-col="MAGV"]').textContent.trim();
            var ho = this.querySelector('[data-col="HO"]'); var ten = this.querySelector('[data-col="TEN"]');
            var name = (ho?ho.textContent.trim():'') + ' ' + (ten?ten.textContent.trim():'');
            var soltc = this.getAttribute('data-soltc') || '0';
            var hv = this.getAttribute('data-hocvi') || '';
            var hh = this.getAttribute('data-hocham') || '';
            document.getElementById('selectedGvStatus').textContent = 'Đã chọn: ' + magv + ' — ' + name;
            document.getElementById('infoSoLTC').textContent = soltc;
            var cap = hh ? hh : hv; document.getElementById('infoCapBac').textContent = cap || '—';
            if (parseInt(soltc) > 0) {
                document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-dangday">Đang giảng dạy</span>';
            } else {
                document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-chuapc">Chưa phân công</span>';
            }
        });
    });
});
function btnThemGV() {
    btnThem('gv');
    document.getElementById('infoSoLTC').textContent = '0';
    document.getElementById('infoCapBac').textContent = '—';
    document.getElementById('infoTrangThai').innerHTML = '<span class="badge-status badge-chuapc">Chưa phân công</span>';
}
function btnXoaGV() {
    var pk = document.getElementById('gvPK');
    if (!pk || !pk.value.trim()) { alert('Chọn GV cần xóa!'); return; }
    var row = document.querySelector('#gvTable tbody tr.selected');
    if (row) {
        var soltc = row.getAttribute('data-soltc');
        if (soltc && parseInt(soltc) > 0) { alert('Không thể xóa! GV ' + pk.value + ' đã phụ trách ' + soltc + ' lớp tín chỉ.'); return; }
    }
    if (confirm('Xóa giảng viên ' + pk.value + '?')) {
        var f = document.createElement('form'); f.method='POST';
        f.action = '${pageContext.request.contextPath}/giangvien/delete';
        var i = document.createElement('input'); i.type='hidden'; i.name='magv'; i.value=pk.value.trim();
        f.appendChild(i); document.body.appendChild(f); f.submit();
    }
}
function filterGV(type, el) {
    document.querySelectorAll('.filter-tab').forEach(function(t) { t.classList.remove('active'); });
    el.classList.add('active');
    document.querySelectorAll('#gvTable tbody tr').forEach(function(r) {
        var soltc = parseInt(r.getAttribute('data-soltc')) || 0;
        var hv = (r.getAttribute('data-hocvi') || '').toLowerCase();
        var hh = (r.getAttribute('data-hocham') || '').toLowerCase();
        switch(type) {
            case 'dangday': r.style.display = soltc > 0 ? '' : 'none'; break;
            case 'chuapc': r.style.display = soltc === 0 ? '' : 'none'; break;
            case 'gspgsts': r.style.display = (hh.indexOf('gs') >= 0 || hh.indexOf('pgs') >= 0 || hv.indexOf('tiến sĩ') >= 0 || hv.indexOf('ts') >= 0) ? '' : 'none'; break;
            default: r.style.display = '';
        }
    });
}
</script>
</body>
</html>
