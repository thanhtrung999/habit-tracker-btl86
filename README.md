# Ứng Dụng Theo Dõi Thói Quen & Hoàn Thành Mục Tiêu Hằng Ngày (Habit Tracker APK)

Một ứng dụng di động gọn nhẹ, tinh tế và dễ sử dụng, được thiết kế chuyên biệt để giúp bạn xây dựng kỷ luật, theo dõi tiến độ mục tiêu từng ngày, ghi chú nhật ký và trực quan hóa kết quả qua lịch & biểu đồ.

---

## ✨ Các Tính Năng Chính Đã Hoàn Thiện

### 1. Quản lý Mục tiêu / Thói quen (CRUD)
- **Thêm mới mục tiêu**: Đặt tên, mô tả động lực, phân loại danh mục (Sức khỏe, Học tập, Công việc, Tinh thần, Kỷ luật lối sống).
- **Tùy chỉnh linh hoạt**: Chọn chu kỳ (Hằng ngày hoặc chọn các thứ cụ thể trong tuần T2 - CN), thiết lập định lượng (ví dụ: uống 4 ly nước, đọc 20 trang sách, tập 30 phút).
- **Màu sắc nhận diện**: Bảng màu pastel nhẹ nhàng, dịu mắt (Sage Green, Ocean Blue, Lavender, Warm Amber...), không gây mỏi mắt hay phân tâm.
- **Chỉnh sửa & Xóa**: Cập nhật thông tin hoặc xóa mục tiêu dễ dàng.

### 2. Theo Dõi Tiến Độ Hằng Ngày (Daily Check-in)
- Check-in 1 chạm trực tiếp trên danh sách nhiệm vụ.
- Hỗ trợ nút tăng/giảm số lượng với các mục tiêu có định lượng.
- **Hero Card Tiến Độ**: Hiển thị trực quan tỷ lệ % hoàn thành trong ngày cùng thanh tiến trình đổi màu mượt mà.
- **Bộ đếm Streak (Chuỗi ngày liên tục)**: Tạo động lực duy trì thói quen không ngắt quãng (biểu tượng 🔥).
- Điều hướng ngày linh hoạt: Xem lại lịch sử các ngày trước hoặc xem trước lịch trình ngày mai.

### 3. Ghi Chú & Nhật Ký Cho Từng Nhiệm Vụ (Task Notes)
- Mỗi nhiệm vụ trong từng ngày đều có thể gắn kèm **ghi chú chi tiết**: ghi lại cảm nhận, trang sách đã đọc, cự ly chạy bộ hoặc bài học rút ra.
- Hiển thị xem nhanh ghi chú ngay trên thẻ nhiệm vụ.
- Dữ liệu ghi chú được gắn theo từng ngày để bạn dễ dàng nhìn lại hành trình phát triển bản thân.

### 4. Lịch Biểu & Biểu Đồ Thống Kê (Calendar & Analytics)
- **Lịch tháng trực quan (Heatmap Calendar)**:
  - Màu **Xanh lá**: Ngày hoàn thành 100% mục tiêu.
  - Màu **Vàng cam nhạt**: Ngày hoàn thành một phần.
  - Màu **Xám nhạt**: Ngày chưa hoàn thành.
  - **Chạm vào bất kỳ ngày nào** trên lịch để xem ngay chi tiết danh sách nhiệm vụ và ghi chú của ngày đó.
- **Biểu đồ 7 ngày gần nhất (Canvas Chart)**: Biểu đồ cột tự động tính toán hiệu suất tuần, chạy **offline 100%** không phụ thuộc thư viện mạng bên ngoài.
- **Bảng số liệu tổng quan**: Thống kê chuỗi ngày liên tục dài nhất, tỷ lệ hoàn thành trung bình tuần, tổng số lượt hoàn thành tích lũy.

### 5. Sao Lưu & Bảo Mật Dữ Liệu
- Dữ liệu lưu trữ cục bộ (Offline-first trên thiết bị), tuyệt đối an toàn và riêng tư.
- Chức năng **Xuất dữ liệu dự phòng (JSON)** và **Khôi phục dữ liệu từ tệp JSON**.
- Nút nạp dữ liệu mẫu để trải nghiệm đầy đủ giao diện chỉ trong 1 giây.

---

## 🚀 Cách Chạy Thử Ngay Trên Máy Tính Hoặc Điện Thoại

Bạn không cần cài đặt phần mềm phức tạp nào:
1. Mở trực tiếp tệp `index.html` bằng trình duyệt web bất kỳ (Chrome, Safari, Edge, Firefox).
2. Hoặc mở Terminal tại thư mục này và chạy lệnh:
   ```bash
   python3 -m http.server 8080
   ```
   Sau đó mở trình duyệt tại địa chỉ: `http://localhost:8080`.
   *(Nếu mở trên điện thoại cùng mạng Wi-Fi, truy cập `http://<địa-chỉ-IP-máy-tính>:8080`)*.

---

## 📱 Hướng Dẫn 3 Cách Xuất / Cài Đặt File APK Cho Điện Thoại Android

### Cách 1: Tạo File APK Tự Động Miễn Phí Qua GitHub Actions (Khuyên Dùng Nhất)
Dự án đã được tích hợp sẵn tệp CI/CD: `.github/workflows/build-apk.yml`.
1. Bạn đưa toàn bộ thư mục mã nguồn này lên một kho lưu trữ (Repository) trên **GitHub** của bạn:
   ```bash
   git init
   git add .
   git commit -m "Khoi tao ung dung Habit Tracker"
   git branch -M main
   git remote add origin https://github.com/<tai-khoan-cua-ban>/habit-tracker.git
   git push -u origin main
   ```
2. Truy cập vào kho lưu trữ trên GitHub -> chọn tab **Actions**.
3. GitHub sẽ tự động chạy máy chủ build mã nguồn và tạo ra file APK (`app-debug.apk`) trong vòng khoảng 3 phút.
4. Bạn vào mục **Artifacts** trong Action vừa chạy để tải file APK về điện thoại Android và cài đặt trực tiếp.

---

### Cách 2: Sử Dụng PWABuilder (Không Cần Code)
1. Tải thư mục này lên dịch vụ hosting miễn phí (như GitHub Pages, Vercel, Netlify hoặc Firebase Hosting).
2. Truy cập trang web: [PWABuilder.com](https://www.pwabuilder.com).
3. Dán đường link website của bạn vào ô tìm kiếm -> Nhấn **Start**.
4. Chọn mục **Android** -> Nhấn **Package for Android** -> Tải gói file `.apk` về điện thoại.

---

### Cách 3: Biên Dịch Cục Bộ Bằng Capacitor & Android Studio (Dành Cho Lập Trình Viên)
Nếu máy bạn có cài sẵn **Node.js** và **Android Studio**:
1. Cài đặt các gói phụ thuộc:
   ```bash
   npm install
   ```
2. Khởi tạo dự án Android native:
   ```bash
   npx cap add android
   npx cap sync android
   ```
3. Mở trong Android Studio:
   ```bash
   npx cap open android
   ```
4. Trong Android Studio, chọn menu **Build** > **Build Bundle(s) / APK(s)** > **Build APK(s)**. File `.apk` sẽ được tạo ra tại thư mục `android/app/build/outputs/apk/debug/app-debug.apk`.

---

### Cách 4: Cài Đặt Dưới Dạng Ứng Dụng PWA (Trải Nghiệm Y Hệt APK)
Ứng dụng đã có đầy đủ cấu hình `manifest.json` và `icon.svg`:
- Trên điện thoại Android, mở ứng dụng qua Chrome.
- Nhấn vào nút menu **3 chấm** ở góc trên trình duyệt Chrome -> Chọn **"Thêm vào màn hình chính" (Add to Home screen)** hoặc **"Cài đặt ứng dụng" (Install app)**.
- Ứng dụng sẽ xuất hiện trên màn hình điện thoại với biểu tượng riêng, mở toàn màn hình (không thanh địa chỉ duyệt web), chạy mượt mà như một ứng dụng APK cài từ CH Play.

---

## 📂 Cấu Trúc Thư Mục Dự Án

```
├── index.html                 # Giao diện chính của ứng dụng
├── css/
│   └── styles.css             # Thiết kế giao diện mobile, màu sắc pastel, chuẩn kích thước chạm
├── js/
│   └── app.js                 # Toàn bộ logic: CRUD, Streak, Lịch, Ghi chú, Canvas Chart
├── assets/
│   └── icon.svg               # Biểu tượng ứng dụng vector sắc nét
├── manifest.json              # Cấu hình PWA & App Manifest cho Android
├── capacitor.config.json      # Cấu hình đóng gói Android APK bằng Capacitor
├── package.json               # Cấu hình scripts & dependencies
├── .github/
│   └── workflows/
│       └── build-apk.yml      # CI/CD tự động biên dịch APK trên đám mây GitHub
└── README.md                  # Tài liệu hướng dẫn sử dụng và xuất APK
```

---

## 💡 Gợi Ý Lời Nhắc (Prompt) Mở Rộng Thêm Tính Năng Sau Này

Nếu muốn tích hợp thêm tính năng trong các phiên bản tiếp theo, bạn có thể sử dụng các câu nhắc sau:

- **Thêm tính năng Nhắc nhở thông báo (Push Notifications)**:
  > *"Thêm tính năng hẹn giờ nhắc nhở (Notification) cho từng mục tiêu trong app bằng Web Notification API hoặc Capacitor Local Notifications, cho phép người dùng đặt giờ như 07:00 sáng mỗi ngày."*

- **Đồng bộ đám mây (Cloud Sync)**:
  > *"Tích hợp Firebase Firestore hoặc Supabase để đồng bộ dữ liệu mục tiêu và ghi chú giữa điện thoại và máy tính qua tài khoản đăng nhập Google."*

- **Thêm chế độ Pomodoro Timer cho nhiệm vụ**:
  > *"Bổ sung đồng hồ đếm ngược Pomodoro 25 phút tập trung kèm âm thanh chuông nhẹ nhàng khi hoàn thành một phiên làm việc."*
