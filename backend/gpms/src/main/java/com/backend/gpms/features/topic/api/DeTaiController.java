package com.backend.gpms.features.topic.api;

import com.backend.gpms.features.topic.application.DeTaiService;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.dto.request.DeTaiApprovalRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiGiangVienHuongDanRequest;
import com.backend.gpms.features.topic.dto.request.DeTaiRequest;
import com.backend.gpms.features.topic.dto.response.DeTaiGiangVienHuongDanResponse;
import com.backend.gpms.features.topic.dto.response.DeTaiResponse;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/de_tai")
@AllArgsConstructor
public class DeTaiController {

    private final DeTaiService deTaiService;

    @PostMapping(value = "/dang-ky", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<DeTaiResponse> registerDeTai(@ModelAttribute @Valid DeTaiRequest request) {
        return ResponseEntity.ok(deTaiService.registerDeTai(request));
    }

    @GetMapping("/xet-duyet")
    public ResponseEntity<Page<DeTaiResponse>> listForGiangVien(
            @RequestParam(defaultValue = "PENDING") TrangThaiDeTai trangThai,
            @PageableDefault(page = 0, size = 10, sort = "updatedAt", direction = Sort.Direction.DESC)
            Pageable pageable) {

        return ResponseEntity.ok(deTaiService.getDeTaiByLecturerAndStatus(trangThai, pageable));
    }

    @PutMapping("/xet-duyet/{deTaiId}")
    public ResponseEntity<DeTaiResponse> approveDeTai(
            @PathVariable Long deTaiId,
            @RequestBody @Valid DeTaiApprovalRequest request) {

        return ResponseEntity.ok(deTaiService.approveDeTai(deTaiId, request));
    }

    @GetMapping("/chi-tiet")
    public ResponseEntity<DeTaiResponse> getMyDeTai() {
        return ResponseEntity.ok(deTaiService.getMyDeTai());
    }

    @PostMapping("/gan-de-tai")
    public ResponseEntity<Boolean> addGiangVienHuongDan(@RequestBody DeTaiGiangVienHuongDanRequest request) {
        return ResponseEntity.ok(deTaiService.addGiangVienHuongDan(request));
    }
}