package com.backend.gpms.features.student.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.student.application.SinhVienService;
import com.backend.gpms.features.student.dto.request.SinhVienCreationRequest;
import com.backend.gpms.features.student.dto.request.SinhVienUpdateRequest;
import com.backend.gpms.features.student.dto.response.*;
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

import java.io.IOException;
import java.util.List;

@Tag(name = "SinhVien")
@RestController
@RequestMapping("/api/sinh-vien")
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class SinhVienController {

    SinhVienService sinhVienService;

    @PostMapping
    public ApiResponse<SinhVienCreationResponse> createSinhVien(@RequestBody @Valid SinhVienCreationRequest request) {

        return ApiResponse.<SinhVienCreationResponse>builder()
                .result(sinhVienService.createSinhVien(request))
                .build();

    }

    @PostMapping(value = "import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<SinhVienImportResponse>  importSinhVien(@RequestBody MultipartFile file) throws IOException {

        return ApiResponse.<SinhVienImportResponse>builder()
                .result(sinhVienService.importSinhVien(file))
                .build();

    }

    @GetMapping
    public ApiResponse<Page<SinhVienResponse>> getAllSinhVien(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.<Page<SinhVienResponse>>builder()
                .result(sinhVienService.getAllSinhVien(pageable))
                .build();
    }

    @GetMapping("search")
    public ApiResponse<Page<SinhVienResponse>> getAllSinhVienByTenOrMaSV(
            @RequestParam String info,
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.<Page<SinhVienResponse>>builder()
                .result(sinhVienService.getAllSinhVienByTenOrMaSV(info, pageable))
                .build();
    }

    @PutMapping("change-status/{maSV}")
    public ApiResponse<String> changeSinhVienStatus(@PathVariable String maSV) {
        sinhVienService.changeSinhVienStatus(maSV);
        return ApiResponse.<String>builder()
                .result("Change status successfully!")
                .build();
    }

    @PutMapping("{maSV}")
    public ApiResponse<SinhVienCreationResponse> updateSinhVien(
            @RequestBody @Valid SinhVienUpdateRequest request,
            @PathVariable String maSV
    ) {
        return ApiResponse.<SinhVienCreationResponse>builder()
                .result(sinhVienService.updateSinhVien(request, maSV))
                .build();
    }

    @GetMapping("{maSV}")
    public ApiResponse<SinhVienInfoResponse> getSinhVienInfo(@PathVariable String maSV) {
        return ApiResponse.<SinhVienInfoResponse>builder()
                .result(sinhVienService.getSinhVienInfo(maSV))
                .build();
    }

    @GetMapping("without-de-tai")
    public ApiResponse<List<GetSinhVienWithoutDeTaiResponse>> getSinhVienWithoutDeTai() {
        return ApiResponse.<List<GetSinhVienWithoutDeTaiResponse>>builder()
                .result(sinhVienService.getSinhVienWithoutDeTai())
                .build();
    }

    @PostMapping(value = "upload-cv", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> uploadCV(@RequestParam("file") MultipartFile file) throws IOException {
        sinhVienService.uploadCV(file);
        return ApiResponse.<String>builder()
                .result("Upload CV successfully!")
                .build();
    }

}