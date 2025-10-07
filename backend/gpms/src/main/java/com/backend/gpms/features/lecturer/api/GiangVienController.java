package com.backend.gpms.features.lecturer.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.lecturer.application.GiangVienService;
import com.backend.gpms.features.lecturer.dto.request.GiangVienCreationRequest;
import com.backend.gpms.features.lecturer.dto.request.GiangVienUpdateRequest;
import com.backend.gpms.features.lecturer.dto.request.TroLyKhoaCreationRequest;
import com.backend.gpms.features.lecturer.dto.response.*;
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
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Set;

@Tag(name = "GiangVien")
@RestController
@RequestMapping("/api/giang_vien")
@RequiredArgsConstructor
@Validated
public class GiangVienController {

    private final GiangVienService giangVienService;
    DeTaiService deTaiService;

    @Operation(summary = "Tra cứu giảng viên có slot hướng dẫn theo id lớp")
    @GetMapping("/advisors")
    public ApiResponse<List<GiangVienLiteResponse>> giangVienList() {
       return ApiResponse.success(giangVienService.giangVienLiteResponseList());

    }


    @PostMapping
    public ApiResponse<GiangVienCreationResponse> createGiangVien(@RequestBody @Valid GiangVienCreationRequest giangVienCreationRequest) {

        return ApiResponse.success(giangVienService.createGiangVien(giangVienCreationRequest));
    }

    @PostMapping("tro-ly-khoa")
    public ApiResponse<String> createTroLyKhoa(@RequestBody TroLyKhoaCreationRequest troLyKhoaCreationRequest) {

        giangVienService.createTroLyKhoa(troLyKhoaCreationRequest);
        return ApiResponse.<String>builder()
                .result("Create Tro Ly Khoa successfully")
                .build();

    }

    @PostMapping(value = "import", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<GiangVienImportResponse> importGiangVien(@RequestBody MultipartFile file) throws IOException {

        return ApiResponse.<GiangVienImportResponse>builder()
                .result(giangVienService.importGiangVien(file))
                .build();

    }

    @GetMapping("/sinh-vien")
    public ApiResponse<Page<SinhVienSupervisedResponse>> getMySupervisedStudents(
            @PageableDefault(page = 0, size = 10, sort = "hoTen", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.<Page<SinhVienSupervisedResponse>>builder()
                .result(giangVienService.getMySinhVienSupervised(pageable))
                .build();
    }

    @GetMapping("/do-an/xet-duyet-de-tai")
    public ApiResponse<Page<ApprovalSinhVienResponse>> getDeTaiSinhVienApproval(
            @RequestParam(name = "status", required = false) TrangThaiDeTai status,
            @PageableDefault(page = 0, size = 10, sort = "hoTen", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.<Page<ApprovalSinhVienResponse>>builder()
                .result(giangVienService.getDeTaiSinhVienApproval(status, pageable))
                .build();
    }

    @GetMapping("/{boMonId}")
    public ApiResponse<Set<GiangVienInfoResponse>> getGiangVienByBoMon(@PathVariable("boMonId") Long boMonId) {

        return ApiResponse.<Set<GiangVienInfoResponse>>builder()
                .result(giangVienService.getGiangVienByBoMonAndSoLuongDeTai(boMonId))
                .build();

    }

    @GetMapping("/by-bo-mon/{boMonId}")
    public ApiResponse<List<GiangVienLiteResponse>> getByBoMon(@PathVariable Long boMonId) {
        return ApiResponse.<List<GiangVienLiteResponse>>builder()
                .result(giangVienService.getGiangVienLiteByBoMon(boMonId))
                .build();
    }

    @GetMapping("/list")
    public ApiResponse<Page<GiangVienResponse>> listGiangVien(
            @PageableDefault(size = 10, sort = "maGV", direction = Sort.Direction.ASC)
            Pageable pageable
    ) {
        return ApiResponse.<Page<GiangVienResponse>>builder()
                .result(giangVienService.getAllGiangVien(pageable))
                .build();
    }

    @PutMapping("/{id}")
    public ApiResponse<GiangVienResponse> updateGiangVien(
            @PathVariable Long id,
            @RequestBody @Valid GiangVienUpdateRequest request) {

        return ApiResponse.<GiangVienResponse>builder()
                .result(giangVienService.updateGiangVien(id, request))
                .build();
    }

    @PutMapping("/do-an/xet-duyet-de-tai/{deTaiId}/approve")
    public ApiResponse<DeTaiResponse> approveDeTaiByLecturer(
            @PathVariable Long deTaiId,
            @RequestBody(required = false) DeTaiApprovalRequest request) {

        if (request == null) request = new DeTaiApprovalRequest();
        request.setApproved(true);

        return ApiResponse.<DeTaiResponse>builder()
                .result(deTaiService.approveByGiangVien(deTaiId, request.getNhanXet()))
                .build();
    }

    @PutMapping("/do-an/xet-duyet-de-tai/{deTaiId}/reject")
    @Operation(requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
            required = false,
            content = @Content(examples = @ExampleObject(
                    name = "Reject body", value = "{ \"approved\": false, \"nhanXet\": \"Lý do từ chối\" }"
            ))
    ))
    public ApiResponse<DeTaiResponse> rejectDeTaiByLecturer(
            @PathVariable Long deTaiId,
            @RequestBody(required = false) @Valid DeTaiApprovalRequest request) {
        if (request == null) request = new DeTaiApprovalRequest();
        request.setApproved(false); // ép false bất kể client gửi gì
        return ApiResponse.<DeTaiResponse>builder()
                .result(deTaiService.rejectByGiangVien(deTaiId, request.getNhanXet()))
                .build();
    }

    @GetMapping("/sinh-vien/all")
    public ApiResponse<List<SinhVienSupervisedResponse>> getMySupervisedStudentsAll(
            @RequestParam(required = false) String q) {

        return ApiResponse.<List<SinhVienSupervisedResponse>>builder()
                .result(giangVienService.getMySinhVienSupervisedAll(q))
                .build();
    }





}
