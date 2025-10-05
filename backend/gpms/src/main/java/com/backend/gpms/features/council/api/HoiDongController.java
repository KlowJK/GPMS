package com.backend.gpms.features.council.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.council.application.HoiDongService;
import com.backend.gpms.features.council.dto.request.HoiDongRequest;
import com.backend.gpms.features.council.dto.response.HoiDongResponse;
import com.backend.gpms.features.council.dto.response.PhanCongBaoVeResponse;
import com.backend.gpms.features.council.dto.response.ThanhVienHoiDongResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Hội đồng", description = "API quản lý hội đồng")
@RestController
@RequestMapping("/api/hoi-dong")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class HoiDongController {

    HoiDongService hoiDongService;

    @GetMapping
    public ApiResponse<Page<HoiDongResponse>> getHoiDongDangDienRa(
            @RequestParam(required = false) String keyword,
            @PageableDefault(page = 0, size = 10, sort = "thoiGianBatDau", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.<Page<HoiDongResponse>>builder()
                .result(hoiDongService.getHoiDongsDangDienRa(keyword, pageable))
                .build();
    }

    @GetMapping("{hoiDongId}")
    public ApiResponse<ThanhVienHoiDongResponse> getHoiDongDetail(@PathVariable Long hoiDongId) {
        return ApiResponse.<ThanhVienHoiDongResponse>builder()
                .result(hoiDongService.getHoiDongDetail(hoiDongId))
                .build();
    }

    @PostMapping("/them-hoi-dong")
    public ApiResponse<ThanhVienHoiDongResponse> createHoiDong(@RequestBody @Valid HoiDongRequest request) {
        return ApiResponse.<ThanhVienHoiDongResponse>builder()
                .result(hoiDongService.createHoiDong(request))
                .build();
    }

    @PostMapping(value = "/{hoiDongId}/import-sinh-vien", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<PhanCongBaoVeResponse> importSinhVienToHoiDong(
            @PathVariable Long hoiDongId,
            @RequestPart("file") MultipartFile file) {
        return ApiResponse.<PhanCongBaoVeResponse>builder()
                .result(hoiDongService.importSinhVienToHoiDong(hoiDongId, file))
                .build();
    }

    @GetMapping("/hoi-dong-theo-dot")
    public ApiResponse<Page<HoiDongResponse>> getHoiDongTheoDot(
            @RequestParam Long dotBaoVeId,
            @RequestParam(required = false) String keyword,

            @PageableDefault(page = 0, size = 10, sort = "thoiGianBatDau", direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        return ApiResponse.<Page<HoiDongResponse>>builder()
                .result(hoiDongService.getTatCaHoiDongByDot(dotBaoVeId, keyword,  pageable))
                .build();
    }
}
