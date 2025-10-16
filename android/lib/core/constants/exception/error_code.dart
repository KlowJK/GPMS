import 'package:flutter/foundation.dart';
import 'package:http/http.dart' show Response;

enum ErrorCode {
  // Auth Errors
  unauthenticated(
    code: 1001,
    message: 'Bạn cần đăng nhập.',
    httpStatusCode: 401, // HttpStatus.UNAUTHORIZED
  ),
  forbidden(
    code: 1002,
    message: 'Bạn không có quyền truy cập.',
    httpStatusCode: 403, // HttpStatus.FORBIDDEN
  ),
  tokenExpired(code: 1003, message: 'Token đã hết hạn.', httpStatusCode: 401),
  invalidToken(code: 1004, message: 'Token không hợp lệ.', httpStatusCode: 401),
  inactivatedAccount(
    code: 1005,
    message: 'Tài khoản chưa được kích hoạt.',
    httpStatusCode: 403,
  ),
  wrongPassword(
    code: 1006,
    message: 'Mật khẩu không đúng.',
    httpStatusCode: 403,
    field: 'password',
  ),
  userNotFound(
    code: 1007,
    message: 'Người dùng không tồn tại.',
    httpStatusCode: 404, // HttpStatus.NOT_FOUND
    field: 'email',
  ),
  notGvhdOfDeTai(
    code: 1008,
    message: 'Giảng viên không có quyền trên đề tài này.',
    httpStatusCode: 403,
  ),
  notAGvhd(
    code: 1009,
    message: 'Tài khoản không phải giảng viên hướng dẫn.',
    httpStatusCode: 403,
  ),
  oldPassword(
    code: 1010,
    message: 'Mật khẩu cũ không được sử dụng.',
    httpStatusCode: 403,
    field: 'password',
  ),
  invalidResponse(
    code: 1011,
    message: 'Phản hồi không hợp lệ từ máy chủ.',
    httpStatusCode: 500,
  ),

  // Validation Errors
  invalidValidation(
    code: 2001,
    message: 'Dữ liệu đầu vào không hợp lệ.',
    httpStatusCode: 400, // HttpStatus.BAD_REQUEST
  ),
  emailInvalid(
    code: 2002,
    message: 'Email không hợp lệ.',
    httpStatusCode: 400,
    field: 'email',
  ),
  passwordInvalid(
    code: 2003,
    message: 'Mật khẩu phải có ít nhất 6 ký tự.',
    httpStatusCode: 400,
    field: 'password',
  ),
  emailExisted(
    code: 2004,
    message: 'Email đã tồn tại.',
    httpStatusCode: 400,
    field: 'email',
  ),
  maSvExisted(
    code: 2005,
    message: 'Mã sinh viên đã tồn tại.',
    httpStatusCode: 400,
  ),
  maGvExisted(
    code: 2006,
    message: 'Mã giảng viên đã tồn tại.',
    httpStatusCode: 400,
  ),
  khoaEmpty(
    code: 2007,
    message: 'Tên khoa không được để trống.',
    httpStatusCode: 400,
  ),
  nganhEmpty(
    code: 2008,
    message: 'Tên ngành không được để trống.',
    httpStatusCode: 400,
  ),
  boMonEmpty(
    code: 2009,
    message: 'Tên bộ môn không được để trống.',
    httpStatusCode: 400,
  ),
  lopEmpty(
    code: 2010,
    message: 'Tên lớp không được để trống.',
    httpStatusCode: 400,
  ),
  deTaiEmpty(
    code: 2011,
    message: 'Tên đề tài không được để trống.',
    httpStatusCode: 400,
  ),
  deCuongEmpty(
    code: 2012,
    message: 'Đề cương không được để trống.',
    httpStatusCode: 400,
  ),
  fileUrlEmpty(
    code: 2013,
    message: 'URL file không được để trống.',
    httpStatusCode: 400,
  ),
  deTaiIdMustBePositive(
    code: 2014,
    message: 'ID đề tài phải là số dương.',
    httpStatusCode: 400,
  ),
  deCuongReasonRequired(
    code: 2015,
    message: 'Lý do từ chối đề cương là bắt buộc.',
    httpStatusCode: 400,
  ),
  lyDoHoanRequired(
    code: 2016,
    message: 'Lý do hoãn không được để trống.',
    httpStatusCode: 400,
  ),
  invalidFileType(
    code: 2017,
    message: 'Định dạng file không được phép.',
    httpStatusCode: 400,
  ),
  fileTooLarge(
    code: 2018,
    message: 'Kích thước file vượt quá giới hạn.',
    httpStatusCode: 400,
  ),
  maSvInvalid(
    code: 2019,
    message: 'Mã sinh viên không hợp lệ.',
    httpStatusCode: 400,
  ),
  hoTenEmpty(
    code: 2020,
    message: 'Họ tên không được để trống.',
    httpStatusCode: 400,
  ),
  soDienThoaiInvalid(
    code: 2021,
    message: 'Số điện thoại không hợp lệ.',
    httpStatusCode: 400,
  ),
  namHocEmpty(
    code: 2022,
    message: 'Năm học không được để trống.',
    httpStatusCode: 400,
  ),
  hocKiEmpty(
    code: 2023,
    message: 'Học kỳ không được để trống.',
    httpStatusCode: 400,
  ),
  noiDungRequired(
    code: 2024,
    message: 'Nội dung không được để trống.',
    httpStatusCode: 400,
  ),
  nhanXetRequired(
    code: 2025,
    message: 'Nhận xét không được để trống.',
    httpStatusCode: 400,
  ),
  nhatKyIdRequired(
    code: 2026,
    message: 'ID nhật ký là bắt buộc.',
    httpStatusCode: 400,
  ),
  invalidWeekNumber(
    code: 2027,
    message: 'Số tuần không hợp lệ.',
    httpStatusCode: 400,
  ),
  invalidWeekFormat(
    code: 2028,
    message: 'Định dạng tuần không hợp lệ.',
    httpStatusCode: 400,
  ),
  duongDanRequired(
    code: 2029,
    message: 'Đường dẫn file không được để trống.',
    httpStatusCode: 400,
  ),
  idBaoCaoRequired(
    code: 2030,
    message: 'ID báo cáo là bắt buộc.',
    httpStatusCode: 400,
  ),
  invalidBaoCaoId(
    code: 2031,
    message: 'ID báo cáo không hợp lệ.',
    httpStatusCode: 400,
  ),
  scoreRequiredForApproval(
    code: 2032,
    message: 'Điểm số là bắt buộc khi phê duyệt báo cáo.',
    httpStatusCode: 400,
  ),
  invalidScoreRange(
    code: 2033,
    message: 'Điểm số phải từ 0 đến 10.',
    httpStatusCode: 400,
  ),
  invalidEnumValue(
    code: 2034,
    message: 'Giá trị enum không hợp lệ.',
    httpStatusCode: 400,
  ),
  methodNotAllowed(
    code: 2035,
    message: 'Phương thức không được phép.',
    httpStatusCode: 405, // HttpStatus.METHOD_NOT_ALLOWED
  ),
  invalidRequest(
    code: 2036,
    message: 'Yêu cầu không hợp lệ.',
    httpStatusCode: 400,
  ),
  fileEmpty(
    code: 2037,
    message: 'File không được để trống.',
    httpStatusCode: 400,
  ),
  deTaiGvhdRequired(
    code: 2038,
    message: 'Giảng viên hướng dẫn là bắt buộc.',
    httpStatusCode: 400,
  ),
  deTaiFileInvalid(
    code: 2039,
    message: 'File tổng quan đề tài không hợp lệ.',
    httpStatusCode: 400,
  ),
  excelInvalid(
    code: 2040,
    message: 'File Excel không hợp lệ.',
    httpStatusCode: 400,
  ),
  invalidHoiDongTypeConfig(
    code: 2041,
    message: 'Cấu hình hội đồng không hợp lệ.',
    httpStatusCode: 400,
  ),
  invalidTimeRange(
    code: 2042,
    message: 'Khoảng thời gian không hợp lệ.',
    httpStatusCode: 400,
  ),
  congViecExisted(
    code: 2043,
    message: 'Công việc đã tồn tại trong đợt bảo vệ này.',
    httpStatusCode: 400,
  ),
  dangKyTimeInvalid(
    code: 2044,
    message: 'Ngoài thời gian đăng ký.',
    httpStatusCode: 400,
  ),
  fileTypeNotAllowed(
    code: 2045,
    message: 'Chỉ chấp nhận file PDF.',
    httpStatusCode: 400,
  ),

  // Resource Not Found Errors
  khoaNotFound(code: 3001, message: 'Khoa không tồn tại.', httpStatusCode: 404),
  nganhNotFound(
    code: 3002,
    message: 'Ngành không tồn tại.',
    httpStatusCode: 404,
  ),
  boMonNotFound(
    code: 3003,
    message: 'Bộ môn không tồn tại.',
    httpStatusCode: 404,
  ),
  lopNotFound(code: 3004, message: 'Lớp không tồn tại.', httpStatusCode: 404),
  deTaiNotFound(
    code: 3005,
    message: 'Đề tài không tồn tại.',
    httpStatusCode: 404,
  ),
  deCuongNotFound(
    code: 3006,
    message: 'Đề cương không tồn tại.',
    httpStatusCode: 404,
  ),
  giangVienNotFound(
    code: 3007,
    message: 'Giảng viên không tồn tại.',
    httpStatusCode: 404,
  ),
  sinhVienNotFound(
    code: 3008,
    message: 'Sinh viên không tồn tại.',
    httpStatusCode: 404,
  ),
  hoiDongNotFound(
    code: 3009,
    message: 'Hội đồng không tồn tại.',
    httpStatusCode: 404,
  ),
  fileNotFound(code: 3010, message: 'File không tồn tại.', httpStatusCode: 404),
  thongBaoNotFound(
    code: 3011,
    message: 'Thông báo không tồn tại.',
    httpStatusCode: 404,
  ),
  nhatKyNotFound(
    code: 3012,
    message: 'Nhật ký không tồn tại.',
    httpStatusCode: 404,
  ),
  dotBaoVeNotFound(
    code: 3013,
    message: 'Đợt bảo vệ không tồn tại.',
    httpStatusCode: 404,
  ),
  thoiGianThucHienNotFound(
    code: 3014,
    message: 'Thời gian thực hiện không tồn tại.',
    httpStatusCode: 404,
  ),
  baoCaoNotFound(
    code: 3015,
    message: 'Báo cáo không tồn tại.',
    httpStatusCode: 404,
  ),

  // Business Logic Errors
  duplicatedKhoa(
    code: 4001,
    message: 'Tên khoa đã tồn tại.',
    httpStatusCode: 409, // HttpStatus.CONFLICT
  ),
  duplicatedNganh(
    code: 4002,
    message: 'Tên ngành đã tồn tại.',
    httpStatusCode: 409,
  ),
  duplicatedBoMon(
    code: 4003,
    message: 'Tên bộ môn đã tồn tại.',
    httpStatusCode: 409,
  ),
  duplicatedLop(
    code: 4004,
    message: 'Tên lớp đã tồn tại.',
    httpStatusCode: 409,
  ),
  deTaiAlreadyAccepted(
    code: 4005,
    message: 'Đề tài đã được chấp nhận.',
    httpStatusCode: 409,
  ),
  deCuongAlreadyApproved(
    code: 4006,
    message: 'Đề cương đã được phê duyệt.',
    httpStatusCode: 409,
  ),
  deCuongAlreadySubmitted(
    code: 4007,
    message: 'Đề cương đã được nộp.',
    httpStatusCode: 409,
  ),
  deCuongAlreadyRejected(
    code: 4008,
    message: 'Đề cương đã bị từ chối.',
    httpStatusCode: 409,
  ),
  deCuongNotApproved(
    code: 4009,
    message: 'Đề cương chưa được phê duyệt.',
    httpStatusCode: 409,
  ),
  outOfSubmissionWindow(
    code: 4010,
    message: 'Ngoài thời gian nộp đề cương.',
    httpStatusCode: 400,
  ),
  noActiveSubmissionWindow(
    code: 4011,
    message: 'Chưa đến thời gian nộp đề cương.',
    httpStatusCode: 400,
  ),
  noActiveReviewList(
    code: 4012,
    message: 'Chưa đến thời gian xét duyệt đề cương.',
    httpStatusCode: 400,
  ),
  sinhVienAlreadyRegisteredDeTai(
    code: 4013,
    message: 'Sinh viên đã đăng ký đề tài.',
    httpStatusCode: 409,
  ),
  trangThaiInvalid(
    code: 4014,
    message: 'Trạng thái không hợp lệ.',
    httpStatusCode: 400,
  ),
  donHoanAlreadyPending(
    code: 4015,
    message: 'Đơn hoãn đồ án đang chờ xử lý.',
    httpStatusCode: 409,
  ),
  postponeNotAllowedWhenHasDeTai(
    code: 4016,
    message: 'Sinh viên đã có đề tài, không thể hoãn.',
    httpStatusCode: 400,
  ),
  duplicatedHoiDong(
    code: 4017,
    message: 'Tên hội đồng đã tồn tại trong đợt này.',
    httpStatusCode: 409,
  ),
  hoiDongTimeOutOfDot(
    code: 4018,
    message: 'Thời gian hội đồng không nằm trong khoảng thời gian đợt.',
    httpStatusCode: 400,
  ),
  gvKhongThuocDot(
    code: 4019,
    message: 'Giảng viên không đăng ký trong đợt này.',
    httpStatusCode: 400,
  ),
  hoiDongInvalidMembers(
    code: 4020,
    message: 'Hội đồng phải có ít nhất Chủ tịch và Thư ký.',
    httpStatusCode: 400,
  ),
  deTaiInOtherCouncil(
    code: 4021,
    message: 'Đề tài đã thuộc hội đồng khác.',
    httpStatusCode: 409,
  ),
  deTaiNotInDot(
    code: 4022,
    message: 'Đề tài không thuộc đợt của hội đồng.',
    httpStatusCode: 400,
  ),
  deTaiNotAccepted(
    code: 4023,
    message: 'Đề tài chưa được chấp nhận.',
    httpStatusCode: 409,
  ),
  truongBoMonAlready(
    code: 4024,
    message: 'Tài khoản đã là Trưởng bộ môn.',
    httpStatusCode: 409,
  ),
  notInBoMon(
    code: 4025,
    message: 'Giảng viên không thuộc bộ môn.',
    httpStatusCode: 400,
  ),
  invalidTroLyKhoa(
    code: 4026,
    message: 'Trưởng bộ môn không thể là Trợ lý khoa.',
    httpStatusCode: 400,
  ),
  duplicatedDotBaoVe(
    code: 4027,
    message: 'Đợt bảo vệ đã tồn tại.',
    httpStatusCode: 409,
  ),
  notInDotBaoVe(
    code: 4028,
    message: 'Ngoài thời gian đợt bảo vệ.',
    httpStatusCode: 400,
  ),
  nhatKyAlreadyReviewed(
    code: 4029,
    message: 'Nhật ký đã được nhận xét.',
    httpStatusCode: 409,
  ),
  noWeeksAvailable(
    code: 4030,
    message: 'Không còn tuần nào để tạo nhật ký mới.',
    httpStatusCode: 400,
  ),
  deTaiNotApprovedByGvhd(
    code: 4031,
    message: 'Đề tài chưa được giảng viên hướng dẫn phê duyệt.',
    httpStatusCode: 400,
  ),
  deCuongNotApprovedByGvhd(
    code: 4032,
    message: 'Đề cương chưa được giảng viên hướng dẫn phê duyệt.',
    httpStatusCode: 400,
  ),
  deCuongFullyApproved(
    code: 4033,
    message: 'Đề cương đã được phê duyệt hoàn toàn.',
    httpStatusCode: 409,
  ),
  boMonOrTbmNotAssigned(
    code: 4034,
    message: 'Bộ môn hoặc Trưởng bộ môn chưa được phân công cho sinh viên này.',
    httpStatusCode: 400,
  ),
  nopBaoCaoTimeInvalid(
    code: 4035,
    message: 'Ngoài thời gian nộp báo cáo.',
    httpStatusCode: 400,
  ),
  baoCaoAlreadyApproved(
    code: 4036,
    message: 'Báo cáo đã được phê duyệt.',
    httpStatusCode: 409,
  ),
  baoCaoAlreadyRejected(
    code: 4037,
    message: 'Báo cáo đã bị từ chối.',
    httpStatusCode: 409,
  ),
  baoCaoNotRejected(
    code: 4038,
    message: 'Báo cáo chưa bị từ chối.',
    httpStatusCode: 400,
  ),
  reviewRequiredForRejection(
    code: 4039,
    message: 'Nhận xét là bắt buộc khi từ chối báo cáo.',
    httpStatusCode: 400,
  ),
  deCuongNotApprovedByGvpb(
    code: 4040,
    message: 'Đề cương chưa được giảng viên phản biện phê duyệt.',
    httpStatusCode: 400,
  ),
  deCuongNotPending(
    code: 4041,
    message: 'Đề cương không ở trạng thái chờ phê duyệt.',
    httpStatusCode: 400,
  ),
  deTaiNotPending(
    code: 4042,
    message: 'Đề tài không ở trạng thái chờ phê duyệt.',
    httpStatusCode: 400,
  ),

  // Server Errors
  internalServerError(
    code: 5001,
    message: 'Lỗi hệ thống.',
    httpStatusCode: 500, // HttpStatus.INTERNAL_SERVER_ERROR
  ),
  uploadFileFailed(
    code: 5002,
    message: 'Tải file lên thất bại.',
    httpStatusCode: 500,
  ),
  donHoanFileUploadFailed(
    code: 5003,
    message: 'Tải file minh chứng cho đơn hoãn thất bại.',
    httpStatusCode: 500,
  );

  const ErrorCode({
    required this.code,
    required this.message,
    required this.httpStatusCode,
    this.field,
  });

  final int code;
  final String message;
  final int httpStatusCode;
  final String? field;

  static ErrorCode fromCode(int code, {String? message}) {
    try {
      return ErrorCode.values.firstWhere(
        (e) => e.code == code,
        orElse: () => ErrorCode.internalServerError,
      );
    } catch (e) {
      return ErrorCode.internalServerError;
    }
  }

  static ErrorCode fromResponse(Map<String, dynamic> response) {
    final code = response['code'] as int? ?? 5001;
    final message = response['message'] as String? ?? 'Lỗi không xác định';
    if (kDebugMode) {
      print('Parsing response - code: $code, message: $message');
    }
    final errorCode = fromCode(code);
    if (kDebugMode) {
      print(
        'Mapped to ErrorCode: ${errorCode.name}, field: ${errorCode.field}',
      );
    }
    return errorCode;
  }
}
