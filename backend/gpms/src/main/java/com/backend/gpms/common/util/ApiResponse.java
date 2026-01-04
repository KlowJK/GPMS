package com.backend.gpms.common.util;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.*;
import lombok.experimental.FieldDefaults;
@Data
@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
@FieldDefaults(level = AccessLevel.PRIVATE)
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {
    T result;
    String message;
    int code;

    public static <T> ApiResponse<T> success(T result) {
        ApiResponse<T> resp = new ApiResponse<>();
        resp.setResult(result);
        resp.setCode(200);
        resp.setMessage("Success");
        return resp;
    }
}