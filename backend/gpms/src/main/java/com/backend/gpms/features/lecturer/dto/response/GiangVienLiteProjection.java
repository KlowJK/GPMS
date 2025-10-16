package com.backend.gpms.features.lecturer.dto.response;

public interface GiangVienLiteProjection {
    Long getId();
    String getHoTen();
    Long getBoMonId();
    Integer getQuotaInstruct();
    Long getCurrentInstruct();
    Integer getRemaining();
}
