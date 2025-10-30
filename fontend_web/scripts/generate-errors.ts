import * as fs from 'fs'
import * as path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const JAVA_ENUM_PATH = path.resolve(__dirname, '../../backend/gpms/src/main/java/com/backend/gpms/common/exception/ErrorCode.java')
const TS_OUTPUT_PATH = path.resolve(__dirname, '../src/shared/constants/errorMessages.ts')

const MESSAGE_MAP: Record<string, string> = {
    // Auth
    'Ban can dang nhap.': 'Bạn cần đăng nhập.',
    'Ban khong co quyen truy cap.': 'Bạn không có quyền truy cập.',
    'Token da het han.': 'Phiên đăng nhập đã hết hạn.',
    'Token khong hop le.': 'Token không hợp lệ.',
    'Tai khoan chua duoc kich hoat.': 'Tài khoản chưa được kích hoạt.',
    'Mat khau khong dung.': 'Mật khẩu không đúng.',
    'Nguoi dung khong ton tai.': 'Người dùng không tồn tại.',
    'Giang vien khong co quyen tren de tai nay.': 'Giảng viên không có quyền trên đề tài này.',
    'Tai khoan khong phai giang vien huong dan.': 'Tài khoản không phải giảng viên hướng dẫn.',
    'Mat khau cu khong duoc su dung.': 'Mật khẩu cũ không được sử dụng.',

    // Validation
    'Du lieu dau vao khong hop le.': 'Dữ liệu đầu vào không hợp lệ.',
    'Email khong hop le.': 'Email không hợp lệ.',
    'Mat khau phai co it nhat 6 ky tu.': 'Mật khẩu phải có ít nhất 6 ký tự.',
    'Email da ton tai.': 'Email đã tồn tại.',
    'Ma sinh vien da ton tai.': 'Mã sinh viên đã tồn tại.',
    'Ma giang vien da ton tai.': 'Mã giảng viên đã tồn tại.',
    'Ten khoa khong duoc de trong.': 'Tên khoa không được để trống.',
    'Ten nganh khong duoc de trong.': 'Tên ngành không được để trống.',
    'Ten bo mon khong duoc de trong.': 'Tên bộ môn không được để trống.',
    'Ten lop khong duoc de trong.': 'Tên lớp không được để trống.',
    'Ten de tai khong duoc de trong.': 'Tên đề tài không được để trống.',
    'De cuong khong duoc de trong.': 'Đề cương không được để trống.',
    'URL file khong duoc de trong.': 'URL file không được để trống.',
    'ID de tai phai la so duong.': 'ID đề tài phải là số dương.',
    'Ly do tu choi de cuong la bat buoc.': 'Lý do từ chối đề cương là bắt buộc.',
    'Ly do hoan khong duoc de trong.': 'Lý do hoãn không được để trống.',
    'Dinh dang file khong duoc phep.': 'Định dạng file không được phép.',
    'Kich thuoc file vuot qua gioi han.': 'Kích thước file vượt quá giới hạn.',
    'Ma sinh vien khong hop le.': 'Mã sinh viên không hợp lệ.',
    'Ho ten khong duoc de trong.': 'Họ tên không được để trống.',
    'So dien thoai khong hop le.': 'Số điện thoại không hợp lệ.',
    'Nam hoc khong duoc de trong.': 'Năm học không được để trống.',
    'Hoc ky khong duoc de trong.': 'Học kỳ không được để trống.',
    'Noi dung khong duoc de trong.': 'Nội dung không được để trống.',
    'Nhan xet khong duoc de trong.': 'Nhận xét không được để trống.',
    'ID nhat ky la bat buoc.': 'ID nhật ký là bắt buộc.',
    'So tuan khong hop le.': 'Số tuần không hợp lệ.',
    'Dinh dang tuan khong hop le.': 'Định dạng tuần không hợp lệ.',
    'Duong dan file khong duoc de trong.': 'Đường dẫn file không được để trống.',
    'ID bao cao la bat buoc.': 'ID báo cáo là bắt buộc.',
    'ID bao cao khong hop le.': 'ID báo cáo không hợp lệ.',
    'Diem so la bat buoc khi phe duyet bao cao.': 'Điểm số là bắt buộc khi phê duyệt báo cáo.',
    'Diem so phai tu 0 den 10.': 'Điểm số phải từ 0 đến 10.',
    'Gia tri enum khong hop le.': 'Giá trị enum không hợp lệ.',
    'Phuong thuc khong duoc phep.': 'Phương thức không được phép.',
    'Yeu cau khong hop le.': 'Yêu cầu không hợp lệ.',
    'File khong duoc de trong.': 'File không được để trống.',
    'Giang vien huong dan la bat buoc.': 'Giảng viên hướng dẫn là bắt buộc.',
    'File tong quan de tai khong hop le.': 'File tổng quan đề tài không hợp lệ.',
    'File Excel khong hop le.': 'File Excel không hợp lệ.',
    'Cau hinh hoi dong khong hop le.': 'Cấu hình hội đồng không hợp lệ.',
    'Khoang thoi gian khong hop le.': 'Khoảng thời gian không hợp lệ.',
    'Cong viec da ton tai trong dot bao ve nay.': 'Công việc đã tồn tại trong đợt bảo vệ này.',
    'Ngoai thoi gian dang ky.': 'Ngoài thời gian đăng ký.',
    'Chi chap nhan file PDF.': 'Chỉ chấp nhận file PDF.',

    // Not Found
    'Khoa khong ton tai.': 'Khoa không tồn tại.',
    'Nganh khong ton tai.': 'Ngành không tồn tại.',
    'Bo mon khong ton tai.': 'Bộ môn không tồn tại.',
    'Lop khong ton tai.': 'Lớp không tồn tại.',
    'De tai khong ton tai.': 'Đề tài không tồn tại.',
    'De cuong khong ton tai.': 'Đề cương không tồn tại.',
    'Giang vien khong ton tai.': 'Giảng viên không tồn tại.',
    'Sinh vien khong ton tai.': 'Sinh viên không tồn tại.',
    'Hoi dong khong ton tai.': 'Hội đồng không tồn tại.',
    'File khong ton tai.': 'File không tồn tại.',
    'Thong bao khong ton tai.': 'Thông báo không tồn tại.',
    'Nhat ky khong ton tai.': 'Nhật ký không tồn tại.',
    'Dot bao ve khong ton tai.': 'Đợt bảo vệ không tồn tại.',
    'Thoi gian thuc hien khong ton tai.': 'Thời gian thực hiện không tồn tại.',
    'Bao cao khong ton tai.': 'Báo cáo không tồn tại.',
    'Tro ly khoa khong ton tai.': 'Trợ lý khoa không tồn tại.',

    // Business Logic
    'Ten khoa da ton tai.': 'Tên khoa đã tồn tại.',
    'Ten nganh da ton tai.': 'Tên ngành đã tồn tại.',
    'Ten bo mon da ton tai.': 'Tên bộ môn đã tồn tại.',
    'Ten lop da ton tai.': 'Tên lớp đã tồn tại.',
    'De tai da duoc chap nhan.': 'Đề tài đã được chấp nhận.',
    'De cuong da duoc phe duyet.': 'Đề cương đã được phê duyệt.',
    'De cuong da duoc nop.': 'Đề cương đã được nộp.',
    'De cuong da bi tu choi.': 'Đề cương đã bị từ chối.',
    'De cuong chua duoc phe duyet.': 'Đề cương chưa được phê duyệt.',
    'Ngoai thoi gian nop de cuong.': 'Ngoài thời gian nộp đề cương.',
    'Chua den thoi gian nop de cuong.': 'Chưa đến thời gian nộp đề cương.',
    'Chua den thoi gian xet duyet de cuong.': 'Chưa đến thời gian xét duyệt đề cương.',
    'Sinh vien da dang ky de tai.': 'Sinh viên đã đăng ký đề tài.',
    'Trang thai khong hop le.': 'Trạng thái không hợp lệ.',
    'Don hoan do an dang cho xu ly.': 'Đơn hoãn đồ án đang chờ xử lý.',
    'Sinh vien da co de tai, khong the hoan.': 'Sinh viên đã có đề tài, không thể hoãn.',
    'Ten hoi dong da ton tai trong dot nay.': 'Tên hội đồng đã tồn tại trong đợt này.',
    'Thoi gian hoi dong khong nam trong khoang thoi gian dot.': 'Thời gian hội đồng không nằm trong khoảng thời gian đợt.',
    'Giang vien khong dang ky trong dot nay.': 'Giảng viên không đăng ký trong đợt này.',
    'Hoi dong phai co it nhat Chu tich va Thu ky.': 'Hội đồng phải có ít nhất Chủ tịch và Thư ký.',
    'De tai da thuoc hoi dong khac.': 'Đề tài đã thuộc hội đồng khác.',
    'De tai khong thuoc dot cua hoi dong.': 'Đề tài không thuộc đợt của hội đồng.',
    'De tai chua duoc chap nhan.': 'Đề tài chưa được chấp nhận.',
    'Tai khoan da la Truong bo mon.': 'Tài khoản đã là Trưởng bộ môn.',
    'Giang vien khong thuoc bo mon.': 'Giảng viên không thuộc bộ môn.',
    'Truong bo mon khong the la Tro ly khoa.': 'Trưởng bộ môn không thể là Trợ lý khoa.',
    'Dot bao ve da ton tai.': 'Đợt bảo vệ đã tồn tại.',
    'Ngoai thoi gian dot bao ve.': 'Ngoài thời gian đợt bảo vệ.',
    'Nhat ky da duoc nhan xet.': 'Nhật ký đã được nhận xét.',
    'Khong con tuan nao de tao nhat ky moi.': 'Không còn tuần nào để tạo nhật ký mới.',
    'De tai chua duoc giang vien huong dan phe duyet.': 'Đề tài chưa được giảng viên hướng dẫn phê duyệt.',
    'De cuong chua duoc giang vien huong dan phe duyet.': 'Đề cương chưa được giảng viên hướng dẫn phê duyệt.',
    'De cuong da duoc phe duyet hoan toan.': 'Đề cương đã được phê duyệt hoàn toàn.',
    'Bo mon hoac Truong bo mon chua duoc phan cong cho sinh vien nay.': 'Bộ môn hoặc Trưởng bộ môn chưa được phân công cho sinh viên này.',
    'Ngoai thoi gian nop bao cao.': 'Ngoài thời gian nộp báo cáo.',
    'Bao cao da duoc phe duyet.': 'Báo cáo đã được phê duyệt.',
    'Bao cao da bi tu choi.': 'Báo cáo đã bị từ chối.',
    'Bao cao chua bi tu choi.': 'Báo cáo chưa bị từ chối.',
    'Nhan xet la bat buoc khi tu choi bao cao.': 'Nhận xét là bắt buộc khi từ chối báo cáo.',
    'De cuong chua duoc giang vien phan bien phe duyet.': 'Đề cương chưa được giảng viên phản biện phê duyệt.',
    'De cuong khong o trang thai cho phe duyet.': 'Đề cương không ở trạng thái chờ phê duyệt.',
    'De tai khong o trang thai cho phe duyet.': 'Đề tài không ở trạng thái chờ phê duyệt.',
    'Khong phai de tai cua ban huong dan.': 'Không phải đề tài của bạn hướng dẫn.',

    // Server
    'Loi he thong.': 'Lỗi hệ thống.',
    'Tai file len that bai.': 'Tải file lên thất bại.',
    'Tai file minh chung cho don hoan that bai.': 'Tải file minh chứng cho đơn hoãn thất bại.',
}

// === MAIN ===
try {
    if (!fs.existsSync(JAVA_ENUM_PATH)) {
        console.error('Không tìm thấy file ErrorCode.java:', JAVA_ENUM_PATH)
        process.exit(1)
    }

    console.log('Đang đọc ErrorCode.java...')
    const javaContent = fs.readFileSync(JAVA_ENUM_PATH, 'utf-8')

    const enumRegex = /^\s*([A-Z_]+)\((\d+),\s*"([^"]+)"\s*,/gm
    const matches = [...javaContent.matchAll(enumRegex)]

    if (matches.length === 0) throw new Error('Không tìm thấy enum ErrorCode')

    const entries: string[] = []
    const missing: string[] = []

    for (const [, name, , message] of matches) {
        const frontendMessage = MESSAGE_MAP[message]
        if (frontendMessage) {
            entries.push(`  [ErrorCode.${name}]: '${frontendMessage}',`)
        } else {
            missing.push(`${name}: "${message}"`)
            entries.push(`  [ErrorCode.${name}]: '${message}', // TODO: Thêm bản có dấu`)
        }
    }

    const output = `// src/shared/constants/errorMessages.ts
// TỰ ĐỘNG SINH - KHÔNG SỬA TRỰC TIẾP
import { ErrorCode } from './errorCode'

export const ERROR_MESSAGES: Record<ErrorCode, string> = {
${entries.join('\n')}
}
`

    fs.writeFileSync(TS_OUTPUT_PATH, output, 'utf-8')
    console.log(`Đã sinh ${entries.length} message → ${TS_OUTPUT_PATH}`)

    if (missing.length > 0) {
        console.warn('Cảnh báo: Thiếu bản có dấu:', missing.join(', '))
    }
} catch (error) {
    console.error('Lỗi:', error)
    process.exit(1)
}