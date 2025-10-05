package com.backend.gpms.features.defense.application;


import com.backend.gpms.common.exception.ApplicationException;
import com.backend.gpms.common.exception.ErrorCode;
import com.backend.gpms.common.mapper.DotBaoVeMapper;
import com.backend.gpms.features.defense.domain.DotBaoVe;
import com.backend.gpms.features.defense.dto.request.AddSinhVienToDotBaoVeRequest;
import com.backend.gpms.features.defense.dto.request.DotBaoVeRequest;
import com.backend.gpms.features.defense.dto.response.AddSinhVienToDotBaoVeResponse;
import com.backend.gpms.features.defense.dto.response.DotBaoVeResponse;
import com.backend.gpms.features.defense.infra.DotBaoVeRepository;
import com.backend.gpms.features.storage.application.StorageService;
import com.backend.gpms.features.topic.domain.DeTai;
import com.backend.gpms.features.topic.domain.TrangThaiDeTai;
import com.backend.gpms.features.topic.infra.DeTaiRepository;
import jakarta.transaction.Transactional;
import lombok.AccessLevel;
import lombok.RequiredArgsConstructor;
import lombok.experimental.FieldDefaults;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@FieldDefaults(makeFinal = true, level = AccessLevel.PRIVATE)
@RequiredArgsConstructor
@Transactional
public class DotBaoVeService {

    DotBaoVeRepository dotBaoVeRepository;
    DotBaoVeMapper dotBaoVeMapper;
    DeTaiRepository deTaiRepository;
    StorageService cloudinaryService;


    public DotBaoVeResponse createDotBaoVe(DotBaoVeRequest request) {

        validateDotBaoVeTime(request);
        return dotBaoVeMapper.toDotBaoVeResponse(dotBaoVeRepository.save(dotBaoVeMapper.toDotBaoVe(request)));

    }

    public DotBaoVeResponse updateDotBaoVe(DotBaoVeRequest request, Long dotBaoVeId) {
        DotBaoVe dotBaoVe = dotBaoVeRepository.findById(dotBaoVeId)
                .orElseThrow(() -> new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND));
        if(dotBaoVeRepository.existsByTenDotAndIdNot(request.getTenDotBaoVe(), dotBaoVeId)){
            throw new ApplicationException(ErrorCode.DUPLICATED_DOT_BAO_VE);
        }
        if (request.getThoiGianBatDau().isAfter(request.getThoiGianKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
        dotBaoVeMapper.updateDotBaoVeFromDto(request, dotBaoVe);
        return dotBaoVeMapper.toDotBaoVeResponse(dotBaoVeRepository.save(dotBaoVe));
    }

    private void validateDotBaoVeTime(DotBaoVeRequest request) {
        if(dotBaoVeRepository.existsByTenDot(request.getTenDotBaoVe())) {
            throw new ApplicationException(ErrorCode.DUPLICATED_DOT_BAO_VE);
        }
        if (request.getThoiGianBatDau().isAfter(request.getThoiGianKetThuc())) {
            throw new ApplicationException(ErrorCode.INVALID_TIME_RANGE);
        }
    }


    public void deleteDotBaoVe(Long id) {

        dotBaoVeRepository.deleteById(id);

    }


    public Page<DotBaoVeResponse> findAllDotBaoVe(Pageable pageable) {
        Page<DotBaoVe> page = dotBaoVeRepository.findAll(pageable);
        return page.map(dotBaoVeMapper::toDotBaoVeResponse);
    }


    public AddSinhVienToDotBaoVeResponse addSinhVienToDotBaoVe(AddSinhVienToDotBaoVeRequest request) throws IOException {
        List<AddSinhVienToDotBaoVeResponse.FailureItem> failures = new ArrayList<>();
        int success = 0;

        try (InputStream is = request.getDataFile().getInputStream();
             Workbook workbook = new XSSFWorkbook(is)) {

            Sheet sheet = workbook.getSheetAt(0);

            // Tìm đợt bảo vệ
            DotBaoVe dotBaoVe = dotBaoVeRepository.findByHocKiAndNamHoc(
                    request.getHocKi(), request.getNamHoc()
            ).orElseThrow(() -> new ApplicationException(ErrorCode.DOT_BAO_VE_NOT_FOUND));

            // Duyệt từng dòng (bỏ dòng header = row 0)
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                DataFormatter formatter = new DataFormatter();
                String maSinhVien = formatter.formatCellValue(row.getCell(0)).trim();
                String tenDeTai = formatter.formatCellValue(row.getCell(1)).trim();

                Optional<DeTai> deTaiOpt = deTaiRepository.findByTenDeTaiIgnoreCaseAndSinhVien_MaSinhVienIgnoreCase(tenDeTai, maSinhVien);

                if (deTaiOpt.isPresent()) {
                    DeTai deTai = deTaiOpt.get();
                    if(deTai.getDotBaoVe() != null) {
                        failures.add(AddSinhVienToDotBaoVeResponse.FailureItem.builder()
                                .maSinhVien(maSinhVien)
                                .tenDeTai(tenDeTai)
                                .reason("Đề tài đã có trong đợt bảo vệ khác")
                                .build());
                        continue;
                    }
                    if(deTai.getTrangThai() != TrangThaiDeTai.DA_DUYET){
                        failures.add(AddSinhVienToDotBaoVeResponse.FailureItem.builder()
                                .maSinhVien(maSinhVien)
                                .tenDeTai(tenDeTai)
                                .reason("Đề tài chưa được duyệt")
                                .build());
                        continue;
                    }
                    deTai.setDotBaoVe(dotBaoVe);
                    deTaiRepository.save(deTai);
                    success++;
                } else {
                    failures.add(AddSinhVienToDotBaoVeResponse.FailureItem.builder()
                            .maSinhVien(maSinhVien)
                            .tenDeTai(tenDeTai)
                            .reason("Không tìm thấy đề tài hoặc sinh viên")
                            .build());
                }
            }

        } catch (IOException e) {
            throw new RuntimeException("Lỗi đọc file Excel", e);
        }

        String logFileUrl = null;
        if (!failures.isEmpty()) {
            try {
                File logFile = generateFailureLogExcel(failures);
                logFileUrl = cloudinaryService.upload(logFile);
            } catch (IOException e) {
                throw new RuntimeException("Không thể tạo hoặc upload file log Excel", e);
            }
        }

        return AddSinhVienToDotBaoVeResponse.builder()
                .totalRecords(success + failures.size())
                .successCount(success)
                .failureCount(failures.size())
                .failureItems(failures)
                .logFileUrl(logFileUrl)
                .build();
    }

    private File generateFailureLogExcel(List<AddSinhVienToDotBaoVeResponse.FailureItem> failures) throws IOException {
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Failures");

        // Header
        Row headerRow = sheet.createRow(0);
        headerRow.createCell(0).setCellValue("Mã Sinh Viên");
        headerRow.createCell(1).setCellValue("Tên Đề Tài");
        headerRow.createCell(2).setCellValue("Lý Do");

        // Data
        int rowIdx = 1;
        for (AddSinhVienToDotBaoVeResponse.FailureItem item : failures) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(item.getMaSinhVien());
            row.createCell(1).setCellValue(item.getTenDeTai());
            row.createCell(2).setCellValue(item.getReason());
        }

        // Tạo file tạm
        File tempFile = File.createTempFile("import-failures", ".xlsx");
        try (FileOutputStream fos = new FileOutputStream(tempFile)) {
            workbook.write(fos);
        }
        workbook.close();

        return tempFile;
    }
}

