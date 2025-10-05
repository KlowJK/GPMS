package com.backend.gpms.features.lecturer.application;

import com.backend.gpms.common.mapper.GiangVienMapper;
import com.backend.gpms.features.department.infra.BoMonRepository;
import com.backend.gpms.features.department.infra.LopRepository;
import com.backend.gpms.features.department.infra.NganhRepository;
import com.backend.gpms.features.lecturer.dto.response.GiangVienLookupResponse;
import com.backend.gpms.features.lecturer.infra.GiangVienRepository;
import com.backend.gpms.features.topic.infra.DeTaiRepository;

import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@Transactional
@AllArgsConstructor
public class GiangVienLookupService {
    private final GiangVienMapper mapper;
    private final LopRepository lopRepo;
    private final NganhRepository nganhRepo;
    private final BoMonRepository boMonRepo;
    private final GiangVienRepository giangVienRepo;
    private final DeTaiRepository deTaiRepo;

    public GiangVienLookupResponse lookupByLopId(Long lopId) {
        return mapper.fromLopId(lopId, lopRepo, nganhRepo, boMonRepo, giangVienRepo, deTaiRepo);
    }
}

