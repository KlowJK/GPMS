package com.backend.gpms.features.outline.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.outline.application.DeCuongService;
import com.backend.gpms.features.outline.dto.request.DeCuongUploadRequest;
import com.backend.gpms.features.outline.dto.response.DeCuongNhanXetResponse;
import com.backend.gpms.features.outline.dto.response.DeCuongResponse;
import com.backend.gpms.features.outline.dto.response.NhanXetDeCuongResponse;
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
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Tag(name = "DeCuong")
@RestController
@RequestMapping(value = "/api/de-cuong")
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class DeCuongController {
    DeCuongService deCuongService;

    @Operation(summary = "Lấy ra danh sách đề cương theo tài khoản đăng nhập, nếu tải khoản là gv hướng dẫn,phản biện,trưởng bộ môn có tham gia duyệt đề cương - Role giảng viên, trưởng bộ môn, trợ lý khoa")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN', 'ROLE_TRUONG_BO_MON', 'ROLE_TRO_LY_KHOA')")
    @GetMapping
    public ApiResponse<Page<DeCuongResponse>> getAll(
            @ParameterObject
            @PageableDefault(page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC)
            Pageable pageable) {
        return ApiResponse.success(deCuongService.getAllDeCuong(pageable));
    }

    @Operation(summary = "Nộp đề cương - Role sinh viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @PostMapping(value = "/sinh-vien/nop-de-cuong", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<DeCuongResponse> submitDeCuong(
            @ModelAttribute @Valid DeCuongUploadRequest request) throws IOException {
        return ApiResponse.success(deCuongService.submitDeCuong(request));
    }

    @Operation(summary = "List đề cương của sinh viên đã nộp - Role sinh viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping("/sinh-vien/log")
    public ApiResponse<List<DeCuongNhanXetResponse>> viewDeCuongLog() {
        return ApiResponse.success( deCuongService.viewDeCuongLog());
    }

    @Operation(summary = "Duyệt đề cương - Role trưởng bộ môn, giảng viên, trợ lý khoa")
    @PreAuthorize("hasAnyAuthority('ROLE_TRUONG_BO_MON','ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA')")
    @PutMapping("/{id}/duyet")
    public ApiResponse<DeCuongResponse> approveDeCuong(@PathVariable Long id,
                                                       @RequestParam(value = "reason", required = false) String reason,
                                                       @RequestBody(required = false) Map<String, Object> body) {
        if (body != null && (reason == null || reason.isBlank())) {
            reason = toStringVal(body.get("reason"));
        }
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Thiếu tham số 'reason'");
        }
        var res = deCuongService.reviewDeCuong(id, true, reason);
        return ApiResponse.success(res);
    }

    @Operation(summary = "Từ chối đề cương - Role trưởng bộ môn, giảng viên, trợ lý khoa")
    @PreAuthorize("hasAnyAuthority('ROLE_TRUONG_BO_MON','ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA')")
    @PutMapping(value = "/{id}/tu-choi")
    public ApiResponse<DeCuongResponse> rejectDeCuong(
            @PathVariable Long id,
            @RequestParam(value = "reason", required = false) String reason,
            @RequestBody(required = false) Map<String, Object> body
    ) {
        if (body != null && (reason == null || reason.isBlank())) {
            reason = toStringVal(body.get("reason"));
        }
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Thiếu tham số 'reason'");
        }
        var res = deCuongService.reviewDeCuong(id, false, reason);
        return ApiResponse.success(res);
    }

    @Operation(summary = "Danh sách đề cương đã duyệt thuộc bộ môn của trưởng bộ môn - Role trưởng bộ môn")
    @PreAuthorize("hasAuthority('ROLE_TRUONG_BO_MON')")
    @GetMapping("/truong-bo-mon/danh-sach")
    public ApiResponse<Page<DeCuongResponse>> getAcceptedForTBM(
            @ParameterObject
            @PageableDefault(page = 0, size = 10, sort = "deTai.sinhVien.hoTen", direction = Sort.Direction.ASC)
            Pageable pageable) {
        return ApiResponse.success(deCuongService.getAcceptedForTBM(pageable));
    }

    @Operation(summary = "Xuất excel danh sách đề cương đã duyệt thuộc bộ môn của trưởng bộ môn - Role trưởng bộ môn")
    @PreAuthorize("hasAuthority('ROLE_TRUONG_BO_MON')")
    @GetMapping(
            value = "/truong-bo-mon/danh-sach/excel",
            produces = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    public ResponseEntity<byte[]> exportAcceptedForTBMAsExcel() {
        byte[] xlsx = deCuongService.exportAcceptedForTBMAsExcel();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=de-cuong-accepted.xlsx")
                .contentType(MediaType.parseMediaType(
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(xlsx);
    }

    private Long toLong(Object v) {
        if (v == null) return null;
        if (v instanceof Number n) return n.longValue();
        if (v instanceof String s) {
            try {
                return Long.parseLong(s.trim());
            } catch (NumberFormatException ignored) { }
        }
        return null;
    }

    private String toStringVal(Object v) {
        return v == null ? null : String.valueOf(v);
    }
}