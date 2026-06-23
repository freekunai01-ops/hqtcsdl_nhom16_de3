<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLSV_HTC - Báo cáo & In ấn</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/style.css?v=3" rel="stylesheet">
    <style>
        .report-radio-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 20px;
        }
        .report-radio-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            color: #1e293b;
            cursor: pointer;
        }
        .report-radio-item input {
            cursor: pointer;
        }
        .preview-pane-content {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 4px;
            padding: 20px;
            min-height: 350px;
            font-family: 'Times New Roman', Times, serif;
            color: #000000;
        }
        .preview-title-block {
            text-align: center;
            margin-bottom: 20px;
        }
        .preview-title-block h4 {
            margin: 0 0 4px 0;
            font-size: 16px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .preview-title-block h5 {
            margin: 0 0 6px 0;
            font-size: 14px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .preview-title-block p {
            margin: 2px 0;
            font-size: 13px;
        }
        .preview-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
            font-size: 13px;
        }
        .preview-table th, .preview-table td {
            border: 1px solid #000000;
            padding: 6px 8px;
            text-align: left;
        }
        .preview-table th {
            background-color: #f1f5f9;
            font-weight: bold;
            text-align: center;
        }
        .preview-footer {
            font-size: 13px;
            font-weight: bold;
            margin-top: 10px;
        }

        /* Printable stylesheet rules */
        @media print {
            body * {
                visibility: hidden;
            }
            .preview-pane-content, .preview-pane-content * {
                visibility: visible;
            }
            .preview-pane-content {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                border: none;
                padding: 0;
                background: transparent;
                box-shadow: none;
                max-height: none !important;
                overflow-y: visible !important;
            }
            /* Multi-page table printing fixes */
            table.preview-table {
                page-break-inside: auto;
            }
            table.preview-table tr {
                page-break-inside: avoid;
                page-break-after: auto;
            }
            table.preview-table thead {
                display: table-header-group;
            }
            table.preview-table tfoot {
                display: table-footer-group;
            }
            /* Hide print preview button when printing */
            .preview-pane-content button {
                display: none !important;
            }
        }
    </style>
</head>
<body>
<%@ include file="layout/header.jsp" %>
<div class="d-flex">
    <%@ include file="layout/sidebar.jsp" %>
    <main class="content-area">
        <div class="desktop-form-window">
            <!-- Form Titlebar -->
            <div class="form-window-titlebar">
                <div class="title-left">
                    <i class="fas fa-file-invoice"></i> Form: In ấn / Báo cáo
                </div>
                <div class="title-right">
                    <span class="window-btn green"></span>
                    <span class="window-btn yellow"></span>
                    <span class="window-btn red"></span>
                </div>
            </div>

            <!-- Form Body -->
            <div class="form-window-body">
                <!-- Stat Cards -->
                <div style="display:flex;gap:12px;margin-bottom:12px;">
                    <div style="flex:1;border:1px solid #e2e8f0;border-radius:4px;padding:8px 14px;background:#f8fafc;"><div style="font-size:10px;color:#64748b;">Role</div><div style="font-size:16px;font-weight:bold;color:#2563eb;">${sessionScope.nhomQuyen}</div></div>
                    <div style="flex:1;border:1px solid #e2e8f0;border-radius:4px;padding:8px 14px;background:#f8fafc;"><div style="font-size:10px;color:#64748b;">Báo cáo khả dụng</div><div style="font-size:16px;font-weight:bold;">${sessionScope.nhomQuyen == 'SV' ? '1' : '5'}</div></div>
                    <div style="flex:1;border:1px solid #e2e8f0;border-radius:4px;padding:8px 14px;background:#f8fafc;"><div style="font-size:10px;color:#64748b;">Dòng preview</div><div style="font-size:16px;font-weight:bold;color:#16a34a;">${not empty data ? fn:length(data) : (not empty dssv ? fn:length(dssv) : 0)}</div></div>
                    <div style="flex:1;border:1px solid #e2e8f0;border-radius:4px;padding:8px 14px;background:#f8fafc;"><div style="font-size:10px;color:#64748b;">Phạm vi</div><div style="font-size:13px;font-weight:bold;color:#7c3aed;">${not empty nienkhoa ? nienkhoa : ''} ${not empty hocky ? 'HK'.concat(hocky) : ''}</div></div>
                </div>
                <div class="form-split-container">
                    
                    <!-- Left Pane: Bộ lọc báo cáo -->
                    <div class="form-left-pane" style="flex: 0 0 320px;">
                        <div class="pane-title"><i class="fas fa-list"></i> Trung tâm báo cáo</div>
                        <form id="reportForm" action="${pageContext.request.contextPath}/baocao/preview" method="post">
                            <c:if test="${sessionScope.nhomQuyen == 'SV'}">
                                <div style="background:#dbeafe;border:1px solid #93c5fd;padding:8px 12px;border-radius:4px;margin-bottom:12px;font-size:12px;color:#1e40af;">
                                    <i class="fas fa-info-circle"></i> Sinh viên chỉ được xem <strong>Phiếu điểm cá nhân</strong> (tổng hợp tất cả môn đã học).
                                </div>
                            </c:if>
                            <div class="report-radio-group">
                                <c:if test="${sessionScope.nhomQuyen != 'SV'}">
                                <label class="report-radio-item" style="padding:8px 10px;border:1px solid #e2e8f0;border-radius:4px;background:${empty reportType || reportType == 'DS_LTC' ? '#dbeafe' : '#fff'};">
                                    <input type="radio" name="reportType" value="DS_LTC" 
                                           ${empty reportType || reportType == 'DS_LTC' ? 'checked' : ''} 
                                           onchange="autoSubmitReport()">
                                    <div><strong>Danh sách lớp tín chỉ</strong><br><span style="font-size:10px;color:#64748b;">Lọc theo niên khóa/học kỳ/khoa hoặc xem tất cả</span></div>
                                </label>
                                <label class="report-radio-item" style="padding:8px 10px;border:1px solid #e2e8f0;border-radius:4px;background:${reportType == 'DS_SV_DK' ? '#dbeafe' : '#fff'};">
                                    <input type="radio" name="reportType" value="DS_SV_DK" 
                                           ${reportType == 'DS_SV_DK' ? 'checked' : ''} 
                                           onchange="autoSubmitReport()">
                                    <div><strong>DSSV đăng ký LTC</strong><br><span style="font-size:10px;color:#64748b;">Theo một lớp tín chỉ cụ thể</span></div>
                                </label>
                                <label class="report-radio-item" style="padding:8px 10px;border:1px solid #e2e8f0;border-radius:4px;background:${reportType == 'BANG_DIEM' ? '#dbeafe' : '#fff'};">
                                    <input type="radio" name="reportType" value="BANG_DIEM" 
                                           ${reportType == 'BANG_DIEM' ? 'checked' : ''} 
                                           onchange="autoSubmitReport()">
                                    <div><strong>Bảng điểm môn học</strong><br><span style="font-size:10px;color:#64748b;">CC/GK/CK, điểm chữ, hệ 4</span></div>
                                </label>
                                </c:if>
                                <label class="report-radio-item" style="padding:8px 10px;border:1px solid #e2e8f0;border-radius:4px;background:${reportType == 'PHIEU_DIEM' ? '#dbeafe' : '#fff'};">
                                    <input type="radio" name="reportType" value="PHIEU_DIEM" 
                                           ${reportType == 'PHIEU_DIEM' || sessionScope.nhomQuyen == 'SV' ? 'checked' : ''} 
                                           onchange="autoSubmitReport()">
                                    <div><strong>Phiếu điểm sinh viên</strong><br><span style="font-size:10px;color:#64748b;">Toàn khóa hoặc theo học kỳ</span></div>
                                </label>
                                <c:if test="${sessionScope.nhomQuyen != 'SV'}">
                                <label class="report-radio-item" style="padding:8px 10px;border:1px solid #e2e8f0;border-radius:4px;background:${reportType == 'BANG_DIEM_TK' ? '#dbeafe' : '#fff'};">
                                    <input type="radio" name="reportType" value="BANG_DIEM_TK" 
                                           ${reportType == 'BANG_DIEM_TK' ? 'checked' : ''} 
                                           onchange="autoSubmitReport()">
                                    <div><strong>Bảng điểm tổng kết</strong><br><span style="font-size:10px;color:#64748b;">Cross-tab theo lớp hành chính</span></div>
                                </label>
                                </c:if>
                            </div>

                            <div class="pane-title" style="margin-top:12px;"><i class="fas fa-sliders-h"></i> Tham số báo cáo</div>
                            <div class="pane-grid">

                                <div class="pane-row" id="rowPhamVi" style="display:none;">
                                    <span class="pane-label" style="width:80px;">Phạm vi:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="phamvi" id="selPhamVi" class="pane-input" style="padding:4px 6px;" onchange="updateReportFields()">
                                            <option value="all" ${phamvi == 'all' ? 'selected' : ''}>Tất cả / Toàn khóa</option>
                                            <option value="hk" ${phamvi == 'hk' ? 'selected' : ''}>Theo niên khóa/HK</option>
                                        </select>
                                    </div>
                                </div>
                                
                                <div class="pane-row" id="rowKhoa">
                                    <span class="pane-label" style="width: 80px;">Khoa:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="maKhoa" class="pane-input" style="padding: 4px 6px;">
                                            <c:if test="${sessionScope.nhomQuyen == 'PGV'}">
                                                <option value="ALL" ${maKhoa == 'ALL' ? 'selected' : ''}>Toàn trường</option>
                                            </c:if>
                                            <c:forEach items="${khoaList}" var="k">
                                                <option value="${k.MAKHOA}" ${maKhoa == k.MAKHOA ? 'selected' : ''}>${k.TENKHOA}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <div class="pane-row" id="rowNienKhoa">
                                    <span class="pane-label" style="width: 80px;">Niên khóa:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="nienkhoa" class="pane-input" style="padding: 4px 6px;">
                                            <c:forEach items="${dsNienKhoa}" var="nk">
                                                <option value="${nk}" ${nienkhoa == nk ? 'selected' : ''}>${nk}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <div class="pane-row" id="rowHocKy">
                                    <span class="pane-label" style="width: 80px;">Học kỳ:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="hocky" class="pane-input" style="padding: 4px 6px;">
                                            <c:forEach items="${dsHocKy}" var="hk">
                                                <option value="${hk}" ${hocky == hk ? 'selected' : ''}>${hk}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <div class="pane-row" id="rowMonHoc" style="display: none;">
                                    <span class="pane-label" style="width: 80px;">Môn học:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="mamh" class="pane-input" style="padding:4px 6px;">
                                            <c:forEach items="${dsmh}" var="mh">
                                                <option value="${mh.MAMH}" ${mh.MAMH == mamh ? 'selected' : ''}>${mh.MAMH} - ${mh.TENMH}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                                <div class="pane-row" id="rowNhom" style="display: none;">
                                    <span class="pane-label" style="width: 80px;">Nhóm:</span>
                                    <div class="pane-input-wrapper">
                                        <input type="number" name="nhom" class="pane-input" min="1" value="${not empty nhom ? nhom : 1}">
                                    </div>
                                </div>

                                <div class="pane-row" id="rowSV" style="display: none;">
                                    <span class="pane-label" style="width: 80px;">Mã SV:</span>
                                    <div class="pane-input-wrapper">
                                        <c:choose>
                                            <c:when test="${sessionScope.nhomQuyen == 'SV'}">
                                                <input type="text" name="masv" class="pane-input" value="${sessionScope.masv}" readonly 
                                                       style="background:#f1f5f9; cursor:not-allowed;">
                                            </c:when>
                                            <c:otherwise>
                                                <input type="text" name="masv" class="pane-input" placeholder="Mã sinh viên" value="${masv}">
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <div class="pane-row" id="rowLop" style="display: none;">
                                    <span class="pane-label" style="width: 80px;">Lớp:</span>
                                    <div class="pane-input-wrapper">
                                        <select name="malop" class="pane-input" style="padding:4px 6px;">
                                            <c:forEach items="${dsLop}" var="lp">
                                                <option value="${lp.MALOP}" ${lp.MALOP == malop ? 'selected' : ''}>${lp.MALOP} - ${lp.TENLOP}</option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                </div>

                            </div>

                            <div style="display:flex;gap:8px;margin-top:15px;flex-wrap:wrap;">
                                <button type="submit" class="win-form-btn btn-save" style="flex:1;justify-content:center;"
                                        formaction="${pageContext.request.contextPath}/baocao/preview">
                                    <i class="fas fa-eye"></i> Xem trước
                                </button>
                                <button type="submit" class="win-form-btn" style="flex:1;justify-content:center;background:linear-gradient(to bottom,#fff9c4,#fef08a);border-color:#f59e0b;color:#78350f;"
                                        formaction="${pageContext.request.contextPath}/baocao/print" formtarget="_blank">
                                    <i class="fas fa-print"></i> In / PDF
                                </button>
                            </div>
                            <div style="display:flex;gap:8px;margin-top:8px;">
                                <button type="button" class="win-form-btn" style="flex:1;justify-content:center;" onclick="window.location.href='${pageContext.request.contextPath}/baocao'"><i class="fas fa-redo"></i> Làm mới</button>
                                <button type="button" class="win-form-btn" style="flex:1;justify-content:center;" onclick="window.location.href='${pageContext.request.contextPath}/home'"><i class="fas fa-sign-out-alt"></i> Thoát</button>
                            </div>
                        </form>
                    </div>

                    <!-- Right Pane: Xem trước báo cáo -->
                    <div class="form-right-pane">
                        <div class="pane-title" style="display:flex;justify-content:space-between;align-items:center;">
                            <span><i class="fas fa-eye"></i> Xem trước báo cáo</span>
                            <c:if test="${not empty data || not empty svInfo || not empty lopInfo}">
                                <button onclick="window.print()" class="win-form-btn btn-save" style="padding:2px 10px;min-width:auto;height:22px;font-size:11px;"><i class="fas fa-eye"></i> Preview / Print</button>
                            </c:if>
                        </div>

                        <div class="preview-pane-content">
                            <c:choose>
                                <c:when test="${not empty error}">
                                    <div style="color: #991b1b; background: #fee2e2; border: 1px solid #fca5a5; padding: 12px; border-radius: 4px; font-family: sans-serif; font-size: 13px;">
                                        <i class="fas fa-exclamation-triangle"></i> <strong>Lỗi:</strong> ${error}
                                    </div>
                                </c:when>
                                <c:when test="${empty reportType}">
                                    <div style="text-align: center; color: #64748b; padding-top: 100px; font-family: sans-serif; font-size: 13.5px;">
                                        <i class="fas fa-file-alt fa-3x" style="margin-bottom: 12px; color: #cbd5e1;"></i>
                                        <p>Chọn loại báo cáo, điền tham số và nhấn "In" để xem trước</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    
                                    <%-- 1. DS LỚP TÍN CHỈ --%>
                                    <c:if test="${reportType == 'DS_LTC'}">
                                        <div class="preview-title-block">
                                            <h4>DANH SÁCH LỚP TÍN CHỈ</h4>
                                            <h5>KHOA ${tenKhoa}</h5>
                                            <p>Niên khóa: ${nienkhoa} &nbsp;&nbsp;&nbsp; Học kỳ: ${hocky}</p>
                                        </div>
                                        <table class="preview-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 40px;">STT</th>
                                                    <th>Tên môn học</th>
                                                    <th style="width: 60px; text-align: center;">Nhóm</th>
                                                    <th>Họ tên GV</th>
                                                    <th style="width: 70px; text-align: center;">SV min</th>
                                                    <th style="width: 70px; text-align: center;">SV đã ĐK</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${data}" var="d" varStatus="st">
                                                    <tr>
                                                        <td style="text-align: center;">${st.index + 1}</td>
                                                        <td>${d.TENMH}</td>
                                                        <td style="text-align: center;">${d.NHOM}</td>
                                                        <td>${d.HOTENGV}</td>
                                                        <td style="text-align: center;">${d.SOSVTOITHIEU}</td>
                                                        <td style="text-align: center;">${d.SOSVDK}</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <div class="preview-footer">Số lượng lớp đã mở: ${fn:length(data)}</div>
                                    </c:if>

                                    <%-- 2. DS SV ĐĂNG KÝ --%>
                                    <c:if test="${reportType == 'DS_SV_DK'}">
                                        <div class="preview-title-block">
                                            <h4>DANH SÁCH SINH VIÊN ĐĂNG KÝ LỚP TÍN CHỈ</h4>
                                            <h5>KHOA ${tenKhoa}</h5>
                                            <p>Niên khóa: ${nienkhoa} &nbsp;&nbsp;&nbsp; Học kỳ: ${hocky}</p>
                                            <p>Môn học: ${tenmh} &nbsp;&nbsp;&nbsp; Nhóm: ${nhom}</p>
                                        </div>
                                        <table class="preview-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 40px;">STT</th>
                                                    <th>Mã SV</th>
                                                    <th>Họ</th>
                                                    <th>Tên</th>
                                                    <th style="width: 60px; text-align: center;">Phái</th>
                                                    <th>Mã lớp</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${data}" var="d" varStatus="st">
                                                    <tr>
                                                        <td style="text-align: center;">${st.index + 1}</td>
                                                        <td>${d.MASV}</td>
                                                        <td>${d.HO}</td>
                                                        <td>${d.TEN}</td>
                                                        <td style="text-align: center;">${d.PHAI == true ? 'Nữ' : 'Nam'}</td>
                                                        <td>${d.MALOP}</td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <div class="preview-footer">Số sinh viên đã đăng ký: ${fn:length(data)}</div>
                                    </c:if>

                                    <%-- 3. BẢNG ĐIỂM HẾT MÔN --%>
                                    <c:if test="${reportType == 'BANG_DIEM'}">
                                        <div class="preview-title-block">
                                            <h4>BẢNG ĐIỂM HẾT MÔN</h4>
                                            <h5>KHOA ${tenKhoa}</h5>
                                            <p>Niên khóa: ${nienkhoa} &nbsp;&nbsp;&nbsp; Học kỳ: ${hocky}</p>
                                            <p>Môn học: ${tenmh} &nbsp;&nbsp;&nbsp; Nhóm: ${nhom}</p>
                                        </div>
                                        <table class="preview-table">
                                            <thead><tr>
                                                <th style="width:35px;">STT</th><th>Mã SV</th><th>Họ</th><th>Tên</th>
                                                <th style="width:80px;text-align:center;">Điểm chuyên cần</th>
                                                <th style="width:70px;text-align:center;">Điểm giữa kỳ</th>
                                                <th style="width:70px;text-align:center;">Điểm cuối kỳ</th>
                                                <th style="width:80px;text-align:center;">Điểm hết môn</th>
                                            </tr></thead>
                                            <tbody>
                                                <c:forEach items="${data}" var="d" varStatus="st">
                                                    <tr>
                                                        <td style="text-align:center;">${st.index+1}</td>
                                                        <td>${d.MASV}</td><td>${d.HO}</td><td>${d.TEN}</td>
                                                        <td style="text-align:center;">${d.DIEM_CC}</td>
                                                        <td style="text-align:center;">${d.DIEM_GK}</td>
                                                        <td style="text-align:center;">${d.DIEM_CK}</td>
                                                        <td style="text-align:center;font-weight:bold;">
                                                            <c:if test="${d.DIEM_HM != null}"><fmt:formatNumber value="${d.DIEM_HM}" maxFractionDigits="1"/></c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <div class="preview-footer">Số sinh viên: ${fn:length(data)}</div>
                                    </c:if>

                                    <%-- 4. PHIẾU ĐIỂM SV --%>
                                    <c:if test="${reportType == 'PHIEU_DIEM'}">
                                        <div class="preview-title-block">
                                            <h4>PHIẾU ĐIỂM SINH VIÊN</h4>
                                            <c:if test="${not empty svInfo}">
                                                <p>Họ tên: <strong>${svInfo.HO} ${svInfo.TEN}</strong> &mdash; Mã SV: <strong>${svInfo.MASV}</strong> &mdash; Lớp: <strong>${svInfo.MALOP}</strong></p>
                                            </c:if>
                                        </div>
                                        <table class="preview-table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 50px;">STT</th>
                                                    <th>Tên môn học</th>
                                                    <th style="width: 100px; text-align: center;">Điểm</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${data}" var="d" varStatus="st">
                                                    <tr>
                                                        <td style="text-align: center;">${st.index + 1}</td>
                                                        <td>${d.TENMH}</td>
                                                        <td style="text-align: center; font-weight: bold;">
                                                            <fmt:formatNumber value="${d.DIEM}" maxFractionDigits="1"/>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                        <p style="margin-top:10px; font-size:13px;">Số môn: <strong>${soMon}</strong></p>
                                    </c:if>

                                    <%-- 5. BẢNG ĐIỂM TỔNG KẾT --%>
                                    <c:if test="${reportType == 'BANG_DIEM_TK'}">
                                        <div class="preview-title-block">
                                            <h4>
                                                <c:choose>
                                                    <c:when test="${phamvi == 'hk'}">BẢNG ĐIỂM TỔNG KẾT HỌC KỲ</c:when>
                                                    <c:otherwise>BẢNG ĐIỂM TỔNG KẾT CUỐI KHÓA</c:otherwise>
                                                </c:choose>
                                            </h4>
                                            <c:if test="${not empty lopInfo}">
                                                <p>LỚP: ${lopInfo.TENLOP} &ndash; KHÓA HỌC: ${lopInfo.KHOAHOC}</p>
                                                <p>KHOA: ${lopInfo.TENKHOA}</p>
                                                <c:if test="${phamvi == 'hk' && not empty nienkhoa}">
                                                    <p>Niên khóa: ${nienkhoa} &mdash; Học kỳ: ${hocky}</p>
                                                </c:if>
                                            </c:if>
                                        </div>
                                        <div style="overflow-x:auto;">
                                            <table class="preview-table" style="font-size:11px;">
                                                <thead><tr>
                                                    <th style="min-width:170px;text-align:left;position:sticky;left:0;background:#f1f5f9;z-index:1;">MASV - Họ tên</th>
                                                    <c:forEach items="${dsmhCross}" var="mh">
                                                        <th style="text-align:center;padding:4px;min-width:45px;">
                                                            <div style="writing-mode:vertical-rl;transform:rotate(180deg);display:inline-block;white-space:nowrap;margin:4px auto;font-size:10px;font-weight:bold;color:#1e40af;" title="${mh.MAMH}">${mh.TENMH}</div>
                                                        </th>
                                                    </c:forEach>
                                                    <th style="text-align:center;min-width:40px;background:#eef2ff;">GPA</th>
                                                    <th style="text-align:center;min-width:65px;background:#f0fdf4;">Xếp loại</th>
                                                </tr></thead>
                                                <tbody>
                                                    <c:forEach items="${dssv}" var="sv">
                                                        <tr>
                                                            <td style="position:sticky;left:0;background:#fff;z-index:1;white-space:nowrap;"><strong>${sv.MASV}</strong> - ${sv.HOTENSV}</td>
                                                            <c:forEach items="${dsmhCross}" var="mh">
                                                                <c:set var="cellKey" value="${fn:trim(sv.MASV)}_${fn:trim(mh.MAMH)}"/>
                                                                <c:set var="cellDiem" value="${diemMap[cellKey]}"/>
                                                                <td style="text-align:center;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty cellDiem}">
                                                                            <span style="font-weight:bold;color:${cellDiem >= 5 ? '#16a34a' : '#dc2626'};">
                                                                                <fmt:formatNumber value="${cellDiem}" maxFractionDigits="1"/>
                                                                            </span>
                                                                        </c:when>
                                                                        <c:otherwise><span style="color:#cbd5e1;">-</span></c:otherwise>
                                                                    </c:choose>
                                                                </td>
                                                            </c:forEach>
                                                            <c:set var="svMasv" value="${fn:trim(sv.MASV)}"/>
                                                            <c:set var="svGpa" value="${gpaMap[svMasv]}"/>
                                                            <c:set var="svRank" value="${rankMap[svMasv]}"/>
                                                            <td style="text-align:center;font-weight:bold;color:#1e40af;background:#eef2ff;">
                                                                <c:choose>
                                                                    <c:when test="${not empty svGpa}"><fmt:formatNumber value="${svGpa}" maxFractionDigits="2"/></c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td style="text-align:center;font-weight:bold;font-size:10px;color:#15803d;background:#f0fdf4;">
                                                                <c:choose>
                                                                    <c:when test="${not empty svRank}">${svRank}</c:when>
                                                                    <c:otherwise>-</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                        <div class="preview-footer" style="display:flex; justify-content:space-between; align-items:center; margin-bottom:12px;">
                                            <span>Số sinh viên: <strong>${fn:length(dssv)}</strong> | Số môn: <strong>${fn:length(dsmhCross)}</strong></span>
                                            <span style="font-size:11px; color:#64748b; font-style:italic;">* Nhấn "In / PDF" để xem GPA & Xếp loại trên bản in</span>
                                        </div>

                                        <%-- Legend for subject codes --%>
                                        <c:if test="${not empty dsmhCross}">
                                            <div class="preview-legend p-3 mt-2" style="border: 1px dashed #cbd5e1; background: #f8fafc; border-radius: 4px;">
                                                <h6 style="font-size: 12px; font-weight: bold; margin-bottom: 6px; color: #1e293b;">
                                                    <i class="fas fa-info-circle"></i> Chú thích mã môn học:
                                                </h6>
                                                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 4px; font-size: 11px; line-height: 1.4; color:#475569;">
                                                    <c:forEach items="${dsmhCross}" var="mh">
                                                        <div><strong>${mh.MAMH}</strong>: ${mh.TENMH}</div>
                                                    </c:forEach>
                                                </div>
                                            </div>
                                        </c:if>
                                    </c:if>

                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                </div>
            </div>

            <!-- Form Status bar -->
            <div class="form-window-status">
                <span>Báo cáo: <c:choose><c:when test="${reportType=='DS_LTC'}">Danh sách lớp tín chỉ</c:when><c:when test="${reportType=='DS_SV_DK'}">DSSV đăng ký LTC</c:when><c:when test="${reportType=='BANG_DIEM'}">Bảng điểm môn học</c:when><c:when test="${reportType=='PHIEU_DIEM'}">Phiếu điểm sinh viên</c:when><c:when test="${reportType=='BANG_DIEM_TK'}">Bảng điểm tổng kết</c:when><c:otherwise>Chưa chọn</c:otherwise></c:choose></span>
                <span>Khoa: ${not empty maKhoa ? maKhoa : '...'} | Dòng preview: ${not empty data ? fn:length(data) : (not empty dssv ? fn:length(dssv) : 0)}</span>
            </div>
        </div>
    </main>
</div>
</div><%-- close app-window-container --%>

<script src="${pageContext.request.contextPath}/js/app.js?v=16"></script>
<script>
    var isSV = '${sessionScope.nhomQuyen}' === 'SV';
    function updateReportFields() {
        var radios = document.getElementsByName('reportType');
        var selected = 'DS_LTC';
        for (var i = 0; i < radios.length; i++) {
            if (radios[i].checked) {
                selected = radios[i].value;
                break;
            }
        }

        // Hide all rows first
        document.getElementById('rowPhamVi').style.display = 'none';
        document.getElementById('rowKhoa').style.display = 'none';
        document.getElementById('rowNienKhoa').style.display = 'none';
        document.getElementById('rowHocKy').style.display = 'none';
        document.getElementById('rowMonHoc').style.display = 'none';
        document.getElementById('rowNhom').style.display = 'none';
        document.getElementById('rowSV').style.display = 'none';
        document.getElementById('rowLop').style.display = 'none';

        // SV can only see PHIEU_DIEM
        if (isSV) {
            document.getElementById('rowSV').style.display = 'flex';
            var phamViVal = document.getElementById('selPhamVi').value;
            document.getElementById('rowPhamVi').style.display = 'flex';
            if (phamViVal === 'hk') {
                document.getElementById('rowNienKhoa').style.display = 'flex';
                document.getElementById('rowHocKy').style.display = 'flex';
            }
            return;
        }

        if (selected === 'DS_LTC') {
            document.getElementById('rowKhoa').style.display = 'flex';
            document.getElementById('rowNienKhoa').style.display = 'flex';
            document.getElementById('rowHocKy').style.display = 'flex';
        } else if (selected === 'DS_SV_DK' || selected === 'BANG_DIEM') {
            document.getElementById('rowKhoa').style.display = 'flex';
            document.getElementById('rowNienKhoa').style.display = 'flex';
            document.getElementById('rowHocKy').style.display = 'flex';
            document.getElementById('rowMonHoc').style.display = 'flex';
            document.getElementById('rowNhom').style.display = 'flex';
        } else if (selected === 'PHIEU_DIEM') {
            document.getElementById('rowPhamVi').style.display = 'flex';
            document.getElementById('rowSV').style.display = 'flex';
            var phamViVal = document.getElementById('selPhamVi').value;
            if (phamViVal === 'hk') {
                document.getElementById('rowNienKhoa').style.display = 'flex';
                document.getElementById('rowHocKy').style.display = 'flex';
            }
        } else if (selected === 'BANG_DIEM_TK') {
            document.getElementById('rowKhoa').style.display = 'flex';
            document.getElementById('rowLop').style.display = 'flex';
            document.getElementById('rowPhamVi').style.display = 'flex';
            var phamViVal = document.getElementById('selPhamVi').value;
            if (phamViVal === 'hk') {
                document.getElementById('rowNienKhoa').style.display = 'flex';
                document.getElementById('rowHocKy').style.display = 'flex';
            }
        }
    }

    function autoSubmitReport() {
        updateReportFields();
        var radios = document.getElementsByName('reportType');
        var selected = '';
        for (var i = 0; i < radios.length; i++) { if (radios[i].checked) { selected = radios[i].value; break; } }
        // Only auto-submit for types with safe defaults
        if (selected === 'DS_LTC' || selected === 'BANG_DIEM_TK') {
            setTimeout(function() { document.getElementById('reportForm').submit(); }, 100);
        }
    }

    document.addEventListener("DOMContentLoaded", function() {
        updateReportFields();
    });
</script>
</body>
</html>