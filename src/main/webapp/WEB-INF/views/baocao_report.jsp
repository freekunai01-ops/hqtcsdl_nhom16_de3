<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>QLDSV HTC - Báo cáo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body { background: #fff; font-family: 'Times New Roman', Times, serif; }
        .report-container { max-width: 1100px; margin: 20px auto; padding: 30px; }
        .report-header-bar {
            background: #1a237e; color: white;
            text-align: center; padding: 8px 20px; display: flex;
            align-items: center; justify-content: center; gap: 12px;
        }
        .report-header-bar button {
            font-size: 13px; padding: 4px 14px; border: none;
            border-radius: 4px; cursor: pointer;
        }
        .btn-print-doc { background: #ffc107; color: #000; font-weight: bold; }
        .btn-close-doc { background: #6c757d; color: #fff; }

        /* Report Title Block */
        .report-title-block {
            text-align: center; margin-bottom: 18px; border-bottom: 2px solid #1a237e; padding-bottom: 10px;
        }
        .report-title-block .school-name {
            font-size: 13px; font-weight: bold; text-transform: uppercase; color: #333; margin-bottom: 2px;
        }
        .report-title-block h4 {
            font-size: 17px; font-weight: bold; text-transform: uppercase;
            color: #1a237e; margin: 6px 0 4px;
        }
        .report-title-block .sub-info {
            font-size: 13px; color: #444; margin: 3px 0;
        }

        /* Report table */
        .report-table {
            width: 100%; border-collapse: collapse; font-size: 12px;
            margin-bottom: 14px;
        }
        .report-table th, .report-table td {
            border: 1px solid #333; padding: 5px 7px; vertical-align: middle;
        }
        .report-table th {
            background: #e3eaf7; text-align: center; font-weight: bold;
        }
        .report-table tbody tr:nth-child(even) { background: #f9fbff; }

        /* Cross-tab specific */
        .cross-tab th.subject-header {
            font-size: 11px;
            font-weight: bold;
            text-align: center;
            vertical-align: middle;
            min-width: 100px;
            max-width: 130px;
            white-space: normal;
            word-wrap: break-word;
            background: #e3eaf7;
            padding: 6px 4px;
        }
        .cross-tab td { text-align: center; font-size: 12px; padding: 4px 3px; }
        .cross-tab td.sv-info-cell { text-align: left; min-width: 180px; padding: 4px 7px; }
        .cross-tab td.gpa-cell { font-weight: bold; color: #1a237e; background: #eef2ff; }
        .cross-tab td.rank-cell { font-weight: bold; font-size: 11px; background: #f0fdf4; color: #15803d; }
        .cross-tab td.score-empty { color: #ccc; }

        .report-footer-note {
            font-size: 12px; color: #555; margin-top: 10px; font-style: italic;
        }
        .report-footer-stats {
            font-size: 13px; font-weight: bold; margin-top: 8px;
        }

        /* Wide table note */
        .wide-table-note {
            background: #fff3cd; border: 1px solid #ffc107; padding: 8px 12px;
            border-radius: 4px; font-size: 12px; margin-bottom: 10px; color: #856404;
        }

        .table-scroll-container {
            overflow-x: auto;
            width: 100%;
        }

        /* ===== PRINT STYLES ===== */
        @media print {
            @page { size: A4 landscape; margin: 10mm; }
            .report-header-bar { display: none !important; }
            body { background: #fff !important; margin: 0; font-size: 9px; }
            .report-container { margin: 0; padding: 5px; max-width: 100%; width: 100%; }
            .table-scroll-container {
                overflow-x: visible !important;
                overflow: visible !important;
            }
            .no-print { display: none !important; }
            /* Lặp lại header bảng khi sang trang mới */
            thead { display: table-header-group; }
            tfoot { display: table-footer-group; }
            tr { page-break-inside: avoid; }
            .cross-tab th.subject-header { font-size: 8px; min-width: 60px; max-width: 80px; padding: 3px 2px; }
            .cross-tab td { font-size: 8px; padding: 2px 2px; }
            .cross-tab td.sv-info-cell { min-width: 120px; font-size: 8px; }
            .report-table { font-size: 8px; }
            .report-title-block .school-name { font-size: 10px; }
            .report-title-block h4 { font-size: 13px; }
            .report-title-block .sub-info { font-size: 10px; }
        }
    </style>
    <script>
        function printLandscape() {
            var style = document.createElement('style');
            style.innerHTML = '@page { size: A3 landscape; margin: 10mm; }';
            style.id = 'landscape-print-style';
            document.head.appendChild(style);
            window.print();
            setTimeout(function() {
                var s = document.getElementById('landscape-print-style');
                if (s) s.remove();
            }, 1000);
        }
        function printPortrait() {
            window.print();
        }
    </script>
</head>
<body>

<%-- Top control bar --%>
<div class="report-header-bar no-print">
    <c:choose>
        <c:when test="${reportType == 'BANG_DIEM_TK'}">
            <button class="btn-print-doc" onclick="printLandscape()">
                <i class="fas fa-print"></i> In ngang (A3)
            </button>
            <button class="btn-print-doc" onclick="printPortrait()" style="background:#4caf50; color:#fff;">
                <i class="fas fa-print"></i> In dọc (A4)
            </button>
        </c:when>
        <c:otherwise>
            <button class="btn-print-doc" onclick="window.print()">
                <i class="fas fa-print"></i> In báo cáo
            </button>
        </c:otherwise>
    </c:choose>
    <button class="btn-close-doc" onclick="window.close()">
        <i class="fas fa-times"></i> Đóng
    </button>
</div>

<div class="report-container">

<%-- Error display --%>
<c:if test="${not empty error}">
    <div style="color:#991b1b; background:#fee2e2; border:1px solid #fca5a5; padding:12px; border-radius:4px; font-size:13px;">
        <i class="fas fa-exclamation-triangle"></i> <strong>Lỗi:</strong> ${error}
    </div>
</c:if>

<%-- ========== 1. DS LỚP TÍN CHỈ ========== --%>
<c:if test="${reportType == 'DS_LTC'}">
    <div class="report-title-block">
        <div class="school-name">Học viện Công nghệ Bưu chính Viễn thông</div>
        <h4>Danh sách lớp tín chỉ</h4>
        <p class="sub-info"><strong>Khoa:</strong> ${tenKhoa} &nbsp;&mdash;&nbsp;
           <strong>Niên khóa:</strong> ${nienkhoa} &nbsp;&mdash;&nbsp;
           <strong>Học kỳ:</strong> ${hocky}</p>
    </div>
    <table class="report-table">
        <thead><tr>
            <th style="width:40px">STT</th>
            <th>Tên môn học</th>
            <th style="width:55px">Nhóm</th>
            <th>Giảng viên</th>
            <th style="width:70px">SV tối thiểu</th>
            <th style="width:70px">SV đã ĐK</th>
        </tr></thead>
        <tbody>
            <c:forEach items="${data}" var="d" varStatus="st">
                <tr>
                    <td style="text-align:center">${st.index+1}</td>
                    <td>${d.TENMH}</td>
                    <td style="text-align:center">${d.NHOM}</td>
                    <td>${d.HOTENGV}</td>
                    <td style="text-align:center">${d.SOSVTOITHIEU}</td>
                    <td style="text-align:center"><strong>${d.SOSVDK}</strong></td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <p class="report-footer-stats">Tổng số lớp đã mở: <strong>${data.size()}</strong></p>
</c:if>

<%-- ========== 2. DS SV ĐĂNG KÝ LTC ========== --%>
<c:if test="${reportType == 'DS_SV_DK'}">
    <div class="report-title-block">
        <div class="school-name">Học viện Công nghệ Bưu chính Viễn thông</div>
        <h4>Danh sách sinh viên đăng ký lớp tín chỉ</h4>
        <p class="sub-info"><strong>Khoa:</strong> ${tenKhoa} &nbsp;&mdash;&nbsp;
           <strong>Niên khóa:</strong> ${nienkhoa} &nbsp;&mdash;&nbsp;
           <strong>Học kỳ:</strong> ${hocky}</p>
        <p class="sub-info"><strong>Môn học:</strong> ${tenmh} &nbsp;&mdash;&nbsp; <strong>Nhóm:</strong> ${nhom}</p>
    </div>
    <table class="report-table">
        <thead><tr>
            <th style="width:40px">STT</th><th>Mã SV</th><th>Họ</th><th>Tên</th><th>Phái</th><th>Mã lớp</th>
        </tr></thead>
        <tbody>
            <c:forEach items="${data}" var="d" varStatus="st">
                <tr>
                    <td style="text-align:center">${st.index+1}</td>
                    <td>${d.MASV}</td><td>${d.HO}</td><td>${d.TEN}</td>
                    <td style="text-align:center">${d.PHAI == true ? 'Nữ' : 'Nam'}</td>
                    <td>${d.MALOP}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <p class="report-footer-stats">Số sinh viên đã đăng ký: <strong>${data.size()}</strong></p>
</c:if>

<%-- ========== 3. BẢNG ĐIỂM HẾT MÔN ========== --%>
<c:if test="${reportType == 'BANG_DIEM'}">
    <div class="report-title-block">
        <div class="school-name">Học viện Công nghệ Bưu chính Viễn thông</div>
        <h4>Bảng điểm hết môn</h4>
        <p class="sub-info"><strong>Khoa:</strong> ${tenKhoa}</p>
        <p class="sub-info"><strong>Niên khóa:</strong> ${nienkhoa} &nbsp;&mdash;&nbsp; <strong>Học kỳ:</strong> ${hocky}</p>
        <p class="sub-info"><strong>Môn học:</strong> ${tenmh} &nbsp;&mdash;&nbsp; <strong>Nhóm:</strong> ${nhom}</p>
    </div>
    <table class="report-table">
        <thead><tr>
            <th style="width:40px">STT</th><th>Mã SV</th><th>Họ</th><th>Tên</th>
            <th style="width:80px">Điểm chuyên cần</th><th style="width:70px">Điểm giữa kỳ</th>
            <th style="width:70px">Điểm cuối kỳ</th><th style="width:80px">Điểm hết môn</th>
        </tr></thead>
        <tbody>
            <c:forEach items="${data}" var="d" varStatus="st">
                <tr>
                    <td style="text-align:center">${st.index+1}</td>
                    <td>${d.MASV}</td><td>${d.HO}</td><td>${d.TEN}</td>
                    <td style="text-align:center">${d.DIEM_CC}</td>
                    <td style="text-align:center">${d.DIEM_GK}</td>
                    <td style="text-align:center">${d.DIEM_CK}</td>
                    <td style="text-align:center; font-weight:bold;">
                        <c:if test="${d.DIEM_HM != null}">
                            <fmt:formatNumber value="${d.DIEM_HM}" maxFractionDigits="1"/>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <p class="report-footer-stats">Số sinh viên: <strong>${data.size()}</strong></p>
</c:if>

<%-- ========== 4. PHIẾU ĐIỂM SV ========== --%>
<c:if test="${reportType == 'PHIEU_DIEM'}">
    <div class="report-title-block">
        <div class="school-name">Học viện Công nghệ Bưu chính Viễn thông</div>
        <h4>Phiếu điểm sinh viên</h4>
        <c:if test="${svInfo != null}">
            <p class="sub-info"><strong>Mã SV:</strong> ${svInfo.MASV} &nbsp;&mdash;&nbsp;
               <strong>Họ tên:</strong> ${svInfo.HO} ${svInfo.TEN}</p>
            <p class="sub-info"><strong>Lớp:</strong> ${svInfo.TENLOP} &nbsp;&mdash;&nbsp;
               <strong>Khoa:</strong> ${svInfo.TENKHOA}</p>
        </c:if>
        <c:if test="${phamvi == 'hk' && not empty nienkhoa}">
            <p class="sub-info"><strong>Phạm vi:</strong> Niên khóa ${nienkhoa} &mdash; Học kỳ ${hocky}</p>
        </c:if>
        <c:if test="${phamvi != 'hk'}">
            <p class="sub-info"><strong>Phạm vi:</strong> Toàn khóa học</p>
        </c:if>
    </div>
    <table class="report-table">
        <thead><tr>
            <th style="width:40px">STT</th>
            <th>Tên môn học</th>
            <th style="width:80px">Điểm</th>
        </tr></thead>
        <tbody>
            <c:forEach items="${data}" var="d" varStatus="st">
                <tr>
                    <td style="text-align:center">${st.index+1}</td>
                    <td>${d.TENMH}</td>
                    <td style="text-align:center; font-weight:bold;">
                        <fmt:formatNumber value="${d.DIEM}" maxFractionDigits="1"/>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
    <p class="report-footer-stats">Số môn: <strong>${soMon}</strong></p>
</c:if>

<%-- ========== 5. BẢNG ĐIỂM TỔNG KẾT (Cross-Tab) ========== --%>
<c:if test="${reportType == 'BANG_DIEM_TK'}">
    <div class="report-title-block">
        <div class="school-name">Học viện Công nghệ Bưu chính Viễn thông</div>
        <h4>
            <c:choose>
                <c:when test="${phamvi == 'hk'}">Bảng điểm tổng kết học kỳ</c:when>
                <c:otherwise>Bảng điểm tổng kết cuối khóa</c:otherwise>
            </c:choose>
        </h4>
        <c:if test="${lopInfo != null}">
            <p class="sub-info">
                <strong>Lớp:</strong> ${lopInfo.TENLOP} &nbsp;&mdash;&nbsp;
                <strong>Khóa học:</strong> ${lopInfo.KHOAHOC} &nbsp;&mdash;&nbsp;
                <strong>Khoa:</strong> ${lopInfo.TENKHOA}
            </p>
            <c:if test="${phamvi == 'hk' && not empty nienkhoa}">
                <p class="sub-info"><strong>Niên khóa:</strong> ${nienkhoa} &nbsp;&mdash;&nbsp; <strong>Học kỳ:</strong> ${hocky}</p>
            </c:if>
            <c:if test="${phamvi != 'hk'}">
                <p class="sub-info"><em>Phạm vi: Toàn khóa &mdash; Chỉ hiển thị môn đã có điểm cuối kỳ</em></p>
            </c:if>
        </c:if>
    </div>

    <%-- Wide table notice --%>
    <c:if test="${not empty dsmhCross}">
        <div class="wide-table-note no-print">
            <i class="fas fa-info-circle"></i>
            Bảng có <strong>${dsmhCross.size()}</strong> môn học.
            <c:if test="${dsmhCross.size() > 12}">
                Bảng rộng &mdash; khuyến nghị nhấn <strong>In ngang (A3)</strong> để in đầy đủ.
            </c:if>
        </div>
    </c:if>

    <div class="table-scroll-container">
        <table class="report-table cross-tab">
            <thead>
                <tr>
                    <th class="align-middle" style="min-width:190px; text-align:center;">MASV &mdash; Họ tên</th>
                    <c:forEach items="${dsmhCross}" var="mh">
                        <th class="subject-header">
                            ${mh.TENMH}
                        </th>
                    </c:forEach>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${dssv}" var="sv">
                    <tr>
                        <td class="sv-info-cell">
                            <strong>${sv.MASV}</strong><br>
                            <span style="font-size:11px;">${sv.HOTENSV}</span>
                        </td>
                        <c:forEach items="${dsmhCross}" var="mh">
                            <c:set var="cellKey" value="${fn:trim(sv.MASV)}_${fn:trim(mh.MAMH)}"/>
                            <c:set var="cellDiem" value="${diemMap[cellKey]}"/>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty cellDiem}">
                                        <fmt:formatNumber value="${cellDiem}" maxFractionDigits="1"/>
                                    </c:when>
                                    <c:otherwise><span class="score-empty">&ndash;</span></c:otherwise>
                                </c:choose>
                            </td>
                        </c:forEach>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>

    <p class="report-footer-stats">
        Số sinh viên: <strong>${dssv.size()}</strong>
        &nbsp;&mdash;&nbsp; Số môn: <strong>${dsmhCross.size()}</strong>
    </p>

    <%-- Legend for subject codes --%>
    <c:if test="${not empty dsmhCross}">
        <div class="report-legend mt-3 mb-3 p-3" style="border: 1px dashed #bbb; background: #fafafa; border-radius: 4px; page-break-inside: avoid;">
            <h6 style="font-size: 13px; font-weight: bold; margin-bottom: 8px; color: #1a237e; border-bottom: 1px solid #ddd; padding-bottom: 4px;">
                <i class="fas fa-info-circle"></i> Chú thích mã môn học:
            </h6>
            <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 5px; font-size: 11px; line-height: 1.5;">
                <c:forEach items="${dsmhCross}" var="mh">
                    <div><strong>${mh.MAMH}</strong>: ${mh.TENMH}</div>
                </c:forEach>
            </div>
        </div>
    </c:if>

    <p class="report-footer-note">
        * Điểm hết môn = CC&times;10% + GK&times;30% + CK&times;60%. Nếu học lại, lấy điểm cao nhất.
        <c:if test="${phamvi != 'hk'}"> Toàn khóa: chỉ hiện môn đã có điểm cuối kỳ (DIEM_CK &ne; NULL).</c:if>
    </p>
</c:if>

</div>
</body>
</html>
