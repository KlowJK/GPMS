package com.backend.gpms.features.score.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.score.application.DiemService;
import com.backend.gpms.features.score.dto.request.DiemRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.transaction.Transactional;
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

@Tag(name = "Diem")
@RestController
@RequestMapping("/api/diem")
@RequiredArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE, makeFinal = true)
@Transactional
public class DiemController {
    DiemService service;

    @Operation(summary = "Nhập điểm chung cho phản biện và thành viên hội đồng")
    @PostMapping("/nhap-diem-chung")
    public ApiResponse<String> nhapDiemChung(@Valid @RequestBody DiemRequest request) {
        return ApiResponse.success(service.nhapDiemChung(request));
    }

    @Operation(summary = "Phê duyệt điểm chung cho phản biện và thành viên hội đồng")
    @PostMapping("/{idDeTai}/phe-duyet-diem-chung")
    public ApiResponse<String> pheDuyetDiemChung(@PathVariable Long idDeTai) {
        return ApiResponse.success(service.pheDuyetDiemChung(idDeTai));
    }




}