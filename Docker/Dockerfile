FROM --platform=linux/amd64 public.ecr.aws/ubuntu/ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ="Pacific/Auckland"

RUN apt update -y && \
    apt install -y bash curl wget python3 python3-pip unzip vim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/gputest

WORKDIR /opt/gputest

COPY testgpu.py /opt/gputest/

RUN python3 -m pip install --upgrade pip \
    && pip install torch

ENTRYPOINT ["python3", "testgpu.py"]
# CMD ["bash", "-c", "trap : TERM INT; sleep infinity & wait"]
