# ---------- Build stage ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# CÀI dos2unix ĐỂ FIX CRLF
RUN apt-get update && apt-get install -y dos2unix && rm -rf /var/lib/apt/lists/*

# Copy Maven wrapper
COPY mvnw ./
COPY .mvn .mvn
COPY pom.xml ./

# DEBUG + FIX LINE ENDING + RUN
RUN echo "=== FILES IN /app ===" && ls -la && \
    echo "=== FIRST LINE OF mvnw (raw) ===" && head -c 20 mvnw | cat -v && \
    echo "=== FIX LINE ENDING ===" && \
    dos2unix mvnw && \
    chmod +x mvnw && \
    echo "=== RUN MAVEN ===" && \
    ./mvnw -q -DskipTests dependency:go-offline

# Copy source và build
COPY src src
RUN ./mvnw -q -DskipTests package

# ---------- Run stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app

RUN useradd -m spring

COPY --from=build /app/target/*.jar app.jar

RUN mkdir -p /app/config && chown -R spring:spring /app
USER spring

EXPOSE 8080

ENV SPRING_CONFIG_IMPORT=optional:file:/app/config/secret.yml \
    SPRING_PROFILES_ACTIVE=prod \
    JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]