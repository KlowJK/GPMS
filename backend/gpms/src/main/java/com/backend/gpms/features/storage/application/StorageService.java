
package com.backend.gpms.features.storage.application;

import com.backend.gpms.features.storage.domain.ThuVienDeTai;
import com.backend.gpms.features.storage.dto.response.ThuVienDeTaiResponse;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;

public interface StorageService {
    String upload(MultipartFile file);
    String upload(File file);

    void delete(String publicId);

    String uploadRawFile(MultipartFile file);

    record UploadResult(String publicId, String url, String resourceType, long bytes) {}

    List<ThuVienDeTaiResponse> getTatCaThuVienDeTai();

}
