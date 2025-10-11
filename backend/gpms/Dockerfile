# ---------- Build stage ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copy Maven wrapper & config để tận dụng cache
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./

# Tải dependencies để cache
RUN chmod +x mvnw && ./mvnw -q -DskipTests dependency:go-offline

# Copy source và build
COPY src src
RUN ./mvnw -q -DskipTests package

# ---------- Run stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

# Tạo user non-root
RUN useradd -m spring

# Copy jar đã build
COPY --from=build /app/target/*.jar app.jar

# Thư mục mount secret.yml (tùy chọn)
RUN mkdir -p /app/config && chown -R spring:spring /app
USER spring

EXPOSE 8080

# Các biến mặc định; có thể override trong docker-compose/.env
ENV SPRING_CONFIG_IMPORT=optional:file:/app/config/secret.yml \
    SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]