package com.backend.gpms.common.mapper;

import org.mapstruct.Mapper;

@Mapper(    componentModel = "spring",
           unmappedTargetPolicy = org.mapstruct.ReportingPolicy.IGNORE
)
public interface AuthMapper {
}
