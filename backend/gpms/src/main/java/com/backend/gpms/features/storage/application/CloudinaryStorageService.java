package com.backend.gpms.features.storage.application;

import com.backend.gpms.features.storage.domain.ThuVienDeCuong;
import com.backend.gpms.features.storage.domain.ThuVienDeTai;
import com.backend.gpms.features.storage.dto.response.ThuVienDeTaiResponse;
import com.backend.gpms.features.storage.infra.ThuVienDeTaiRepository;
import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import org.apache.commons.io.FilenameUtils;
import org.springframework.beans.factory.annotation.Value;
import com.backend.gpms.features.storage.infra.ThuVienDeCuongRepository;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;

@FieldDefaults( level = AccessLevel.PRIVATE)
@Service
@RequiredArgsConstructor
@Transactional
public class CloudinaryStorageService implements StorageService {

    final Cloudinary cloudinary;
    final ThuVienDeTaiRepository thuVienDeTaiRepository;
    final ThuVienDeCuongRepository thuVienDeCuongRepository;

    @Value("${cloudinary.folder:gpms}")
    String defaultFolder;

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

    public List<ThuVienDeTaiResponse> getTatCaThuVienDeTai() {
        List<ThuVienDeTai> thuVienDeTais = thuVienDeTaiRepository.findAllByOrderByIdDesc();

        return thuVienDeTais.stream()
                .map(this::mapToResponse)
                .collect(Collectors.toList());
    }

    ThuVienDeTaiResponse mapToResponse(ThuVienDeTai thuVienDeTai) {
        List<ThuVienDeCuong> deCuongs = thuVienDeCuongRepository.findByThuVienDeTai(thuVienDeTai);

        List<ThuVienDeTaiResponse.DeCuongCuaDeTai> deCuongResponses = deCuongs.stream()
                .map(dc -> ThuVienDeTaiResponse.DeCuongCuaDeTai.builder()
                        .id(dc.getId())
                        .duongDan(dc.getDuongDan())
                        .phienBan(dc.getPhienBan())
                        .build())
                .collect(Collectors.toList());

        String namHoc = null;
        String hocKy = null;
        if (thuVienDeTai.getDotBaoVe() != null) {
            namHoc = thuVienDeTai.getDotBaoVe().getNamHoc();
            hocKy = thuVienDeTai.getDotBaoVe().getHocKi(); // map hocKi -> hocKy in response
        }

        return ThuVienDeTaiResponse.builder()
                .id(thuVienDeTai.getId())
                .deTai(thuVienDeTai.getDeTai())
                .duongDan(thuVienDeTai.getDuongDan())
                .idDotBaoVe(thuVienDeTai.getDotBaoVe() != null ? thuVienDeTai.getDotBaoVe().getId() : null)
                .namHoc(namHoc)
                .hocKy(hocKy)
                .deCuongCuaDeTai(deCuongResponses)
                .build();
    }
}
