package com.backend.gpms.common.exception;

import com.backend.gpms.common.util.ApiResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(value = ApplicationException.class)
    public ResponseEntity<ApiResponse<?>> applicationException(final ApplicationException e) {

        ApiResponse<?> apiResponse = new ApiResponse<>();
        ErrorCode errorCode = e.getErrorCode();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity
                .status(errorCode.getHttpStatusCode())
                .body(apiResponse);

    }

    @ExceptionHandler(value = AccessDeniedException.class)
    public ResponseEntity<ApiResponse<?>> accessDeniedException(final AccessDeniedException e) {

        ApiResponse<?> apiResponse = new ApiResponse<>();
        ErrorCode errorCode = ErrorCode.FORBIDDEN;
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity
                .status(errorCode.getHttpStatusCode())
                .body(apiResponse);

    }

    @ExceptionHandler(value = MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<?>> handleMethodArgumentNotValidException(MethodArgumentNotValidException e) {

        ApiResponse<?> response = new ApiResponse<>();
        ErrorCode errorCode = null;
        BindingResult bindingResult = e.getBindingResult();
        String message;

        // class validation will be applied as global error
        if (!bindingResult.getFieldErrors().isEmpty()) {
            message = bindingResult.getFieldErrors().get(0).getDefaultMessage();
        }else {
            message = e.getGlobalErrors().get(0).getDefaultMessage();
        }

        try {
            errorCode = ErrorCode.valueOf(message);
        }catch (Exception ex) {
            errorCode = ErrorCode.INVALID_VALIDATION;
        }

        response.setCode(errorCode.getCode());
        response.setMessage(errorCode.getMessage());
        return ResponseEntity
                .status(errorCode.httpStatusCode)
                .body(response);

    }

}
