package com.backend.gpms.features.lecturer.api;

import com.backend.gpms.features.lecturer.application.GiangVienLookupService;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLookupResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.constraints.Positive;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@Tag(name = "GiangVien")
@RestController
@RequestMapping("/api/giang_vien")
@RequiredArgsConstructor
@Validated
public class GiangVienController {

    private final GiangVienLookupService service;

    @Operation(summary = "Tra cứu giảng viên có slot hướng dẫn theo id lớp")
    @GetMapping("/advisors")
    public ResponseEntity<GiangVienLookupResponse> advisors(
            @RequestParam("idLop") @Positive Long idLop) {
        return ResponseEntity.ok(service.lookupByLopId(idLop));
    }
}
