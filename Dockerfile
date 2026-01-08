FROM swift:6.1 as builder
WORKDIR /app
COPY . .
RUN swift build -c release
# aarch64-unknown-linux-gnu for raspberry pi
# x86_64-unknown-linux-gnu for intel based architectures
RUN mkdir output
RUN cp $(swift build --show-bin-path -c release)/HttpFileStorage output/App
RUN strip -s output/App

FROM swift:6.1-slim
RUN apt-get update -y
RUN apt-get install -y file
WORKDIR /app
COPY --from=builder /app/output/App .
CMD ["./App", "workingDir=/local-storage", "port=80"]
