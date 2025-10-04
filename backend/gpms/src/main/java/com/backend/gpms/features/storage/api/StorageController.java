// features/storage/api/FileUploadController.java
package com.backend.gpms.features.storage.api;

import com.backend.gpms.features.storage.application.StorageService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Storage")
@RestController
@RequestMapping("/api/files")
@RequiredArgsConstructor
public class StorageController {
    private final StorageService storage;

    @PostMapping("/upload")
    public ResponseEntity<?> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "folder", required = false) String folder,
            @RequestParam(value = "publicId", required = false) String publicId
    ) {
        // TODO: validate quyền, loại file, kích thước...
        var result = storage.upload(file, folder, publicId);
        return ResponseEntity.ok(result);
    }

    @DeleteMapping
    public ResponseEntity<?> delete(@RequestParam("publicId") String publicId) {
        storage.delete(publicId);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/upload-single-test")
    public ResponseEntity<String> uploadSingleFile(@ModelAttribute("file") MultipartFile file) {
        String url = storage.upload(file);
        return ResponseEntity.ok(url);
    }
}
