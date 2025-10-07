package com.backend.gpms.common.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
@AllArgsConstructor
@NoArgsConstructor
public enum ErrorCode {

    UNAUTHORIZED(1001, "Unauthorized", HttpStatus.UNAUTHORIZED),
    UNAUTHENTICATED(1002, "Unauthenticated", HttpStatus.UNAUTHORIZED),
    INVALID_VALIDATION(1003,"Invalid Validation", HttpStatus.BAD_REQUEST),
    EMAIL_INVALID(1004, "Invalid Email", HttpStatus.BAD_REQUEST),
    PASSWORD_INVALID(1005, "Password must be at least 6 characters", HttpStatus.BAD_REQUEST),
    ACCOUNT_NOT_FOUND(1006, "Account not found", HttpStatus.NOT_FOUND),
    WRONG_PASSWORD(1007, "Wrong Password", HttpStatus.FORBIDDEN),
    INACTIVATED_ACCOUNT(1008, "Inactivated Account", HttpStatus.FORBIDDEN),
    KHOA_NOT_FOUND(1009, "Khoa Not Found", HttpStatus.NOT_FOUND),
    KHOA_EMPTY(1010, "Ten khoa cannot be empty", HttpStatus.BAD_REQUEST),
    DUPLICATED_KHOA(1011, "Ten khoa already exists", HttpStatus.BAD_REQUEST),
    NGANH_EMPTY(1012, "Ten nganh cannot be empty", HttpStatus.BAD_REQUEST),
    DUPLICATED_NGANH(1013, "Ten nganh already exists", HttpStatus.BAD_REQUEST),
    NGANH_NOT_FOUND(1014, "Ten nganh not found", HttpStatus.NOT_FOUND),
    DUPLICATED_BO_MON(1015, "Ten bo mon already exists", HttpStatus.BAD_REQUEST),
    BO_MON_EMPTY(1016, "Ten bo cannot be empty", HttpStatus.BAD_REQUEST),
    BO_MON_NOT_FOUND(1017, "Bo mon not found", HttpStatus.BAD_REQUEST),
    LOP_EMPTY(1018, "Ten lop cannot be empty", HttpStatus.BAD_REQUEST),
    DUPLICATED_LOP(1019, "Ten lop already exists", HttpStatus.BAD_REQUEST),
    LOP_NOT_FOUND(1020, "Lop not found", HttpStatus.NOT_FOUND),
    FILE_NOT_FOUND(1201, "File not found", HttpStatus.NOT_FOUND),
    FILE_URL_EMPTY(1202, "File URL cannot be empty", HttpStatus.BAD_REQUEST),
    DE_TAI_ID_EMPTY(1203, "De tai ID cannot be empty", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_FOUND   (1204, "De tai not found",   HttpStatus.NOT_FOUND),
    DE_CUONG_NOT_FOUND (1205, "De cuong not found", HttpStatus.NOT_FOUND),
    DE_CUONG_ALREADY_APPROVED(1206, "De cuong already approved!", HttpStatus.BAD_REQUEST),
    DE_CUONG_ALREADY_SUBMITTED(1207, "De cuong already submitted!", HttpStatus.BAD_REQUEST),
    DE_CUONG_ALREADY_REJECTED(1208, "De cuong already rejected!", HttpStatus.BAD_REQUEST),
    DE_CUONG_EMPTY(1209, "De cuong cannot be empty", HttpStatus.CONFLICT),
    OUTLINE_NOT_PENDING(1210, "Outline is not in PENDING state", HttpStatus.CONFLICT),
    DE_TAI_ID_MUST_BE_POSITIVE(1211, "De tai ID must be positive", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_ACCEPTED       (1212, "Topic has not been accepted", HttpStatus.BAD_REQUEST),
    DE_CUONG_REASON_REQUIRED(1213, "Reason is required when rejecting the outline", HttpStatus.BAD_REQUEST),
    INTERNAL_SERVER_ERROR(1214, "Internal Server Error", HttpStatus.INTERNAL_SERVER_ERROR),
    OUT_OF_SUBMISSION_WINDOW(1215, "Ngoài thời gian nộp đề cương", HttpStatus.BAD_REQUEST),
    NO_ACTIVE_SUBMISSION_WINDOW(1216, "Chưa tới thời gian nộp đề cương", HttpStatus.BAD_REQUEST),
    NO_ACTIVE_REVIEW_LIST(1217, "Chưa đến thời gian thực hiện xét duyệt đề cương", HttpStatus.BAD_REQUEST),
    ACCESS_DENIED(1218, "Access Denied", HttpStatus.FORBIDDEN),
    FILE_EMPTY(1219, "File is empty", HttpStatus.BAD_REQUEST),
    FILE_TYPE_NOT_ALLOWED(1220, "File type not allowed", HttpStatus.BAD_REQUEST),
    //
    DE_TAI_EMPTY(1101, "Ten de tai cannot be empty", HttpStatus.BAD_REQUEST),
    DE_TAI_GVHD_REQUIRED(1102, "GVHD is required", HttpStatus.BAD_REQUEST),
    DE_TAI_FILE_INVALID(1103, "Invalid overview file", HttpStatus.BAD_REQUEST),
    GIANG_VIEN_NOT_FOUND(1104, "Giang vien not found", HttpStatus.NOT_FOUND),
    SINH_VIEN_NOT_FOUND(1105, "Sinh vien not found", HttpStatus.NOT_FOUND),
    SINH_VIEN_ALREADY_REGISTERED_DE_TAI(1106, "Sinh vien already registered a de tai", HttpStatus.BAD_REQUEST),
    UPLOAD_FILE_FAILED(1107, "Upload file failed", HttpStatus.INTERNAL_SERVER_ERROR),
    TRANG_THAI_INVALID(1109, "Trang thai invalid", HttpStatus.BAD_REQUEST),
    NOT_GVHD_OF_DE_TAI(1110, "Giang vien khong co quyen tren de tai nay", HttpStatus.FORBIDDEN),
    DE_TAI_NOT_IN_PENDING_STATUS(1111, "Only process de tai in PENDING status", HttpStatus.BAD_REQUEST),
    LY_DO_HOAN_REQUIRED(1113, "Ly do hoan cannot be empty", HttpStatus.BAD_REQUEST),
    DON_HOAN_ALREADY_PENDING(1114, "Sinh vien has already submitted a DonHoanDoAn and it is still pending", HttpStatus.BAD_REQUEST),
    DON_HOAN_FILE_UPLOAD_FAILED(1115, "Failed to upload MinhChungFile for DonHoanDoAn", HttpStatus.INTERNAL_SERVER_ERROR),
    POSTPONE_NOT_ALLOWED_WHEN_HAS_DE_TAI(1116, "Sinh viên has a DeTai already; postpone request is not allowed", HttpStatus.BAD_REQUEST),
    NOT_A_GVHD(2004, "Current account is not an GVHD", HttpStatus.FORBIDDEN),
    DE_TAI_NOT_FOUND_FOR_STUDENT(1117, "De tai not found by student code and title", HttpStatus.NOT_FOUND),
    HOI_DONG_NOT_FOUND(1118, "Hoi dong not found", org.springframework.http.HttpStatus.NOT_FOUND),
    DUPLICATED_HOI_DONG(1119, "Duplicate council name in this dot", HttpStatus.BAD_REQUEST),
    HOI_DONG_TIME_OUT_OF_DOT(1120, "Council time not in dot time range", HttpStatus.BAD_REQUEST),
    GV_KHONG_THUOC_DOT(1121, "Lecturer not registered in this dot", HttpStatus.BAD_REQUEST),
    HOI_DONG_INVALID_MEMBERS(1122, "Council must have at least CHAIR and SECRETARY", HttpStatus.BAD_REQUEST),
    EXCEL_INVALID(1123, "Invalid Excel file", HttpStatus.BAD_REQUEST),
    DE_TAI_IN_OTHER_COUNCIL(1124, "De tai already in another council", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_IN_DOT(1125, "De tai not in council's dot", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_APPROVED(1126, "De tai is not approved", HttpStatus.BAD_REQUEST),
    INVALID_HOI_DONG_TYPE_CONFIG(1024, "Invalid committee configuration", HttpStatus.BAD_REQUEST),
    GIANGVIEN_LECTURER_NOT_FOUND(1025, "Lecturer not found", HttpStatus.NOT_FOUND),

    MA_SV_INVALID(1021, "Ma SV invalid", HttpStatus.BAD_REQUEST),
    HO_TEN_EMPTY(1022, "Ho ten cannot be empty", HttpStatus.BAD_REQUEST),
    SO_DIEN_THOAI_INVALID(1023, "So dien thoai invalid", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(1024, "Email already exists", HttpStatus.BAD_REQUEST),
    MA_SV_EXISTED(1025, "Ma SV already exists", HttpStatus.BAD_REQUEST),
    MA_GV_EXISTED(1026, "Ma GV already exists", HttpStatus.BAD_REQUEST),
    USER_NOT_FOUND(1027, "User not found", HttpStatus.NOT_FOUND),
    TRUONG_BO_MON_ALREADY(1029, "This account has been Truong Bo Mon", HttpStatus.BAD_REQUEST),
    NOT_IN_BO_MON(1030, "Giang Vien is not in Bo Mon", HttpStatus.BAD_REQUEST),
    INVALID_TRO_LY_KHOA(1031, "Truong bo mon cannot be Tro Ly Khoa", HttpStatus.BAD_REQUEST),
    DUPLICATED_DOT_BAO_VE(1032, "Dot bao ve has been existed",  HttpStatus.BAD_REQUEST),
    DOT_BAO_VE_NOT_FOUND(1033, "Dot bao ve not found", HttpStatus.NOT_FOUND),
    INVALID_TIME_RANGE(1034, "Invalid time range", HttpStatus.BAD_REQUEST),
    CONG_VIEC_EXISTED(1035, "Cong viec already exists in this dot bao ve", HttpStatus.BAD_REQUEST),
    THOI_GIAN_THUC_HIEN_NOT_FOUND(1036, "Thoi gian thuc hien not found", HttpStatus.NOT_FOUND),
    NAM_HOC_EMPTY(1037, "Nam hoc cannot be empty", HttpStatus.BAD_REQUEST),

    HOC_KI_EMPTY(1039, "Hoc ki cannot be empty", HttpStatus.BAD_REQUEST),
    INVALID_FILE_TYPE(1040, "Invalid file type", HttpStatus.BAD_REQUEST),
    FILE_TOO_LARGE(1041, "File size exceeds the limit", HttpStatus.BAD_REQUEST),
    THONG_BAO_NOT_FOUND(1042, "Thong bao not found", HttpStatus.NOT_FOUND),
    DANG_KY_TIME_INVALID(1043, "Not in thoi gian dang ki", HttpStatus.BAD_REQUEST),
    DE_TAI_ALREADY_ACCEPTED(1044, "De tai already accepted", HttpStatus.BAD_REQUEST),
    NOT_IN_DOT_BAO_VE(1045, "Not in dot bao ve", HttpStatus.BAD_REQUEST),
    OLD_PASSWORD(1046, "This is old password", HttpStatus.FORBIDDEN),
    ;


    int code;
    String message;
    HttpStatusCode httpStatusCode;

}


