# KIỂM THỬ HỆ THỐNG QLDSV_HTC — Nhóm 16, Đề 3

> **Dự án:** Quản lý Sinh viên Hệ Tín chỉ  
> **Môn:** Hệ Quản Trị CSDL — PTIT HCM  
> **Ngày:** 19/06/2026

---

## Nhóm 1 — PHÂN QUYỀN & ĐĂNG NHẬP

### 1.1 Đăng nhập

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-01 | PGV đăng nhập đúng | Nhập login `pgv_admin` / `123456`, chọn role PGV → Đăng nhập | Vào trang chủ, hiện "Toàn quyền", dropdown khoa = "Tất cả" | ☐ |
| TC-02 | KHOA đăng nhập đúng | Nhập `khoa_cntt` / `khoa123`, chọn KHOA | Vào trang chủ, khoa = CNTT, dropdown khóa | ☐ |
| TC-03 | SV đăng nhập đúng | Chọn tab SV, nhập MASV `N22CN0001` / `123456` | Vào trang chủ, hiện tên SV, khoa = CNTT disabled | ☐ |
| TC-04 | Sai mật khẩu | Nhập `pgv_admin` / `sai123` | Hiện thông báo lỗi "Tên đăng nhập hoặc mật khẩu không đúng" | ☐ |
| TC-05 | SV nghỉ học | Nhập MASV `N22CN0005` (DANGHIHOC=1) | "Mã sinh viên không tồn tại hoặc đã nghỉ học!" | ☐ |
| TC-06 | MASV không tồn tại | Nhập MASV `XXX999` | Hiện lỗi không tìm thấy | ☐ |
| TC-07 | Role không khớp | Nhập login PGV nhưng chọn role KHOA | "Nhóm quyền chọn không khớp phân quyền" | ☐ |

### 1.2 Phân quyền PGV

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-08 | PGV thấy đầy đủ menu | Đăng nhập PGV → kiểm tra sidebar | Hiện: Lớp, SV, Môn học, GV, LTC, Đăng ký, Nhập điểm, Báo cáo, Quản trị TK | ☐ |
| TC-09 | PGV chuyển khoa | Dropdown "Khoa đang xem" → chọn VT | Dữ liệu lọc theo khoa VT | ☐ |
| TC-10 | PGV CRUD hoạt động | Vào form Lớp → thêm/sửa/xóa | Các nút hoạt động bình thường | ☐ |

### 1.3 Phân quyền KHOA

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-11 | KHOA thấy menu hạn chế | Đăng nhập KHOA → sidebar | Hiện: Lớp, SV, Môn học, GV, LTC, Nhập điểm, Báo cáo. **Không có** Quản trị TK | ☐ |
| TC-12 | KHOA không thêm/sửa/xóa | Vào form Lớp/SV/MH/GV | Nút Thêm/Sửa/Xóa disabled hoặc ẩn | ☐ |
| TC-13 | KHOA khóa dropdown khoa | Header → "Khoa đang xem" | Hiện mã khoa cố định, disabled | ☐ |
| TC-14 | KHOA truy cập URL admin | Gõ URL `/taikhoan` trực tiếp | Redirect về trang chủ | ☐ |

### 1.4 Phân quyền SV

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-15 | SV menu rút gọn | Đăng nhập SV → sidebar | Chỉ: Trang chủ, Đăng ký LTC, In ấn. Các mục khác khóa/ẩn | ☐ |
| TC-16 | SV MASV tự điền | Vào Đăng ký LTC | MASV tự lấy từ session, không sửa được | ☐ |
| TC-17 | SV báo cáo chỉ Phiếu điểm | Vào In ấn / Báo cáo | Chỉ thấy radio "Phiếu điểm SV", MASV readonly | ☐ |
| TC-18 | SV không xem SV khác | Vào Báo cáo → thay MASV qua DevTools | Server-side vẫn trả phiếu điểm của chính SV | ☐ |
| TC-19 | SV truy cập URL nhập điểm | Gõ URL `/diem` trực tiếp | Redirect về trang chủ | ☐ |

---

## Nhóm 2 — NGHIỆP VỤ CHÍNH

### 2.1 Đăng ký Lớp tín chỉ (SV)

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-20 | SV đăng ký LTC | Chọn NK 2025-2026, HK 1 → tick checkbox CTDL → Đăng ký | Thông báo thành công, panel "LTC của tôi" hiện CTDL | ☐ |
| TC-21 | SV hủy đăng ký (chưa có điểm) | Panel phải → nhấn ✕ trên LTC chưa có điểm | Confirm → xóa khỏi danh sách "LTC của tôi" | ☐ |
| TC-22 | SV hủy đăng ký (đã có điểm CK) | Panel phải → nhấn ✕ trên LTC đã có điểm | "Không thể hủy — môn này đã có điểm cuối kỳ!" | ☐ |
| TC-23 | Panel "LTC của tôi" cập nhật | Đăng ký thêm 1 LTC → kiểm tra panel phải | Số lớp tăng, bản ghi mới xuất hiện | ☐ |
| TC-24 | Cột TT hiện đúng | Bảng LTC đang mở → kiểm tra cột TT | "Đã ĐK" (xanh) cho LTC đã đăng ký, "Chưa ĐK" (xám) cho chưa | ☐ |
| TC-25 | Điểm HM có màu | Panel phải → kiểm tra cột Điểm HM | Đỏ <5, vàng <7, xanh ≥7, "—" nếu chưa có | ☐ |

### 2.2 Đăng ký LTC (PGV)

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-26 | PGV chọn SV để đăng ký | Nhập MASV `N23CN0001` → Xác nhận SV | Hiện thông tin SV, form đăng ký xuất hiện | ☐ |
| TC-27 | PGV đăng ký LTC cho SV | Tick checkbox → Đăng ký | Thành công, panel phải cập nhật | ☐ |
| TC-28 | PGV hủy đăng ký cho SV | Panel phải → ✕ | Hủy thành công (nếu chưa có điểm CK) | ☐ |
| TC-29 | PGV nhập MASV không tồn tại | Nhập `XXX999` → Xác nhận | "Không tìm thấy sinh viên" | ☐ |

### 2.3 Mở Lớp tín chỉ

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-30 | PGV mở LTC hợp lệ | Điền NK, HK, chọn MH, GV, nhóm, sĩ số → Lưu | Thêm thành công, hiện trong bảng | ☐ |
| TC-31 | Thiếu trường bắt buộc | Bỏ trống Môn học hoặc GV → Lưu | Hiện lỗi "Vui lòng điền đầy đủ" | ☐ |
| TC-32 | Sĩ số ≤ 0 | Nhập sĩ số = 0 hoặc âm → Lưu | Lỗi validation | ☐ |
| TC-33 | Hủy lớp TC | Nhấn Hủy lớp trên LTC chưa có đăng ký | Cột HUYLOP = 1, LTC không hiện trong form đăng ký | ☐ |
| TC-34 | Xóa LTC đã có đăng ký | Nhấn Xóa trên LTC đã có SV đăng ký | "Không thể xóa LTC đã có sinh viên đăng ký" | ☐ |
| TC-35 | KHOA không mở/sửa/xóa LTC | Đăng nhập KHOA → vào LTC | Chỉ xem danh sách, nút thêm/sửa/xóa disabled | ☐ |

### 2.4 Nhập điểm

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-36 | PGV nhập điểm CC/GK/CK | Chọn LTC → nhập CC=8, GK=7, CK=8.5 → Lưu | Lưu thành công | ☐ |
| TC-37 | Điểm ngoài [0-10] | Nhập CC=11 hoặc CK=-1 → Lưu | Lỗi "Điểm phải từ 0 đến 10" | ☐ |
| TC-38 | Nhập chữ vào ô điểm | Nhập "abc" vào ô điểm | Không cho nhập hoặc hiện lỗi | ☐ |
| TC-39 | KHOA xem điểm | Đăng nhập KHOA → vào Nhập điểm | Xem được bảng điểm, không sửa | ☐ |
| TC-40 | SV không vào nhập điểm | Đăng nhập SV → URL `/diem` | Redirect về trang chủ | ☐ |
| TC-41 | Sau nhập điểm CK, SV không hủy ĐK | Nhập CK cho SV → SV đăng nhập → hủy ĐK | "Không thể hủy — đã có điểm cuối kỳ" | ☐ |

---

## Nhóm 3 — RÀNG BUỘC DỮ LIỆU (CRUD)

### 3.1 Form Lớp

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-42 | Thêm lớp hợp lệ | Nhập MALOP, TENLOP, KHOAHOC, chọn KHOA → Lưu | Thêm thành công | ☐ |
| TC-43 | Trùng mã lớp | Nhập MALOP đã tồn tại → Lưu | "Mã lớp đã tồn tại" | ☐ |
| TC-44 | Bỏ trống mã lớp | Để trống MALOP → Lưu | Lỗi validation | ☐ |
| TC-45 | Sửa lớp | Chọn lớp → sửa tên → Lưu | Cập nhật thành công | ☐ |
| TC-46 | Xóa lớp chưa có SV | Chọn lớp trống → Xóa | Xóa thành công | ☐ |
| TC-47 | Xóa lớp đã có SV | Chọn lớp có SV → Xóa | "Không thể xóa lớp đã có sinh viên" | ☐ |

### 3.2 Form Sinh viên

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-48 | Thêm SV hợp lệ | Nhập đầy đủ MASV, Họ, Tên, Phái, Ngày sinh, Địa chỉ → Lưu | Thành công | ☐ |
| TC-49 | Trùng MASV | Nhập MASV đã tồn tại → Lưu | "Mã SV đã tồn tại" | ☐ |
| TC-50 | Bỏ trống Họ tên | Để trống Họ hoặc Tên → Lưu | Lỗi validation | ☐ |
| TC-51 | Ngày sinh không hợp lệ | Nhập ngày sinh = "31/02/2005" | Lỗi "Ngày sinh không hợp lệ" | ☐ |
| TC-52 | Sửa SV | Chọn SV → sửa địa chỉ → Lưu | Cập nhật thành công | ☐ |
| TC-53 | Xóa SV chưa có ĐK | Chọn SV chưa đăng ký LTC → Xóa | Xóa thành công | ☐ |
| TC-54 | Xóa SV đã có ĐK/điểm | Chọn SV đã có đăng ký → Xóa | "Không thể xóa SV đã có đăng ký/điểm" | ☐ |

### 3.3 Form Môn học

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-55 | Thêm MH hợp lệ | Nhập MAMH, TENMH, số tiết LT, TH → Lưu | Thành công | ☐ |
| TC-56 | Trùng mã MH | Nhập MAMH đã tồn tại → Lưu | "Mã môn học đã tồn tại" | ☐ |
| TC-57 | Bỏ trống tên MH | Để trống TENMH → Lưu | Lỗi validation | ☐ |
| TC-58 | Số tiết ≤ 0 | Nhập SOTIET_LT = 0 → Lưu | Lỗi | ☐ |
| TC-59 | Xóa MH đã mở LTC | Chọn MH đã có LTC → Xóa | "Không thể xóa môn đã mở lớp tín chỉ" | ☐ |
| TC-60 | Sửa MH | Chọn MH → sửa tên → Lưu | Cập nhật thành công | ☐ |

### 3.4 Form Giảng viên

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-61 | Thêm GV hợp lệ | Nhập MAGV, Họ, Tên, Học vị, Chuyên môn, Khoa → Lưu | Thành công | ☐ |
| TC-62 | Trùng mã GV | Nhập MAGV đã tồn tại → Lưu | "Mã GV đã tồn tại" | ☐ |
| TC-63 | Bỏ trống Họ tên | Để trống → Lưu | Lỗi validation | ☐ |
| TC-64 | Xóa GV đã dạy LTC | Chọn GV đã phân công LTC → Xóa | "Không thể xóa GV đã dạy lớp tín chỉ" | ☐ |
| TC-65 | Sửa GV | Chọn GV → sửa chuyên môn → Lưu | Cập nhật thành công | ☐ |
| TC-66 | KHOA chỉ xem GV | Đăng nhập KHOA → form GV | Nút thêm/sửa/xóa disabled | ☐ |

---

## Nhóm 4 — GIAO DIỆN, BÁO CÁO & TÌM KIẾM

### 4.1 Báo cáo / In ấn

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-67 | In DS lớp tín chỉ | Chọn "DS LTC", NK 2025-2026, HK 1 → In | Hiện preview bảng DS LTC đúng dữ liệu | ☐ |
| TC-68 | In DSSV đăng ký LTC | Chọn "DSSV đăng ký", điền MH + Nhóm → In | Hiện danh sách SV đã đăng ký | ☐ |
| TC-69 | In Bảng điểm LTC | Chọn "Bảng điểm LTC", điền MH + Nhóm → In | Hiện bảng điểm CC/GK/CK | ☐ |
| TC-70 | In Phiếu điểm SV | Chọn "Phiếu điểm SV", nhập MASV → In | Hiện phiếu điểm tổng hợp, điểm = MAX các lần thi | ☐ |
| TC-71 | In Bảng điểm tổng kết | Chọn "Cross-Tab", nhập MALOP → In | Hiện bảng pivot SV × Môn | ☐ |
| TC-72 | SV in phiếu điểm | SV đăng nhập → Báo cáo → In | MASV readonly, chỉ phiếu điểm cá nhân | ☐ |
| TC-73 | LTC không tồn tại | Nhập MH/Nhóm không tồn tại → In | "Không tìm thấy Lớp tín chỉ này!" | ☐ |
| TC-74 | MASV không tồn tại | Nhập MASV sai → In phiếu điểm | "Không tìm thấy sinh viên!" | ☐ |
| TC-75 | PGV xem toàn trường | PGV chọn "Toàn trường" → In DS LTC | Hiện LTC tất cả khoa | ☐ |

### 4.2 DataGrid — Tìm kiếm

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-76 | Tìm theo mã | Form Lớp → ô tìm kiếm → gõ "N22" | Chỉ hiện lớp có chứa "N22" | ☐ |
| TC-77 | Tìm theo tên | Form MH → tìm "Cơ sở" | Hiện "Cơ sở dữ liệu" | ☐ |
| TC-78 | Không phân biệt hoa/thường | Tìm "cntt" hoặc "CNTT" | Kết quả giống nhau | ☐ |
| TC-79 | Không có kết quả | Tìm "XYZABC" | Bảng trống, hiện "Không tìm thấy" | ☐ |
| TC-80 | Xóa tìm kiếm | Xóa text ô tìm → Enter | Hiện lại toàn bộ dữ liệu | ☐ |

### 4.3 DataGrid — Sắp xếp & Phân trang

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-81 | Sắp xếp tăng dần | Click header "Tên môn học" | Sắp xếp A→Z, icon ▲ | ☐ |
| TC-82 | Sắp xếp giảm dần | Click header lần 2 | Sắp xếp Z→A, icon ▼ | ☐ |
| TC-83 | Phân trang hiển thị | Bảng >8 dòng | Hiện thanh "< 1 2 >" + "Hiển thị 1-8 trên X bản ghi" | ☐ |
| TC-84 | Chuyển trang | Nhấn trang 2 | Hiện dòng 9-16, highlight trang 2 | ☐ |
| TC-85 | Phân trang + tìm kiếm | Tìm kiếm → kết quả <8 dòng | Phân trang ẩn hoặc hiện 1 trang | ☐ |
| TC-86 | Column filter | Click icon phễu cột "Khoa" → chọn "CNTT" | Chỉ hiện dòng khoa CNTT | ☐ |

### 4.4 Quản trị tài khoản

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-87 | PGV tạo TK mới | Nhập login, mật khẩu, role → Tạo | Thành công | ☐ |
| TC-88 | Trùng login | Nhập login đã tồn tại → Tạo | "Login đã tồn tại" | ☐ |
| TC-89 | Thiếu trường | Bỏ trống password → Tạo | Lỗi validation | ☐ |
| TC-90 | KHOA không tạo TK | Đăng nhập KHOA → URL `/taikhoan` | Redirect hoặc readonly | ☐ |
| TC-91 | SV không thấy menu QT | Đăng nhập SV | Không có mục "Quản trị tài khoản" | ☐ |

### 4.5 Dashboard

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-92 | Tổng SV đúng | Trang chủ → card "Tổng SV" | Khớp `SELECT COUNT(*) FROM SINHVIEN WHERE DANGHIHOC=0` | ☐ |
| TC-93 | Tổng LTC đúng | Card "Tổng LTC" | Khớp `SELECT COUNT(*) FROM LOPTINCHI WHERE HUYLOP=0` | ☐ |
| TC-94 | Tổng đăng ký đúng | Card "Tổng ĐK" | Khớp `SELECT COUNT(*) FROM DANGKY WHERE HUYDANGKY=0` | ☐ |
| TC-95 | KHOA xem dashboard | Đăng nhập KHOA → Trang chủ | Hiện thống kê, không có nút nhập liệu | ☐ |

### 4.6 Đồng bộ Frontend — Backend

| ID | Mô tả | Bước | Kết quả mong đợi | KQ |
|----|--------|------|-------------------|-----|
| TC-96 | Role khớp sau login | Đăng nhập mỗi role → kiểm tra session | `nhomQuyen` khớp với bảng TaiKhoan | ☐ |
| TC-97 | KHOA POST thêm SV | Dùng Postman/cURL POST `/sinhvien/add` | Server trả redirect/403, không thêm | ☐ |
| TC-98 | SV POST nhập điểm | Dùng Postman POST `/diem/save` | Server trả redirect, không lưu | ☐ |
| TC-99 | SV POST báo cáo admin | POST `/baocao/preview` với reportType=DS_LTC | Server force về PHIEU_DIEM | ☐ |
| TC-100 | Cache-bust hoạt động | Sửa CSS/JS → F5 | Thay đổi hiện ngay nhờ `?v=2` | ☐ |

---

## Tổng hợp kết quả

| Nhóm | Số TC | Đạt | Lỗi | Ghi chú |
|------|-------|-----|-----|---------|
| 1. Phân quyền & Đăng nhập | 19 | | | |
| 2. Nghiệp vụ chính | 22 | | | |
| 3. Ràng buộc dữ liệu | 25 | | | |
| 4. Giao diện & Báo cáo | 34 | | | |
| **Tổng** | **100** | | | |

> [!TIP]
> **Thứ tự ưu tiên test:** Đăng nhập → Đăng ký/Hủy LTC → Mở LTC → Nhập điểm → Phiếu điểm → GV → CRUD Lớp/SV/MH → Báo cáo → Dashboard
