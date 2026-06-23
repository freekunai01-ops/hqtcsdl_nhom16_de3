<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
<meta charset="UTF-8">
<title>QLSV_HTC - Đăng ký Lớp tín chỉ</title>
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
<style>
.fp{background:#fff;border:1px solid #d1d5db;border-radius:4px;padding:12px;margin-bottom:12px}
.sv-search-panel{display:flex;gap:12px;margin-bottom:12px}
.sv-search-left{flex:0 0 420px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:4px;padding:12px}
.sv-search-right{flex:1;background:#fff;border:1px solid #e2e8f0;border-radius:4px;padding:12px}
.sv-list{max-height:160px;overflow-y:auto;border:1px solid #e2e8f0;border-radius:3px;margin-top:8px}
.sv-item{padding:6px 10px;cursor:pointer;font-size:12px;display:flex;justify-content:space-between;border-bottom:1px solid #f1f5f9}
.sv-item:hover{background:#dbeafe}.sv-item.active{background:#2563eb;color:#fff}
.sv-item .sv-name{font-weight:bold}.sv-item .sv-status{font-size:10px}
.stat-mini{display:inline-block;padding:4px 10px;border:1px solid #e2e8f0;border-radius:4px;margin-right:6px;font-size:11px;background:#f8fafc}
.stat-mini strong{color:#2563eb}
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
<div class="title-left"><i class="fas fa-clipboard-list"></i> Form: Đăng ký Lớp tín chỉ</div>
<div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
</div>
<div class="form-window-body">
<div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
<i class="fas fa-info-circle"></i> PGV chọn lớp hành chính rồi chọn sinh viên để đăng ký/hủy LTC; SV đăng nhập thì MASV bị khóa theo tài khoản. KHOA chỉ xem, không tick đăng ký/hủy.
</div>

<%-- ===== PGV/KHOA: Search SV Panel ===== --%>
<c:if test="${sessionScope.nhomQuyen == 'PGV' || sessionScope.nhomQuyen == 'KHOA'}">
<fieldset class="fp" style="border:1px solid #93c5fd;background:#f0f9ff;">
<legend style="font-size:13px;font-weight:bold;color:#1e40af;padding:0 8px;"><i class="fas fa-user-check"></i> Chọn sinh viên</legend>
<div class="sv-search-panel">
<div class="sv-search-left">
<div class="pane-row" style="margin-bottom:8px;">
<span class="pane-label" style="width:60px;">Lớp HC:</span>
<div class="pane-input-wrapper">
<form action="${pageContext.request.contextPath}/dangky/selectLop" method="post" style="display:flex;gap:8px;">
<select name="malop" class="pane-input" style="padding:4px 6px;" onchange="this.form.submit()">
<option value="">— Chọn lớp —</option>
<c:forEach items="${dsLopHC}" var="lhc">
<option value="${lhc.MALOP}" ${lhc.MALOP == selectedLopHC ? 'selected' : ''}>${lhc.MALOP} - ${lhc.TENLOP} (${lhc.SISO} SV)</option>
</c:forEach>
</select>
</form>
</div>
</div>
<c:if test="${not empty selectedLopHC}">
<div class="pane-row" style="margin-bottom:4px;">
<span class="pane-label" style="width:60px;">Tìm SV:</span>
<div class="pane-input-wrapper"><input type="text" id="svSearchInput" class="pane-input" placeholder="Nhập MASV hoặc họ tên..." oninput="filterSvList()"></div>
</div>
<div class="sv-list" id="svList">
<c:forEach items="${dsSvLop}" var="sv">
<div class="sv-item ${sv.MASV == svInfo.MASV ? 'active' : ''}" data-masv="${sv.MASV}" data-name="${sv.HO} ${sv.TEN}" onclick="pickSV('${sv.MASV}')">
<span class="sv-name">${sv.MASV} — ${sv.HO} ${sv.TEN}</span>
<span class="sv-status">
<c:choose>
<c:when test="${sv.DANGHIHOC == true}">❌ Nghỉ</c:when>
<c:when test="${sv.TOTNGHIEP == 1}">🎓 Tốt nghiệp</c:when>
<c:otherwise>✔ Đang học</c:otherwise>
</c:choose>
</span>
</div>
</c:forEach>
</div>
<div style="font-size:10px;color:#94a3b8;margin-top:4px;"><i class="fas fa-info-circle"></i> Gõ ý lọc theo lớp đang chọn, tìm được bằng MASV hoặc họ tên.</div>
</c:if>
</div>
<div class="sv-search-right">
<div style="font-size:12px;font-weight:bold;color:#475569;margin-bottom:8px;"><i class="fas fa-id-card"></i> Hồ sơ đăng ký đang chọn</div>
<c:choose>
<c:when test="${not empty svInfo}">
<div style="display:grid;grid-template-columns:1fr 1fr;gap:6px 20px;font-size:12px;">
<div><span style="color:#64748b;">Mã SV:</span> <strong>${svInfo.MASV}</strong></div>
<div><span style="color:#64748b;">Họ tên:</span> <strong>${svInfo.HO} ${svInfo.TEN}</strong></div>
<div><span style="color:#64748b;">Mã lớp:</span> <strong>${svInfo.MALOP}</strong></div>
<div><span style="color:#64748b;">Khoa:</span> <strong>${svInfo.MAKHOA}</strong></div>
</div>
<div style="margin-top:8px;">
<span class="stat-mini">Trạng thái: <strong><c:choose><c:when test="${svInfo.DANGHIHOC == true}">Nghỉ học</c:when><c:when test="${svInfo.TOTNGHIEP == 1}">Đã tốt nghiệp</c:when><c:otherwise>Đang học</c:otherwise></c:choose></strong></span>
<span class="stat-mini">HK ${hocky}/${nienkhoa}: <strong>${daDangKyHK} môn</strong></span>
<span class="stat-mini">Tổng LTC: <strong>${fn:length(myLTC)} lớp</strong></span>
</div>
</c:when>
<c:otherwise><div style="text-align:center;color:#94a3b8;padding:20px;"><i class="fas fa-hand-pointer" style="font-size:24px;"></i><p style="margin:8px 0 0;">Chọn lớp HC rồi click sinh viên</p></div></c:otherwise>
</c:choose>
</div>
</div>
</fieldset>
</c:if>

<%-- ===== SV: Hồ sơ sinh viên (không search) ===== --%>
<c:if test="${sessionScope.nhomQuyen == 'SV' && not empty svInfo}">
<fieldset class="fp"><legend style="font-size:13px;font-weight:bold;color:#475569;padding:0 8px;"><i class="fas fa-id-card"></i> Hồ sơ sinh viên</legend>
<div style="display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:8px;font-size:12px;">
<div><span style="color:#64748b;">Mã SV:</span> <strong>${svInfo.MASV}</strong></div>
<div><span style="color:#64748b;">Họ tên:</span> <strong>${svInfo.HO} ${svInfo.TEN}</strong></div>
<div><span style="color:#64748b;">Mã lớp:</span> <strong>${svInfo.MALOP}</strong></div>
<div><span style="color:#64748b;">Khoa:</span> <strong>${svInfo.MAKHOA}</strong></div>
</div>
<div style="margin-top:8px;">
<span class="stat-mini">Trạng thái: <strong><c:choose><c:when test="${svInfo.DANGHIHOC == true}">Nghỉ học</c:when><c:when test="${svInfo.TOTNGHIEP == 1}">Đã tốt nghiệp</c:when><c:otherwise>Đang học</c:otherwise></c:choose></strong></span>
<span class="stat-mini">HK ${hocky}/${nienkhoa}: <strong>${daDangKyHK} môn</strong></span>
<span class="stat-mini">Tổng LTC: <strong>${fn:length(myLTC)} lớp</strong></span>
</div>
</fieldset>
</c:if>

<c:if test="${not empty svInfo}">
<%-- ===== Niên khóa / Học kỳ filter ===== --%>
<fieldset class="fp"><legend style="font-size:12px;font-weight:bold;color:#475569;padding:0 8px;">Niên khóa / Học kỳ</legend>
<form action="${pageContext.request.contextPath}/dangky/search" method="post" style="display:flex;gap:20px;align-items:center;">
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:75px;">Niên khóa:</span><input type="text" name="nienkhoa" class="pane-input" style="width:130px;" placeholder="2025-2026" value="${nienkhoa}" required></div>
<div class="pane-row" style="margin:0;"><span class="pane-label" style="width:60px;">Học kỳ:</span><select name="hocky" class="pane-input" style="width:80px;padding:4px 6px;" required><option value="1" ${hocky==1?'selected':''}>1</option><option value="2" ${hocky==2?'selected':''}>2</option><option value="3" ${hocky==3?'selected':''}>3</option></select></div>
<button type="submit" class="win-form-btn btn-save" style="padding:4px 15px;min-width:auto;"><i class="fas fa-search"></i> Lọc</button>
</form>
</fieldset>

<div style="display:flex;gap:12px;">
<%-- ===== LTC đang mở ===== --%>
<div style="flex:1;">
<form action="${pageContext.request.contextPath}/dangky/saveMultiple" method="post">
<input type="hidden" name="nienkhoa" value="${nienkhoa}"><input type="hidden" name="hocky" value="${hocky}">
<fieldset class="fp"><legend style="font-size:12px;font-weight:bold;color:#475569;padding:0 8px;">Lớp tín chỉ đang mở — chọn để đăng ký (<span id="alreadyRegCount">0</span> đã chọn)</legend>
<div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="regSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('regTable','regSearch')"></div>
<div class="win-table-container" style="max-height:220px;">
<table class="win-table" id="regTable"><thead><tr>
<th style="width:40px;text-align:center;">Chọn</th>
<th data-sort-col="1">Mã MH</th><th data-sort-col="2">Tên môn học</th><th data-sort-col="3">Nhóm</th><th data-sort-col="4">TC</th>
<th data-sort-col="5">GV giảng</th><th data-sort-col="6">Hết ĐK</th><th data-sort-col="7">Trạng thái</th><th data-sort-col="8">SV ĐK/Max</th>
</tr></thead><tbody>
<c:if test="${not empty dsltc}"><jsp:useBean id="now" class="java.util.Date"/>
<c:forEach items="${dsltc}" var="l">
<c:set var="isReg" value="false"/><c:forEach items="${daDangKy}" var="dk"><c:if test="${dk.MALTC==l.MALTC}"><c:set var="isReg" value="true"/></c:if></c:forEach>
<c:set var="isFull" value="${l.SOSVDK>=l.SOSVTOIDA}"/>
<c:set var="dlOk" value="true"/><c:set var="dlSt" value="Đang mở"/>
<c:if test="${not empty l.NGAYBATDAU_DK && now.time < l.NGAYBATDAU_DK.time}"><c:set var="dlOk" value="false"/><c:set var="dlSt" value="Chưa tới hạn"/></c:if>
<c:if test="${not empty l.NGAYKETTHUC_DK && now.time > l.NGAYKETTHUC_DK.time}"><c:set var="dlOk" value="false"/><c:set var="dlSt" value="Hết hạn ĐK"/></c:if>
<tr><td style="text-align:center;">
<c:choose>
<c:when test="${isReg}"><span style="color:#16a34a;font-weight:bold;font-size:10px;">✔ Đã ĐK</span></c:when>
<c:when test="${isFull}"><span style="color:#dc2626;font-size:10px;">Đầy</span></c:when>
<c:when test="${!dlOk}"><span style="color:#9ca3af;font-size:10px;">🔒</span></c:when>
<c:when test="${sessionScope.nhomQuyen=='KHOA'}"><span style="color:#9ca3af;font-size:10px;">—</span></c:when>
<c:otherwise><input type="checkbox" name="selectedLtcs" value="${l.MALTC}" onchange="updateSelectedCount()"></c:otherwise>
</c:choose>
</td>
<td>${l.MAMH}</td><td>${l.TENMH}</td><td>${l.NHOM}</td>
<td style="text-align:center;"><span style="background:#dbeafe;color:#1e40af;padding:1px 6px;border-radius:3px;font-size:10px;font-weight:bold;">${l.TINCHI}</span></td>
<td>${l.HOTENGV}</td>
<td style="font-size:11px;"><fmt:formatDate value="${l.NGAYKETTHUC_DK}" pattern="yyyy-MM-dd"/></td>
<td style="font-size:11px;font-weight:bold;color:${dlOk?'#16a34a':'#dc2626'};">${dlSt}</td>
<td style="text-align:center;${isFull?'color:#dc2626;font-weight:bold;':''}">${l.SOSVDK}/${l.SOSVTOIDA}</td>
</tr></c:forEach></c:if>
<c:if test="${empty dsltc}"><tr><td colspan="9" style="text-align:center;color:#94a3b8;padding:20px;">Không tìm thấy LTC nào.</td></tr></c:if>
</tbody></table></div>
<div id="limitWarning" style="display:none;padding:6px 12px;margin-top:8px;background:#fef2f2;border:1px solid #fca5a5;border-radius:4px;font-size:12px;color:#dc2626;font-weight:bold;"></div>
<div class="form-buttons-row" style="margin-top:8px;">
<c:if test="${sessionScope.nhomQuyen != 'KHOA'}">
<button type="submit" class="win-form-btn btn-save"><i class="fas fa-check-square"></i> Đăng ký (<span id="newRegCount">0</span>)</button>
</c:if>
<button type="button" class="win-form-btn" onclick="window.location.href='${pageContext.request.contextPath}/home'"><i class="fas fa-sign-out-alt"></i> Thoát</button>
</div>
</fieldset></form>
</div>

<%-- ===== Panel phải: LTC của SV ===== --%>
<div style="flex:0 0 400px;">
<fieldset class="fp">
<legend style="font-size:12px;font-weight:bold;color:#475569;padding:0 8px;">
<c:choose><c:when test="${sessionScope.nhomQuyen=='SV'}">Lớp tín chỉ của tôi</c:when><c:otherwise>Lớp tín chỉ của sinh viên — ${svInfo.MASV}</c:otherwise></c:choose>
<c:if test="${not empty myLTC}"> (${fn:length(myLTC)} lớp)</c:if>
</legend>
<div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="myLTCSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('myLTCTable','myLTCSearch')"></div>
<div class="win-table-container" style="max-height:280px;">
<table class="win-table" id="myLTCTable"><thead><tr>
<th data-sort-col="0">Niên khóa</th><th data-sort-col="1">HK</th><th data-sort-col="2">Tên môn học</th>
<th data-sort-col="3">N</th><th data-sort-col="4">TC</th><th data-sort-col="5">Hạn hủy</th><th data-sort-col="6">TT hủy</th><th data-sort-col="7">Điểm HM</th><th style="width:35px;">Hủy</th>
</tr></thead><tbody>
<c:if test="${not empty myLTC}"><c:forEach items="${myLTC}" var="m">
<c:set var="canC" value="true"/><c:set var="cSt" value="Còn hạn hủy"/>
<c:if test="${not empty m.NGAYHETHAN_HUY && now.time > m.NGAYHETHAN_HUY.time}"><c:set var="canC" value="false"/><c:set var="cSt" value="Hết hạn hủy"/></c:if>
<c:if test="${m.DIEM_HM != null}"><c:set var="canC" value="false"/><c:set var="cSt" value="Đã có điểm"/></c:if>
<tr><td>${m.NIENKHOA}</td><td>${m.HOCKY}</td><td>${m.TENMH}</td><td>${m.NHOM}</td>
<td style="text-align:center;"><span style="background:#dbeafe;color:#1e40af;padding:1px 5px;border-radius:3px;font-size:10px;font-weight:bold;">${m.TINCHI}</span></td>
<td style="font-size:11px;"><fmt:formatDate value="${m.NGAYHETHAN_HUY}" pattern="yyyy-MM-dd"/></td>
<td style="font-size:11px;font-weight:bold;color:${canC?'#16a34a':'#dc2626'};">${cSt}</td>
<td style="text-align:center;font-weight:bold;<c:choose><c:when test="${m.DIEM_HM==null}">color:#94a3b8;</c:when><c:when test="${m.DIEM_HM<5}">color:#dc2626;</c:when><c:when test="${m.DIEM_HM<7}">color:#d97706;</c:when><c:otherwise>color:#16a34a;</c:otherwise></c:choose>">
<c:choose><c:when test="${m.DIEM_HM!=null}"><fmt:formatNumber value="${m.DIEM_HM}" pattern="#0.00"/></c:when><c:otherwise>—</c:otherwise></c:choose></td>
<td style="text-align:center;">
<c:if test="${canC && sessionScope.nhomQuyen != 'KHOA'}">
<form action="${pageContext.request.contextPath}/dangky/cancel" method="post" style="display:inline;" onsubmit="return confirm('Hủy đăng ký môn ${m.TENMH}?');">
<input type="hidden" name="maltc" value="${m.MALTC}">
<button type="submit" class="win-form-btn" style="padding:1px 5px;min-width:auto;height:18px;font-size:10px;color:#dc2626;border-color:#fca5a5;">✕</button>
</form></c:if></td></tr>
</c:forEach></c:if>
<c:if test="${empty myLTC}"><tr><td colspan="9" style="text-align:center;color:#94a3b8;padding:20px;">Chưa đăng ký LTC nào.</td></tr></c:if>
</tbody></table></div>
</fieldset>
</div>
</div>
</c:if>

<c:if test="${empty svInfo && sessionScope.nhomQuyen == 'SV'}">
<div style="text-align:center;padding:40px;color:#64748b;"><i class="fas fa-user-slash fa-3x" style="color:#cbd5e1;"></i><h5>Không tìm thấy thông tin sinh viên</h5></div>
</c:if>
</div>
<div class="form-window-status">
<span>Đã ĐK: ${not empty daDangKyHK ? daDangKyHK : 0} lớp | HK${hocky}/${nienkhoa} | Hôm nay: <fmt:formatDate value="<%=new java.util.Date()%>" pattern="yyyy-MM-dd"/></span>
<span>SV: ${not empty svInfo.MASV ? svInfo.MASV : '—'} — ${svInfo.HO} ${svInfo.TEN}</span>
</div>
</div>
</main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
var MAX_MON=8, daDangKyHK=${not empty daDangKyHK?daDangKyHK:0};
function updateSelectedCount(){
var cbs=document.querySelectorAll('input[name="selectedLtcs"]');
var cnt=document.querySelectorAll('input[name="selectedLtcs"]:checked').length;
var rem=MAX_MON-daDangKyHK-cnt;
var e1=document.getElementById('newRegCount');if(e1)e1.textContent=cnt;
var e2=document.getElementById('alreadyRegCount');if(e2)e2.textContent=cnt;
cbs.forEach(function(cb){cb.disabled=(!cb.checked&&rem<=0);});
var w=document.getElementById('limitWarning');
if(w){if(rem<=0&&cnt>0){w.style.display='block';w.style.color='#dc2626';w.textContent='Đã đạt giới hạn '+MAX_MON+' môn/HK';}
else if(rem<=2&&rem>0){w.style.display='block';w.style.color='#d97706';w.textContent='Còn '+rem+' môn nữa là đạt giới hạn';}
else{w.style.display='none';}}
}
function filterSvList(){
var q=document.getElementById('svSearchInput').value.toLowerCase();
document.querySelectorAll('#svList .sv-item').forEach(function(el){
var id=el.getAttribute('data-masv').toLowerCase();
var nm=el.getAttribute('data-name').toLowerCase();
el.style.display=(id.indexOf(q)>=0||nm.indexOf(q)>=0)?'':'none';
});
}
function pickSV(masv){
var f=document.createElement('form');f.method='POST';
f.action='${pageContext.request.contextPath}/dangky/selectStudent';
var i=document.createElement('input');i.type='hidden';i.name='masv';i.value=masv;
f.appendChild(i);document.body.appendChild(f);f.submit();
}
document.addEventListener("DOMContentLoaded",function(){updateSelectedCount();});
</script>
</body>
</html>
