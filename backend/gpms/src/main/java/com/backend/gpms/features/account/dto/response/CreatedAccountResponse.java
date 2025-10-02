package com.backend.gpms.features.account.dto.response;

import lombok.*;


@Getter
@Setter
@AllArgsConstructor
@Builder
@NoArgsConstructor
public class CreatedAccountResponse
{
    Long idTaiKhoan;
    String email;
    String vaiTro;
    Long idProfile;
    String hoTen;
}
