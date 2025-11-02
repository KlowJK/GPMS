// features/storage/api/FileUploadController.java
package com.backend.gpms.features.storage.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.storage.application.StorageService;
import com.backend.gpms.features.storage.dto.response.ThuVienDeTaiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Tag(name = "Storage")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class StorageController {
    private final StorageService storage;

    @PostMapping(value = "/files/upload",  consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<String> upload(
            @RequestParam("file") MultipartFile file
    ) {
        // TODO: validate quyền, loại file, kích thước...
        var result = storage.upload(file);
        return ApiResponse.success(result);
    }

    @DeleteMapping("/files/delete")
    public ResponseEntity<?> delete(@RequestParam("publicId") String publicId) {
        storage.delete(publicId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/files/upload-single-test")
    public ResponseEntity<String> uploadSingleFile(@ModelAttribute("file") MultipartFile file) {
        String url = storage.upload(file);
        return ResponseEntity.ok(url);
    }

    @GetMapping("public/thu-vien/de-tai")
    public ApiResponse<List<ThuVienDeTaiResponse>> getThuVienDeTai() {
       return ApiResponse.success(storage.getTatCaThuVienDeTai());

    }

}
