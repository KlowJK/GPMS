package com.backend.gpms.features.department.api;


import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.department.application.BoMonService;
import com.backend.gpms.features.department.application.KhoaService;
import com.backend.gpms.features.department.application.LopService;
import com.backend.gpms.features.department.application.NganhService;
import com.backend.gpms.features.department.dto.request.*;
import com.backend.gpms.features.department.dto.response.*;
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
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Department", description = "API for managing departments, faculties, classes, and majors")
@RestController
@RequestMapping(
        value = "/api/public"
)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class DepartmentController {

    BoMonService boMonService;
    KhoaService khoaService;
    LopService lopService;
    NganhService nganhService;

    @GetMapping("/bo-mon")
    public ApiResponse<Page<BoMonResponse>> getAllBoMon(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.<Page<BoMonResponse>>builder()
                .result(boMonService.getAllBoMon(pageable))
                .build();
    }

    @PostMapping("/bo-mon")
    public ApiResponse<BoMonResponse> createBoMon(@RequestBody @Valid BoMonRequest boMonRequest) {
        return ApiResponse.<BoMonResponse>builder()
                .result(boMonService.createBoMon(boMonRequest))
                .build();
    }

    @PutMapping(value = "/bo-mon/{boMonId}")
    public ApiResponse<BoMonResponse> updateBoMon(
            @RequestBody @Valid BoMonRequest boMonRequest,
            @PathVariable Long boMonId) {
        return ApiResponse.<BoMonResponse>builder()
                .result(boMonService.updateBoMon(boMonRequest, boMonId))
                .build();
    }

    @DeleteMapping({ "/bo-mon/{boMonId}" })
    public ApiResponse<String> deleteBoMon(
            @RequestParam(value = "boMonId", required = false) Long boMonIdQuery,
            @PathVariable(value = "boMonId", required = false) Long boMonIdPath) {

        Long boMonId = (boMonIdPath != null) ? boMonIdPath : boMonIdQuery;
        if (boMonId == null) {
            throw new IllegalArgumentException("Thiếu tham số 'boMonId'");
        }

        boMonService.deleteBoMon(boMonId);
        return ApiResponse.<String>builder()
                .result("Delete bo mon successfully")
                .build();
    }

    @PostMapping(value = "/bo-mon/truong-bo-mon")
    public ApiResponse<TruongBoMonCreationResponse> createTruongBoMon(
            @RequestBody TruongBoMonCreationRequest truongBoMonCreationRequest) {
        return ApiResponse.<TruongBoMonCreationResponse>builder()
                .result(boMonService.createTruongBoMon(truongBoMonCreationRequest))
                .build();
    }

    @GetMapping("/bo-mon/with-truong-bo-mon")
    public ApiResponse<Page<BoMonWithTruongBoMonResponse>> getAllWithTBM(
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable
    ) {
        return ApiResponse.<Page<BoMonWithTruongBoMonResponse>>builder()
                .result(boMonService.findAllWithTruongBoMon(pageable))
                .build();
    }



    @GetMapping("/khoa")
    public ApiResponse<List<KhoaResponse>> getKhoa() {
        return ApiResponse.<List<KhoaResponse>>builder()
                .result(khoaService.getAllKhoa())
                .build();
    }

    @PostMapping("/khoa")
    public ApiResponse<KhoaResponse> createKhoa(@Valid @RequestBody KhoaRequest khoaRequest) {
        return ApiResponse.<KhoaResponse>builder()
                .result(khoaService.createKhoa(khoaRequest))
                .build();
    }

    @PutMapping("/khoa/{khoaId}")
    public ApiResponse<KhoaResponse> updateKhoa(@PathVariable Long khoaId,
                                                @Valid @RequestBody KhoaRequest khoaRequest) {
        return ApiResponse.<KhoaResponse>builder()
                .result(khoaService.updateKhoa(khoaRequest, khoaId))
                .build();
    }

    @DeleteMapping("/khoa/{khoaId}")  // ⬅️ thêm "/" (trước bạn đang thiếu)
    public ApiResponse<String> deleteKhoa(@PathVariable Long khoaId) {
        khoaService.deleteKhoa(khoaId);
        return ApiResponse.<String>builder()
                .result("Delete khoa successfully")
                .build();
    }

    @GetMapping("/lop")
    public ApiResponse<Page<LopResponse>> getLop(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {

        return ApiResponse.<Page<LopResponse>>builder()
                .result(lopService.getAllLop(pageable))
                .build();

    }

    @PostMapping("/lop")
    public ApiResponse<LopResponse> createLop(@RequestBody @Valid LopRequest lopRequest) {

        return ApiResponse.<LopResponse>builder()
                .result(lopService.createLop(lopRequest))
                .build();

    }

    @PutMapping("/lop/{lopId}")
    public ApiResponse<LopResponse> updateLop(@PathVariable Long lopId, @RequestBody @Valid LopRequest lopRequest) {

        return ApiResponse.<LopResponse>builder()
                .result(lopService.updateLop(lopRequest, lopId))
                .build();

    }

    @DeleteMapping("/lop/{lopId}")
    public ApiResponse<String> deleteLop(@PathVariable Long lopId) {

        lopService.deleteLop(lopId);
        return ApiResponse.<String>builder()
                .result("Delete lop successfully")
                .build();

    }

    @GetMapping("/nganh")
    public ApiResponse<Page<NganhResponse>> getAllNganh(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.<Page<NganhResponse>>builder()
                .result(nganhService.getAllNganh(pageable))
                .build();
    }

    @PostMapping("/nganh")
    public ApiResponse<NganhResponse> createNganh(@RequestBody @Valid NganhRequest nganhRequest) {
        return ApiResponse.<NganhResponse>builder()
                .result(nganhService.createNganh(nganhRequest))
                .build();
    }

    @PutMapping("/nganh/{nganhId}")
    public ApiResponse<NganhResponse> updateNganh(@PathVariable Long nganhId, @RequestBody @Valid NganhRequest nganhRequest) {
        return ApiResponse.<NganhResponse>builder()
                .result(nganhService.updateNganh(nganhRequest, nganhId))
                .build();
    }

    @DeleteMapping("/nganh/{nganhId}")
    public ApiResponse<String> deleteNganh(@PathVariable Long nganhId) {
        nganhService.deleteNganh(nganhId);
        return ApiResponse.<String>builder()
                .result("Delete nganh successfully!")
                .build();
    }

}
