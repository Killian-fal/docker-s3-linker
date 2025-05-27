FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ARG AWS_CLI_ARCH_SUFFIX=x86_64

RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
        unzip \
        less \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo "Downloading AWS CLI v2 for ${AWS_CLI_ARCH_SUFFIX}" && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_CLI_ARCH_SUFFIX}.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws


WORKDIR /app

COPY script.sh .
RUN chmod +x script.sh

CMD ["./script.sh"]
