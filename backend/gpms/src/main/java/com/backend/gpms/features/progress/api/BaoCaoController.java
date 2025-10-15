package com.backend.gpms.features.progress.api;
import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.util.ApiResponse;
import com.backend.gpms.features.outline.domain.TrangThaiDuyetDon;
import com.backend.gpms.features.progress.application.BaoCaoService;
import com.backend.gpms.features.progress.dto.request.DuyetBaoCaoRequest;
import com.backend.gpms.features.progress.dto.response.BaoCaoResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
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

@Tag(name = "BaoCao")
@RestController
@RequestMapping("/api/bao-cao")
@AllArgsConstructor
public class BaoCaoController {


    private BaoCaoService service;

    @Operation(summary = "Lấy list báo cáo - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @GetMapping("/list-bao-cao")
    public ApiResponse<List<BaoCaoResponse>> getTuanList() {
        return ApiResponse.success(service.getBaoCaoOfSinhVien());
    }


    @Operation(summary = "Nộp báo cáo - Role Sinh Viên")
    @PreAuthorize("hasAuthority('ROLE_SINH_VIEN')")
    @PostMapping(value = "/nop-bao-cao", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<BaoCaoResponse> getNhatKyList(
            @RequestParam(name = "duongDanFile", required = true)
            MultipartFile duongDanFile){
        return ApiResponse.success(service.nopBaoCao(duongDanFile));
    }

    @Operation(summary = "App - Lấy list báo cáo sinh viên của giảng viên hướng dẫn - Role giảng viên, trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA','ROLE_TRUONG_BO_MON')")
    @GetMapping("/list-bao-cao-giang-vien")
    public ApiResponse<List<BaoCaoResponse>> getBaoCaoOfGiangVien(
            @RequestParam(name = "status", required = false) TrangThaiDuyetDon status
          ) {
        return ApiResponse.success(service.getBaoCaoOfGiangVienList(status));
    }

    @Operation(summary = "Web - Lấy page báo cáo sinh viên của giảng viên hướng dẫn - Role giảng viên, trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA','ROLE_TRUONG_BO_MON')")
    @GetMapping("/page-bao-cao-giang-vien")
    public ApiResponse<Page<BaoCaoResponse>> getBaoCaoOfGiangVien(
            @RequestParam(name = "status", required = false) TrangThaiDuyetDon status,
            @ParameterObject
            @PageableDefault(
                    page = 0,
                    size = 10,
                    sort = "createdAt",
                    direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ApiResponse.success(service.getBaoCaoOfGiangVienPage(status,pageable));
    }

    @Operation(summary = "Duyệt báo cáo - Role giảng viên, trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA','ROLE_TRUONG_BO_MON')")
    @PutMapping("/duyet")
    public ApiResponse<BaoCaoResponse> duyetBaoCao(
            @RequestParam(name = "idBaoCao", required = false)
            Long idBaoCao,
            @RequestParam(name = "diemHuongDan", required = false)
            double diemHuongDan,
             @RequestParam(name = "nhanXet", required = false)
                    String nhanXet
            ) {

        DuyetBaoCaoRequest request = new DuyetBaoCaoRequest();
        request.setIdBaoCao(idBaoCao);

        request.setDiemHuongDan(diemHuongDan);
        request.setNhanXet(nhanXet);
        BaoCaoResponse response = service.duyetBaoCao(request);
        return ApiResponse.success(response);
    }

    @Operation(summary = "Từ chối báo cáo - Role giảng viên, trợ lý khoa, trưởng bộ môn")
    @PreAuthorize("hasAnyAuthority('ROLE_GIANG_VIEN','ROLE_TRO_LY_KHOA','ROLE_TRUONG_BO_MON')")
    @PutMapping("/tu-choi")
    public ApiResponse<BaoCaoResponse> tuChoiBaoCao(
            @RequestParam(name = "idBaoCao", required = false)
            Long idBaoCao,
            @RequestParam(name = "nhanXet", required = false)
            String nhanXet
            ) {
        DuyetBaoCaoRequest request = new DuyetBaoCaoRequest();

        // Đồng bộ ID từ path vào request
        request.setIdBaoCao(idBaoCao);
        request.setNhanXet(nhanXet);


        BaoCaoResponse response = service.tuChoiBaoCao(request);
        return ApiResponse.success(response);
    }
}