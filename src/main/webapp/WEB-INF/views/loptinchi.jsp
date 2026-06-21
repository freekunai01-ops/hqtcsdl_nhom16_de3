<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Mở Lớp Tín Chỉ</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
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
                <div class="title-left"><i class="fas fa-chalkboard"></i> Form: Mở Lớp Tín chỉ</div>
                <div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
            </div>
            <div class="form-window-body">
                <div style="background:#fffbeb;color:#b45309;border:1px solid #fde68a;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12px;font-weight:500;">
                    Lưu ý: Không được mở lớp tín chỉ cho niên khóa/học kỳ trong quá khứ (chốt từ ngày 19/04/2026).
                </div>

                <form id="ltcForm" action="${pageContext.request.contextPath}/loptinchi/save" method="post">
                    <input type="hidden" id="ltcAction" name="action" value="add">

                    <div style="background:#fef9c3;border:1px solid #facc15;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#854d0e;">
                        <i class="fas fa-info-circle"></i> <strong>Lưu ý:</strong> PGV cấu hình ngày bắt đầu/kết thúc ĐK và hạn hủy ngay khi mở LTC. PGV và SV đều bị chặn ngoài hạn.
                    </div>

                    <div class="form-split-container">
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin lớp tín chỉ</div>
                            <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px 15px;">
                                <div class="pane-grid">
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Mã LTC:</span><div class="pane-input-wrapper"><input type="text" id="ltcMaltcDisplay" class="pane-input" disabled placeholder="(Tự động tăng)"><input type="hidden" id="ltcMaltc" name="maltc" value=""></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Học kỳ:</span><div class="pane-input-wrapper"><select name="hocky" data-field="HOCKY" class="pane-input" style="padding:4px 6px;" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>><option value="1">1</option><option value="2">2</option><option value="3">3</option></select></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Môn học:</span><div class="pane-input-wrapper"><select name="mamh" data-field="MAMH" class="pane-input" style="padding:4px 6px;" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>><c:forEach items="${dsmh}" var="mh"><option value="${mh.MAMH}">${mh.MAMH} - ${mh.TENMH}</option></c:forEach></select></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Giảng viên:</span><div class="pane-input-wrapper"><select name="magv" data-field="MAGV" class="pane-input" style="padding:4px 6px;" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>><c:forEach items="${dsgv}" var="gv"><option value="${gv.MAGV}">${gv.MAGV} - ${gv.HOTENGV}</option></c:forEach></select></div></div>
                                </div>
                                <div class="pane-grid">
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Niên khóa:</span><div class="pane-input-wrapper"><input type="text" name="nienkhoa" data-field="NIENKHOA" class="pane-input" placeholder="2025-2026" maxlength="9" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Nhóm:</span><div class="pane-input-wrapper"><input type="number" name="nhom" data-field="NHOM" class="pane-input" min="1" value="1" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">Khoa QL:</span><div class="pane-input-wrapper"><c:choose><c:when test="${sessionScope.nhomQuyen == 'PGV'}"><select name="maKhoa" data-field="MAKHOA" class="pane-input" style="padding:4px 6px;" required><c:forEach items="${khoaList}" var="k"><option value="${k.MAKHOA}">${k.MAKHOA}</option></c:forEach></select></c:when><c:otherwise><input type="text" class="pane-input" value="${sessionScope.maKhoa}" disabled><input type="hidden" name="maKhoa" data-field="MAKHOA" value="${sessionScope.maKhoa}"></c:otherwise></c:choose></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">SV tối thiểu:</span><div class="pane-input-wrapper"><input type="number" name="sosvtoithieu" data-field="SOSVTOITHIEU" class="pane-input" min="1" value="20" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <div class="pane-row"><span class="pane-label" style="width:80px;">SV tối đa:</span><div class="pane-input-wrapper"><input type="number" name="sosvtoida" data-field="SOSVTOIDA" class="pane-input" min="1" value="40" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                </div>
                            </div>

                            <div class="pane-section" style="margin-top:10px;">
                                <div class="pane-row"><span class="pane-label" style="width:80px;">Bắt đầu ĐK:</span><div class="pane-input-wrapper"><input type="date" name="ngaybatdauDk" data-field="NGAYBATDAU_DK" class="pane-input" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label" style="width:80px;">Kết thúc ĐK:</span><div class="pane-input-wrapper"><input type="date" name="ngayketthucDk" data-field="NGAYKETTHUC_DK" class="pane-input" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                <div class="pane-row"><span class="pane-label" style="width:80px;">Hạn hủy:</span><div class="pane-input-wrapper"><input type="date" name="ngayhethanHuy" data-field="NGAYHETHAN_HUY" class="pane-input" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                            </div>

                            <div style="margin-top:10px;padding-left:95px;">
                                <label style="font-size:13px;font-weight:bold;cursor:pointer;display:flex;align-items:center;gap:6px;">
                                    <input type="checkbox" id="ltcHuylop" name="huylop" value="true" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>> Hủy lớp
                                </label>
                            </div>
                            <div class="pane-row" style="margin-top:6px;">
                                <span class="pane-label" style="width:80px;">Lý do hủy:</span>
                                <div class="pane-input-wrapper">
                                    <input type="text" name="lydohuy" data-field="LYDOHUY" class="pane-input" placeholder="Ví dụ: Không đủ sĩ số tối thiểu" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                </div>
                            </div>
                        </div>

                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách lớp tín chỉ đã mở</div>
                            <div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="ltcSearch" placeholder="Tìm lớp tín chỉ..." oninput="initTableSearch('ltcTable','ltcSearch')"></div>
                            <div class="win-table-container">
                                <table id="ltcTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MALTC" data-sort-col="0">MALTC</th>
                                        <th data-sort-key="NIENKHOA" data-sort-col="1">Niên khóa</th>
                                        <th data-sort-key="HOCKY" data-sort-col="2">HK</th>
                                        <th data-sort-key="MAMH" data-sort-col="3">Môn</th>
                                        <th data-sort-key="NHOM" data-sort-col="4">Nhóm</th>
                                        <th data-sort-key="MAGV" data-sort-col="5">GV</th>
                                        <th data-sort-key="SOSVTOITHIEU" data-sort-col="6">SVmin</th>
                                        <th data-sort-key="SOSVTOIDA" data-sort-col="7">SVmax</th>
                                        <th data-sort-key="NGAYKETTHUC_DK" data-sort-col="8">Hết ĐK</th>
                                        <th data-sort-key="NGAYHETHAN_HUY" data-sort-col="9">Hạn hủy</th>
                                        <th data-sort-key="HUYLOP_TXT" data-sort-col="10">Hủy</th>
                                        <th data-sort-key="LYDOHUY" data-sort-col="11">Lý do hủy</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dsltc}" var="l">
                                            <tr onclick="selectLTC(this)" data-maltc="${l.MALTC}" data-huylop="${l.HUYLOP}">
                                                <td data-col="MALTC">${l.MALTC}</td>
                                                <td data-col="NIENKHOA">${l.NIENKHOA}</td>
                                                <td data-col="HOCKY">${l.HOCKY}</td>
                                                <td>${l.MAMH} <span class="d-none" data-col="MAMH">${l.MAMH}</span></td>
                                                <td data-col="NHOM">${l.NHOM}</td>
                                                <td>${l.MAGV} <span class="d-none" data-col="MAGV">${l.MAGV}</span></td>
                                                <td data-col="SOSVTOITHIEU">${l.SOSVTOITHIEU}</td>
                                                <td data-col="SOSVTOIDA">${l.SOSVTOIDA}</td>
                                                <td data-col="NGAYKETTHUC_DK"><fmt:formatDate value="${l.NGAYKETTHUC_DK}" pattern="yyyy-MM-dd"/></td>
                                                <td data-col="NGAYHETHAN_HUY"><fmt:formatDate value="${l.NGAYHETHAN_HUY}" pattern="yyyy-MM-dd"/></td>
                                                <td data-col="HUYLOP_TXT">${l.HUYLOP == true ? 'Đã hủy' : ''}</td>
                                                <td data-col="LYDOHUY">${l.LYDOHUY}</td>
                                                <td data-col="MAKHOA" style="display:none;">${l.MAKHOA}</td>
                                                <td data-col="NGAYBATDAU_DK" style="display:none;"><fmt:formatDate value="${l.NGAYBATDAU_DK}" pattern="yyyy-MM-dd"/></td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="ltcTableFilterCount" class="table-filter-count"></span>
                        </div>
                    </div>

                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemOpen()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaOpen()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="submit" class="win-form-btn btn-save"><i class="fas fa-save"></i> Ghi</button>
                            <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                        </c:if>
                        <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                    </div>
                </form>
            </div>
            <div class="form-window-status">
                <span>Tổng LTC: ${fn:length(dsltc)}</span>
                <span><c:choose><c:when test="${sessionScope.maKhoa == 'ALL'}">Khoa: Tất cả</c:when><c:otherwise>Khoa: ${sessionScope.maKhoa}</c:otherwise></c:choose></span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=3"></script>
<script>
function selectLTC(row) {
    document.querySelectorAll('#ltcTable tbody tr').forEach(function(r) { r.classList.remove('selected'); });
    row.classList.add('selected');
    var maltc = row.getAttribute('data-maltc');
    var huylop = row.getAttribute('data-huylop') === 'true';
    document.getElementById('ltcMaltcDisplay').value = maltc;
    document.getElementById('ltcMaltc').value = maltc;
    document.getElementById('ltcAction').value = 'update';
    document.getElementById('ltcHuylop').checked = huylop;
    document.querySelectorAll('[data-field]').forEach(function(input) {
        var field = input.getAttribute('data-field');
        var cell = row.querySelector('[data-col="' + field + '"]');
        if (cell) input.value = cell.textContent.trim();
    });
}
function btnThemOpen() {
    document.getElementById('ltcAction').value = 'add';
    document.getElementById('ltcMaltc').value = '';
    document.getElementById('ltcMaltcDisplay').value = '(Tự động tăng)';
    document.getElementById('ltcHuylop').checked = false;
    document.querySelector('input[name="nienkhoa"]').value = '';
    document.querySelector('input[name="nhom"]').value = '1';
    document.querySelector('input[name="sosvtoithieu"]').value = '20';
    document.querySelectorAll('#ltcTable tbody tr').forEach(function(r) { r.classList.remove('selected'); });
}
function btnXoaOpen() {
    var maltc = document.getElementById('ltcMaltc').value;
    if (!maltc) { alert('Vui lòng chọn lớp tín chỉ cần xóa!'); return; }
    if (confirm('Bạn có chắc chắn muốn xóa lớp tín chỉ này?')) {
        var f = document.createElement('form'); f.method='POST';
        f.action = '${pageContext.request.contextPath}/loptinchi/delete';
        var i = document.createElement('input'); i.type='hidden'; i.name='maltc'; i.value=maltc;
        f.appendChild(i); document.body.appendChild(f); f.submit();
    }
}
</script>
</body>
</html>
