package com.backend.gpms.features.progress.api;

import com.backend.gpms.common.util.ApiResponse;

import com.backend.gpms.features.progress.application.NhatKyTienTrinhService;
import com.backend.gpms.features.progress.domain.TrangThaiNhatKy;
import com.backend.gpms.features.progress.dto.request.DuyetNhatKyRequest;
import com.backend.gpms.features.progress.dto.request.NhatKyTienTrinhRequest;
import com.backend.gpms.features.progress.dto.response.NhatKyTienTrinhResponse;
import com.backend.gpms.features.progress.dto.response.TuanResponse;
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
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "NhatKyTienTrinh")
@RestController
@RequestMapping("/api/nhat-ky-tien-trinh")
@AllArgsConstructor

public class NhatKyTienTrinhController {

   
    private NhatKyTienTrinhService service;

    @Operation(summary = "Lấy danh sách tuần tính theo ngày đề tài được duyệt đến ngày kết thúc đợt - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping("/tuans")
    public ApiResponse<List<TuanResponse>> getTuanList(
            @RequestParam(name = "includeAll", required = false, defaultValue = "false") boolean includeAll) {
        return ApiResponse.success(service.getTuanList(includeAll));
    }

    @Operation(summary = "Lấy danh sách nhật ký tiến trình của mình, nếu true, lấy tất cả nhật ký; nếu false, chỉ lấy nhật ký của sinh viên từ tuần đầu tiên đến hiện tại (mặc định false)- Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyList(
            @RequestParam(name = "includeAll", required = false, defaultValue = "false") boolean includeAll) {
        return ApiResponse.success(service.getNhatKyListBySinhVien(includeAll));
    }

    @Operation(summary = "Nộp nhật ký tiến trình(Nội dung kèm file) - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @PutMapping(value = "/{deTaiId}/nop-nhat-ky", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<NhatKyTienTrinhResponse> nopNhatKy(
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

    @Operation(summary = "Lấy page nhật ký sinh viên được giảng viên hướng dẫn - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/my-supervised-students")
    public ApiResponse<Page<NhatKyTienTrinhResponse>> getNhatKyPage(
            @RequestParam(name = "status", required = false) TrangThaiNhatKy status,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "createdAt", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.success(service.getNhatKyPage(status,pageable));
    }
    @Operation(summary = "App - Lấy danh sách nhật ký sinh viên được giảng viên hướng dẫn - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/my-supervised-students/list")
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyPage(
            @RequestParam(name = "status", required = false) TrangThaiNhatKy status
          ) {
        return ApiResponse.success(service.getNhatKyList(status));
    }

    @Operation(summary = "Nếu includeAll =false ấy tuần tự động tính theo ngày hiện tại, còn lại tất cả, tuần được tính theo ngày đề tài được duyệt đến ngày kết thúc đợt - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/tuans-by-lecturer")
    public ApiResponse<List<TuanResponse>> getTuanListByGVHD(
            @RequestParam(name = "includeAll", required = false, defaultValue = "false") boolean includeAll) {
        return ApiResponse.success(service.getTuanListByGVHD(includeAll));
    }

    @Operation(summary = "Lấy page sinh viên thuộc tuần hiện tại hoặc tất cả sinh viên nếu includeAll=true - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/all-nhat-ky")
    public ApiResponse<Page<NhatKyTienTrinhResponse>> getNhatKyPage(
            @RequestParam(name = "tuan",defaultValue = "0", required = false) int status,
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "createdAt", direction = Sort.Direction.ASC)
            Pageable pageable) {

        return ApiResponse.success(service.getNhatKyTienTrinhPage(status,pageable));

    }

    @Operation(summary = "Lấy list sinh viên thuộc tuần hiện tại hoặc tất cả sinh viên nếu includeAll=true - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/all-nhat-ky/list")
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyPage(
            @RequestParam(name = "tuan", defaultValue = "0",required = false) int status
           ) {

        return ApiResponse.success(service.getNhatKyTienTrinhList(status));

    }

    @Operation(summary = "Lấy list nhật ký của sinh viên thuộc tuần hiện tại - Role giảng viên")
    @PreAuthorize("hasAuthority('ROLE_GIANG_VIEN')")
    @GetMapping("/{id}")
    public ApiResponse<List<NhatKyTienTrinhResponse>> getNhatKyListByGiangVien(
            @RequestParam(name = "idDeTai", defaultValue = "0",required = false) long idDeTai
    ) {
        return ApiResponse.success(service.getNhatKyListByGiangVien(idDeTai));

    }
}