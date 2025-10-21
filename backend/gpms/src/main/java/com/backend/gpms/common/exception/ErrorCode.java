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

    // Auth Errors
    UNAUTHENTICATED(1001, "Ban can dang nhap.", HttpStatus.UNAUTHORIZED),
    FORBIDDEN(1002, "Ban khong co quyen truy cap.", HttpStatus.FORBIDDEN),
    TOKEN_EXPIRED(1003, "Token da het han.", HttpStatus.UNAUTHORIZED),
    INVALID_TOKEN(1004, "Token khong hop le.", HttpStatus.UNAUTHORIZED),
    INACTIVATED_ACCOUNT(1005, "Tai khoan chua duoc kich hoat.", HttpStatus.FORBIDDEN),
    WRONG_PASSWORD(1006, "Mat khau khong dung.", HttpStatus.FORBIDDEN),
    USER_NOT_FOUND(1007, "Nguoi dung khong ton tai.", HttpStatus.NOT_FOUND),
    NOT_GVHD_OF_DE_TAI(1008, "Giang vien khong co quyen tren de tai nay.", HttpStatus.FORBIDDEN),
    NOT_A_GVHD(1009, "Tai khoan khong phai giang vien huong dan.", HttpStatus.FORBIDDEN),
    OLD_PASSWORD(1010, "Mat khau cu khong duoc su dung.", HttpStatus.FORBIDDEN),

    // Validation Errors
    INVALID_VALIDATION(2001, "Du lieu dau vao khong hop le.", HttpStatus.BAD_REQUEST),
    EMAIL_INVALID(2002, "Email khong hop le.", HttpStatus.BAD_REQUEST),
    PASSWORD_INVALID(2003, "Mat khau phai co it nhat 6 ky tu.", HttpStatus.BAD_REQUEST),
    EMAIL_EXISTED(2004, "Email da ton tai.", HttpStatus.BAD_REQUEST),
    MA_SV_EXISTED(2005, "Ma sinh vien da ton tai.", HttpStatus.BAD_REQUEST),
    MA_GV_EXISTED(2006, "Ma giang vien da ton tai.", HttpStatus.BAD_REQUEST),
    KHOA_EMPTY(2007, "Ten khoa khong duoc de trong.", HttpStatus.BAD_REQUEST),
    NGANH_EMPTY(2008, "Ten nganh khong duoc de trong.", HttpStatus.BAD_REQUEST),
    BO_MON_EMPTY(2009, "Ten bo mon khong duoc de trong.", HttpStatus.BAD_REQUEST),
    LOP_EMPTY(2010, "Ten lop khong duoc de trong.", HttpStatus.BAD_REQUEST),
    DE_TAI_EMPTY(2011, "Ten de tai khong duoc de trong.", HttpStatus.BAD_REQUEST),
    DE_CUONG_EMPTY(2012, "De cuong khong duoc de trong.", HttpStatus.BAD_REQUEST),
    FILE_URL_EMPTY(2013, "URL file khong duoc de trong.", HttpStatus.BAD_REQUEST),
    DE_TAI_ID_MUST_BE_POSITIVE(2014, "ID de tai phai la so duong.", HttpStatus.BAD_REQUEST),
    DE_CUONG_REASON_REQUIRED(2015, "Ly do tu choi de cuong la bat buoc.", HttpStatus.BAD_REQUEST),
    LY_DO_HOAN_REQUIRED(2016, "Ly do hoan khong duoc de trong.", HttpStatus.BAD_REQUEST),
    INVALID_FILE_TYPE(2017, "Dinh dang file khong duoc phep.", HttpStatus.BAD_REQUEST),
    FILE_TOO_LARGE(2018, "Kich thuoc file vuot qua gioi han.", HttpStatus.BAD_REQUEST),
    MA_SV_INVALID(2019, "Ma sinh vien khong hop le.", HttpStatus.BAD_REQUEST),
    HO_TEN_EMPTY(2020, "Ho ten khong duoc de trong.", HttpStatus.BAD_REQUEST),
    SO_DIEN_THOAI_INVALID(2021, "So dien thoai khong hop le.", HttpStatus.BAD_REQUEST),
    NAM_HOC_EMPTY(2022, "Nam hoc khong duoc de trong.", HttpStatus.BAD_REQUEST),
    HOC_KI_EMPTY(2023, "Hoc ky khong duoc de trong.", HttpStatus.BAD_REQUEST),
    NOI_DUNG_REQUIRED(2024, "Noi dung khong duoc de trong.", HttpStatus.BAD_REQUEST),
    NHAN_XET_REQUIRED(2025, "Nhan xet khong duoc de trong.", HttpStatus.BAD_REQUEST),
    NHAT_KY_ID_REQUIRED(2026, "ID nhat ky la bat buoc.", HttpStatus.BAD_REQUEST),
    INVALID_WEEK_NUMBER(2027, "So tuan khong hop le.", HttpStatus.BAD_REQUEST),
    INVALID_WEEK_FORMAT(2028, "Dinh dang tuan khong hop le.", HttpStatus.BAD_REQUEST),
    DUONG_DAN_REQUIRED(2029, "Duong dan file khong duoc de trong.", HttpStatus.BAD_REQUEST),
    ID_BAO_CAO_REQUIRED(2030, "ID bao cao la bat buoc.", HttpStatus.BAD_REQUEST),
    INVALID_BAO_CAO_ID(2031, "ID bao cao khong hop le.", HttpStatus.BAD_REQUEST),
    SCORE_REQUIRED_FOR_APPROVAL(2032, "Diem so la bat buoc khi phe duyet bao cao.", HttpStatus.BAD_REQUEST),
    INVALID_SCORE_RANGE(2033, "Diem so phai tu 0 den 10.", HttpStatus.BAD_REQUEST),
    INVALID_ENUM_VALUE(2034, "Gia tri enum khong hop le.", HttpStatus.BAD_REQUEST),
    METHOD_NOT_ALLOWED(2035, "Phuong thuc khong duoc phep.", HttpStatus.METHOD_NOT_ALLOWED),
    INVALID_REQUEST(2036, "Yeu cau khong hop le.", HttpStatus.BAD_REQUEST),
    FILE_EMPTY(2037, "File khong duoc de trong.", HttpStatus.BAD_REQUEST),
    DE_TAI_GVHD_REQUIRED(2038, "Giang vien huong dan la bat buoc.", HttpStatus.BAD_REQUEST),
    DE_TAI_FILE_INVALID(2039, "File tong quan de tai khong hop le.", HttpStatus.BAD_REQUEST),
    EXCEL_INVALID(2040, "File Excel khong hop le.", HttpStatus.BAD_REQUEST),
    INVALID_HOI_DONG_TYPE_CONFIG(2041, "Cau hinh hoi dong khong hop le.", HttpStatus.BAD_REQUEST),
    INVALID_TIME_RANGE(2042, "Khoang thoi gian khong hop le.", HttpStatus.BAD_REQUEST),
    CONG_VIEC_EXISTED(2043, "Cong viec da ton tai trong dot bao ve nay.", HttpStatus.BAD_REQUEST),
    DANG_KY_TIME_INVALID(2044, "Ngoai thoi gian dang ky.", HttpStatus.BAD_REQUEST),
    FILE_TYPE_NOT_ALLOWED(2045, "Chi chap nhan file PDF.", HttpStatus.BAD_REQUEST),

    // Resource Not Found Errors
    KHOA_NOT_FOUND(3001, "Khoa khong ton tai.", HttpStatus.NOT_FOUND),
    NGANH_NOT_FOUND(3002, "Nganh khong ton tai.", HttpStatus.NOT_FOUND),
    BO_MON_NOT_FOUND(3003, "Bo mon khong ton tai.", HttpStatus.NOT_FOUND),
    LOP_NOT_FOUND(3004, "Lop khong ton tai.", HttpStatus.NOT_FOUND),
    DE_TAI_NOT_FOUND(3005, "De tai khong ton tai.", HttpStatus.NOT_FOUND),
    DE_CUONG_NOT_FOUND(3006, "De cuong khong ton tai.", HttpStatus.NOT_FOUND),
    GIANG_VIEN_NOT_FOUND(3007, "Giang vien khong ton tai.", HttpStatus.NOT_FOUND),
    SINH_VIEN_NOT_FOUND(3008, "Sinh vien khong ton tai.", HttpStatus.NOT_FOUND),
    HOI_DONG_NOT_FOUND(3009, "Hoi dong khong ton tai.", HttpStatus.NOT_FOUND),
    FILE_NOT_FOUND(3010, "File khong ton tai.", HttpStatus.NOT_FOUND),
    THONG_BAO_NOT_FOUND(3011, "Thong bao khong ton tai.", HttpStatus.NOT_FOUND),
    NHAT_KY_NOT_FOUND(3012, "Nhat ky khong ton tai.", HttpStatus.NOT_FOUND),
    DOT_BAO_VE_NOT_FOUND(3013, "Dot bao ve khong ton tai.", HttpStatus.NOT_FOUND),
    THOI_GIAN_THUC_HIEN_NOT_FOUND(3014, "Thoi gian thuc hien khong ton tai.", HttpStatus.NOT_FOUND),
    BAO_CAO_NOT_FOUND(3015, "Bao cao khong ton tai.", HttpStatus.NOT_FOUND),

    // Business Logic Errors
    DUPLICATED_KHOA(4001, "Ten khoa da ton tai.", HttpStatus.CONFLICT),
    DUPLICATED_NGANH(4002, "Ten nganh da ton tai.", HttpStatus.CONFLICT),
    DUPLICATED_BO_MON(4003, "Ten bo mon da ton tai.", HttpStatus.CONFLICT),
    DUPLICATED_LOP(4004, "Ten lop da ton tai.", HttpStatus.CONFLICT),
    DE_TAI_ALREADY_ACCEPTED(4005, "De tai da duoc chap nhan.", HttpStatus.CONFLICT),
    DE_CUONG_ALREADY_APPROVED(4006, "De cuong da duoc phe duyet.", HttpStatus.CONFLICT),
    DE_CUONG_ALREADY_SUBMITTED(4007, "De cuong da duoc nop.", HttpStatus.CONFLICT),
    DE_CUONG_ALREADY_REJECTED(4008, "De cuong da bi tu choi.", HttpStatus.CONFLICT),
    DE_CUONG_NOT_APPROVED(4009, "De cuong chua duoc phe duyet.", HttpStatus.CONFLICT),
    OUT_OF_SUBMISSION_WINDOW(4010, "Ngoai thoi gian nop de cuong.", HttpStatus.BAD_REQUEST),
    NO_ACTIVE_SUBMISSION_WINDOW(4011, "Chua den thoi gian nop de cuong.", HttpStatus.BAD_REQUEST),
    NO_ACTIVE_REVIEW_LIST(4012, "Chua den thoi gian xet duyet de cuong.", HttpStatus.BAD_REQUEST),
    SINH_VIEN_ALREADY_REGISTERED_DE_TAI(4013, "Sinh vien da dang ky de tai.", HttpStatus.CONFLICT),
    TRANG_THAI_INVALID(4014, "Trang thai khong hop le.", HttpStatus.BAD_REQUEST),
    DON_HOAN_ALREADY_PENDING(4015, "Don hoan do an dang cho xu ly.", HttpStatus.CONFLICT),
    POSTPONE_NOT_ALLOWED_WHEN_HAS_DE_TAI(4016, "Sinh vien da co de tai, khong the hoan.", HttpStatus.BAD_REQUEST),
    DUPLICATED_HOI_DONG(4017, "Ten hoi dong da ton tai trong dot nay.", HttpStatus.CONFLICT),
    HOI_DONG_TIME_OUT_OF_DOT(4018, "Thoi gian hoi dong khong nam trong khoang thoi gian dot.", HttpStatus.BAD_REQUEST),
    GV_KHONG_THUOC_DOT(4019, "Giang vien khong dang ky trong dot nay.", HttpStatus.BAD_REQUEST),
    HOI_DONG_INVALID_MEMBERS(4020, "Hoi dong phai co it nhat Chu tich va Thu ky.", HttpStatus.BAD_REQUEST),
    DE_TAI_IN_OTHER_COUNCIL(4021, "De tai da thuoc hoi dong khac.", HttpStatus.CONFLICT),
    DE_TAI_NOT_IN_DOT(4022, "De tai khong thuoc dot cua hoi dong.", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_ACCEPTED(4023, "De tai chua duoc chap nhan.", HttpStatus.CONFLICT),
    TRUONG_BO_MON_ALREADY(4024, "Tai khoan da la Truong bo mon.", HttpStatus.CONFLICT),
    NOT_IN_BO_MON(4025, "Giang vien khong thuoc bo mon.", HttpStatus.BAD_REQUEST),
    INVALID_TRO_LY_KHOA(4026, "Truong bo mon khong the la Tro ly khoa.", HttpStatus.BAD_REQUEST),
    DUPLICATED_DOT_BAO_VE(4027, "Dot bao ve da ton tai.", HttpStatus.CONFLICT),
    NOT_IN_DOT_BAO_VE(4028, "Ngoai thoi gian dot bao ve.", HttpStatus.BAD_REQUEST),
    NHAT_KY_ALREADY_REVIEWED(4029, "Nhat ky da duoc nhan xet.", HttpStatus.CONFLICT),
    NO_WEEKS_AVAILABLE(4030, "Khong con tuan nao de tao nhat ky moi.", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_APPROVED_BY_GVHD(4031, "De tai chua duoc giang vien huong dan phe duyet.", HttpStatus.BAD_REQUEST),
    DE_CUONG_NOT_APPROVED_BY_GVHD(4032, "De cuong chua duoc giang vien huong dan phe duyet.", HttpStatus.BAD_REQUEST),
    DE_CUONG_FULLY_APPROVED(4033, "De cuong da duoc phe duyet hoan toan.", HttpStatus.CONFLICT),
    BO_MON_OR_TBM_NOT_ASSIGNED(4034, "Bo mon hoac Truong bo mon chua duoc phan cong cho sinh vien nay.", HttpStatus.BAD_REQUEST),
    NOP_BAO_CAO_TIME_INVALID(4035, "Ngoai thoi gian nop bao cao.", HttpStatus.BAD_REQUEST),
    BAO_CAO_ALREADY_APPROVED(4036, "Bao cao da duoc phe duyet.", HttpStatus.CONFLICT),
    BAO_CAO_ALREADY_REJECTED(4037, "Bao cao da bi tu choi.", HttpStatus.CONFLICT),
    BAO_CAO_NOT_REJECTED(4038, "Bao cao chua bi tu choi.", HttpStatus.BAD_REQUEST),
    REVIEW_REQUIRED_FOR_REJECTION(4039, "Nhan xet la bat buoc khi tu choi bao cao.", HttpStatus.BAD_REQUEST),
    DE_CUONG_NOT_APPROVED_BY_GVPB(4040, "De cuong chua duoc giang vien phan bien phe duyet.", HttpStatus.BAD_REQUEST),
    DE_CUONG_NOT_PENDING(4041, "De cuong khong o trang thai cho phe duyet.", HttpStatus.BAD_REQUEST),
    DE_TAI_NOT_PENDING(4042, "De tai khong o trang thai cho phe duyet.", HttpStatus.BAD_REQUEST),
    NOT_YOUR_DETAI(4043, "Khong phai de tai cua ban huong dan.", HttpStatus.FORBIDDEN),

    // Server Errors
    INTERNAL_SERVER_ERROR(5001, "Loi he thong.", HttpStatus.INTERNAL_SERVER_ERROR),
    UPLOAD_FILE_FAILED(5002, "Tai file len that bai.", HttpStatus.INTERNAL_SERVER_ERROR),
    DON_HOAN_FILE_UPLOAD_FAILED(5003, "Tai file minh chung cho don hoan that bai.", HttpStatus.INTERNAL_SERVER_ERROR);
    ;

    int code;
    String message;
    HttpStatusCode httpStatusCode;

}
