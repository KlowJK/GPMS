
package com.backend.gpms.features.storage.application;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;

import java.io.IOException;
import java.util.Map;
@Service
@RequiredArgsConstructor
public class CloudinaryStorageService implements StorageService {

    private final Cloudinary cloudinary;

    @Value("${cloudinary.folder:gpms/dev}")
    private String defaultFolder;

    @Override
    public UploadResult upload(MultipartFile file, String folder, String publicIdHint) {
        try {
            String ext = FilenameUtils.getExtension(file.getOriginalFilename());
            String baseName = FilenameUtils.getBaseName(file.getOriginalFilename());
            String safeBase = baseName.replaceAll("[^a-zA-Z0-9_-]+","-");
            String publicId = (publicIdHint != null && !publicIdHint.isBlank())
                    ? publicIdHint
                    : (safeBase + "-" + System.currentTimeMillis());

            Map<String, Object> params = ObjectUtils.asMap(
                    "folder", (folder == null || folder.isBlank()) ? defaultFolder : folder,
                    "public_id", publicId,
                    "resource_type", "auto",
                    "use_filename", true,
                    "unique_filename", false,
                    "overwrite", true
            );

            var res = cloudinary.uploader().upload(file.getBytes(), params);
            return new UploadResult(
                    (String) res.get("public_id"),
                    (String) res.get("secure_url"),
                    (String) res.get("resource_type"),
                    ((Number) res.get("bytes")).longValue()
            );
        } catch (IOException e) {
            throw new RuntimeException("Upload Cloudinary thất bại", e);
        }
    }

    @Override
    public void delete(String publicId) {
        try {
            cloudinary.uploader().destroy(publicId, ObjectUtils.asMap("resource_type", "auto"));
        } catch (IOException e) {
            throw new RuntimeException("Xoá Cloudinary thất bại", e);
        }
    }
}
