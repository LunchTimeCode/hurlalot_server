FROM alpine:3.18 AS builder
ARG TARGETPLATFORM
WORKDIR /tmp/hurl-docker
COPY . /tmp/hurl-docker
RUN apk add --no-cache bash git && \
    bash -c "./bin/install_prerequisites_alpine.sh" && \
    bash -c "./bin/install_rust.sh" && \
    bash -c "./bin/release.sh"
FROM alpine:3.18 AS runner
COPY --from=builder /tmp/hurl-docker/target/release/hurlalot_server /usr/bin/
ENV ROCKET_ADDRESS=0.0.0.0
EXPOSE 3721
CMD ["/usr/bin/hurlalot_server"]