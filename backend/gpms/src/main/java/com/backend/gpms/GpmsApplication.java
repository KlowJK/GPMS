package com.backend.gpms;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
public class GpmsApplication {

    public static void main(String[] args) {
        SpringApplication.run(GpmsApplication.class, args);
    }

}