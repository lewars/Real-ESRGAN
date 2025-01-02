FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

RUN curl -s -L https://nvidia.github.io/libnvidia-container/stable/ubuntu22.04/nvidia-container-toolkit.list | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
    apt-key adv --fetch-keys https://nvidia.github.io/nvidia-container-runtime/gpgkey && \
    apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    python3 \
    python3-pip \
    libgl1-mesa-glx \
    libegl1-mesa \
    libgles2-mesa \
    libglib2.0-0 \
    nvidia-container-toolkit \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --no-cache-dir --upgrade pip

ENV HOME=/home/realgan \
    PATH=/home/realgan/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR $HOME/Real-ESRGAN

COPY --chown=1000:1000 . .
RUN mkdir -p weights && \
    mkdir -p ../output && \
    chown -R 1000:1000 $HOME

USER 1000:1000
RUN pip3 install --no-cache-dir --user torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 && \
    pip install --no-cache-dir --user -r requirements.txt && \
    pip install --no-cache-dir --user -e .

VOLUME ["/tmp", "$HOME/input", "$HOME/output"]
LABEL maintainer="Alistair Y. Lewars" \
      description="Real-ESRGAN Image Processing with GPU Support" \
      seccomp="seccomp-profile.json" \
      selinux="container_file_t"

ENTRYPOINT ["python3", "inference_realesrgan.py"]
