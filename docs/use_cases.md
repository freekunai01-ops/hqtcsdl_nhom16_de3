# Use Cases - Hệ thống QLSV Hệ Tín Chỉ (Đề 3)

## 1. Đăng nhập (5 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC01 | Đăng nhập PGV (pgv_admin/123456) | PGV |
| UC02 | Đăng nhập KHOA (khoa_cntt, khoa_vt) | KHOA |
| UC03 | Đăng nhập SV (MASV/123456) | SV |
| UC04 | Đăng nhập sai → báo lỗi | All |
| UC05 | Đăng xuất | All |

## 2. Danh mục Lớp (12 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC06 | Xem danh sách lớp + sĩ số + trạng thái TN | PGV, KHOA |
| UC07 | Tìm kiếm lớp theo mã/tên | PGV, KHOA |
| UC08 | Sắp xếp theo cột | PGV, KHOA |
| UC09 | Lọc Đang học / Đã tốt nghiệp | PGV, KHOA |
| UC10 | Thêm lớp mới | PGV |
| UC11 | Sửa thông tin lớp | PGV |
| UC12 | Xóa lớp chưa có SV | PGV |
| UC13 | Validate trùng mã lớp | PGV |
| UC14 | Validate KHOAHOC format (YYYY-YYYY) | PGV |
| UC15 | Không đổi khoa khi lớp có SV | PGV |
| UC16 | Không xóa lớp đã tốt nghiệp | PGV |
| UC17 | KHOA xem read-only | KHOA |

## 3. Sinh viên - SubForm (6 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC18 | Xem SV theo lớp (SubForm 2 cấp) | PGV, KHOA |
| UC19 | Thêm SV mới vào lớp | PGV |
| UC20 | Sửa thông tin SV | PGV |
| UC21 | Xóa SV chưa có đăng ký | PGV |
| UC22 | Đánh dấu nghỉ học (DANGHIHOC) | PGV |
| UC23 | Lọc Đang học / Nghỉ học / Có ĐK | PGV, KHOA |

## 4. Môn học (5 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC24 | Xem danh sách môn + tín chỉ quy đổi + số LTC | PGV, KHOA |
| UC25 | Thêm môn học mới (validate trùng mã, tổng tiết > 0) | PGV |
| UC26 | Sửa môn học (cảnh báo nếu đã mở LTC) | PGV |
| UC27 | Xóa môn chưa mở LTC | PGV |
| UC28 | Lọc Đã mở LTC / Chưa mở | PGV, KHOA |

## 5. Giảng viên (7 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC29 | Xem DS GV + số LTC phụ trách + trạng thái | PGV, KHOA |
| UC30 | Thêm GV mới (validate trùng mã, bỏ trống) | PGV |
| UC31 | Sửa thông tin GV | PGV |
| UC32 | Xóa GV chưa phân công LTC | PGV |
| UC33 | Lọc Đang giảng dạy / Chưa phân công / GS/PGS/TS | PGV, KHOA |
| UC34 | Validate không xóa GV đã phụ trách LTC | PGV |
| UC35 | KHOA xem read-only | KHOA |

## 6. Mở Lớp Tín Chỉ (8 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC36 | Xem DS lớp tín chỉ theo niên khóa/học kỳ | PGV |
| UC37 | Mở LTC mới (chọn môn, GV, nhóm) | PGV |
| UC38 | Sửa thông tin LTC | PGV |
| UC39 | Hủy LTC (đánh dấu HUYLOP) | PGV |
| UC40 | Validate SV tối thiểu/tối đa | PGV |
| UC41 | Validate deadline đăng ký | PGV |
| UC42 | Validate không mở trùng nhóm | PGV |
| UC43 | Xóa LTC chưa có SV đăng ký | PGV |

## 7. Đăng ký LTC (12 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC44 | SV xem DS LTC mở đăng ký ("Lớp tín chỉ của tôi") | SV |
| UC45 | SV đăng ký LTC | SV |
| UC46 | SV hủy đăng ký (trong thời hạn) | SV |
| UC47 | SV xem LTC đã đăng ký | SV |
| UC48 | Validate không đăng ký trùng môn | SV |
| UC49 | Validate sĩ số tối đa | SV |
| UC50 | Validate thời hạn đăng ký | SV |
| UC51 | PGV chọn Lớp HC → tìm SV theo MASV/họ tên | PGV |
| UC52 | PGV click SV → load hồ sơ đăng ký ("Lớp tín chỉ của sinh viên") | PGV |
| UC53 | PGV đăng ký/hủy hộ SV | PGV |
| UC54 | KHOA xem đăng ký read-only (tìm SV, không tick/hủy) | KHOA |
| UC55 | Validate giới hạn 8 môn/HK | SV, PGV |

## 8. Nhập điểm (8 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC56 | Chọn LTC qua bộ lọc (niên khóa/HK/môn/nhóm) | PGV, KHOA |
| UC57 | Xem thống kê: tổng SV, đã nhập, chưa nhập, đạt/rớt, tỷ lệ đạt | PGV, KHOA |
| UC58 | Nhập CC/GK/CK (0-10) → tự tính HM/chữ/hệ 4/kết quả | PGV |
| UC59 | Validate điểm 0-10, LTC không bị hủy | PGV |
| UC60 | Ghi bảng điểm toàn bộ | PGV |
| UC61 | Phục hồi dữ liệu điểm ban đầu | PGV |
| UC62 | KHOA xem bảng điểm read-only (không sửa/ghi) | KHOA |
| UC63 | Cảnh báo LTC đã hủy / không có SV đăng ký | PGV, KHOA |

## 9. In ấn / Báo cáo (10 UC)
| UC | Mô tả | Actor |
|---|---|---|
| UC64 | Chọn loại báo cáo từ trung tâm báo cáo (5 loại) | PGV, KHOA |
| UC65 | DS LTC: lọc niên khóa/HK/khoa → preview → in | PGV, KHOA |
| UC66 | DSSV đăng ký LTC: lọc môn/nhóm → preview → in | PGV, KHOA |
| UC67 | Bảng điểm môn học: CC/GK/CK + HM/chữ/hệ 4 → in | PGV, KHOA |
| UC68 | Phiếu điểm SV: toàn khóa hoặc theo HK → in | PGV, KHOA, SV |
| UC69 | Bảng điểm tổng kết (Cross-Tab) theo lớp HC → in | PGV, KHOA |
| UC70 | SV chỉ xem Phiếu điểm cá nhân (MASV khóa) | SV |
| UC71 | Stat cards: Role/Báo cáo khả dụng/Dòng preview/Phạm vi | PGV, KHOA, SV |
| UC72 | Xuất PDF mô phỏng | PGV, KHOA |
| UC73 | KHOA xem/in như PGV, không ghi dữ liệu | KHOA |

---
**Tổng: 73 use cases** cho 9 form chính.
