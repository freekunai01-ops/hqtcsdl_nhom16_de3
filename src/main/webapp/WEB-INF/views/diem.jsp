<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>QLSV_HTC - Nhập điểm</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
<style>
.fp{background:#fff;border:1px solid #d1d5db;border-radius:4px;padding:12px;margin-bottom:12px}
.stat-card{display:inline-block;border:1px solid #e2e8f0;border-radius:4px;padding:8px 18px;margin-right:8px;text-align:center;min-width:100px;background:#f8fafc}
.stat-card .val{font-size:20px;font-weight:bold;display:block}.stat-card .lbl{font-size:10px;color:#64748b}
.ltc-info{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-top:8px}
.ltc-info-item{background:#f8fafc;border:1px solid #e2e8f0;border-radius:4px;padding:6px 10px;font-size:12px}
.ltc-info-item .ii-label{color:#64748b;font-size:10px}.ltc-info-item .ii-val{font-weight:bold}
.diem-input{text-align:center;width:65px;padding:3px 4px;border:1px solid #d1d5db;border-radius:3px;font-size:12px}
.diem-input:focus{border-color:#2563eb;outline:none;box-shadow:0 0 0 2px rgba(37,99,235,.15)}
.diem-input.invalid{border-color:#dc2626;background:#fef2f2}
.grade-hm{font-weight:bold;font-size:13px}.grade-chu{font-size:11px;font-weight:bold}
.grade-he4{font-size:11px}.grade-kq{font-size:10px;font-weight:bold;padding:2px 6px;border-radius:3px}
.kq-dat{background:#dcfce7;color:#16a34a}.kq-rot{background:#fef2f2;color:#dc2626}.kq-chua{background:#f1f5f9;color:#94a3b8}
</style>
</head>
<body>
<%@ include file="layout/header.jsp" %>
<div class="d-flex">
<%@ include file="layout/sidebar.jsp" %>
<main class="content-area">
<c:if test="${not empty success}"><div style="background:#d1e7dd;color:#0f5132;border:1px solid #badbcc;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12.5px;"><i class="fas fa-check-circle"></i> ${success}</div></c:if>
<c:if test="${not empty error}"><div style="background:#f8d7da;color:#842029;border:1px solid #f5c2c7;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12.5px;"><i class="fas fa-exclamation-triangle"></i> <strong>LỖI:</strong> ${error}</div></c:if>
<div class="desktop-form-window">
<div class="form-window-titlebar">
<div class="title-left"><i class="fas fa-edit"></i> Form: Nhập điểm</div>
<div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
</div>
<div class="form-window-body">
<div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
<i class="fas fa-info-circle"></i> Chọn lớp tín chỉ để nhập CC/GK/CK. Hệ thống tự tính điểm hết môn, điểm chữ, hệ 4 và kết quả; điểm đã có sẽ khóa hủy đăng ký ở form Đăng ký LTC.
</div>

<%-- Bộ lọc LTC --%>
<fieldset class="fp" style="border:1px solid #93c5fd;background:#f0f9ff;">
<legend style="font-size:12px;font-weight:bold;color:#1e40af;padding:0 8px;"><i class="fas fa-filter"></i> Bộ lọc lớp tín chỉ</legend>
<form action="${pageContext.request.contextPath}/diem/load" method="post" style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;">
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:70px;">Niên khóa:</span>
<select name="nienkhoa" class="pane-input" style="padding:4px 6px;width:130px;">
<c:forEach items="${dsNienKhoa}" var="nk"><option value="${nk.NIENKHOA}" ${nk.NIENKHOA == nienkhoa ? 'selected' : ''}>${nk.NIENKHOA}</option></c:forEach>
</select></div>
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:55px;">Học kỳ:</span>
<select name="hocky" class="pane-input" style="padding:4px 6px;width:70px;">
<option value="1" ${hocky==1?'selected':''}>1</option><option value="2" ${hocky==2?'selected':''}>2</option><option value="3" ${hocky==3?'selected':''}>3</option>
</select></div>
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:60px;">Môn học:</span>
<select name="mamh" class="pane-input" style="padding:4px 6px;width:200px;">
<c:forEach items="${dsmh}" var="mh"><option value="${mh.MAMH}" ${mh.MAMH == mamh ? 'selected' : ''}>${mh.MAMH} - ${mh.TENMH}</option></c:forEach>
</select></div>
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:45px;">Nhóm:</span>
<input type="number" name="nhom" class="pane-input" min="1" value="${nhom != null ? nhom : 1}" style="width:60px;"></div>
<button type="submit" class="win-form-btn btn-save" style="padding:4px 15px;min-width:auto;"><i class="fas fa-play"></i> Load bảng điểm</button>
</form>
</fieldset>

<%-- Thông tin LTC + Thống kê --%>
<c:if test="${not empty dssv}">
<div class="ltc-info">
<div class="ltc-info-item"><div class="ii-label">Môn học</div><div class="ii-val">${tenmh}</div></div>
<div class="ltc-info-item"><div class="ii-label">Giảng viên</div><div class="ii-val">${hotenGV}</div></div>
<div class="ltc-info-item"><div class="ii-label">Sĩ số ĐK/Tối thiểu</div><div class="ii-val">${totalSV}/${sosvToithieu}</div></div>
<div class="ltc-info-item"><div class="ii-label">Trạng thái LTC</div><div class="ii-val">
<c:choose><c:when test="${huylop}"><span style="color:#dc2626;">Đã hủy</span></c:when><c:otherwise><span style="color:#16a34a;">Đang mở</span></c:otherwise></c:choose>
</div></div>
</div>
<div style="margin:12px 0;">
<div class="stat-card"><span class="val" style="color:#1e40af;">${totalSV}</span><span class="lbl">Tổng SV</span></div>
<div class="stat-card"><span class="val" style="color:#16a34a;">${daNhap}</span><span class="lbl">Đã nhập</span></div>
<div class="stat-card"><span class="val" style="color:#d97706;">${chuaNhap}</span><span class="lbl">Chưa nhập</span></div>
<div class="stat-card"><span class="val" style="color:#16a34a;">${dat}</span><span class="lbl">Đạt</span></div>
<div class="stat-card"><span class="val" style="color:#dc2626;">${rot}</span><span class="lbl">Rớt</span></div>
<div class="stat-card"><span class="val" style="color:#7c3aed;">${tyLeDat}%</span><span class="lbl">Tỷ lệ đạt</span></div>
</div>
</c:if>

<c:choose>
<c:when test="${empty dssv && empty maltc}">
<div style="text-align:center;padding:40px;background:#fff;border:1px solid #cbd5e1;border-radius:4px;color:#64748b;">
<i class="fas fa-table fa-3x" style="color:#cbd5e1;"></i>
<h5 style="margin:8px 0 0;">Chọn lớp tín chỉ và nhấn "Load bảng điểm" để tải danh sách sinh viên.</h5>
</div>
</c:when>
<c:when test="${huylop}">
<div style="text-align:center;padding:30px;background:#fef2f2;border:1px solid #fca5a5;border-radius:4px;color:#dc2626;">
<i class="fas fa-ban fa-2x"></i><h5 style="margin:8px 0 0;">Lớp tín chỉ đã hủy — không nhập điểm.</h5>
</div>
</c:when>
<c:when test="${empty dssv && not empty maltc}">
<div style="text-align:center;padding:30px;background:#fff;border:1px solid #cbd5e1;border-radius:4px;color:#64748b;">
<i class="fas fa-user-slash fa-2x" style="color:#cbd5e1;"></i><h5 style="margin:8px 0 0;">Chưa có sinh viên đăng ký lớp tín chỉ này.</h5>
</div>
</c:when>
<c:otherwise>
<form action="${pageContext.request.contextPath}/diem/save" method="post" id="gradeForm" onsubmit="return validateAndSubmit()">
<input type="hidden" name="maltc" value="${maltc}"><input type="hidden" name="nienkhoa" value="${nienkhoa}">
<input type="hidden" name="hocky" value="${hocky}"><input type="hidden" name="mamh" value="${mamh}"><input type="hidden" name="nhom" value="${nhom}">
<fieldset class="fp">
<legend style="font-size:12px;font-weight:bold;color:#475569;padding:0 8px;">Bảng nhập điểm — HM = CC×0.1 + GK×0.3 + CK×0.6</legend>
<div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="diemSearch" placeholder="Tìm SV..." oninput="initTableSearch('diemTable','diemSearch')"></div>
<div class="win-table-container" style="max-height:380px;">
<table class="win-table" id="diemTable"><thead><tr>
<th style="width:35px;text-align:center;">STT</th>
<th data-sort-col="1">Mã SV</th><th data-sort-col="2">Họ tên</th><th data-sort-col="3">Lớp</th>
<th style="width:70px;text-align:center;">CC</th><th style="width:70px;text-align:center;">GK</th><th style="width:70px;text-align:center;">CK</th>
<th style="width:65px;text-align:center;">HM</th><th style="width:50px;text-align:center;">Chữ</th>
<th style="width:45px;text-align:center;">Hệ 4</th><th style="width:60px;text-align:center;">Kết quả</th>
</tr></thead><tbody>
<c:forEach items="${dssv}" var="sv" varStatus="st">
<tr class="grade-row">
<td style="text-align:center;">${st.index+1}</td>
<td>${sv.MASV}<input type="hidden" name="masv[]" value="${sv.MASV}"></td>
<td>${sv.HOTENSV}</td><td>${sv.MALOP}</td>
<td style="text-align:center;"><input type="number" name="diemCC[]" class="diem-input dcc" min="0" max="10" step="1" value="${sv.DIEM_CC}" ${sessionScope.nhomQuyen != 'PGV' ? 'disabled' : ''} oninput="recalcRow(this)"></td>
<td style="text-align:center;"><input type="number" name="diemGK[]" class="diem-input dgk" min="0" max="10" step="0.5" value="${sv.DIEM_GK}" ${sessionScope.nhomQuyen != 'PGV' ? 'disabled' : ''} oninput="recalcRow(this)"></td>
<td style="text-align:center;"><input type="number" name="diemCK[]" class="diem-input dck" min="0" max="10" step="0.5" value="${sv.DIEM_CK}" ${sessionScope.nhomQuyen != 'PGV' ? 'disabled' : ''} oninput="recalcRow(this)"></td>
<td style="text-align:center;" class="td-hm"><span class="grade-hm hm-val"><c:if test="${sv.DIEM_HM != null}"><fmt:formatNumber value="${sv.DIEM_HM}" maxFractionDigits="2"/></c:if></span></td>
<td style="text-align:center;" class="td-chu"><span class="grade-chu chu-val"></span></td>
<td style="text-align:center;" class="td-he4"><span class="grade-he4 he4-val"></span></td>
<td style="text-align:center;" class="td-kq"><span class="grade-kq kq-val kq-chua">—</span></td>
</tr>
</c:forEach>
</tbody></table></div>
</fieldset>
<div class="form-buttons-row">
<c:if test="${sessionScope.nhomQuyen == 'PGV'}">
<button type="submit" class="win-form-btn btn-save"><i class="fas fa-save"></i> Ghi bảng điểm</button>
<button type="button" class="win-form-btn" onclick="window.location.reload()"><i class="fas fa-undo"></i> Phục hồi</button>
</c:if>
<button type="button" class="win-form-btn" onclick="window.location.href='${pageContext.request.contextPath}/home'"><i class="fas fa-sign-out-alt"></i> Thoát</button>
</div>
</form>
</c:otherwise>
</c:choose>
</div>
<div class="form-window-status">
<span><c:choose><c:when test="${not empty maltc}">LTC: #${maltc} - ${tenmh} - nhóm ${nhom}</c:when><c:otherwise>Chưa load bảng điểm</c:otherwise></c:choose></span>
<span>Công thức: CC×0.1 + GK×0.3 + CK×0.6 | ≥5: Đạt</span>
</div>
</div>
</main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
function hmToChu(hm){if(hm>=9)return'A+';if(hm>=8.5)return'A';if(hm>=8)return'B+';if(hm>=7)return'B';if(hm>=6.5)return'C+';if(hm>=5.5)return'C';if(hm>=5)return'D+';if(hm>=4)return'D';return'F';}
function hmToHe4(hm){if(hm>=9)return 4.0;if(hm>=8.5)return 3.7;if(hm>=8)return 3.5;if(hm>=7)return 3.0;if(hm>=6.5)return 2.5;if(hm>=5.5)return 2.0;if(hm>=5)return 1.5;if(hm>=4)return 1.0;return 0;}
function recalcRow(el){
var row=el.closest('tr');
var cc=parseFloat(row.querySelector('.dcc').value),gk=parseFloat(row.querySelector('.dgk').value),ck=parseFloat(row.querySelector('.dck').value);
var hmEl=row.querySelector('.hm-val'),chuEl=row.querySelector('.chu-val'),he4El=row.querySelector('.he4-val'),kqEl=row.querySelector('.kq-val');
[row.querySelector('.dcc'),row.querySelector('.dgk'),row.querySelector('.dck')].forEach(function(inp){
var v=parseFloat(inp.value);if(inp.value!==''&&(v<0||v>10||isNaN(v)))inp.classList.add('invalid');else inp.classList.remove('invalid');});
if(!isNaN(ck)){var ccV=isNaN(cc)?0:cc,gkV=isNaN(gk)?0:gk;var hm=ccV*0.1+gkV*0.3+ck*0.6;hm=Math.round(hm*100)/100;
hmEl.textContent=hm.toFixed(2);hmEl.style.color=hm>=5?'#16a34a':'#dc2626';
chuEl.textContent=hmToChu(hm);chuEl.style.color=hm>=5?'#1e40af':'#dc2626';
he4El.textContent=hmToHe4(hm).toFixed(1);
kqEl.textContent=hm>=5?'Đạt':'Rớt';kqEl.className='grade-kq kq-val '+(hm>=5?'kq-dat':'kq-rot');
}else{hmEl.textContent='';chuEl.textContent='';he4El.textContent='';kqEl.textContent='—';kqEl.className='grade-kq kq-val kq-chua';}
}
function validateAndSubmit(){
var ok=true;document.querySelectorAll('.diem-input').forEach(function(inp){
var v=parseFloat(inp.value);if(inp.value!==''&&(v<0||v>10||isNaN(v))){inp.classList.add('invalid');ok=false;}});
if(!ok){alert('Có điểm không hợp lệ (phải từ 0–10 hoặc để trống)!');return false;}
return confirm('Xác nhận ghi tất cả điểm đã nhập?');
}
document.addEventListener("DOMContentLoaded",function(){document.querySelectorAll('.grade-row').forEach(function(r){recalcRow(r.querySelector('.dck')||r.querySelector('.dgk')||r.querySelector('.dcc'));});});
</script>
</body>
</html>
