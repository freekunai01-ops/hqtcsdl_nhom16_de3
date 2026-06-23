# Script Test Toàn Bộ App QLDSV - Dành cho Gemini QA Tester

Bạn là QA tester chuyên nghiệp. Mở Chrome, test toàn bộ app tại:
http://localhost:9090/hqtcsdl_nhom16_de3

Chụp screenshot MỌI bước. Ghi rõ PASS/FAIL và mô tả lỗi nếu có.

================================================================
PHẦN 1: TEST ĐĂNG NHẬP (tất cả các trường hợp)
================================================================

1.1. Đăng nhập sai password PGV
- Chọn tab Giảng viên/Nhân viên
- Login: pgv_admin, Password: sai123
- Kết quả mong đợi: báo lỗi đỏ "sai mật khẩu"

1.2. Đăng nhập đúng PGV
- Login: pgv_admin, Password: 123456
- Kết quả mong đợi: redirect về Home, góc trên phải hiện "PGV"

1.3. Đăng nhập để trống
- Không nhập gì, bấm Đăng nhập
- Kết quả mong đợi: browser chặn, không submit

1.4. Đăng nhập sai role (chọn KHOA nhưng tài khoản là PGV)
- Login: pgv_admin, Password: 123456, chọn nhóm KHOA
- Kết quả mong đợi: báo lỗi "nhóm quyền không khớp"

1.5. Đăng nhập SV sai MASV
- Chọn tab Sinh viên
- MASV: XXXXXXXX, Password: 123456
- Kết quả mong đợi: báo lỗi "không tồn tại"

1.6. Đăng nhập SV đúng
- MASV: N20CN0001, Password: 123456
- Kết quả mong đợi: vào được, hiện tên SV

================================================================
PHẦN 2: TEST PHÂN QUYỀN (quan trọng nhất)
================================================================

Đang login PGV (pgv_admin/123456):

2.1. PGV truy cập Đăng ký LTC
- Vào menu Đăng ký LTC
- Kết quả mong đợi: được phép vào (PGV có toàn quyền)

2.2. PGV vào Nhập điểm
- Vào Nhập điểm, load 1 LTC
- Kết quả mong đợi: ô điểm có thể nhập được (không bị disabled)

Đăng xuất. Đăng nhập SV (N20CN0001/123456):

2.3. SV truy cập Danh mục Lớp
- Vào menu Danh mục Lớp (hoặc gõ thẳng URL /lop)
- Kết quả mong đợi: bị redirect về Home, không vào được

2.4. SV truy cập Nhập điểm
- Vào URL /diem thẳng
- Kết quả mong đợi: bị redirect về Home

2.5. SV truy cập Quản trị tài khoản
- Vào URL /taikhoan thẳng
- Kết quả mong đợi: bị redirect về Home

2.6. SV chỉ thấy menu Đăng ký LTC + In ấn
- Kiểm tra sidebar: có hiện Danh mục Lớp/Nhập điểm không?
- Kết quả mong đợi: KHÔNG hiện các menu PGV/KHOA

Đăng xuất. Đăng nhập KHOA (khoa_all/khoa123 hoặc tài khoản KHOA):

2.7. KHOA vào Danh mục Lớp
- Kiểm tra: chỉ thấy lớp thuộc khoa mình không?
- Dropdown "Khoa đang xem" có bị cố định không?

2.8. KHOA vào Mở LTC
- Kiểm tra: nút Thêm/Ghi có bị ẩn/disabled không?
- Kết quả mong đợi: KHOA không được thêm/sửa LTC

2.9. KHOA vào Nhập điểm
- Load 1 LTC thuộc khoa mình
- Kết quả mong đợi: ĐƯỢC nhập điểm

2.10. KHOA thử vào LTC khoa khác
- Chọn Niên khóa, môn của khoa CK
- Kết quả mong đợi: báo "không tìm thấy" hoặc không hiện

================================================================
PHẦN 3: TEST VALIDATE NHẬP LIỆU (CHI TIẾT)
================================================================

Đăng nhập PGV. Vào Danh mục Lớp:

3.1. Thêm lớp để trống tất cả
- Bấm Thêm, không nhập gì, bấm Ghi
- Kết quả mong đợi: browser báo lỗi required, không submit

3.2. Thêm lớp trùng mã
- Mã lớp: N20DCCN01 (đã tồn tại), điền đủ các trường
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "mã lớp đã tồn tại"

3.3. Thêm lớp hợp lệ
- Mã: TESTLOP01, Tên: Lớp Test QA, Khóa: 2025-2030, Khoa: CNTT
- Bấm Ghi → kiểm tra xuất hiện trong danh sách

3.4. Xóa lớp có sinh viên
- Chọn lớp N20DCCN01 (đang có 25 SV)
- Bấm Xóa
- Kết quả mong đợi: báo lỗi "không xóa lớp đang có SV"

3.5. Phục hồi sau khi nhập sai
- Đang nhập lớp mới, nhập sai tên
- Bấm Phục hồi
- Kết quả mong đợi: form reset về dữ liệu gốc

--- Vào Môn học ---

3.6. Thêm môn để trống
- Bấm Thêm, không nhập gì, bấm Ghi
- Kết quả mong đợi: browser chặn required

3.7. Thêm môn trùng mã
- Mã: INT1306 (đã tồn tại), điền đủ, bấm Ghi
- Kết quả mong đợi: báo lỗi "mã môn đã tồn tại"

3.8. Nhập số tiết LT = 0
- Mã: TESTMH02, Tên: Môn Test 2
- Số tiết LT: 0, TH: 15
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "số tiết LT phải > 0" HOẶC chấp nhận (ghi nhận kết quả thực tế)

3.9. Nhập số tiết TH = 0
- Số tiết LT: 30, TH: 0
- Bấm Ghi
- Kết quả mong đợi: ghi nhận kết quả — có môn chỉ LT không TH là hợp lệ

3.10. Nhập cả LT và TH = 0
- Số tiết LT: 0, TH: 0
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "không thể có cả 2 bằng 0"

3.11. Nhập số tiết âm
- Số tiết LT: -5, TH: 15
- Bấm Ghi
- Kết quả mong đợi: báo lỗi hoặc browser chặn (input min=0)

3.12. Nhập số tiết chữ (không phải số)
- Số tiết LT: "abc", TH: 15
- Kết quả mong đợi: browser chặn (input type=number)

3.13. Nhập số tiết rất lớn
- Số tiết LT: 9999, TH: 9999
- Bấm Ghi
- Kết quả mong đợi: ghi nhận — có chặn giới hạn trên không?

3.14. Thêm môn hợp lệ
- Mã: TESTMH01, Tên: Môn Test, LT: 30, TH: 15
- Bấm Ghi → kiểm tra thêm được

3.15. Xóa môn đang có LTC
- Chọn môn INT1306 (đang có nhiều LTC)
- Bấm Xóa
- Kết quả mong đợi: báo lỗi "không xóa môn đang có lớp tín chỉ"

3.16. Xóa môn chưa có LTC
- Chọn TESTMH01 vừa thêm
- Bấm Xóa
- Kết quả mong đợi: xóa thành công

--- Vào Mở Lớp tín chỉ ---

3.17. Thêm LTC để trống
- Bấm Thêm, không nhập gì, bấm Ghi
- Kết quả mong đợi: browser chặn required

3.18. Thêm LTC trùng (NK+HK+Môn+Nhóm giống nhau)
- NK: 2020-2021, HK: 1, Môn: BAS1150, Nhóm: 1 (đã tồn tại)
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "nhóm lớp đã tồn tại"

3.19. Thêm LTC niên khóa quá khứ
- NK: 2019-2020
- Kết quả mong đợi: báo lỗi "không mở lớp năm cũ"

3.20. Nhập số SV tối thiểu = 0
- NK: 2026-2027, HK: 1, Môn: INT1306, Nhóm: 10
- Số SV tối thiểu: 0
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "tối thiểu phải > 0"

3.21. Nhập số SV tối thiểu âm
- Số SV tối thiểu: -5
- Kết quả mong đợi: browser chặn (input min=1)

3.22. Nhập số SV tối thiểu chữ
- Số SV tối thiểu: "abc"
- Kết quả mong đợi: browser chặn (input type=number)

3.23. Thêm LTC hợp lệ
- NK: 2026-2027, HK: 1, Môn: INT1306, Nhóm: 10, SV tối thiểu: 15
- Bấm Ghi → kiểm tra thêm thành công

3.24. Hủy LTC đang có đủ SV
- Chọn LTC đang có >= 10 SV đăng ký
- Tick Hủy lớp, bấm Ghi
- Kết quả mong đợi: báo lỗi "SV đăng ký >= tối thiểu, không hủy được"

3.25. Hủy LTC ít SV (< tối thiểu)
- Chọn LTC chỉ có 3 SV, tối thiểu 15
- Tick Hủy lớp, bấm Ghi
- Kết quả mong đợi: hủy thành công, HUYLOP = 1

--- Vào Sinh viên ---

3.26. Thêm SV trùng MASV
- Chọn lớp N20DCCN01
- Thêm SV có MASV: N20CN0001 (đã tồn tại)
- Bấm Ghi
- Kết quả mong đợi: báo lỗi "MASV đã tồn tại"

3.27. Thêm SV để trống MASV
- Bấm Thêm, không nhập MASV, bấm Ghi
- Kết quả mong đợi: browser chặn required

3.28. Nhập ngày sinh tương lai
- Ngày sinh: 2030-01-01
- Kết quả mong đợi: ghi nhận — có chặn không?

3.29. Xóa SV đang có đăng ký LTC
- Chọn SV N20CN0001 (đang đăng ký nhiều LTC)
- Bấm Xóa
- Kết quả mong đợi: báo lỗi "không xóa SV đang có đăng ký"

================================================================
PHẦN 4: TEST NHẬP ĐIỂM CHI TIẾT
================================================================

Vào Nhập điểm, load LTC: NK 2020-2021, HK 1, Môn BAS1150, Nhóm 1:

4.1. Nhập điểm CC âm
- Nhập CC = -1
- Kết quả mong đợi: viền ô đỏ NGAY LẬP TỨC (không cần bấm Ghi)

4.2. Nhập điểm CC > 10
- Nhập CC = 11
- Kết quả mong đợi: viền đỏ ngay

4.3. Nhập điểm GK hợp lệ
- Nhập GK = 7.5
- Kết quả mong đợi: chấp nhận, không đỏ

4.4. Nhập điểm CK hợp lệ + kiểm tra tự tính
- Nhập CC=8, GK=7.5, CK=8.0
- Kết quả mong đợi: Điểm HM tự tính = 8*0.1 + 7.5*0.3 + 8.0*0.6 = 7.85

4.5. Bấm Ghi khi có ô điểm đỏ
- Để CC = -1 (đang đỏ), bấm Ghi điểm
- Kết quả mong đợi: KHÔNG submit, báo lỗi

4.6. Ghi điểm hợp lệ
- Nhập CC=8, GK=7.5, CK=8.0 cho 1 SV
- Bấm Ghi điểm
- Kết quả mong đợi: thành công, load lại đúng điểm vừa nhập

4.7. Để trống điểm (NULL)
- Xóa trắng tất cả ô 1 SV, bấm Ghi
- Kết quả mong đợi: lưu NULL, không báo lỗi

4.8. Nhập điểm CC = 0 (hợp lệ)
- CC = 0, GK = 5, CK = 5
- Kết quả mong đợi: chấp nhận, tính HM = 0*0.1+5*0.3+5*0.6 = 4.5

4.9. Nhập điểm chữ vào ô số
- Nhập "abc" vào ô GK
- Kết quả mong đợi: browser chặn (input type=number)

4.10. Nhập điểm = 10 (biên trên)
- CC=10, GK=10, CK=10
- Kết quả mong đợi: hợp lệ, HM = 10.0

================================================================
PHẦN 5: TEST ĐĂNG KÝ LTC (login SV)
================================================================

Đăng nhập SV: N20CN0001/123456

5.1. Chọn niên khóa có LTC
- Vào Đăng ký LTC
- Chọn NK: 2026-2027, HK: 1
- Kết quả mong đợi: hiện danh sách LTC chưa hủy
- Kiểm tra cột: MAMH, TENMH, Nhóm, HotenGV, SoSVDK

5.2. Chọn niên khóa không có LTC
- Chọn NK: 2019-2020, HK: 1
- Kết quả mong đợi: thông báo "không có LTC"

5.3. Đăng ký 1 môn
- Chọn 1 LTC chưa đăng ký, bấm Đăng ký
- Kết quả mong đợi: thành công, SoSVDK tăng lên 1

5.4. Đăng ký trùng môn đã đăng ký
- Bấm Đăng ký lại môn vừa đăng ký
- Kết quả mong đợi: báo lỗi "đã đăng ký"

5.5. Hủy đăng ký
- Bấm Hủy môn vừa đăng ký
- Kết quả mong đợi: hủy thành công, SoSVDK giảm đi 1

5.6. Kiểm tra LTC đã hủy không hiện
- Tìm LTC có HUYLOP=1 trong danh sách
- Kết quả mong đợi: KHÔNG hiện LTC đã hủy

================================================================
PHẦN 6: TEST IN ẤN CHI TIẾT
================================================================

Đăng nhập PGV:

6.1. DS LTC - kiểm tra không hiện LTC đã hủy
- In DS LTC NK 2025-2026, HK 2
- Kiểm tra: LTC có HUYLOP=1 có xuất hiện không?
- Kết quả mong đợi: KHÔNG hiện

6.2. DS SV đăng ký - kiểm tra sort
- In DS SV đăng ký, chọn 1 LTC có nhiều SV
- Kiểm tra: sort theo TÊN+HỌ tăng dần
- Ví dụ: An < Bình < Cường

6.3. Bảng điểm hết môn - sort + công thức
- In bảng điểm 1 LTC đã có điểm
- Kiểm tra sort: TÊN+HỌ tăng dần
- Kiểm tra công thức: HM = CC*0.1 + GK*0.3 + CK*0.6

6.4. Phiếu điểm - MAX điểm + GPA
- In phiếu điểm SV N20CN0001
- Kiểm tra: có GPA hệ 4 không?
- Kiểm tra: điểm là MAX các lần thi không?

6.5. Bảng điểm tổng kết Cross-Tab
- Chọn Lớp N20DCCN01, Tất cả/Toàn khóa
- Kiểm tra: header cột là TÊN môn hay MÃ môn? → phải là TÊN
- Kiểm tra: có đủ ~25 SV không?
- Kiểm tra: điểm hiện đúng không?

6.6. In báo cáo thiếu tham số
- Chọn DS LTC nhưng KHÔNG chọn Niên khóa
- Bấm Xem trước
- Kết quả mong đợi: báo lỗi hoặc không hiện dữ liệu

================================================================
PHẦN 7: TEST QUẢN TRỊ TÀI KHOẢN
================================================================

Đăng nhập PGV:

7.1. Tạo tài khoản để trống Login
- Bấm Thêm, không nhập Login, bấm Ghi
- Kết quả mong đợi: browser chặn required

7.2. Tạo tài khoản KHOA gắn GV01
- Login: khoa_cntt2, Password: 123456
- Nhóm: KHOA, GV: GV01
- Bấm Ghi → kiểm tra thành công

7.3. Đăng nhập bằng tài khoản KHOA vừa tạo
- Đăng xuất, login: khoa_cntt2/123456, chọn KHOA
- Kiểm tra: chỉ thấy dữ liệu CNTT không?

7.4. KHOA tạo tài khoản PGV (không được phép)
- Đang login KHOA
- Vào Quản trị TK, chọn nhóm PGV, bấm Ghi
- Kết quả mong đợi: báo lỗi "không được cấp quyền PGV"

7.5. Xóa tài khoản hệ thống mặc định
- Đăng nhập PGV, thử xóa pgv_admin
- Kết quả mong đợi: báo lỗi "không xóa tài khoản mặc định"

================================================================
YÊU CẦU BÁO CÁO CUỐI
================================================================

Tổng hợp kết quả theo bảng:

| Mục | Test case | PASS/FAIL | Mô tả lỗi nếu FAIL |
|-----|-----------|-----------|---------------------|
| 1.1 | Login sai pass PGV | | |
| 1.2 | Login đúng PGV | | |
| 1.3 | Login để trống | | |
| 1.4 | Login sai role | | |
| 1.5 | Login SV sai MASV | | |
| 1.6 | Login SV đúng | | |
| 2.1 | PGV vào ĐK LTC | | |
| 2.2 | PGV nhập điểm | | |
| 2.3 | SV vào Danh mục Lớp | | |
| 2.4 | SV vào Nhập điểm | | |
| 2.5 | SV vào Quản trị TK | | |
| 2.6 | SV chỉ thấy menu SV | | |
| 2.7 | KHOA lọc đúng khoa | | |
| 2.8 | KHOA không sửa LTC | | |
| 2.9 | KHOA nhập điểm | | |
| 2.10 | KHOA không thấy khoa khác | | |
| 3.1 | Lớp để trống | | |
| 3.2 | Lớp trùng mã | | |
| 3.4 | Xóa lớp có SV | | |
| 3.7 | Môn trùng mã | | |
| 3.8 | Số tiết LT=0 | | |
| 3.9 | Số tiết TH=0 | | |
| 3.10 | Cả LT và TH=0 | | |
| 3.11 | Số tiết âm | | |
| 3.13 | Số tiết 9999 | | |
| 3.15 | Xóa môn có LTC | | |
| 3.18 | LTC trùng NK+HK+Môn+Nhóm | | |
| 3.19 | LTC niên khóa quá khứ | | |
| 3.20 | SV tối thiểu = 0 | | |
| 3.24 | Hủy LTC đủ SV | | |
| 3.25 | Hủy LTC thiếu SV | | |
| 3.26 | SV trùng MASV | | |
| 3.29 | Xóa SV có ĐK | | |
| 4.1 | Điểm CC âm → đỏ ngay | | |
| 4.2 | Điểm CC > 10 → đỏ ngay | | |
| 4.4 | Tự tính HM đúng công thức | | |
| 4.5 | Ghi khi có lỗi đỏ | | |
| 4.6 | Ghi điểm hợp lệ | | |
| 4.7 | Để trống điểm NULL | | |
| 5.3 | SV đăng ký LTC | | |
| 5.4 | Đăng ký trùng | | |
| 5.5 | Hủy đăng ký | | |
| 5.6 | LTC hủy không hiện | | |
| 6.1 | DS LTC không có LTC hủy | | |
| 6.2 | Sort DS SV theo Tên+Họ | | |
| 6.3 | Sort bảng điểm Tên+Họ | | |
| 6.4 | Phiếu điểm MAX + GPA | | |
| 6.5 | Cross-tab header tên môn | | |
| 7.2 | Tạo TK KHOA | | |
| 7.3 | KHOA chỉ thấy khoa mình | | |
| 7.4 | KHOA không tạo PGV | | |
| 7.5 | Không xóa TK mặc định | | |

Đặc biệt chú ý báo cáo rõ:
- Phân quyền có đúng không (SV không vào được trang PGV)
- Sort in ấn đúng Tên+Họ chưa
- Header bảng TK là tên môn hay mã môn
- Báo lỗi đỏ nhập điểm sai có hiện ngay không
- Trùng mã lớp/môn/LTC có báo lỗi không
- Số tiết = 0 hoặc âm có chặn không
