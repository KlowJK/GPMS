package com.backend.gpms.features.outline.dto.response;


import com.backend.gpms.features.outline.domain.NhanXetDeCuong;
import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
@Getter @Setter
public class DeCuongResponse {

    Long id;//
    String deCuongUrl;//
    TrangThaiDeCuong trangThaiDeCuong;//
    Integer phienBan;//
    String tenDeTai;//
    String maSinhVien;//
    String hoTenSinhVien;//
    String giangVienHuongDan;//

    String giangVienPhanBien;//
    String gvPhanBienDuyet;//
    String truongBoMon;//
    String tbmDuyet;//

    List<NhanXetDeCuongResponse> nhanXets;
    LocalDateTime createdAt;

    // DTO lồng
    public static class NhanXetDeCuongResponse {
        private String nhanXet;
        private String hoTenGiangVien;
        private LocalDateTime createdAt;

        // Getters và Setters
        public String getNhanXet() { return nhanXet; }
        public void setNhanXet(String nhanXet) { this.nhanXet = nhanXet; }
        public String getHoTenGiangVien() { return hoTenGiangVien; }
        public void setHoTenGiangVien(String hoTenGiangVien) { this.hoTenGiangVien = hoTenGiangVien; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    }
}
