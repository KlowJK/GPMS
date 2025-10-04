
package com.backend.gpms.features.storage.application;

import org.springframework.web.multipart.MultipartFile;

import java.io.File;

public interface StorageService {
    public String upload(MultipartFile file);
    String upload(File file);
    UploadResult upload(MultipartFile file, String folder, String publicIdHint);
    void delete(String publicId);

    String uploadRawFile(MultipartFile file);

    record UploadResult(String publicId, String url, String resourceType, long bytes) {}
}
