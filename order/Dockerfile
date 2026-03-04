FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY target/order.jar order.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "order.jar"]