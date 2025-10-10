package com.backend.gpms.features.topic.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.topic.application.DeTaiService;
import com.backend.gpms.features.topic.application.DonHoanDoAnService;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiApprovalRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiGiangVienHuongDanRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.request.DonHoanDoAnRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiGiangVienHuongDanResponse;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;


import com.backend.gpms.features.topic.dto.response.DonHoanDoAnResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;


@Tag(name = "DeTai")
@RestController
@RequestMapping("/api/de-tai")
@AllArgsConstructor
public class DeTaiController {

    private final DeTaiService deTaiService;
    private final DonHoanDoAnService donHoanDoAnService;

    @Operation(summary = "Sinh viên đăng ký đề tài- Role sinh viên")
    @PreAuthorize("hasAnyAuthority('ROLE_SINH_VIEN')")
    @PostMapping(value = "/dang-ky", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeTaiResponse> registerDeTai(@ModelAttribute @Valid DeTaiRequest request) {
        return ApiResponse.success(deTaiService.registerDeTai(request));
    }

    @Operation(summary = "Giảng viên xem danh sách đề tài chờ xét duyệt của mình - Role giảng viên")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/xet-duyet")
    public ApiResponse<Page<DeTaiResponse>> listForGiangVien(

            @RequestParam(defaultValue = "CHO_DUYET") TrangThaiDeTai trangThai,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.success(deTaiService.getDeTaiByLecturerAndStatus(trangThai, pageable));
    }

    @Operation(summary = "Xét duyệt đề tài - Phải gửi giá trị duyệt(true) hoặc không duyệt(false), kèm nhận xét ")
    @PutMapping("/xet-duyet/{deTaiId}")
    public ApiResponse<DeTaiResponse> approveDeTai(
            @PathVariable Long deTaiId,
            @RequestBody @Valid DeTaiApprovalRequest request) {
        return ApiResponse.success(deTaiService.approveDeTai(deTaiId, request));
    }

    @Operation(summary = "Đề tài sinh viên đã đăng ký - Role sinh viên")
    @PreAuthorize("hasAnyAuthority('ROLE_SINH_VIEN')")
    @GetMapping("/chi-tiet")
    public ApiResponse<DeTaiResponse> getMyDeTai() {
        return ApiResponse.success(deTaiService.getMyDeTai());
    }

    @Operation(summary = "Add giảng viên - Role trợ lý khoa")
    @PostMapping("/gan-de-tai")
    public ApiResponse<DeTaiGiangVienHuongDanResponse> addGiangVienHuongDan(@RequestBody DeTaiGiangVienHuongDanRequest request) {
        return ApiResponse.success(deTaiService.addGiangVienHuongDan(request));
    }

    @Operation(summary = "Sinh viên gửi đơn hoãn ,lý do + file minh chứng optional")
    @PostMapping(value = "/sinh-vien/hoan-do-an", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DonHoanDoAnResponse> createPostponeRequest(
            @ModelAttribute @Valid DonHoanDoAnRequest request) {
        return ApiResponse.success(donHoanDoAnService.createPostponeRequest(request));
    }

    @Operation(summary = "Sinh viên xem danh sách đơn hoãn của chính mình")
    @GetMapping("/danh-sach-sinh-vien/hoan-do-an")
    public ApiResponse<Page<DonHoanDoAnResponse>> getMyPostponeRequests(
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.success(donHoanDoAnService.getMyPostponeRequests(pageable));
    }
}