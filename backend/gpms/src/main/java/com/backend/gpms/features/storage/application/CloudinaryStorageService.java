package com.backend.gpms.features.storage.application;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.Random;

@Service
@RequiredArgsConstructor
@Transactional
public class CloudinaryStorageService implements StorageService {

    private final Cloudinary cloudinary;

    @Value("${cloudinary.folder:gpms}")
    private String defaultFolder;

    @Override
    public String upload(MultipartFile file) {
        try {
            String originalFilename = FilenameUtils.getBaseName(file.getOriginalFilename());
            String safePublicId = originalFilename.replaceAll("[^a-zA-Z0-9_-]+", "-");
            String randomString = RandomStringUtils.randomAlphanumeric(5);
            String prefixedPublicId = "TLU_" + randomString + "_" + safePublicId;

            Map<String, Object> params = ObjectUtils.asMap(
                    "resource_type", "auto", // Tự động nhận diện PDF, hình ảnh, v.v.
                    "folder", defaultFolder,
                    "public_id", prefixedPublicId,
                    "use_filename", true,
                    "unique_filename", false,
                    "overwrite", true
            );

            Map<?, ?> res = cloudinary.uploader().upload(file.getBytes(), params);
            String secureUrl = (String) res.get("secure_url");

            // Nếu là PDF, thêm transformation f_pdf để xem trực tiếp
            String extension = FilenameUtils.getExtension(file.getOriginalFilename()).toLowerCase();
            if ("pdf".equals(extension)) {
                secureUrl = secureUrl.replace("/image/upload/", "/image/upload/f_pdf/");
            }

            return secureUrl;
        } catch (Exception e) {
            throw new RuntimeException("Cloudinary upload failed: " + e.getMessage(), e);
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

    @Override
    public String upload(File file) {
        try {
            Map result = cloudinary.uploader().upload(file, Map.of("resource_type", "raw"));
            return result.get("secure_url").toString();
        } catch (IOException e) {
            throw new RuntimeException("Upload File thất bại", e);
        }
    }
    @Override
    public String uploadRawFile(MultipartFile file) {
        try {
            Map result = cloudinary.uploader().upload(file.getBytes(), Map.of("resource_type", "raw"));
            return result.get("secure_url").toString();
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private String generateRandomString(int length) {
        String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        Random random = new Random();
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(characters.charAt(random.nextInt(characters.length())));
        }
        return sb.toString();
    }
}
