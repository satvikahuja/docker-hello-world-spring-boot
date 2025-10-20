# ---- build stage ----
FROM maven:3.8.5-openjdk-11 AS maven_build
WORKDIR /tmp

# copy sources
COPY pom.xml /tmp/
COPY src /tmp/src/

# build the fat jar (skip tests to speed CI) and normalize name -> /tmp/app.jar
RUN mvn -DskipTests package && \
    JAR="$(ls target/*.jar | grep -v 'original' | head -n1)" && \
    cp "$JAR" /tmp/app.jar

# ---- runtime stage ----
# smaller, stable JRE image
FROM eclipse-temurin:11-jre-jammy
WORKDIR /data

# copy the normalized jar
COPY --from=maven_build /tmp/app.jar /data/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/data/app.jar"]
