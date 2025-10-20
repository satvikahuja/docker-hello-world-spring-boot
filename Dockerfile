# ---- build stage ----
FROM maven:3.8.5-openjdk-11 AS maven_build
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn -B -ntp -DskipTests dependency:go-offline

# Build sources
COPY src ./src
RUN mvn -B -ntp -DskipTests package

# ---- runtime stage ----
FROM eclipse-temurin:11
WORKDIR /data

# Copy *whatever* jar Maven built and give it a stable name
COPY --from=maven_build /app/target/*.jar /data/app.jar

EXPOSE 8080
CMD ["java", "-jar", "/data/app.jar"]
