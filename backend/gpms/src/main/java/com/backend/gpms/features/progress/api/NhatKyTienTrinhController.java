package com.backend.gpms.features.progress.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.lecturer.dto.response.SinhVienSupervisedResponse;
import com.backend.gpms.features.progress.application.NhatKyTienTrinhService;
import com.backend.gpms.features.progress.dto.request.DuyetNhatKyRequest;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import com.backend.gpms.features.progress.dto.response.TuanResponse;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

import lombok.AllArgsConstructor;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@Tag(name = "NhatKyTienTrinh")
@RestController
@RequestMapping("/api/public")
@AllArgsConstructor
public class NhatKyTienTrinhController {

   
    private NhatKyTienTrinhService service;

    @Operation(summary = "Lấy danh sách tuần tính theo ngày đề tài được duyệt đến ngày kết thúc đợt - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping("/tuans")
    public ApiResponse<List<TuanResponse>> getTuanList() {
        return ApiResponse.success(service.getTuanList());
    }

    @Operation(summary = "Lấy danh sách nhật ký tiến trình của mình - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyList() {
        return ApiResponse.success(service.getNhatKyList());
    }

    @Operation(summary = "Nộp nhật ký tiến trình(Nội dung kèm file) - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @PostMapping("/{deTaiId}")
    public ApiResponse<NhatKyTienTrinhResponse> nopNhatKy(
            @ParameterObject
            @ModelAttribute @Valid NhatKyTienTrinhRequest request){
        return ApiResponse.success(service.nopNhatKy(request));
    }
    @Operation(summary = "Duyệt nhật ký tiến trình, đầu vào id nhật ký + nhận xét - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @PutMapping("/{id}/duyet")
    public ApiResponse<NhatKyTienTrinhResponse> duyetNhatKy(
            @Valid @RequestBody DuyetNhatKyRequest request) {
        return ApiResponse.success(service.duyetNhatKy( request));
    }

    @Operation(summary = "Lấy danh sách nhật ký sinh viên được giảng viên hướng dẫn - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/my-supervised-students")
    public ApiResponse<Page<NhatKyTienTrinhResponse>> getNhatKyPage(
            @RequestParam(name = "status", required = false) TrangThaiDeTai status,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "createdAt", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.success(service.getNhatKyPage(status,pageable));
    }







}