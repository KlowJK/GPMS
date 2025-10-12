package com.backend.gpms.features.lecturer.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.lecturer.application.GiangVienService;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import com.backend.gpms.features.lecturer.dto.request.GiangVienUpdateRequest;
import com.backend.gpms.features.lecturer.dto.request.TroLyKhoaCreationRequest;
import com.backend.gpms.features.lecturer.dto.response.*;
import com.backend.gpms.features.outline.dto.response.DeCuongNhanXetResponse;
import com.backend.gpms.features.topic.application.DeTaiService;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiApprovalRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Set;

@Tag(name = "GiangVien")
@RestController
@RequestMapping("/api/giang-vien")
@RequiredArgsConstructor
@Validated
@Transactional
public class GiangVienController {

    private final GiangVienService giangVienService;
    private final DeTaiService deTaiService;

    @Operation(summary = "List giảng viên có slot hướng dẫn thuộc bộ môn, thuộc khoa của sinh viên đăng ký đề tài")
    @GetMapping("/advisors")
    public ApiResponse<List<GiangVienLiteResponse>> giangVienList() {
       return ApiResponse.success(giangVienService.giangVienLiteResponseList());

    }

    @Operation(summary = "Tạo tài khoản giảng viên - Role trợ lý khoa, trưởng bộ môn, quản trị")
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON', 'ROLE_QUAN_TRI_VIEN')")
    @PostMapping
    public ApiResponse<GiangVienCreationResponse> createGiangVien(@RequestBody @Valid GiangVienCreationRequest giangVienCreationRequest) {

        return ApiResponse.success(giangVienService.createGiangVien(giangVienCreationRequest));
    }

    @Operation(summary = "Tạo tài khoản trợ lý khoa - Role quản trị")
    @PreAuthorize("hasAuthority('ROLE_QUAN_TRI_VIEN')")
    @PostMapping("tro-ly-khoa")
    public ApiResponse<String> createTroLyKhoa(
            @RequestBody TroLyKhoaCreationRequest troLyKhoaCreationRequest) {

        giangVienService.createTroLyKhoa(troLyKhoaCreationRequest);
        return ApiResponse.success("Create Tro Ly Khoa successfully");

    }

    @Operation(summary = "Import giảng viên từ file excel Role trợ lý khoa - Role trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON')")
    @PostMapping(value = "import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<GiangVienImportResponse> importGiangVien(@RequestBody MultipartFile file) throws IOException {

        return ApiResponse.success(giangVienService.importGiangVien(file));

    }

    @Operation(summary = "Lấy danh sách sinh viên được giảng viên hướng dẫn - Role giảng viên, trợ lý khoa, trưởng bộ môn, có phân trang")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN', 'ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON')")
    @GetMapping("/sinh-vien")
    public ApiResponse<Page<SinhVienSupervisedResponse>> getMySupervisedStudents(
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "hoTen", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.success(giangVienService.getMySinhVienSupervised(pageable));
    }

    @Operation(summary = "Lấy danh sách đề tài sinh viên theo trạng thái đề tài - Role giảng viên, trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN', 'ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON')")
    @GetMapping("/do-an/xet-duyet-de-tai")
    public ApiResponse<Page<ApprovalSinhVienResponse>> getDeTaiSinhVienApproval(
            @RequestParam(name = "status", required = false) TrangThaiDeTai status,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "hoTen", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.success(giangVienService.getDeTaiSinhVienApproval(status, pageable));
    }

    @Operation(summary = "List đề cương của sinh viên đã nộp - Role sinh viên")
    @GetMapping("/sinh-vien/log")
    public ApiResponse<List<DeCuongNhanXetResponse>> viewDeCuongLog(@RequestParam String maSinhVien) {
        return ApiResponse.success( giangVienService.viewDeCuongLog(maSinhVien));
    }


    @Operation(summary = "Lấy giảng viên theo bộ môn")
    @GetMapping("/{boMonId}")
    public ApiResponse<Set<GiangVienInfoResponse>> getGiangVienByBoMon(@PathVariable("boMonId") Long boMonId) {

        return ApiResponse.<Set<GiangVienInfoResponse>>builder()
                .result(giangVienService.getGiangVienByBoMonAndSoLuongDeTai(boMonId))
                .build();

    }

    @Operation(summary = "Lấy giảng viên theo bộ môn ")
    @GetMapping("/by-bo-mon/{boMonId}")
    public ApiResponse<List<GiangVienLiteResponse>> getByBoMon(@PathVariable Long boMonId) {
        return ApiResponse.success(giangVienService.getGiangVienLiteByBoMon(boMonId));
    }

    @Operation(summary = "Danh sách giảng viên có phân trang- Role trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON')")
    @GetMapping("/list")
    public ApiResponse<Page<GiangVienResponse>> listGiangVien(
            @ParameterObject
            @PageableDefault(size = 10, sort = "maGiangVien", direction = Sort.Direction.ASC)
            Pageable pageable
    ) {
        return ApiResponse.success(giangVienService.getAllGiangVien(pageable));
    }

    @Operation(summary = "Cập nhật thông tin giảng viên - Role trợ lý khoa, quản trị")
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA', 'ROLE_QUAN_TRI_VIEN')")
    @PutMapping("/{id}")
    public ApiResponse<GiangVienResponse> updateGiangVien(
            @PathVariable Long id,
            @RequestBody @Valid GiangVienUpdateRequest request) {

        return ApiResponse.<GiangVienResponse>builder()
                .result(giangVienService.updateGiangVien(id, request))
                .build();
    }

    @Operation(summary = "Giảng viên xét duyệt đề tài sinh viên đăng ký")
    @PutMapping("/do-an/xet-duyet-de-tai/{deTaiId}/approve")
    public ApiResponse<DeTaiResponse> approveDeTaiByLecturer(
            @PathVariable Long deTaiId,
            @RequestBody(required = false) DeTaiApprovalRequest request) {

        if (request == null) request = new DeTaiApprovalRequest();
        request.setApproved(true);

        return ApiResponse.success(deTaiService.approveByGiangVien(deTaiId, request.getNhanXet()));
    }


    @PutMapping("/do-an/xet-duyet-de-tai/{deTaiId}/reject")
    @Operation(requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
            required = false,
            content = @Content(examples = @ExampleObject(
                    name = "Reject body", value = "{ \"approved\": false, \"nhanXet\": \"Lý do từ chối\" }"
            ))
    ), summary = "Giảng viên từ chối đề tài sinh viên đăng ký")
    public ApiResponse<DeTaiResponse> rejectDeTaiByLecturer(
            @PathVariable Long deTaiId,
            @RequestBody(required = false) @Valid DeTaiApprovalRequest request) {
        if (request == null) request = new DeTaiApprovalRequest();
        request.setApproved(false);
        return ApiResponse.success(deTaiService.rejectByGiangVien(deTaiId, request.getNhanXet()));
    }


    @Operation(summary = "Tìm kiếm sinh viên được giảng viên hướng dẫn (không phân trang) , có thể có tham số q: tìm theo tên, mã sv, lớp, đề tài, số điện thoại")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN', 'ROLE_TRO_LY_KHOA', 'ROLE_TRUONG_BO_MON')")
    @GetMapping("/sinh-vien/all")
    public ApiResponse<List<SinhVienSupervisedResponse>> getMySupervisedStudentsAll(
            @RequestParam(required = false) String q) {

        return ApiResponse.success(giangVienService.getMySinhVienSupervisedAll(q));
    }





}
