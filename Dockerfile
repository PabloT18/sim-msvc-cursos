
FROM eclipse-temurin:17 as builder


WORKDIR /workspace/app

COPY . /workspace/app
RUN --mount=type=cache,target=/root/.gradle ./gradlew clean build -x test
RUN mkdir -p build/dependency && (cd build/dependency; jar -xf ../libs/*-SNAPSHOT.jar)

FROM eclipse-temurin:17
VOLUME /tmp
ARG DEPENDENCY=/workspace/app/build/dependency


COPY --from=builder ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=builder ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=builder ${DEPENDENCY}/BOOT-INF/classes /app
ENV PORT 8080
ENV TZ=EC
EXPOSE $PORT
ENTRYPOINT java -cp app:app/lib/* ec.edu.ups.msvccursos.Main
