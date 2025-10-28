package com.backend.gpms.features.department.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.department.application.NganhService;
import com.backend.gpms.features.department.dto.request.NganhRequest;
import com.backend.gpms.features.department.dto.response.NganhResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Nganh")
@RestController
@RequestMapping(
        value = "/api/nganh"
)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class NganhController {

    NganhService nganhService;

    @GetMapping
    public ApiResponse<Page<NganhResponse>> getAllNganh(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable) {
        return ApiResponse.success(nganhService.getAllNganh(pageable))
               ;
    }

    @PostMapping
    public ApiResponse<NganhResponse> createNganh(@RequestBody @Valid NganhRequest nganhRequest) {
        return ApiResponse.success(nganhService.createNganh(nganhRequest))
                ;
    }

    @PutMapping("/{nganhId}")
    public ApiResponse<NganhResponse> updateNganh(@PathVariable Long nganhId, @RequestBody @Valid NganhRequest nganhRequest) {
        return ApiResponse.success(nganhService.updateNganh(nganhRequest, nganhId))
                ;
    }

    @DeleteMapping("/{nganhId}")
    public ApiResponse<String> deleteNganh(@PathVariable Long nganhId) {
        nganhService.deleteNganh(nganhId);
        return ApiResponse.success("Delete nganh successfully!")
                ;
    }
}
