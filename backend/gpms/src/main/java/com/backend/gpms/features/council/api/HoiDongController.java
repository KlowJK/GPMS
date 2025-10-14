package com.backend.gpms.features.council.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.council.application.HoiDongService;
import com.backend.gpms.features.council.dto.request.HoiDongRequest;
import com.backend.gpms.features.council.dto.response.HoiDongResponse;
import com.backend.gpms.features.council.dto.response.PhanCongBaoVeResponse;
import com.backend.gpms.features.council.dto.response.ThanhVienHoiDongResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Tag(name = "Hội đồng", description = "API quản lý hội đồng")
@RestController
@RequestMapping("/api/hoi-dong")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
public class HoiDongController {

    HoiDongService hoiDongService;

    @Operation(summary = "Lấy danh sách hội đồng đang diễn ra - lấy hội đồng SV-> chỉ truyền id đề tài của sinh viên, giảng viên -> id giảng viên, lấy hội đồng theo tên -> keyword, lấy tất cả hội đồng đang diễn ra -> không truyền gì")
    @GetMapping
    public ApiResponse<Page<HoiDongResponse>> getHoiDongDangDienRa(
            @RequestParam(required = false)
            String keyword,
            @RequestParam(required = false)
            Long idDeTai,
            @RequestParam(required = false)
            Long idGiangVien,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "thoiGianBatDau", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.success(hoiDongService.getHoiDongsDangDienRa(keyword,idDeTai,idGiangVien, pageable));
    }

    @Operation(summary = "App - Lấy danh sách hội đồng đang diễn ra - lấy hội đồng SV-> chỉ truyền id đề tài của sinh viên, giảng viên -> id giảng viên, lấy hội đồng theo tên -> keyword, lấy tất cả hội đồng đang diễn ra -> không truyền gì")
    @GetMapping("/list")
    public ApiResponse<List<HoiDongResponse>> getHoiDongDangDienRa(
            @RequestParam(required = false)
            String keyword,
            @RequestParam(required = false)
            Long idDeTai,
            @RequestParam(required = false)
            Long idGiangVien
            ) {
        return ApiResponse.success(hoiDongService.getHoiDongsDangDienRa(keyword,idDeTai,idGiangVien));
    }

    @Operation(summary = "Lấy chi tiết hội đồng theo idHoiDong - Có list thành viên hội đồng gv,sv")
    @GetMapping("{hoiDongId}")
    public ApiResponse<ThanhVienHoiDongResponse> getHoiDongDetail(@PathVariable Long hoiDongId) {
        return ApiResponse.success(hoiDongService.getHoiDongDetail(hoiDongId));
    }

    @Operation(summary = "Tạo mới hội đồng - Trả về chi tiết hội đồng vừa tạo")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping("/them-hoi-dong")
    public ApiResponse<ThanhVienHoiDongResponse> createHoiDong(@RequestBody @Valid HoiDongRequest request) {
        return ApiResponse.success(hoiDongService.createHoiDong(request));
    }

    @Operation(summary = "Import sinh viên vào hội đồng bảo vệ từ file excel - Excel có 2 cột: 1 mã sinh viên, 1 tên đề tài")
    @PostMapping(value = "/{hoiDongId}/import-sinh-vien", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<PhanCongBaoVeResponse> importSinhVienToHoiDong(
            @PathVariable Long hoiDongId,
            @RequestPart("file") MultipartFile file) {
        return ApiResponse.success(hoiDongService.importSinhVienToHoiDong(hoiDongId, file));
    }
    @Operation(summary = "Lấy tất cả hội đồng theo đợt bảo vệ - có phân trang, tìm kiếm theo tên hội đồng")
    @GetMapping("/hoi-dong-theo-dot")
    public ApiResponse<Page<HoiDongResponse>> getHoiDongTheoDot(
            @RequestParam Long dotBaoVeId,
            @RequestParam(required = false) String keyword,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "thoiGianBatDau", direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        return ApiResponse.success(hoiDongService.getTatCaHoiDongByDot(dotBaoVeId, keyword,  pageable));
    }
}
