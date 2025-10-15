package com.backend.gpms.common.util;

import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.features.defense.domain.CongViec;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.domain.ThoiGianThucHien;
import com.backend.gpms.features.defense.infra.DotBaoVeRepository;
import com.backend.gpms.features.defense.infra.ThoiGianThucHienRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;

@Component
@RequiredArgsConstructor
public class TimeGatekeeper {

    private final ThoiGianThucHienRepository thoiGianThucHienRepository;

    private static final ZoneId ZONE_BKK = ZoneId.of("Asia/Bangkok");
    private final DotBaoVeRepository dotBaoVeRepository;

    /**
     * Ném lỗi nếu hôm nay KHÔNG thuộc khoảng thời gian của công việc cv đối với đợt dot.
     * Trả về chính mốc thời gian để tái sử dụng nếu cần.
     */
    public ThoiGianThucHien assertWithinWindow(CongViec cv, DotBaoVe dot) {
        LocalDate today = LocalDate.now(ZONE_BKK);

        ThoiGianThucHien window = thoiGianThucHienRepository
                .findByDotBaoVe_IdAndCongViec(dot.getId(), cv)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW));

        if (today.isBefore(window.getThoiGianBatDau())) {
            throw new ApplicationException(ErrorCode.NO_ACTIVE_SUBMISSION_WINDOW);
        }
        if (today.isAfter(window.getThoiGianKetThuc())) {
            throw new ApplicationException(ErrorCode.OUT_OF_SUBMISSION_WINDOW);
        }
        return window;
    }

    public ThoiGianThucHien validateThoiGianDangKy(){
        LocalDate today = LocalDate.now(ZONE_BKK);
        return thoiGianThucHienRepository
                .findTopByCongViecAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqualOrderByThoiGianBatDauDesc(CongViec.DANG_KY_DE_TAI, today, today)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DANG_KY_TIME_INVALID));
    }

    public ThoiGianThucHien validateThoiGianNopBaoCao(){
        LocalDate today = LocalDate.now(ZONE_BKK);
        return thoiGianThucHienRepository
                .findTopByCongViecAndThoiGianBatDauLessThanEqualAndThoiGianKetThucGreaterThanEqualOrderByThoiGianBatDauDesc(CongViec.NOP_BAO_CAO, today, today)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOP_BAO_CAO_TIME_INVALID));
    }

    public DotBaoVe getCurrentDotBaoVe(){
        LocalDate today = LocalDate.now(ZONE_BKK);
        return dotBaoVeRepository.
                findTopByNgayBatDauLessThanEqualAndNgayKetThucGreaterThanEqualOrderByNgayBatDauDesc(today, today)
                .orElseThrow(() -> new ApplicationException(ErrorCode.NOT_IN_DOT_BAO_VE));
    }
}
