
FROM gcc:latest AS build

WORKDIR /app

COPY expo.c .

RUN gcc -static -o expo expo.c -lm

FROM scratch

COPY --from=build /app/expo /expo

ENTRYPOINT ["/app/expo"]
