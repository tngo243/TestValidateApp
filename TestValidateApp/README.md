# Video Downloader iOS App

Ứng dụng iOS cho phép người dùng tải video từ đường dẫn URL, hiển thị tiến trình tải trong danh sách, tạo ảnh đại diện (thumbnail) sau khi tải, và hỗ trợ hủy hoặc xóa video đã tải.

---

## Tính năng

- Nhập URL video để bắt đầu tải
- Hiển thị tiến độ tải theo phần trăm trong từng dòng của bảng (UITableView)
- Tạo ảnh thumbnail từ video sau khi tải về
- Hủy quá trình tải video đang diễn ra
- Xóa video đã tải khỏi danh sách
- Lưu trạng thái tải xuống bằng `UserDefaults`

---

## Kiến trúc và Design Pattern sử dụng

### 1. **Kiến trúc tổng thể**
Ứng dụng áp dụng mô hình **MVC (Model - View - Controller)** đơn giản, chia rõ vai trò của từng lớp:

- **Model**: `DownloadItem` đại diện cho dữ liệu của từng video
- **View**: `DownloadedVideoTableViewCell` hiển thị nội dung và trạng thái tải
- **Controller**: `ViewController` điều phối logic, tương tác UI và model

### 2. **Design Patterns**

| Pattern | Vai trò |
|--------|--------|
| **Singleton** | `VideoDownloader.shared`: dùng để quản lý tải xuống một cách tập trung |
| **Delegation** | `URLSessionDownloadDelegate`: xử lý tiến trình và hoàn tất tải |
| **Closure Callback** | Truyền `onProgress`, `onCompletion` từ `VideoDownloader` về `ViewController` |
| **Observer (gián tiếp)** | `UserDefaults`: lưu trạng thái, được reload khi app khởi động lại |
| **Extension** | Mở rộng `UIViewController` để hiển thị alert (`showAlert`) |
| **Weak Capture List** | Tránh retain cycle trong closure (`[weak self]`) khi xử lý UI và completion block |

---
