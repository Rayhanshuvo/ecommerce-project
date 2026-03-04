FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY target/notification.jar notification.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "notification.jar"]