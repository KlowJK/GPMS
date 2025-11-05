package com.backend.gpms.features.lecturer.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;

import java.time.LocalDate;

@Builder
@Data
@AllArgsConstructor
@NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class GiangVienInfoResponse {
    Long id;
    String maGV;
    String hoTen;
    String hocVi;
    String hocHam;
    LocalDate ngaySinh;
    String email;
    String soDienThoai;
    int soLuongDeTai;
    int soLuongChoPhepHuongDan;

}