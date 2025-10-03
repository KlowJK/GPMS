
package com.backend.gpms.features.storage.application;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {
    public String upload(MultipartFile file);
    UploadResult upload(MultipartFile file, String folder, String publicIdHint);
    void delete(String publicId);
    record UploadResult(String publicId, String url, String resourceType, long bytes) {}
}
