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
    <style>
        /* ===== Bảng gọn hơn ===== */
        .ltc-detail-bar {
            display: none;
            padding: 8px 14px;
            margin: 6px 0 4px;
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 4px;
            font-size: 11.5px;
            color: #0369a1;
            gap: 20px;
            flex-wrap: wrap;
        }
        .ltc-detail-bar.show { display: flex; }
        .ltc-detail-bar span { white-space: nowrap; }
        .ltc-detail-bar strong { color: #0c4a6e; }
        /* Badge trạng thái mới */
        .badge-status { display:inline-block;padding:2px 6px;border-radius:3px;font-size:10.5px;font-weight:bold;text-align:center;min-width:75px;border:1px solid transparent; }
        .badge-status.huy { background:#fee2e2; color:#991b1b; border-color:#fca5a5; }
        .badge-status.lichsu { background:#f3f4f6; color:#4b5563; border-color:#d1d5db; }
        .badge-status.daxong { background:#edf2f7; color:#4a5568; border-color:#cbd5e0; }
        .badge-status.day { background:#feebc8; color:#744210; border-color:#fbd38d; }
        .badge-status.chua-min { background:#fef3c7; color:#92400e; border-color:#fde68a; }
        .badge-status.dangmo { background:#dcfce7; color:#15803d; border-color:#86efac; }
        .badge-status.sapmo { background:#f3e8ff; color:#6b21a8; border-color:#d8b4fe; }
        /* Tooltip cột ngắn */
        .ltc-abbr { cursor:help; border-bottom:1px dashed #94a3b8; }
        /* Gọn bảng */
        #ltcTable td, #ltcTable th { padding:4px 7px; font-size:12px; }
        /* Một banner duy nhất */
        .ltc-notice {
            padding: 7px 12px;
            border-radius: 4px;
            margin-bottom: 10px;
            font-size: 12px;
            font-weight: 500;
            background: #fffbeb;
            border: 1px solid #fde68a;
            color: #92400e;
        }
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
                <div class="title-left"><i class="fas fa-chalkboard"></i> Form: Mở Lớp Tín chỉ</div>
                <div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
            </div>
            <div class="form-window-body">

                <%-- ===== Banner đơn giản, gộp 2 thành 1 ===== --%>
                <div class="ltc-notice">
                    <i class="fas fa-info-circle"></i>
                    Cấu hình ngày <strong>Bắt đầu / Kết thúc ĐK</strong> và <strong>Hạn hủy</strong> khi mở lớp.
                    Sinh viên chỉ đăng ký được trong khoảng thời gian này.
                    Không mở lớp cho niên khóa/học kỳ quá khứ.
                </div>

                <form id="ltcForm" action="${pageContext.request.contextPath}/loptinchi/save" method="post" novalidate>
                    <input type="hidden" id="ltcAction" name="action" value="add">

                    <div class="form-split-container">
                        <%-- ===== CỘT TRÁI: Form nhập ===== --%>
                        <div class="form-left-pane">
                            <div class="pane-title">Thông tin lớp tín chỉ</div>
                            <div class="pane-grid">
                                <%-- Hàng 1: Mã LTC + Niên khóa --%>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Mã LTC:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" id="ltcMaltcDisplay" class="pane-input" disabled placeholder="(Tự động tăng)" style="width:100px;">
                                        <input type="hidden" id="ltcMaltc" name="maltc" value="">
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Niên khóa:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" name="nienkhoa" data-field="NIENKHOA" class="pane-input" placeholder="2025-2026" maxlength="9" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Học kỳ:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="hocky" data-field="HOCKY" class="pane-input" style="padding:4px 6px;" required
                                                <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                            <option value="1">1</option>
                                            <option value="2">2</option>
                                            <option value="3">3</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Nhóm:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" name="nhom" data-field="NHOM" class="pane-input" min="1" value="1" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Môn học:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="mamh" data-field="MAMH" class="pane-input" style="padding:4px 6px;" required
                                                <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                            <c:forEach items="${dsmh}" var="mh">
                                                <option value="${mh.MAMH}">${mh.MAMH} - ${mh.TENMH}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Giảng viên:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="magv" data-field="MAGV" class="pane-input" style="padding:4px 6px;" required
                                                <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                            <c:forEach items="${dsgv}" var="gv">
                                                <option value="${gv.MAGV}">${gv.MAGV} - ${gv.HOTENGV}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Khoa QL:</span>
                                    <div class="pane-input-wrapper">
                                        <c:choose>
                                            <c:when test="${sessionScope.nhomQuyen == 'PGV'}">
                                                <select name="maKhoa" data-field="MAKHOA" class="pane-input" style="padding:4px 6px;" required>
                                                    <c:forEach items="${khoaList}" var="k">
                                                        <option value="${k.MAKHOA}">${k.MAKHOA}</option>
                                                    </c:forEach>
                                                </select>
                                            </c:when>
                                            <c:otherwise>
                                                <input type="text" class="pane-input" value="${sessionScope.maKhoa}" disabled>
                                                <input type="hidden" name="maKhoa" data-field="MAKHOA" value="${sessionScope.maKhoa}">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">SV tối thiểu:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" name="sosvtoithieu" data-field="SOSVTOITHIEU" class="pane-input" min="1" value="20" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">SV tối đa:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" name="sosvtoida" data-field="SOSVTOIDA" class="pane-input" min="1" value="40" required
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                            </div>

                            <%-- Ngày ĐK --%>
                            <div style="margin-top:10px;padding-top:8px;border-top:1px solid #e2e8f0;">
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Bắt đầu ĐK:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="date" name="ngaybatdauDk" data-field="NGAYBATDAU_DK" class="pane-input"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Kết thúc ĐK:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="date" name="ngayketthucDk" data-field="NGAYKETTHUC_DK" class="pane-input"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                                <div class="pane-row">
                                    <span class="pane-label" style="width:90px;">Hạn hủy:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="date" name="ngayhethanHuy" data-field="NGAYHETHAN_HUY" class="pane-input"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                            </div>

                            <%-- Hủy lớp --%>
                            <div style="margin-top:8px;">
                                <label style="font-size:13px;font-weight:bold;cursor:pointer;display:flex;align-items:center;gap:6px;padding-left:95px;">
                                    <input type="checkbox" id="ltcHuylop" name="huylop" value="true"
                                           <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>> Hủy lớp
                                </label>
                                <div class="pane-row" style="margin-top:6px;">
                                    <span class="pane-label" style="width:90px;">Lý do hủy:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="text" name="lydohuy" data-field="LYDOHUY" class="pane-input"
                                               placeholder="Ví dụ: Không đủ sĩ số tối thiểu"
                                               <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <%-- ===== CỘT PHẢI: Danh sách gọn ===== --%>
                        <div class="form-right-pane">
                            <div class="pane-title">Danh sách lớp tín chỉ đã mở</div>
                            <div class="table-search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="ltcSearch" placeholder="Tìm lớp tín chỉ..." oninput="initTableSearch('ltcTable','ltcSearch')">
                            </div>
                            <div class="win-table-container">
                                <table id="ltcTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MALTC" data-sort-col="0">Mã LTC</th>
                                        <th data-sort-key="NIENKHOA" data-sort-col="1">Niên khóa</th>
                                        <th data-sort-key="HOCKY" data-sort-col="2">HK</th>
                                        <th data-sort-key="MAMH" data-sort-col="3">Môn</th>
                                        <th data-sort-key="NHOM" data-sort-col="4">Nhóm</th>
                                        <th data-sort-key="MAGV" data-sort-col="5">Giảng viên</th>
                                        <th data-sort-key="SOSVTOIDA" data-sort-col="6" title="Sĩ số (Đã ĐK / Tối đa)">Sĩ số (Đã ĐK/Tối đa)</th>
                                        <th data-sort-key="HUYLOP_TXT" data-sort-col="7">Trạng thái</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dsltc}" var="l">
                                            <tr onclick="selectLTC(this)" data-maltc="${l.MALTC}" data-huylop="${l.HUYLOP}"
                                                data-nienkhoa="${l.NIENKHOA}" data-hocky="${l.HOCKY}"
                                                data-batdau="<fmt:formatDate value='${l.NGAYBATDAU_DK}' pattern='yyyy-MM-dd'/>"
                                                data-ketthuc="<fmt:formatDate value='${l.NGAYKETTHUC_DK}' pattern='yyyy-MM-dd'/>"
                                                data-hethan="<fmt:formatDate value='${l.NGAYHETHAN_HUY}' pattern='yyyy-MM-dd'/>"
                                                data-lydohuy="${l.LYDOHUY}"
                                                class="${l.MALTC == selectedMaltc ? 'selected' : ''}">
                                                <td data-col="MALTC">${l.MALTC}</td>
                                                <td data-col="NIENKHOA">${l.NIENKHOA}</td>
                                                <td data-col="HOCKY">${l.HOCKY}</td>
                                                <td data-col="MAMH">${l.MAMH}</td>
                                                <td data-col="NHOM">${l.NHOM}</td>
                                                <td data-col="MAGV">${l.MAGV}</td>
                                                <td data-col="SOSVTOITHIEU" style="display:none">${l.SOSVTOITHIEU}</td>
                                                <td data-col="SOSVTOIDA" style="display:none">${l.SOSVTOIDA}</td>
                                                <td data-col="SOSVDK_DISPLAY">${l.SOSVDK} / ${l.SOSVTOIDA} <span style="font-size:11px;color:#718096;">(Min: ${l.SOSVTOITHIEU})</span></td>
                                                <td data-col="HUYLOP_TXT">
                                                    <c:choose>
                                                        <c:when test="${l.HUYLOP == true}">
                                                            <span class="badge-status huy"><i class="fas fa-times-circle"></i> Đã hủy</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <c:set var="nkStart" value="${fn:substring(l.NIENKHOA, 0, 4)}" />
                                                            <c:choose>
                                                                <c:when test="${nkStart < 2024}">
                                                                    <span class="badge-status lichsu"><i class="fas fa-history"></i> Lịch sử</span>
                                                                </c:when>
                                                                <c:when test="${l.NIENKHOA == '2024-2025' || (l.NIENKHOA == '2025-2026' && l.HOCKY == 1)}">
                                                                    <span class="badge-status daxong"><i class="fas fa-check-double"></i> Đã xong</span>
                                                                </c:when>
                                                                <c:when test="${l.NIENKHOA == '2026-2027'}">
                                                                    <span class="badge-status sapmo"><i class="fas fa-clock"></i> Sắp mở</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:choose>
                                                                        <c:when test="${l.SOSVDK >= l.SOSVTOIDA}">
                                                                            <span class="badge-status day"><i class="fas fa-users-slash"></i> Đã đầy</span>
                                                                        </c:when>
                                                                        <c:when test="${l.SOSVDK < l.SOSVTOITHIEU}">
                                                                            <span class="badge-status chua-min"><i class="fas fa-users"></i> Thiếu Min</span>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span class="badge-status dangmo"><i class="fas fa-check-circle"></i> Đang mở</span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <%-- Ẩn: dùng để điền form --%>
                                                <td data-col="MAKHOA" style="display:none">${l.MAKHOA}</td>
                                                <td data-col="NGAYBATDAU_DK" style="display:none"><fmt:formatDate value="${l.NGAYBATDAU_DK}" pattern="yyyy-MM-dd"/></td>
                                                <td data-col="NGAYKETTHUC_DK" style="display:none"><fmt:formatDate value="${l.NGAYKETTHUC_DK}" pattern="yyyy-MM-dd"/></td>
                                                <td data-col="NGAYHETHAN_HUY" style="display:none"><fmt:formatDate value="${l.NGAYHETHAN_HUY}" pattern="yyyy-MM-dd"/></td>
                                                <td data-col="LYDOHUY" style="display:none">${l.LYDOHUY}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>

                            <%-- Detail bar — hiện khi chọn dòng --%>
                            <div id="ltcDetailBar" class="ltc-detail-bar">
                                <span><i class="fas fa-calendar-alt"></i> Bắt đầu ĐK: <strong id="dBarBatdau">—</strong></span>
                                <span><i class="fas fa-calendar-check"></i> Kết thúc ĐK: <strong id="dBarKetthuc">—</strong></span>
                                <span><i class="fas fa-calendar-times"></i> Hạn hủy: <strong id="dBarHethan">—</strong></span>
                                <span id="dBarLydoWrapper"><i class="fas fa-comment-alt"></i> Lý do hủy: <strong id="dBarLydo">—</strong></span>
                            </div>
                            <span id="ltcTableFilterCount" class="table-filter-count"></span>
                        </div>
                    </div>

                    <div class="form-buttons-row">
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <button type="button" class="win-form-btn" onclick="btnThemOpen()"><i class="fas fa-plus"></i> Thêm</button>
                            <button type="button" class="win-form-btn btn-delete" onclick="btnXoaOpen()"><i class="fas fa-trash"></i> Xóa</button>
                            <button type="button" class="win-form-btn btn-save" id="btnGhiSubmit" onclick="submitForm()"><i class="fas fa-save"></i> Ghi</button>
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
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
// === Global Error Catcher ===
window.onerror = function(message, source, lineno, colno, error) {
    alert("PHAT HIEN LOI JS:\n" + message + "\nDong: " + lineno + "\nFile: " + source);
    return false;
};

function selectLTC(row) {
    try {
        document.querySelectorAll('#ltcTable tbody tr').forEach(function(r) { r.classList.remove('selected'); });
        row.classList.add('selected');

        var maltc  = row.getAttribute('data-maltc');
        var huylop = row.getAttribute('data-huylop') === 'true';
        var batdau = row.getAttribute('data-batdau')  || '';
        var ketthuc= row.getAttribute('data-ketthuc') || '';
        var hethan = row.getAttribute('data-hethan')  || '';
        var lydo   = row.getAttribute('data-lydohuy') || '';

        var disp = document.getElementById('ltcMaltcDisplay');
        if (disp) disp.value = maltc;
        var valEl = document.getElementById('ltcMaltc');
        if (valEl) valEl.value = maltc;
        var act = document.getElementById('ltcAction');
        if (act) act.value = 'update';
        var huyEl = document.getElementById('ltcHuylop');
        if (huyEl) huyEl.checked = huylop;

        // Fill all [data-field] inputs AND selects from hidden cells
        document.querySelectorAll('[data-field]').forEach(function(el) {
            var field = el.getAttribute('data-field');
            var cell = row.querySelector('[data-col="' + field + '"]');
            if (!cell) return;
            var val = cell.textContent.trim();
            el.value = val;   // works for both <input> and <select>
        });

        // Detail bar
        var bar = document.getElementById('ltcDetailBar');
        if (bar) {
            bar.classList.add('show');
            var d1 = document.getElementById('dBarBatdau');  if(d1) d1.textContent = batdau  || '(Chưa đặt)';
            var d2 = document.getElementById('dBarKetthuc'); if(d2) d2.textContent = ketthuc || '(Chưa đặt)';
            var d3 = document.getElementById('dBarHethan');  if(d3) d3.textContent = hethan  || '(Chưa đặt)';
            var d4 = document.getElementById('dBarLydo');    if(d4) d4.textContent = lydo    || '—';
            var d5 = document.getElementById('dBarLydoWrapper'); if(d5) d5.style.display = huylop ? '' : 'none';
        }
    } catch(err) {
        alert("Loi trong selectLTC: " + err.message);
    }
}

function btnThemOpen() {
    try {
        var actionEl = document.getElementById('ltcAction');
        if (actionEl) actionEl.value = 'add';
        
        var maltcEl = document.getElementById('ltcMaltc');
        if (maltcEl) maltcEl.value = '';
        
        var displayEl = document.getElementById('ltcMaltcDisplay');
        if (displayEl) displayEl.value = '(Tự động tăng)';
        
        var huylopEl = document.getElementById('ltcHuylop');
        if (huylopEl) huylopEl.checked = false;
        
        var nkEl = document.querySelector('input[name="nienkhoa"]');
        if (nkEl) nkEl.value = '';
        
        var nhomEl = document.querySelector('input[name="nhom"]');
        if (nhomEl) nhomEl.value = '1';
        
        var minEl = document.querySelector('input[name="sosvtoithieu"]');
        if (minEl) minEl.value = '20';
        
        var maxEl = document.querySelector('input[name="sosvtoida"]');
        if (maxEl) maxEl.value = '40';
        
        var bdEl = document.querySelector('input[name="ngaybatdauDk"]');
        if (bdEl) bdEl.value = '';
        
        var ktEl = document.querySelector('input[name="ngayketthucDk"]');
        if (ktEl) ktEl.value = '';
        
        var hhEl = document.querySelector('input[name="ngayhethanHuy"]');
        if (hhEl) hhEl.value = '';
        
        var lydoEl = document.querySelector('input[name="lydohuy"]');
        if (lydoEl) lydoEl.value = '';

        document.querySelectorAll('#ltcTable tbody tr').forEach(function(r) { 
            r.classList.remove('selected'); 
        });
        
        var detailBar = document.getElementById('ltcDetailBar');
        if (detailBar) detailBar.classList.remove('show');
    } catch(err) {
        alert("Loi trong btnThemOpen: " + err.message);
    }
}

function btnXoaOpen() {
    try {
        var maltc = document.getElementById('ltcMaltc').value;
        if (!maltc) { alert('Vui lòng chọn lớp tín chỉ cần xóa!'); return; }
        var row = document.querySelector('#ltcTable tbody tr.selected');
        if (confirm('Bạn có chắc chắn muốn xóa lớp tín chỉ này?')) {
            var nextMaltc = '';
            if (row) {
                var nextRow = row.nextElementSibling || row.previousElementSibling;
                if (nextRow) nextMaltc = nextRow.getAttribute('data-maltc') || '';
            }
            var f = document.createElement('form'); f.method='POST';
            f.action = '${pageContext.request.contextPath}/loptinchi/delete';
            var i = document.createElement('input'); i.type='hidden'; i.name='maltc'; i.value=maltc; f.appendChild(i);
            var i2 = document.createElement('input'); i2.type='hidden'; i2.name='nextMaltc'; i2.value=nextMaltc; f.appendChild(i2);
            document.body.appendChild(f); f.submit();
        }
    } catch(err) {
        alert("Loi trong btnXoaOpen: " + err.message);
    }
}

window.addEventListener('load', function() {
    // === Wire up Ghi button validation ===
    var ghiBtn = document.getElementById('btnGhiSubmit');
    if (ghiBtn) {
        ghiBtn.addEventListener('click', function(e) {
            e.preventDefault();
            var form = document.getElementById('ltcForm');
            if (!form) { alert('LOI: Khong tim thay form!'); return; }

            var errors = [];
            var nk = (form.querySelector('input[name="nienkhoa"]') || {}).value || '';
            nk = nk.trim();
            if (!nk) { errors.push('Nien khoa khong duoc de trong!'); }
            else {
                var nkOk = /^\d{4}-\d{4}$/.test(nk);
                if (!nkOk) { errors.push('Nien khoa phai co dang YYYY-YYYY (VD: 2025-2026)!'); }
                else {
                    var pp = nk.split('-');
                    var y1 = parseInt(pp[0]); var y2 = parseInt(pp[1]);
                    if (y2 <= y1) errors.push('Nam ket thuc nien khoa phai lon hon nam bat dau!');
                    var act = (document.getElementById('ltcAction') || {}).value || '';
                    if (act === 'add' && y1 < new Date().getFullYear()) {
                        errors.push('Khong duoc mo lop tin chi cho nien khoa trong qua khu (' + nk + ')!');
                    }
                }
            }

            var nhomEl = form.querySelector('input[name="nhom"]');
            if (nhomEl && (parseInt(nhomEl.value) < 1 || !nhomEl.value)) errors.push('Nhom phai >= 1!');

            var minEl = form.querySelector('input[name="sosvtoithieu"]');
            var maxEl = form.querySelector('input[name="sosvtoida"]');
            var minV = parseInt((minEl||{}).value||'0'); var maxV = parseInt((maxEl||{}).value||'0');
            if (minV <= 0) errors.push('Si so toi thieu phai > 0!');
            if (maxV < minV) errors.push('Si so toi da phai >= si so toi thieu!');

            var bd = (form.querySelector('input[name="ngaybatdauDk"]')||{}).value||'';
            var kt = (form.querySelector('input[name="ngayketthucDk"]')||{}).value||'';
            var hh = (form.querySelector('input[name="ngayhethanHuy"]')||{}).value||'';
            if (bd && kt && new Date(bd) > new Date(kt)) errors.push('Ngay bat dau DK phai truoc ngay ket thuc DK!');
            if (kt && hh && new Date(kt) > new Date(hh)) errors.push('Ngay ket thuc DK phai truoc han huy!');

            var huyEl = document.getElementById('ltcHuylop');
            var lydoEl = form.querySelector('input[name="lydohuy"]');
            if (huyEl && huyEl.checked && lydoEl && !lydoEl.value.trim()) errors.push('Huy lop phai nhap ly do!');

            if (errors.length > 0) {
                alert('LOI:\n- ' + errors.join('\n- '));
                return;
            }
            form.submit();
        });
    }

    // === Sync selected row on page load ===
    var activeMaltc = parseInt('${selectedMaltc}' || '0');
    if (activeMaltc > 0) {
        var rows = document.querySelectorAll('#ltcTable tbody tr');
        rows.forEach(function(row) {
            if (parseInt(row.getAttribute('data-maltc') || '0') === activeMaltc) {
                selectLTC(row);
                row.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        });
    }
});
</script>
</body>
</html>
