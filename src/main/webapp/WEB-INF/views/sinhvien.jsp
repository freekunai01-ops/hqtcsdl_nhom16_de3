<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Sinh viên (SubForm)</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .stat-cards{display:flex;gap:10px;margin-bottom:12px}.stat-card{flex:1;padding:10px 14px;border-radius:6px;border:1px solid #e2e8f0;background:#fff}.stat-card .stat-label{font-size:11px;color:#64748b;margin-bottom:2px}.stat-card .stat-value{font-size:22px;font-weight:bold}.stat-card.blue .stat-value{color:#2563eb}.stat-card.green .stat-value{color:#16a34a}.stat-card.pink .stat-value{color:#ec4899}.stat-card.red .stat-value{color:#dc2626}
        .filter-tabs{display:flex;gap:0;margin-bottom:8px}.filter-tab{padding:5px 14px;font-size:12px;font-weight:bold;cursor:pointer;border:1px solid #cbd5e1;background:#f8fafc;color:#475569;transition:all .15s}.filter-tab:first-child{border-radius:4px 0 0 4px}.filter-tab:last-child{border-radius:0 4px 4px 0}.filter-tab.active{background:#2563eb;color:#fff;border-color:#2563eb}.filter-tab:hover:not(.active){background:#e2e8f0}
        .badge-status{display:inline-block;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:bold;white-space:nowrap}.badge-danghoc{background:#dcfce7;color:#166534;border:1px solid #86efac}.badge-nghihoc{background:#fef2f2;color:#dc2626;border:1px solid #fca5a5}
        .filter-hint{font-size:11px;color:#94a3b8;margin-left:auto;display:flex;align-items:center;gap:4px}
        .subform-grid{display:flex;gap:12px}.subform-left{flex:0 0 320px}.subform-right{flex:1}
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
                <div class="title-left"><i class="fas fa-user-friends"></i> Form: Danh sách Sinh viên (SubForm Lớp → Sinh viên)</div>
                <div class="title-right"><span class="window-btn green"></span><span class="window-btn yellow"></span><span class="window-btn red"></span></div>
            </div>
            <div class="form-window-body">
                <div style="background:#dbeafe;border:1px solid #93c5fd;border-radius:4px;padding:5px 12px;margin-bottom:10px;font-size:11.5px;color:#1e40af;">
                    <i class="fas fa-info-circle"></i>
                    <strong>SubForm</strong> nghĩa là chọn Lớp ở cấp cha, bảng con tự lọc <strong>Sinh viên thuộc lớp đó</strong>.
                    <c:if test="${sessionScope.nhomQuyen == 'KHOA'}"> | <strong>KHOA</strong> xem dữ liệu read-only.</c:if>
                </div>

                <c:if test="${not empty selectedLop}">
                <div class="stat-cards">
                    <div class="stat-card blue"><div class="stat-label">SV trong lớp</div><div class="stat-value">${svInLop}</div></div>
                    <div class="stat-card green"><div class="stat-label">Nam</div><div class="stat-value">${svNam}</div></div>
                    <div class="stat-card pink"><div class="stat-label">Nữ</div><div class="stat-value">${svNu}</div></div>
                    <div class="stat-card red"><div class="stat-label">Nghỉ học</div><div class="stat-value">${svNghiHoc}</div></div>
                </div>
                </c:if>

                <div class="subform-grid">
                    <div class="subform-left">
                        <div class="pane-title">Cấp 1: Danh sách Lớp</div>
                        <!-- Bộ lọc Khoa cho Danh sách Lớp -->
                        <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                            <div style="display:flex; align-items:center; gap:8px; margin-bottom:8px;">
                                <span style="font-size:12px; font-weight:bold; color:#475569; white-space:nowrap;"><i class="fas fa-filter"></i> Lọc Khoa:</span>
                                <select id="svLopKhoaFilter" onchange="applyLopFilter()" style="flex:1; padding:4px 6px; font-size:12px; border:1px solid #cbd5e1; border-radius:4px; background:#fff; color:#1e293b; font-weight:bold;">
                                    <option value="ALL">-- Tất cả khoa --</option>
                                    <c:forEach items="${dskhoa}" var="k">
                                        <option value="${k.MAKHOA}">${k.TENKHOA}</option>
                                    </c:forEach>
                                </select>
                            </div>
                        </c:if>
                        <div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="svLopSearch" placeholder="Tìm kiếm lớp..." oninput="applyLopFilter()"></div>
                        <div class="win-table-container" style="max-height:220px;">
                            <table class="win-table" id="svLopTable">
                                <thead><tr>
                                    <th data-sort-key="MALOP" data-sort-col="0">Mã lớp</th>
                                    <th data-sort-key="TENLOP" data-sort-col="1">Tên lớp</th>
                                    <th data-sort-key="SISO" data-sort-col="2">Sĩ số</th>
                                </tr></thead>
                                <tbody>
                                    <c:forEach items="${dslop}" var="l">
                                        <tr onclick="window.location.href='${pageContext.request.contextPath}/sinhvien?malop=${l.MALOP}'"
                                            class="${l.MALOP.trim() == selectedLop ? 'selected' : ''}"
                                            data-makhoa="${l.MAKHOA.trim()}">
                                            <td data-col="MALOP">${l.MALOP}</td>
                                            <td data-col="TENLOP">${l.TENLOP}</td>
                                            <td style="text-align:center;font-weight:bold;"><c:choose><c:when test="${l.SISO > 0}"><span style="color:#2563eb">${l.SISO}</span></c:when><c:otherwise><span style="color:#94a3b8">${l.SISO}</span></c:otherwise></c:choose></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                        <span id="svLopTableFilterCount" class="table-filter-count"></span>
                        <c:if test="${not empty lopKhoaHoc}">
                            <div style="margin-top:6px;padding:4px 8px;background:#f8fafc;border:1px solid #e2e8f0;border-radius:3px;font-size:11px;color:#64748b;">
                                <i class="fas fa-bookmark"></i> Khóa: <strong>${lopKhoaHoc}</strong> | Khoa: <strong>${lopMaKhoa}</strong>
                            </div>
                        </c:if>
                    </div>

                    <div class="subform-right">
                        <c:if test="${not empty selectedLop}">
                            <div class="pane-title">Cấp 2: Sinh viên thuộc lớp ${selectedLop}</div>
                            <div style="display:flex;align-items:center;margin-bottom:6px;">
                                <div class="filter-tabs">
                                    <div class="filter-tab active" onclick="filterSV('all',this)">Tất cả</div>
                                    <div class="filter-tab" onclick="filterSV('danghoc',this)">Đang học</div>
                                    <div class="filter-tab" onclick="filterSV('nghihoc',this)">Nghỉ học</div>
                                    <div class="filter-tab" onclick="filterSV('codk',this)">Có ĐK/điểm</div>
                                </div>
                                <div class="filter-hint"><i class="fas fa-info-circle"></i> Có đăng ký/điểm: không xóa, chỉ đánh dấu nghỉ học</div>
                            </div>
                            <div class="table-search-box"><i class="fas fa-search"></i><input type="text" id="svSearch" placeholder="Tìm kiếm..." oninput="initTableSearch('svTable','svSearch')"></div>
                            <div class="win-table-container" style="max-height:180px;">
                                <table id="svTable" class="win-table">
                                    <thead><tr>
                                        <th data-sort-key="MASV" data-sort-col="0">Mã SV</th>
                                        <th data-sort-key="HOTEN" data-sort-col="1">Họ tên</th>
                                        <th data-sort-key="PHAI" data-sort-col="2">Phái</th>
                                        <th data-sort-key="NGAYSINH" data-sort-col="3">Ngày sinh</th>
                                        <th data-sort-key="LUOTDK" data-sort-col="4">Lượt ĐK</th>
                                        <th data-sort-key="TT" data-sort-col="5">Trạng thái</th>
                                    </tr></thead>
                                    <tbody>
                                        <c:forEach items="${dssv}" var="sv">
                                            <tr data-danghihoc="${sv.DANGHIHOC}" data-luotdk="${sv.LUOT_DK}"
                                                class="${sv.MASV.trim() == selectedMasv ? 'selected' : ''}">
                                                <td data-col="MASV">${sv.MASV}</td>
                                                <td>${sv.HO} ${sv.TEN}<span style="display:none" data-col="HO">${sv.HO}</span><span style="display:none" data-col="TEN">${sv.TEN}</span></td>
                                                <td data-col="PHAI">${sv.PHAI == true ? 'Nữ' : 'Nam'}</td>
                                                <td data-col="NGAYSINH">${sv.NGAYSINH}</td>
                                                <td style="text-align:center;font-weight:bold;"><c:choose><c:when test="${sv.LUOT_DK > 0}"><span style="color:#2563eb">${sv.LUOT_DK}</span></c:when><c:otherwise><span style="color:#94a3b8">0</span></c:otherwise></c:choose></td>
                                                <td><c:choose><c:when test="${sv.DANGHIHOC == true}"><span class="badge-status badge-nghihoc">Nghỉ học</span></c:when><c:otherwise><span class="badge-status badge-danghoc">Đang học</span></c:otherwise></c:choose></td>
                                                <td style="display:none" data-col="DIACHI">${sv.DIACHI}</td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                            <span id="svTableFilterCount" class="table-filter-count"></span>
                            <div class="pane-title" style="margin-top:10px;">Chi tiết sinh viên</div>
                            <form id="svForm" action="${pageContext.request.contextPath}/sinhvien/save" method="post">
                                <input type="hidden" id="svAction" name="action" value="add">
                                <c:if test="${sessionScope.nhomQuyen != 'PGV'}">
                                    <input type="hidden" name="malop" value="${selectedLop}">
                                </c:if>
                                <div class="pane-grid">
                                    <div class="pane-row"><span class="pane-label">Mã SV:</span><div class="pane-input-wrapper"><input type="text" id="svPK" name="masv" data-field="MASV" class="pane-input" value="${not empty error ? failedMasv : ''}" maxlength="10" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div><span class="pane-label" style="margin-left:20px;">Mã lớp:</span><div class="pane-input-wrapper"><select name="malop" data-field="MALOP" class="pane-input" style="padding:4px 6px;" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>><c:forEach items="${dslop}" var="l"><option value="${l.MALOP}" ${not empty error ? (failedMalop == l.MALOP ? 'selected' : '') : (l.MALOP.trim() == selectedLop ? 'selected' : '')}>${l.MALOP}</option></c:forEach></select></div></div>
                                    <div class="pane-row"><span class="pane-label">Họ:</span><div class="pane-input-wrapper"><input type="text" name="ho" data-field="HO" class="pane-input" value="${not empty error ? failedHo : ''}" maxlength="50" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div><span class="pane-label" style="margin-left:20px;">Tên:</span><div class="pane-input-wrapper"><input type="text" name="ten" data-field="TEN" class="pane-input" value="${not empty error ? failedTen : ''}" maxlength="10" required <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <div class="pane-row"><span class="pane-label">Phái:</span><div class="pane-input-wrapper" style="display:flex;gap:15px;align-items:center;"><label style="font-size:12px;cursor:pointer;"><input type="radio" name="phai" id="phaiNam" value="false" ${not empty error ? (failedPhai == false ? 'checked' : '') : 'checked'} <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>> Nam</label><label style="font-size:12px;cursor:pointer;"><input type="radio" name="phai" id="phaiNu" value="true" ${not empty error && failedPhai == true ? 'checked' : ''} <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>> Nữ</label></div><span class="pane-label" style="margin-left:20px;">Ngày sinh:</span><div class="pane-input-wrapper"><input type="date" name="ngaysinh" data-field="NGAYSINH" class="pane-input" value="${not empty error ? failedNgaysinh : ''}" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <div class="pane-row"><span class="pane-label">Địa chỉ:</span><div class="pane-input-wrapper" style="flex:1;"><input type="text" name="diachi" data-field="DIACHI" class="pane-input" value="${not empty error ? failedDiachi : ''}" maxlength="100" <c:if test="${sessionScope.nhomQuyen != 'PGV'}">disabled</c:if>></div></div>
                                    <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                                    <div class="pane-row"><span class="pane-label"></span><div class="pane-input-wrapper"><label style="font-size:12px;font-weight:bold;cursor:pointer;display:flex;align-items:center;gap:6px;"><input type="checkbox" id="svDangNghiHoc" name="danghihoc" value="true" ${not empty error && failedDanghihoc == true ? 'checked' : ''}> Đang nghỉ học (DANGHIHOC) <span id="svBadge" class="badge-status badge-danghoc">Đang học</span></label></div></div>
                                    </c:if>
                                </div>
                            </form>
                        </c:if>
                        <c:if test="${empty selectedLop}">
                            <div style="text-align:center;color:#94a3b8;padding:50px;">
                                <i class="fas fa-hand-pointer" style="font-size:40px;margin-bottom:12px;display:block;"></i>
                                <h5>Vui lòng chọn một lớp từ danh sách bên trái</h5>
                            </div>
                        </c:if>
                    </div>
                </div>
                <div class="form-buttons-row">
                    <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                        <button type="button" class="win-form-btn" onclick="btnThemSV()"><i class="fas fa-plus"></i> Thêm</button>
                        <button type="button" class="win-form-btn btn-delete" onclick="btnXoaSV()"><i class="fas fa-trash"></i> Xóa</button>
                        <button type="button" class="win-form-btn btn-save" onclick="validateAndSubmitSV()"><i class="fas fa-save"></i> Ghi</button>
                        <button type="button" class="win-form-btn" onclick="btnPhucHoi()"><i class="fas fa-undo"></i> Phục hồi</button>
                    </c:if>
                    <button type="button" class="win-form-btn" onclick="btnThoat('${pageContext.request.contextPath}/home')"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                </div>
            </div>
            <div class="form-window-status">
                <span>Lớp: ${not empty selectedLop ? selectedLop : '-'} | SV hiển thị: ${not empty svInLop ? svInLop : 0}</span>
                <span>Tổng số SV toàn hệ thống: ${totalSv}</span>
            </div>
        </div>
    </main>
</div>
</div>
<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    var table = document.getElementById('svTable'); if (!table) return;
    var rows = table.querySelectorAll('tbody tr');
    rows.forEach(function(row) {
        row.addEventListener('click', function() {
            rows.forEach(function(r) { r.classList.remove('selected'); }); this.classList.add('selected');
            var get = function(col) { var el = row.querySelector('[data-col="'+col+'"]'); return el ? el.textContent.trim() : ''; };
            document.getElementById('svPK').value = get('MASV');
            var ho = document.querySelector('input[name="ho"]'); if(ho) ho.value = get('HO');
            var ten = document.querySelector('input[name="ten"]'); if(ten) ten.value = get('TEN');
            var dc = document.querySelector('input[name="diachi"]'); if(dc) dc.value = get('DIACHI');
            var ns = document.querySelector('input[name="ngaysinh"]'); if(ns) ns.value = get('NGAYSINH');
            if (get('PHAI')==='Nữ') document.getElementById('phaiNu').checked=true; else document.getElementById('phaiNam').checked=true;
            var dnh = this.getAttribute('data-danghihoc');
            var cb = document.getElementById('svDangNghiHoc'); var badge = document.getElementById('svBadge');
            if(cb) cb.checked = (dnh==='true'||dnh==='1');
            if(badge) { if(dnh==='true'||dnh==='1'){badge.className='badge-status badge-nghihoc';badge.textContent='Nghỉ học';}else{badge.className='badge-status badge-danghoc';badge.textContent='Đang học';} }
            document.getElementById('svAction').value = 'update'; document.getElementById('svPK').readOnly = true;
        });
    });
    var cb = document.getElementById('svDangNghiHoc');
    if(cb) cb.addEventListener('change', function() {
        var b = document.getElementById('svBadge');
        if(b) { if(this.checked){b.className='badge-status badge-nghihoc';b.textContent='Nghỉ học';}else{b.className='badge-status badge-danghoc';b.textContent='Đang học';} }
    });

    var activeMasv = '${selectedMasv}';
    if (activeMasv) {
        var foundRow = null;
        rows.forEach(function(row) {
            var cell = row.querySelector('[data-col="MASV"]');
            if (cell && cell.textContent.trim() === activeMasv) {
                foundRow = row;
            }
        });
        if (foundRow) {
            var hasError = ${not empty error};
            if (hasError) {
                foundRow.classList.add('selected');
                foundRow.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
                
                // Restore action state
                document.getElementById('svAction').value = '${failedAction}';
                // Configure fields readOnly/disabled state based on action
                var pkField = document.getElementById('svPK');
                if (pkField && '${failedAction}' === 'update') {
                    pkField.readOnly = true;
                    pkField.style.background = '#f1f5f9';
                }
                var b = document.getElementById('svBadge');
                if (b) {
                    var dnh = '${failedDanghihoc}';
                    if (dnh === 'true') {
                        b.className = 'badge-status badge-nghihoc';
                        b.textContent = 'Nghỉ học';
                    } else {
                        b.className = 'badge-status badge-danghoc';
                        b.textContent = 'Đang học';
                    }
                }
            } else {
                foundRow.click();
                foundRow.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
            }
        }
    }
});
function btnThemSV() {
    var pk=document.getElementById('svPK'); if(pk){pk.value='';pk.readOnly=false;pk.focus();}
    ['ho','ten','diachi','ngaysinh'].forEach(function(n){var e=document.querySelector('input[name="'+n+'"]');if(e)e.value='';});
    document.getElementById('phaiNam').checked=true;
    var cb=document.getElementById('svDangNghiHoc');if(cb)cb.checked=false;
    var b=document.getElementById('svBadge');if(b){b.className='badge-status badge-danghoc';b.textContent='Đang học';}
    document.getElementById('svAction').value='add';
    document.querySelectorAll('#svTable tbody tr').forEach(function(r){r.classList.remove('selected');});
}
function btnXoaSV() {
    var pk=document.getElementById('svPK'); if(!pk||!pk.value.trim()){alert('Chọn SV cần xóa!');return;}
    var row=document.querySelector('#svTable tbody tr.selected');
    if(row){var dk=row.getAttribute('data-luotdk');if(dk&&parseInt(dk)>0){alert('Không thể xóa! SV '+pk.value+' đã có '+dk+' lượt đăng ký.\nDùng "Đang nghỉ học" thay vì xóa.');return;}}
    if(confirm('Xóa sinh viên '+pk.value+'?')){
        var nextMasv = '';
        if (row) {
            var nextRow = row.nextElementSibling;
            if (!nextRow) {
                nextRow = row.previousElementSibling;
            }
            if (nextRow) {
                var cell = nextRow.querySelector('[data-col="MASV"]');
                if (cell) nextMasv = cell.textContent.trim();
            }
        }
        var f=document.createElement('form');f.method='POST';f.action='${pageContext.request.contextPath}/sinhvien/delete';
        var i1=document.createElement('input');i1.type='hidden';i1.name='masv';i1.value=pk.value.trim();f.appendChild(i1);
        var i2=document.createElement('input');i2.type='hidden';i2.name='malop';i2.value='${selectedLop}';f.appendChild(i2);
        var i3=document.createElement('input');i3.type='hidden';i3.name='nextMasv';i3.value=nextMasv;f.appendChild(i3);
        document.body.appendChild(f);f.submit();
    }
}
function filterSV(type,el) {
    document.querySelectorAll('.filter-tab').forEach(function(t){t.classList.remove('active');}); el.classList.add('active');
    document.querySelectorAll('#svTable tbody tr').forEach(function(r){
        var dnh=r.getAttribute('data-danghihoc'), dk=r.getAttribute('data-luotdk');
        var isNghi=(dnh==='true'||dnh==='1'), hasDK=(dk&&parseInt(dk)>0);
        switch(type){case 'danghoc':r.style.display=isNghi?'none':'';break;case 'nghihoc':r.style.display=isNghi?'':'none';break;case 'codk':r.style.display=hasDK?'':'none';break;default:r.style.display='';}
    });
}
function applyLopFilter() {
    var searchInput = document.getElementById('svLopSearch');
    var filter = searchInput ? searchInput.value.toUpperCase() : '';
    
    var select = document.getElementById('svLopKhoaFilter');
    var selectedKhoa = select ? select.value.trim() : 'ALL';
    
    var rows = document.querySelectorAll('#svLopTable tbody tr');
    rows.forEach(function(row) {
        var rowKhoa = row.getAttribute('data-makhoa') ? row.getAttribute('data-makhoa').trim() : '';
        var matchKhoa = (selectedKhoa === 'ALL' || rowKhoa === selectedKhoa);
        
        var matchSearch = false;
        var tds = row.getElementsByTagName("td");
        if (filter === '') {
            matchSearch = true;
        } else {
            for (var j = 0; j < tds.length; j++) {
                var txtValue = tds[j].textContent || tds[j].innerText;
                if (txtValue.toUpperCase().indexOf(filter) > -1) {
                    matchSearch = true;
                    break;
                }
            }
        }
        
        if (matchKhoa && matchSearch) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}
// ===== VALIDATION SINH VIÊN =====
var NAME_REGEX = /^[A-Za-zÀ-ỹà-ỹĂăÂâĐđÊêÔôƠơƯưÁáÀàẢảÃãẠạẤấẦầẨẩẪẫẬậẮắẰằẲẳẴẵẶặÉéÈèẺẻẼẽẸẹẾếỀềỂểỄễỆệÍíÌìỈỉĨĩỊịÓóÒòỎỏÕõỌọỐốỒồổỔỗỖộỘỚớỜờỞởỠỡỢợÚúÙùỦủŨũỤụỨứỪừỬửỮữỰựÝýỲỳỶỷỸỹỴỵ\s]+$/;
function svSetError(inputEl, msg) {
    var wrapper = inputEl.closest('.pane-input-wrapper') || inputEl.parentElement;
    inputEl.style.border = '1.5px solid #dc2626';
    var errId = 'err_' + (inputEl.name || inputEl.id);
    var existing = document.getElementById(errId);
    if (existing) existing.remove();
    var span = document.createElement('span');
    span.id = errId;
    span.style.cssText = 'color:#dc2626;font-size:10.5px;font-weight:bold;display:block;margin-top:2px;';
    span.innerHTML = '<i class="fas fa-exclamation-circle"></i> ' + msg;
    wrapper.appendChild(span);
}
function svClearError(inputEl) {
    inputEl.style.border = '';
    var errId = 'err_' + (inputEl.name || inputEl.id);
    var existing = document.getElementById(errId);
    if (existing) existing.remove();
}
function validateAndSubmitSV() {
    var ho = document.querySelector('input[name="ho"]');
    var ten = document.querySelector('input[name="ten"]');
    var ns = document.querySelector('input[name="ngaysinh"]');
    var masv = document.getElementById('svPK');
    var ok = true;
    // Reset tất cả
    [ho, ten, ns, masv].forEach(function(el) { if(el) svClearError(el); });

    if (masv && !masv.value.trim()) { svSetError(masv, 'Mã SV không được để trống.'); ok = false; }
    if (!ho || !ho.value.trim()) { svSetError(ho, 'Họ không được để trống.'); ok = false; }
    else if (!NAME_REGEX.test(ho.value.trim())) { svSetError(ho, 'Họ không được chứa số hoặc ký tự đặc biệt.'); ok = false; }
    if (!ten || !ten.value.trim()) { svSetError(ten, 'Tên không được để trống.'); ok = false; }
    else if (!NAME_REGEX.test(ten.value.trim())) { svSetError(ten, 'Tên không được chứa số hoặc ký tự đặc biệt.'); ok = false; }
    if (ns) {
        if (!ns.value) { svSetError(ns, 'Ngày sinh không được để trống.'); ok = false; }
        else {
            var born = new Date(ns.value);
            var today = new Date(); today.setHours(0,0,0,0);
            var age = today.getFullYear() - born.getFullYear() - (today < new Date(today.getFullYear(), born.getMonth(), born.getDate()) ? 1 : 0);
            if (born >= today) { svSetError(ns, 'Ngày sinh không được lớn hơn ngày hiện tại.'); ok = false; }
            else if (age < 16) { svSetError(ns, 'Sinh viên phải từ 16 tuổi trở lên.'); ok = false; }
            else if (age > 60) { svSetError(ns, 'Tuổi sinh viên không hợp lệ (trên 60 tuổi).'); ok = false; }
        }
    }
    if (ok) document.getElementById('svForm').submit();
}
</script>
</body>
</html>
