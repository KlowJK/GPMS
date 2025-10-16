package com.backend.gpms.features.student.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.student.application.SinhVienService;
import com.backend.gpms.features.student.dto.request.SinhVienCreationRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.*;
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

import java.io.IOException;
import java.util.List;

@Tag(name = "SinhVien")
@RestController
@RequestMapping("/api/sinh-vien")
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class SinhVienController {

    SinhVienService sinhVienService;

    @Operation(summary = "Tạo mới sinh viên - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping
    public ApiResponse<SinhVienCreationResponse> createSinhVien(@RequestBody @Valid SinhVienCreationRequest request) {

        return ApiResponse.success(sinhVienService.createSinhVien(request));

    }

    @Operation(summary = "Import danh sách sinh viên từ file excel - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping(value = "import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<SinhVienImportResponse>  importSinhVien(@RequestBody MultipartFile file) throws IOException {

        return ApiResponse.success(sinhVienService.importSinhVien(file));

    }

    @Operation(summary = "Lấy danh sách sinh viên có phân trang")
    @GetMapping
    public ApiResponse<Page<SinhVienResponse>> getAllSinhVien(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.success(sinhVienService.getAllSinhVien(pageable));
    }

    @Operation(summary = "Tìm kiếm sinh viên theo tên hoặc mã sinh viên")
    @GetMapping("search")
    public ApiResponse<Page<SinhVienResponse>> getAllSinhVienByTenOrMaSV(
            @RequestParam String info,
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.success(sinhVienService.getAllSinhVienByTenOrMaSV(info, pageable));
    }

    @Operation(summary = "Thay đổi trạng thái đủ điều kiện của sinh viên, inoput mã sinh viên - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PutMapping("change-status/{maSV}")
    public ApiResponse<String> changeSinhVienStatus(@PathVariable String maSV) {
        sinhVienService.changeSinhVienStatus(maSV);
        return ApiResponse.success("Change status successfully!");
    }

    @Operation(summary = "Cập nhật thông tin sinh viên theo mã sinh viên - Role Trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PutMapping("{maSV}")
    public ApiResponse<SinhVienCreationResponse> updateSinhVien(
            @RequestBody @Valid SinhVienUpdateRequest request,
            @PathVariable String maSV
    ) {
        return ApiResponse.success(sinhVienService.updateSinhVien(request, maSV));
    }

    @Operation(summary = "Lấy thông tin chi tiết sinh viên theo mã sinh viên")
    @GetMapping("{maSV}")
    public ApiResponse<SinhVienInfoResponse> getSinhVienInfo(@PathVariable String maSV) {
        return ApiResponse.success(sinhVienService.getSinhVienInfo(maSV));
    }

    @Operation(summary = "Lấy thông tin chi tiết sinh viên theo id sinh vien")
    @GetMapping("/by-id/{idSV}")
    public ApiResponse<SinhVienInfoResponse> getSinhVienInfoById(@PathVariable Long idSV) {
        return ApiResponse.success(sinhVienService.getSinhVienInfoById(idSV));
    }

    @Operation(summary = "Lấy danh sách sinh viên chưa có đề tài")
    @GetMapping("without-de-tai")
    public ApiResponse<List<GetSinhVienWithoutDeTaiResponse>> getSinhVienWithoutDeTai() {
        return ApiResponse.success(sinhVienService.getSinhVienWithoutDeTai());
    }

    @Operation(summary = "Upload CV cho sinh viên - Role sinh viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @PostMapping(value = "upload-cv", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> uploadCV(@RequestParam("file") MultipartFile file) throws IOException {
        sinhVienService.uploadCV(file);
        return ApiResponse.success("Upload CV successfully!");
    }

}