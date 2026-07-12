# Slice 02: Mobile Auth UI & Real-Date Dashboard Streak

## Contract Unlocked
Người dùng mobile có thể bấm vào nút Đăng nhập / Tài khoản trên màn hình chính (`DashboardScreen`), đăng ký tài khoản mới hoặc đăng nhập tài khoản đã có. Khi học tập hoặc mở app trong ngày, hệ thống cập nhật streak và hiển thị chính xác chuỗi ngày học trên thẻ Streak của Dashboard. Nếu không học trong ngày, thẻ Streak sẽ hiển thị trạng thái chính xác theo thực tế (giữ hoặc reset).

## UI & Integration Seams
1. **`RemoteAiDataSource` (`remote_ai_datasource.dart`)**:
   - `Future<Map<String, dynamic>> register({required String username, required String email, required String password})`
   - `Future<Map<String, dynamic>> login({required String username, required String password})`
   - `Future<Map<String, dynamic>> recordActivity({required String username, String? activityDate})`
2. **`AuthDialog` / `AuthScreen` (`presentation/widgets/auth/auth_modal.dart`)**:
   - Modal hiển thị form Đăng ký / Đăng nhập phong cách Sakura/Modern UI tinh gọn.
   - Khi hoàn tất, lưu thông tin vào `SharedPreferences` (`auth_token`, `auth_username`, `streak_count`, `last_activity_date`).
3. **`DashboardScreen` (`dashboard_screen.dart`)**:
   - Thêm nút quản lý tài khoản ở AppBar/Header.
   - Hiển thị Streak theo ngày thực tế từ SharedPreferences/Backend.
   - Tính toán 7 ngày trong tuần theo lịch thực tế (`T2`, `T3`, ..., `CN`) và đánh dấu ngày hôm nay (`isToday`).

## Verification Gates
- `flutter test` đảm bảo toàn bộ widget và các kết nối hoạt động chính xác.
