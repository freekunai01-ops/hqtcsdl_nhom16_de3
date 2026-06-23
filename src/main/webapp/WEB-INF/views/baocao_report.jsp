<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
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
            .report-header-bar { display: none !important; }
            body { background: #fff !important; margin: 0; }
            .report-container { margin: 0; padding: 10px; max-width: 100%; width: 100%; }
            .table-scroll-container {
                overflow-x: visible !important;
                overflow: visible !important;
            }
            .no-print { display: none !important; }
            tr { page-break-inside: avoid; }
        }

        /* Landscape for cross-tab (more columns) */
        @media print and (orientation: landscape) {
            .report-container { padding: 6px; }
            .cross-tab th.subject-header { font-size: 9px; min-width: 80px; max-width: 100px; }
            .cross-tab td { font-size: 10px; padding: 3px 2px; }
            .report-table { font-size: 10px; }
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
        <p class="sub-info"><strong>Khoa:</strong> ${tenKhoa} &nbsp;&mdash;&nbsp;
           <strong>Niên khóa:</strong> ${nienkhoa} &nbsp;&mdash;&nbsp;
           <strong>Học kỳ:</strong> ${hocky}</p>
        <p class="sub-info"><strong>Môn học:</strong> ${tenmh} &nbsp;&mdash;&nbsp; <strong>Nhóm:</strong> ${nhom}</p>
    </div>
    <table class="report-table">
        <thead><tr>
            <th style="width:40px">STT</th><th>Mã SV</th><th>Họ</th><th>Tên</th>
            <th style="width:60px">ĐCC</th><th style="width:60px">ĐGK</th>
            <th style="width:60px">ĐCK</th><th style="width:80px">Điểm hết môn</th>
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
            <th style="width:80px">Điểm (10)</th>
            <th style="width:60px">Điểm chữ</th>
            <th style="width:70px">Hệ 4</th>
        </tr></thead>
        <tbody>
            <c:forEach items="${data}" var="d" varStatus="st">
                <tr>
                    <td style="text-align:center">${st.index+1}</td>
                    <td>${d.TENMH}</td>
                    <td style="text-align:center; font-weight:bold;">
                        <fmt:formatNumber value="${d.DIEM}" maxFractionDigits="1"/>
                    </td>
                    <td style="text-align:center">${d.DIEMCHU}</td>
                    <td style="text-align:center">${d.THANG4}</td>
                </tr>
            </c:forEach>
        </tbody>
        <tfoot>
            <tr style="background:#e3eaf7;">
                <td colspan="2" style="text-align:right; font-weight:bold;">GPA (Hệ 4):</td>
                <td colspan="3" style="text-align:center; font-weight:bold; font-size:14px; color:#1a237e;">
                    ${gpa} &nbsp;&mdash;&nbsp; <em>${xepLoai}</em>
                </td>
            </tr>
        </tfoot>
    </table>
    <p class="report-footer-stats">Số môn: <strong>${soMon}</strong> &nbsp;&mdash;&nbsp; GPA: <strong>${gpa}</strong> &nbsp;&mdash;&nbsp; Xếp loại: <strong>${xepLoai}</strong></p>
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
                    <th class="align-middle" style="width:55px; text-align:center; background:#eef2ff;">GPA</th>
                    <th class="align-middle" style="width:80px; text-align:center; background:#f0fdf4;">Xếp loại</th>
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
                            <td>
                                <c:set var="hasScore" value="false"/>
                                <c:forEach items="${diemData}" var="dd">
                                    <c:if test="${dd.MASV.trim() == sv.MASV.trim() && dd.MAMH.trim() == mh.MAMH.trim()}">
                                        <c:set var="hasScore" value="true"/>
                                        <fmt:formatNumber value="${dd.DIEM}" maxFractionDigits="1"/>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${hasScore == 'false'}">
                                    <span class="score-empty">&ndash;</span>
                                </c:if>
                            </td>
                        </c:forEach>
                        <%-- GPA/Xếp loại: tính client-side từ diemData cho SV này --%>
                        <td class="gpa-cell">
                            <c:set var="sumDiem" value="0"/>
                            <c:set var="cntMon" value="0"/>
                            <c:forEach items="${diemData}" var="dd">
                                <c:if test="${dd.MASV.trim() == sv.MASV.trim()}">
                                    <c:set var="cntMon" value="${cntMon + 1}"/>
                                    <c:set var="diem10" value="${dd.DIEM}"/>
                                    <c:choose>
                                        <c:when test="${diem10 >= 9.0}"><c:set var="t4" value="4.0"/></c:when>
                                        <c:when test="${diem10 >= 8.5}"><c:set var="t4" value="4.0"/></c:when>
                                        <c:when test="${diem10 >= 8.0}"><c:set var="t4" value="3.5"/></c:when>
                                        <c:when test="${diem10 >= 7.0}"><c:set var="t4" value="3.0"/></c:when>
                                        <c:when test="${diem10 >= 6.5}"><c:set var="t4" value="2.5"/></c:when>
                                        <c:when test="${diem10 >= 5.5}"><c:set var="t4" value="2.0"/></c:when>
                                        <c:when test="${diem10 >= 5.0}"><c:set var="t4" value="1.5"/></c:when>
                                        <c:when test="${diem10 >= 4.0}"><c:set var="t4" value="1.0"/></c:when>
                                        <c:otherwise><c:set var="t4" value="0.0"/></c:otherwise>
                                    </c:choose>
                                    <c:set var="sumDiem" value="${sumDiem + t4}"/>
                                </c:if>
                            </c:forEach>
                            <c:if test="${cntMon > 0}">
                                <fmt:formatNumber value="${sumDiem / cntMon}" maxFractionDigits="2"/>
                            </c:if>
                            <c:if test="${cntMon == 0}">&ndash;</c:if>
                        </td>
                        <td class="rank-cell">
                            <c:if test="${cntMon > 0}">
                                <c:set var="gpaVal" value="${sumDiem / cntMon}"/>
                                <c:choose>
                                    <c:when test="${gpaVal >= 3.6}">Xuất sắc</c:when>
                                    <c:when test="${gpaVal >= 3.2}">Giỏi</c:when>
                                    <c:when test="${gpaVal >= 2.5}">Khá</c:when>
                                    <c:when test="${gpaVal >= 2.0}">Trung bình</c:when>
                                    <c:otherwise>Yếu</c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${cntMon == 0}">&ndash;</c:if>
                        </td>
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
