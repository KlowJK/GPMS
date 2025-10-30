package com.backend.gpms.features.department.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.department.application.BoMonService;
import com.backend.gpms.features.department.dto.request.BoMonRequest;
import com.backend.gpms.features.department.dto.request.TruongBoMonCreationRequest;
import com.backend.gpms.features.department.dto.response.BoMonResponse;
import com.backend.gpms.features.department.dto.response.BoMonWithTruongBoMonResponse;
import com.backend.gpms.features.department.dto.response.TruongBoMonCreationResponse;
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
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Tag(name = "BoMon")
@RestController
@RequestMapping(
        value = "/api/bo-mon"
)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class BoMonController {
    BoMonService boMonService;

    @GetMapping
    public ApiResponse<Page<BoMonResponse>> getAllBoMon(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.success(boMonService.getAllBoMon(pageable));
    }

    @PostMapping
    public ApiResponse<BoMonResponse> createBoMon(@RequestBody @Valid BoMonRequest boMonRequest) {
        return ApiResponse.success(boMonService.createBoMon(boMonRequest));
    }

    @PutMapping(value = "/{boMonId}")
    public ApiResponse<BoMonResponse> updateBoMon(
            @RequestBody @Valid BoMonRequest boMonRequest,
            @PathVariable Long boMonId) {
        return ApiResponse.success(boMonService.updateBoMon(boMonRequest, boMonId));
    }

    @DeleteMapping({ "/{boMonId}" })
    public ApiResponse<String> deleteBoMon(
            @RequestParam(value = "boMonId", required = false) Long boMonIdQuery,
            @PathVariable(value = "boMonId", required = false) Long boMonIdPath) {

        Long boMonId = (boMonIdPath != null) ? boMonIdPath : boMonIdQuery;
        if (boMonId == null) {
            throw new IllegalArgumentException("Thiếu tham số 'boMonId'");
        }

        boMonService.deleteBoMon(boMonId);
        return ApiResponse.success("Delete bo mon successfully");
    }

    @Operation(summary = "Thêm, cập nhật trưởng bộ môn cho bộ môn - thêm hoặc cập nhật giảng viên khác làm trưởng bộ môn đều gọi api này - Role trợ lý khoa")
    @PreAuthorize("hasAuthority('ROLE_TRO_LY_KHOA')")
    @PostMapping(value = "/truong-bo-mon")
    public ApiResponse<TruongBoMonCreationResponse> createTruongBoMon(
            @RequestBody TruongBoMonCreationRequest truongBoMonCreationRequest) {
        return ApiResponse.success(boMonService.createTruongBoMon(truongBoMonCreationRequest));
    }

    @GetMapping("/with-truong-bo-mon")
    public ApiResponse<Page<BoMonWithTruongBoMonResponse>> getAllWithTBM(
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        return ApiResponse.success(boMonService.findAllWithTruongBoMon(pageable));
    }

}
