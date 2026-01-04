package com.backend.gpms.features.notification.domain;

public enum KieuThongBao {
    DANG_KY_DE_TAI(
            "Có đăng ký đề tài mới",
            "Sinh viên {sinhVien} đã đăng ký đề tài \"{tenDeTai}\"."
    ),
    DUYET_DE_TAI(
            "Đề tài được duyệt",
            "Đề tài \"{tenDeTai}\" của bạn đã được giảng viên duyệt."
    ),
    TU_CHOI_DE_TAI(
            "Đề tài bị từ chối",
            "Đề tài \"{tenDeTai}\" của bạn đã bị từ chối. Nhận xét: {lyDo}"
    ),
    CAP_NHAT_DE_TAI(
            "Đề tài được cập nhật",
            "Thông tin đề tài \"{tenDeTai}\" đã được cập nhật."
    ),
    NOP_DE_CUONG(
            "Sinh viên nộp đề cương",
            "Sinh viên {sinhVien} đã nộp đề cương cho đề tài \"{tenDeTai}\"."
    ),
    GVHD_DUYET_DE_CUONG(
            "Đề cương được GVHD duyệt",
            "Đề cương của bạn đã được giảng viên hướng dẫn duyệt."
    ),
    GVHD_TU_CHOI_DE_CUONG(
            "Đề cương bị GVHD từ chối",
            "Đề cương của bạn đã bị giảng viên hướng dẫn từ chối. Nhận xét: {lyDo}"
    ),

    GVPB_DUYET_DE_CUONG(
            "Đề cương được GVPB duyệt",
            "Đề cương của bạn đã được giảng viên phản biện duyệt."
    ),
    GVPB_TU_CHOI_DE_CUONG(
            "Đề cương bị GVPB từ chối",
            "Đề cương của bạn đã bị giảng viên phản biện từ chối. Nhận xét: {lyDo}"
    ),

    TBM_DUYET_DE_CUONG(
            "Đề cương được TBM duyệt",
            "Đề cương của bạn đã được Trưởng bộ môn duyệt."
    ),
    TBM_TU_CHOI_DE_CUONG(
            "Đề cương bị TBM từ chối",
            "Đề cương của bạn đã bị Trưởng bộ môn từ chối. Nhận xét: {lyDo}"
    ),

    NOP_BAO_CAO(
            "Sinh viên nộp báo cáo",
            "Sinh viên {sinhVien} đã nộp báo cáo tiến độ cho đề tài \"{tenDeTai}\"."
    ),
    DUYET_BAO_CAO(
            "Báo cáo được duyệt",
            "Báo cáo tiến độ của bạn đã được giảng viên duyệt."
    ),
    TU_CHOI_BAO_CAO(
            "Báo cáo bị từ chối",
            "Báo cáo tiến độ của bạn đã bị từ chối. Nhận xét: {lyDo}"
    ),

    NOP_NHAT_KY(
            "Sinh viên nộp nhật ký",
            "Sinh viên {sinhVien} đã nộp nhật ký thực hiện tuần này."
    ),
    DUYET_NHAT_KY(
            "Nhật ký đã được nhận xét",
            "Nhật ký của bạn đã được giảng viên nhận xét: \"{nhanXet}\""
    ),

    GAN_GV_HUONG_DAN_DE_TAI(
            "Bạn được phân làm GVHD",
            "Bạn đã được phân làm giảng viên hướng dẫn cho sinh viên {sinhVien}."
    ),
    GAN_GV_PHAN_BIEN_DE_TAI(
            "Bạn được phân làm GVPB",
            "Bạn đã được phân làm giảng viên phản biện cho sinh viên {sinhVien}. Đề tài: \"{tenDeTai}\""
    ),

    SV_DUOC_GAN_GV_HUONG_DAN(
            "Có giảng viên hướng dẫn",
            "Bạn đã được phân giảng viên hướng dẫn {giangVien}. Đề tài: \"{tenDeTai}\""
    ),

    THANH_VIEN_HOI_DONG(
            "Bạn thuộc hội đồng bảo vệ",
            "Bạn đã được thêm vào hội đồng bảo vệ \"{tenHoiDong}\"."
    ),
    THONG_BAO_HOI_DONG(
            "Thông tin hội đồng bảo vệ",
            "Hội đồng \"{tenHoiDong}\" sẽ họp vào {thoiGian} tại {diaDiem}."
    ),

    THANH_VIEN_PHAN_BIEN(
            "Phân công phản biện",
            "Bạn đã được phân làm giảng viên phản biện cho đề tài \"{tenDeTai}\". Sinh viên: {sinhVien}"
    ),
    THANH_VIEN_BAO_VE(
            "Phân công hội đồng bảo vệ",
            "Bạn đã được phân vào hội đồng bảo vệ đề tài \"{tenDeTai}\". Sinh viên: {sinhVien}"
    ),

    THONG_BAO_BAO_VE(
            "Lịch bảo vệ đồ án",
            "Lịch bảo vệ đồ án của bạn đã được xác nhận.\nThời gian: {thoiGian}\nĐịa điểm: {diaDiem}\nHội đồng: {tenHoiDong}"
    );

    private final String tieuDe;
    private final String noiDungMau;

    KieuThongBao(String tieuDe, String noiDungMau) {
        this.tieuDe = tieuDe;
        this.noiDungMau = noiDungMau;
    }

    public String getTieuDe() { return tieuDe; }
    public String getNoiDungMau() { return noiDungMau; }
}
