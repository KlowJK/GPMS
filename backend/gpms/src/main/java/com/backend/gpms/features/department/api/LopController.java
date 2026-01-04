package com.backend.gpms.features.department.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.department.application.LopService;
import com.backend.gpms.features.department.dto.request.LopRequest;
import com.backend.gpms.features.department.dto.response.LopResponse;
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

@Tag(name = "Lop")
@RestController
@RequestMapping(
        value = "/api/lop"
)
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class LopController {


    LopService lopService;

    @GetMapping
    public ApiResponse<Page<LopResponse>> getLop(
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.success(lopService.getAllLop(pageable));
    }

    @PostMapping
    public ApiResponse<LopResponse> createLop(@RequestBody @Valid LopRequest lopRequest) {
        return ApiResponse.success(lopService.createLop(lopRequest));

    }

    @PutMapping("/{lopId}")
    public ApiResponse<LopResponse> updateLop(@PathVariable Long lopId, @RequestBody @Valid LopRequest lopRequest) {

        return ApiResponse.success(lopService.updateLop(lopRequest, lopId));

    }

    @DeleteMapping("/{lopId}")
    public ApiResponse<String> deleteLop(@PathVariable Long lopId) {

        lopService.deleteLop(lopId);
        return ApiResponse.success("Delete lop successfully");

    }
}
