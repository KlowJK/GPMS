package com.backend.gpms.features.notification.api;

import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.notification.application.ThongBaoService;
import com.backend.gpms.features.notification.domain.LoaiThongBao;
import com.backend.gpms.features.notification.dto.request.ThongBaoRequest;
import com.backend.gpms.features.notification.dto.response.ThongBaoResponse;
import com.backend.gpms.features.outline.domain.TrangThaiDeCuong;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.springdoc.core.annotations.ParameterObject;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.MediaType;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Tag(name = "ThongBao")
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
public class ThongBaoController {

    ThongBaoService thongBaoService;

    @Operation(summary = "Lấy danh sách thông báo có phân trang - chỉ trợ lý khoa và quản trị viên mới được phép truy cập")
    @GetMapping("/thong-bao/page")
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA','ROLE_QUAN_TRI_VIEN')")
    public ApiResponse<Page<ThongBaoResponse>> getAllThongBao(
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "updatedAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ){
        return ApiResponse.success(thongBaoService.getAllThongBao(pageable));
    }
    @GetMapping("/public/thong-bao/list")
    public ApiResponse<List<ThongBaoResponse>> getAllThongBaoList(){
        return ApiResponse.success(thongBaoService.getAllThongBaoList());
    }

    @GetMapping("/thong-bao/list-by-user")
    public ApiResponse<List<ThongBaoResponse>> getAllThongBaoListByUser(){
        return ApiResponse.success(thongBaoService.getAllThongBaoListByUser());
    }
    @Operation(summary = "Tạo thông báo - chỉ trợ lý khoa và quản trị viên mới được phép truy cập")
    @PostMapping(value = ("/thong-bao"), consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyAuthority('ROLE_TRO_LY_KHOA','ROLE_QUAN_TRI_VIEN')")
    public ApiResponse<ThongBaoResponse> createThongBao(
            @RequestParam(value = "file", required = false) MultipartFile file,
            @RequestParam("tieuDe") String tieuDe,
            @RequestParam("noiDung") String noiDung,
            @RequestParam(value = "kieuNguoiNhan", defaultValue = "0", required = false) Long kieuNguoiNhan
    ) {
        // Xác định loaiThongBao dựa trên kieuNguoiNhan
        String loaiThongBao = kieuNguoiNhan == 0 ? LoaiThongBao.TRUONG.name() : LoaiThongBao.KHOA.name();

        // Tạo ThongBaoRequest
        ThongBaoRequest request = ThongBaoRequest.builder()
                .tieuDe(tieuDe)
                .noiDung(noiDung)
                .loaiThongBao(loaiThongBao)
                .kieuNguoiNhan(kieuNguoiNhan)
                .file(file)
                .build();

        // Gọi service để xử lý
        return ApiResponse.success(thongBaoService.createThongBao(request));
    }

    @GetMapping("/public/thong-bao/{thongBaoId}")
    public ApiResponse<ThongBaoResponse> getThongBaoById(@PathVariable Long thongBaoId){
        return ApiResponse.success(thongBaoService.getThongBaoById(thongBaoId));
    }

}