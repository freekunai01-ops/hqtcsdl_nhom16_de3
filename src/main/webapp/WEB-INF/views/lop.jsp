<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Danh mục Lớp</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .stat-cards{display:flex;gap:10px;margin-bottom:12px}.stat-card{flex:1;padding:10px 14px;border-radius:6px;border:1px solid #e2e8f0;background:#fff}.stat-card .stat-label{font-size:11px;color:#64748b;margin-bottom:2px}.stat-card .stat-value{font-size:22px;font-weight:bold}.stat-card.blue .stat-value{color:#2563eb}.stat-card.green .stat-value{color:#16a34a}.stat-card.gray .stat-value{color:#6b7280}.stat-card.orange .stat-value{color:#d97706}
        .filter-tabs{display:flex;gap:0;margin-bottom:8px}.filter-tab{padding:5px 14px;font-size:12px;font-weight:bold;cursor:pointer;border:1px solid #cbd5e1;background:#f8fafc;color:#475569;border-bottom:2px solid transparent;transition:all .15s}.filter-tab:first-child{border-radius:4px 0 0 4px}.filter-tab:last-child{border-radius:0 4px 4px 0}.filter-tab.active{background:#2563eb;color:#fff;border-color:#2563eb}.filter-tab:hover:not(.active){background:#e2e8f0}
        .badge-status{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:bold;white-space:nowrap}.badge-danghoc{background:#dcfce7;color:#166534;border:1px solid #86efac}.badge-totnghiep{background:#f3f4f6;color:#6b7280;border:1px solid #d1d5db}
        .info-panel{margin-top:10px;padding:10px 14px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:4px;font-size:12px}.info-panel .info-row{display:flex;justify-content:space-between;margin-bottom:4px}.info-panel .info-label{color:#64748b}.info-panel .info-value{font-weight:bold;color:#1e293b}
        .delete-note{margin-top:10px;padding:6px 10px;background:#fef9c3;border:1px solid #fde68a;border-radius:4px;font-size:11px;color:#92400e}
        .filter-hint{font-size:11px;color:#94a3b8;margin-left:auto;display:flex;align-items:center;gap:4px}
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
            <div class="error-alert alert-danger" style="background:#f8d7da;color:#842029;border:1px solid #f5c2c7;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12.5px;">
                <i class="fas fa-exclamation-triangle"></i> <strong>LỖI:</strong> ${error}
            </div>
        </c:if>

        <div class="desktop-form-window">
            <div class="form-window-titlebar">
                <div class="title-left"><i class="fas fa-layer-group"></i> Form: Danh mục Lớp</div>
                <div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
            </div>
            <div class="form-window-body">
                <div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
                    <i class="fas fa-info-circle"></i>
                    <strong>Danh mục Lớp</strong> là lớp hành chính theo khóa/khoa. Lớp đã tốt nghiệp vẫn hiển thị để tra cứu, in điểm và giữ lịch sử; trạng thái được suy từ <strong>KHOAHOC</strong>, không cần cột TOTNGHIEP.
                </div>

                <div class="stat-cards">
                    <div class="stat-card blue"><div class="stat-label">Tổng lớp</div><div class="stat-value">${totalLop}</div></div>
                    <div class="stat-card green"><div class="stat-label">Đang học</div><div class="stat-value">${dangHoc}</div></div>
                    <div class="stat-card gray"><div class="stat-label">Khóa đã kết thúc</div><div class="stat-value">${daTotNghiep}</div></div>
                    <div class="stat-card orange"><div class="stat-label">Sinh viên lớp chọn</div><div class="stat-value" id="statSiSo">—</div></div>
                </div>

                <form id="lopForm" action="${pageContext.request.contextPath}/lop/save" method="post">
                    <input type="hidden" id="lopAction" name="action" value="add">
                    <div class="form-split-container">
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin lớp</div>
                            <div class="pane-grid">
                                <div class="pane-row"><span class="pane-label">Mã lớp:</span><div class="pane-input-wrapper"><input type="text" id="lopPK" name="maLop" data-field="MALOP" class="pane-input" value="${not empty error ? failedMaLop : ''}" maxlength="10" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Tên lớp:</span><div class="pane-input-wrapper"><input type="text" name="tenLop" data-field="TENLOP" class="pane-input" value="${not empty error ? failedTenLop : ''}" maxlength="50" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Khóa học:</span><div class="pane-input-wrapper"><input type="text" name="khoaHoc" data-field="KHOAHOC" class="pane-input" value="${not empty error ? failedKhoaHoc : ''}" maxlength="9" placeholder="2022-2026" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label">Khoa:</span><div class="pane-input-wrapper"><c:choose><c:when test="${sessionScope.nhomQuyen == 'PGV'}"><select name="maKhoa" data-field="MAKHOA" class="pane-input" style="padding:4px 6px;" required><c:forEach items="${khoaList}" var="k"><option value="${k.MAKHOA}" ${not empty error && failedMaKhoa == k.MAKHOA ? 'selected' : ''}>${k.MAKHOA} - ${k.TENKHOA}</option></c:forEach></select></c:when><c:otherwise><input type="text" class="pane-input" value="${sessionScope.maKhoa}" disabled><input type="hidden" name="maKhoa" data-field="MAKHOA" value="${sessionScope.maKhoa}"></c:otherwise></c:choose></div></div>
                            </div>
                            <div class="info-panel" id="lopInfoPanel" style="display:none;">
                                <div class="info-row"><span class="info-label">Trạng thái:</span><span class="info-value" id="infoTrangThai">—</span></div>
                                <div class="info-row"><span class="info-label">Năm kết thúc:</span><span class="info-value" id="infoNamKT">—</span></div>
                                <div class="info-row"><span class="info-label">Sĩ số hiện có:</span><span class="info-value" id="infoSiSo">—</span></div>
                            </div>
                            <div class="delete-note" id="deleteNote" style="display:none;">
                                <i class="fas fa-exclamation-triangle"></i> <span id="deleteNoteText"></span>
                            </div>
                        </div>

                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách lớp — tìm kiếm / sắp xếp / lọc trạng thái</div>
                            <div style="display:flex;align-items:center;margin-bottom:6px;">
                                <div class="filter-tabs">
                                    <div class="filter-tab active" data-filter="all" onclick="filterLopByStatus('all',this)">Tất cả</div>
                                    <div class="filter-tab" data-filter="danghoc" onclick="filterLopByStatus('danghoc',this)">Đang học</div>
                                    <div class="filter-tab" data-filter="totnghiep" onclick="filterLopByStatus('totnghiep',this)">Khóa đã kết thúc</div>
                                </div>
                                <div class="filter-hint"><i class="fas fa-info-circle"></i> Có SV: không xóa &nbsp;|&nbsp; <i class="fas fa-graduation-cap"></i> Tốt nghiệp: vẫn hiện</div>
                            </div>
                            <div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="lopSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('lopTable','lopSearch')"></div>
                            <div class="win-table-container">
                                <table id="lopTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MALOP" data-sort-col="0">Mã lớp</th>
                                        <th data-sort-key="TENLOP" data-sort-col="1">Tên lớp</th>
                                        <th data-sort-key="KHOAHOC" data-sort-col="2">Khóa học</th>
                                        <th data-sort-key="MAKHOA" data-sort-col="3">Khoa</th>
                                        <th data-sort-key="SISO" data-sort-col="4">Sĩ số</th>
                                        <th data-sort-key="TRANGTHAI" data-sort-col="5">Trạng thái</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dslop}" var="l">
                                            <tr data-malop="${l.MALOP}" data-siso="${l.SISO}" data-totnghiep="${l.TOTNGHIEP}"
                                                class="${l.MALOP.trim() == selectedMalop ? 'selected' : ''}">
                                                <td data-col="MALOP">${l.MALOP}</td>
                                                <td data-col="TENLOP">${l.TENLOP}</td>
                                                <td data-col="KHOAHOC">${l.KHOAHOC}</td>
                                                <td data-col="MAKHOA">${l.MAKHOA}</td>
                                                <td style="text-align:center;font-weight:bold;"><c:choose><c:when test="${l.SISO > 0}"><span style="color:#2563eb">${l.SISO}</span></c:when><c:otherwise><span style="color:#94a3b8">${l.SISO}</span></c:otherwise></c:choose></td>
                                                <td><c:choose><c:when test="${l.TOTNGHIEP == 1}"><span class="badge-status badge-totnghiep">Khóa đã kết thúc</span></c:when><c:otherwise><span class="badge-status badge-danghoc">Đang học</span></c:otherwise></c:choose></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="lopTableFilterCount" class="table-filter-count"></span>
                        </div>
                    </div>
                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemLop()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaLop()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="button" class="win-form-btn btn-save" onclick="validateAndSubmitLop()"><i class="fas fa-save"></i> Ghi</button>
                            <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                        </c:if>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                    </div>
                </form>
            </div>
            <div class="form-window-status">
                <span>Tổng số: ${totalLop} lớp | Đang học: ${dangHoc} | Khóa đã kết thúc: ${daTotNghiep}</span>
                <span id="selectedLopStatus">Đã chọn: Chưa chọn</span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
var currentStatusFilter = 'all';
document.addEventListener("DOMContentLoaded", function() {
    initTableSelection('lopTable', 'lop');
    var rows = document.querySelectorAll('#lopTable tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            var malop = this.getAttribute('data-malop');
            var siso = parseInt(this.getAttribute('data-siso') || '0');
            var tn = parseInt(this.getAttribute('data-totnghiep') || '0');
            var kh = this.querySelector('[data-col="KHOAHOC"]').textContent.trim();
            // Lock PK field — MALOP không được sửa khi đang update
            var pk = document.getElementById('lopPK');
            if (pk) { pk.readOnly = true; pk.style.background = '#f1f5f9'; }
            document.getElementById('selectedLopStatus').textContent = 'Đã chọn: ' + malop;
            document.getElementById('statSiSo').textContent = siso;
            var ip = document.getElementById('lopInfoPanel'); ip.style.display = '';
            document.getElementById('infoTrangThai').innerHTML = tn === 1
                ? '<span class="badge-status badge-totnghiep">Khóa đã kết thúc</span>'
                : '<span class="badge-status badge-danghoc">Đang học</span>';
            document.getElementById('infoNamKT').textContent = kh.length >= 9 ? kh.substring(5, 9) : '—';
            document.getElementById('infoSiSo').textContent = siso;
            var dn = document.getElementById('deleteNote'); var dt = document.getElementById('deleteNoteText');
            if (siso > 0) { dn.style.display = ''; dt.textContent = 'Xóa chỉ cho lớp tạo nhầm, chưa có SV và chưa tốt nghiệp.'; }
            else if (tn === 1) { dn.style.display = ''; dt.textContent = 'Không xóa lớp đã tốt nghiệp — dữ liệu lịch sử cần giữ lại.'; }
            else { dn.style.display = 'none'; }

            // Nếu lớp đã có sinh viên, không cho sửa Khóa học và Khoa
            var khInput = document.querySelector('input[name="khoaHoc"]');
            var mkSelect = document.querySelector('select[name="maKhoa"]');
            if (siso > 0) {
                if (khInput) {
                    khInput.readOnly = true;
                    khInput.style.background = '#f1f5f9';
                    khInput.title = 'Không thể sửa Khóa học của lớp đã có sinh viên!';
                }
                if (mkSelect) {
                    mkSelect.style.pointerEvents = 'none';
                    mkSelect.style.background = '#f1f5f9';
                    mkSelect.title = 'Không thể sửa Khoa của lớp đã có sinh viên!';
                }
            } else {
                if (khInput) {
                    khInput.readOnly = false;
                    khInput.style.background = '';
                    khInput.title = '';
                }
                if (mkSelect) {
                    mkSelect.style.pointerEvents = '';
                    mkSelect.style.background = '';
                    mkSelect.title = '';
                }
            }
        });
    });

    var activeMalop = '${selectedMalop}';
    if (activeMalop) {
        var foundRow = null;
        rows.forEach(function(row) {
            if (row.getAttribute('data-malop').trim() === activeMalop) {
                foundRow = row;
            }
        });
        if (foundRow) {
            var hasError = ${not empty error};
            if (hasError) {
                foundRow.classList.add('selected');
                foundRow.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                var siso = parseInt(foundRow.getAttribute('data-siso') || '0');
                var tn = parseInt(foundRow.getAttribute('data-totnghiep') || '0');
                var kh = foundRow.querySelector('[data-col="KHOAHOC"]').textContent.trim();
                document.getElementById('selectedLopStatus').textContent = 'Đã chọn: ' + activeMalop;
                document.getElementById('statSiSo').textContent = siso;
                var ip = document.getElementById('lopInfoPanel'); ip.style.display = '';
                document.getElementById('infoTrangThai').innerHTML = tn === 1
                    ? '<span class="badge-status badge-totnghiep">Khóa đã kết thúc</span>'
                    : '<span class="badge-status badge-danghoc">Đang học</span>';
                document.getElementById('infoNamKT').textContent = kh.length >= 9 ? kh.substring(5, 9) : '—';
                document.getElementById('infoSiSo').textContent = siso;
                var dn = document.getElementById('deleteNote'); var dt = document.getElementById('deleteNoteText');
                if (siso > 0) { dn.style.display = ''; dt.textContent = 'Xóa chỉ cho lớp tạo nhầm, chưa có SV và chưa tốt nghiệp.'; }
                else if (tn === 1) { dn.style.display = ''; dt.textContent = 'Không xóa lớp đã tốt nghiệp — dữ liệu lịch sử cần giữ lại.'; }
                else { dn.style.display = 'none'; }

                // Restore action state
                document.getElementById('lopAction').value = '${failedAction}';
                // Configure fields readOnly/disabled state based on action
                var pkField = document.getElementById('lopPK');
                if (pkField && '${failedAction}' === 'update') {
                    pkField.readOnly = true;
                    pkField.style.background = '#f1f5f9';
                }
                
                var khInput = document.querySelector('input[name="khoaHoc"]');
                var mkSelect = document.querySelector('select[name="maKhoa"]');
                if ('${failedAction}' === 'update' && siso > 0) {
                    if (khInput) {
                        khInput.readOnly = true;
                        khInput.style.background = '#f1f5f9';
                        khInput.title = 'Không thể sửa Khóa học của lớp đã có sinh viên!';
                    }
                    if (mkSelect) {
                        mkSelect.style.pointerEvents = 'none';
                        mkSelect.style.background = '#f1f5f9';
                        mkSelect.title = 'Không thể sửa Khoa của lớp đã có sinh viên!';
                    }
                }
            } else {
                foundRow.click();
                foundRow.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        }
    }
});
function filterLopByStatus(filter, btn) {
    currentStatusFilter = filter;
    document.querySelectorAll('.filter-tab').forEach(function(t) { t.classList.remove('active'); });
    btn.classList.add('active');
    document.querySelectorAll('#lopTable tbody tr').forEach(function(r) {
        var tn = parseInt(r.getAttribute('data-totnghiep') || '0');
        if (filter === 'all') r.removeAttribute('data-status-hidden');
        else if (filter === 'danghoc' && tn === 1) r.setAttribute('data-status-hidden', '1');
        else if (filter === 'totnghiep' && tn === 0) r.setAttribute('data-status-hidden', '1');
        else r.removeAttribute('data-status-hidden');
    });
    displayTablePage('lopTable');
}
function btnXoaLop() {
    var pk = document.getElementById('lopPK');
    if (!pk || !pk.value.trim()) { alert('Vui lòng chọn lớp cần xóa!'); return; }
    var row = document.querySelector('#lopTable tbody tr.selected');
    if (row) {
        var siso = parseInt(row.getAttribute('data-siso') || '0');
        var tn = parseInt(row.getAttribute('data-totnghiep') || '0');
        if (siso > 0) { alert('Không thể xóa lớp ' + pk.value + ' vì đã có ' + siso + ' sinh viên!'); return; }
        if (tn === 1) { alert('Không thể xóa lớp đã tốt nghiệp — dữ liệu lịch sử phải được giữ lại.'); return; }
    }
    if (confirm('Bạn có chắc chắn muốn xóa lớp ' + pk.value + '?')) {
        var nextMaLop = '';
        if (row) {
            var nextRow = row.nextElementSibling;
            if (!nextRow) {
                nextRow = row.previousElementSibling;
            }
            if (nextRow) {
                nextMaLop = nextRow.getAttribute('data-malop');
            }
        }
        var f = document.createElement('form'); f.method = 'POST';
        f.action = '${pageContext.request.contextPath}/lop/delete';
        var i = document.createElement('input'); i.type='hidden'; i.name='maLop'; i.value=pk.value.trim(); f.appendChild(i);
        var i2 = document.createElement('input'); i2.type='hidden'; i2.name='nextMaLop'; i2.value=nextMaLop; f.appendChild(i2);
        document.body.appendChild(f); f.submit();
    }
}
function btnThemLop() {
    btnThem('lop');
    // Mở khóa PK — thêm mới cần nhập MALOP
    var pkF = document.getElementById('lopPK');
    if (pkF) { pkF.readOnly = false; pkF.style.background = ''; }
    var khInput = document.querySelector('input[name="khoaHoc"]');
    var mkSelect = document.querySelector('select[name="maKhoa"]');
    if (khInput) {
        khInput.readOnly = false;
        khInput.style.background = '';
        khInput.title = '';
    }
    if (mkSelect) {
        mkSelect.style.pointerEvents = '';
        mkSelect.style.background = '';
        mkSelect.title = '';
    }
    document.getElementById('lopInfoPanel').style.display = 'none';
    document.getElementById('deleteNote').style.display = 'none';
    document.getElementById('selectedLopStatus').textContent = 'Đã chọn: Chưa chọn';
}
// ===== VALIDATION LỚP =====
var KHOAHOC_REGEX = /^(\d{4})-(\d{4})$/;
function lopSetError(inputEl, msg) {
    var wrapper = inputEl.closest('.pane-input-wrapper') || inputEl.parentElement;
    inputEl.style.border = '1.5px solid #dc2626';
    var errId = 'err_lop_' + (inputEl.name || inputEl.id);
    var existing = document.getElementById(errId);
    if (existing) existing.remove();
    var span = document.createElement('span');
    span.id = errId;
    span.style.cssText = 'color:#dc2626;font-size:10.5px;font-weight:bold;display:block;margin-top:2px;';
    span.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + msg;
    wrapper.appendChild(span);
}
function lopClearError(inputEl) {
    if (!inputEl) return;
    inputEl.style.border = '';
    var errId = 'err_lop_' + (inputEl.name || inputEl.id);
    var existing = document.getElementById(errId);
    if (existing) existing.remove();
}
function validateAndSubmitLop() {
    var pk = document.getElementById('lopPK');
    var tenLop = document.querySelector('input[name="tenLop"]');
    var khoaHoc = document.querySelector('input[name="khoaHoc"]');
    var maKhoa = document.querySelector('select[name="maKhoa"]');
    var ok = true;
    [pk, tenLop, khoaHoc].forEach(function(el) { if (el) lopClearError(el); });

    if (pk && !pk.value.trim()) { lopSetError(pk, 'Mã lớp không được để trống.'); ok = false; }
    if (!tenLop || !tenLop.value.trim()) { lopSetError(tenLop, 'Tên lớp không được để trống.'); ok = false; }
    if (khoaHoc && !khoaHoc.readOnly) {
        var kh = khoaHoc.value.trim();
        if (!kh) { lopSetError(khoaHoc, 'Khóa học không được để trống.'); ok = false; }
        else {
            var m = kh.match(KHOAHOC_REGEX);
            if (!m) { lopSetError(khoaHoc, 'Khóa học phải có dạng YYYY-YYYY (vd: 2020-2025).'); ok = false; }
            else if (parseInt(m[2]) <= parseInt(m[1])) { lopSetError(khoaHoc, 'Năm kết thúc phải lớn hơn năm bắt đầu.'); ok = false; }
        }
    }
    if (maKhoa && !maKhoa.value.trim()) { alert('Vui lòng chọn Khoa.'); ok = false; }
    if (ok) document.getElementById('lopForm').submit();
}
</script>
</body>
</html>
