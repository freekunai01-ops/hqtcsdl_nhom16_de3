# Kết luận Nghiệp vụ - QLSV Hệ Tín Chỉ (Đề 3)

## 1. Tóm tắt nghiệp vụ
Hệ thống QLSV HTC quản lý toàn bộ quy trình đào tạo theo hệ tín chỉ:
- **Danh mục**: Lớp, Sinh viên, Môn học, Giảng viên, Khoa
- **Vận hành**: Mở lớp tín chỉ, Đăng ký LTC, Nhập điểm
- **Báo cáo**: Bảng điểm, Phiếu điểm, Thống kê

## 2. Ràng buộc dữ liệu

### Lớp (LOP)
| Ràng buộc | Mô tả |
|---|---|
| MALOP | PK, không trùng, không rỗng |
| TENLOP | Không rỗng |
| KHOAHOC | Format YYYY-YYYY |
| MAKHOA | FK → KHOA |
| Xóa | Không xóa nếu có SV hoặc đã tốt nghiệp |
| Sửa khoa | Không đổi khoa nếu lớp đã có SV |

### Sinh viên (SINHVIEN)
| Ràng buộc | Mô tả |
|---|---|
| MASV | PK, không trùng |
| HO, TEN | Không rỗng |
| MALOP | FK → LOP |
| PHAI | BIT (0=Nam, 1=Nữ) |
| DANGHIHOC | BIT (0=Đang học, 1=Nghỉ học) |
| Xóa | Không xóa nếu đã có đăng ký LTC |
| PASSWORD | Default = MASV |

### Môn học (MONHOC)
| Ràng buộc | Mô tả |
|---|---|
| MAMH | PK, không trùng |
| TENMH | Không rỗng |
| SOTIET_LT, SOTIET_TH | >= 0, tổng > 0 |
| Tín chỉ | = round(LT/15 + TH/30), min 1 |
| Xóa | Không xóa nếu đã mở LTC |
| Sửa số tiết | Cảnh báo nếu đã mở LTC (ảnh hưởng TC/GPA) |

### Giảng viên (GIANGVIEN)
| Ràng buộc | Mô tả |
|---|---|
| MAGV | PK, không trùng, không rỗng |
| HO, TEN | Không rỗng |
| HOCVI | Học vị (Thạc sĩ, Tiến sĩ...) |
| HOCHAM | Học hàm (GS, PGS...) - có thể rỗng |
| CHUYENMON | Chuyên môn giảng dạy |
| MAKHOA | FK → KHOA |
| Xóa | Không xóa nếu đã phụ trách LTC |
| Sửa khoa | Không nên đổi khoa nếu đã phân công LTC |

### Lớp Tín Chỉ (LOPTINCHI)
| Ràng buộc | Mô tả |
|---|---|
| MALTC | PK, identity |
| NIENKHOA + HOCKY + MAMH + NHOM | Không trùng |
| SOSVTOITHIEU | SV tối thiểu để mở |
| SOSVTOIDA | SV tối đa cho phép đăng ký |
| HUYLOP | BIT (1 = đã hủy) |
| NGAYBATDAU_DK, NGAYKETTHUC_DK | Thời hạn đăng ký |

### Đăng ký (DANGKY)
| Ràng buộc | Mô tả |
|---|---|
| MASV + MALTC | PK composite |
| DIEM_CC, DIEM_GK, DIEM_CK | 0-10 |
| Không đăng ký trùng môn | 1 SV không đăng ký 2 LTC cùng MAMH |
| Thời hạn | Chỉ đăng ký/hủy trong NGAYBATDAU_DK - NGAYKETTHUC_DK |
| Giới hạn | Tối đa 8 môn/học kỳ |
| Luồng PGV | Chọn Lớp HC → Tìm SV (MASV/họ tên) → Click SV → Đăng ký/hủy hộ |
| Luồng SV | MASV khóa theo tài khoản → Đăng ký/hủy cho chính mình |
| Luồng KHOA | Chọn Lớp HC → Tìm SV → Chỉ xem, không tick/hủy |
| Panel title | PGV/KHOA: "Lớp tín chỉ của sinh viên"; SV: "Lớp tín chỉ của tôi" |

## 3. Thang điểm
| Loại | Trọng số | Thang |
|---|---|---|
| Chuyên cần (DIEM_CC) | 10% | 0-10, số nguyên |
| Giữa kỳ (DIEM_GK) | 30% | 0-10, bước 0.5 |
| Cuối kỳ (DIEM_CK) | 60% | 0-10, bước 0.5 |
| **Hết môn (HM)** | **Tự tính** | **CC×0.1 + GK×0.3 + CK×0.6** |

### Quy đổi điểm chữ / hệ 4
| HM | Chữ | Hệ 4 | Kết quả |
|---|---|---|---|
| ≥9 | A+ | 4.0 | Đạt |
| 8.5–8.9 | A | 3.7 | Đạt |
| 8.0–8.4 | B+ | 3.5 | Đạt |
| 7.0–7.9 | B | 3.0 | Đạt |
| 6.5–6.9 | C+ | 2.5 | Đạt |
| 5.5–6.4 | C | 2.0 | Đạt |
| 5.0–5.4 | D+ | 1.5 | Đạt |
| 4.0–4.9 | D | 1.0 | Rớt |
| <4 | F | 0 | Rớt |

## 4. Phân quyền theo form

| Form | PGV | KHOA | SV |
|---|---|---|---|
| Danh mục Lớp | CRUD + filter | Read-only | ❌ |
| Sinh viên (SubForm) | CRUD + filter + DANGHIHOC | Read-only | ❌ |
| Môn học | CRUD + filter + TC | Read-only | ❌ |
| Giảng viên | CRUD | Read-only | ❌ |
| Mở LTC | CRUD + hủy lớp | ❌ | ❌ |
| Đăng ký LTC | Chọn lớp HC + tìm SV + ĐK hộ | Tìm SV xem read-only | ĐK/hủy ĐK |
| Nhập điểm | Nhập/sửa CC/GK/CK + thống kê | Xem read-only | ❌ |
| Báo cáo | 5 loại BC + preview + in/PDF | Xem/in như PGV | Chỉ phiếu điểm cá nhân |
| Quản trị TK | Full | ❌ | ❌ |

## 5. Trung tâm báo cáo
| Loại báo cáo | Tham số | PGV | KHOA | SV |
|---|---|---|---|---|
| DS lớp tín chỉ | NK/HK/Khoa | ✅ | ✅ | ❌ |
| DSSV đăng ký LTC | NK/HK/Môn/Nhóm | ✅ | ✅ | ❌ |
| Bảng điểm môn học | NK/HK/Môn/Nhóm + HM/chữ/hệ4 | ✅ | ✅ | ❌ |
| Phiếu điểm SV | MASV + toàn khóa/theo HK | ✅ | ✅ | ✅ (chỉ mình) |
| Bảng điểm tổng kết | Lớp HC (Cross-Tab) | ✅ | ✅ | ❌ |

## 6. Ghi chú triển khai
- **KHOA** hiện dùng chung role, thực tế nên tách: khoa_cntt, khoa_vt...
- **Môn tiên quyết**: bỏ qua vì đề không yêu cầu
- **Tín chỉ**: không có cột riêng, tính từ SOTIET_LT/SOTIET_TH
- **Trạng thái tốt nghiệp**: suy từ KHOAHOC, không cần cột TOTNGHIEP
