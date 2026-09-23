# 🌿 Atomic Habit (Flutter Native)

Một ứng dụng theo dõi thói quen và rèn luyện kỷ luật bản thân **Atomic Habit - Flutter Native 100% Offline**, được thiết kế với giao diện **Sage Green** hiện đại, hoạt ảnh vi tương tác (micro-interactions) sống động, và lưu trữ dữ liệu an toàn trên thiết bị bằng SQLite.

---

## ✨ Điểm Nổi Bật

- **Hoạt ảnh nảy xúc giác (Tactile Bounce)**: Nút tròn check-in nảy mượt mà khi bấm, thẻ thói quen gạch ngang và tự động hạ dần độ đậm, đưa thói quen đã xong xuống cuối danh sách.
- **Ngọn lửa Streak Flame**: Icon `🔥` nhịp đập liên tục, tự động biến đổi màu và biểu tượng theo 8 cấp độ danh hiệu (từ Khởi Đầu đến Huyền Thoại Kim Cương).
- **Pháo hoa giấy (Confetti)**: Bắn pháo hoa giấy rực rỡ khắp màn hình khi bạn hoàn thành 100% mục tiêu của ngày hôm nay.
- **Biểu đồ cột 7 ngày**: Các cột tự động nâng hạ độ cao chuyển động theo % hoàn thành với màu Sage Green.
- **Lịch nhiệt tháng (Heatmap Calendar)**: Lưới lịch trực quan với các chấm trạng thái (hoàn thành 100%, một phần, chưa thực hiện), chạm vào ngày bất kỳ để xem lại lịch sử.
- **Dữ liệu 100% Offline & Bảo mật**: Dữ liệu lưu trong SQLite trên máy người dùng, không phụ thuộc server hay internet, không sợ rò rỉ dữ liệu.
- **Sao lưu & Khôi phục JSON**: Dễ dàng sao chép mã sao lưu JSON hoặc dán vào để khôi phục toàn bộ thói quen và lịch sử check-in.

---

## 🏗️ Cấu Trúc Dự Án

```
habit_tracker_flutter/
├── lib/
│   ├── main.dart                          # Điểm khởi chạy ứng dụng & Provider setup
│   ├── core/
│   │   ├── constants/milestone_tiers.dart # 8 cấp độ danh hiệu
│   │   ├── theme/app_colors.dart          # Bảng màu Sage Green, status & danh mục
│   │   ├── theme/app_theme.dart           # Material 3 Theme & Google Fonts
│   │   └── utils/date_utils.dart          # Định dạng ngày giờ tiếng Việt & chuẩn ISO
│   ├── data/
│   │   ├── models/goal.dart               # Model mục tiêu thói quen & lịch lặp
│   │   ├── models/goal_record.dart        # Model lịch sử check-in & ghi chú
│   │   ├── models/day_progress.dart       # Model tiến độ ngày (% hoàn thành)
│   │   ├── services/database_service.dart # SQLite offline engine
│   │   └── repositories/habit_repository.dart # Xử lý nghiệp vụ & tính chuỗi streak
│   └── ui/
│       ├── viewmodels/habit_viewmodel.dart# Quản lý trạng thái phản ứng (ChangeNotifier)
│       ├── widgets/
│       │   ├── habit_card.dart            # Thẻ thói quen với nút tick nảy, bộ đếm & ghi chú
│       │   ├── streak_flame.dart          # Huy hiệu ngọn lửa nhịp đập & cấp bậc
│       │   ├── weekly_chart.dart          # Biểu đồ cột hiệu suất 7 ngày
│       │   ├── calendar_heatmap.dart      # Lưới lịch nhiệt tháng
│       │   └── confetti_overlay.dart      # Pháo hoa ăn mừng khi đạt 100%
│       └── screens/
│           ├── today_screen.dart          # Tab 1: Hôm nay (Mục tiêu, tiến độ, bộ lọc danh mục)
│           ├── calendar_screen.dart       # Tab 2: Lịch tháng, thống kê & danh sách cột mốc
│           ├── goals_screen.dart          # Tab 3: Quản lý thói quen & Sao lưu JSON offline
│           └── main_navigation.dart       # Thanh điều hướng NavigationBar đáy màn hình
└── test/
    └── widget_test.dart                   # Bộ test tự động (Models, Streak, DateUtils)
```

---

## 📦 Tự Động Build APK Qua GitHub Actions

Dự án đã tích hợp sẵn workflow tại `.github/workflows/build-flutter-apk.yml`.

Khi bạn push code lên GitHub:
1. GitHub Actions sẽ tự động kích hoạt máy ảo Ubuntu.
2. Cài đặt môi trường Flutter & Java 17.
3. Chạy `dart analyze lib` kiểm tra code.
4. Biên dịch bản phát hành: `flutter build apk --release`.
5. File `app-release.apk` sẽ tự động sẵn sàng trong mục **Artifacts** của GitHub Actions để bạn tải về cài đặt lên điện thoại.

---

## 💻 Chạy Thử Trên Máy Tính (Local)

Di chuyển vào thư mục Flutter:
```bash
cd habit_tracker_flutter
flutter pub get
```

Kiểm tra mã nguồn & chạy kiểm thử:
```bash
dart analyze lib
flutter test
```
