# ---- build stage ----
FROM maven:3.8.5-openjdk-11 AS maven_build
WORKDIR /tmp

# copy sources
COPY pom.xml /tmp/
COPY src /tmp/src/

# build the fat jar
RUN mvn package

# ---- runtime stage ----
# use a stable, smaller JRE image (avoids flaky "manifests 11" pulls)
FROM eclipse-temurin:11-jre-jammy
WORKDIR /data

# copy the built jar from the builder stage
COPY --from=maven_build /tmp/target/hello-world-0.1.0.jar /data/hello-world-0.1.0.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/data/hello-world-0.1.0.jar"]
