package com.backend.gpms.features.lecturer.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.lecturer.application.GiangVienService;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLiteResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "GiangVien")
@RestController
@RequestMapping("/api/giang_vien")
@RequiredArgsConstructor
@Validated
public class GiangVienController {

    private final GiangVienService service;

    @Operation(summary = "Tra cứu giảng viên có slot hướng dẫn theo id lớp")
    @GetMapping("/advisors")
    public ApiResponse<List<GiangVienLiteResponse>> giangVienList() {
       return ApiResponse.<List<GiangVienLiteResponse>>builder()
               .result(service.giangVienLiteResponseList())
               .build();
    }
}
