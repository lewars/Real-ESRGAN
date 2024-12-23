FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Create non-root user
RUN useradd -m -u 1000 realgan
USER realgan
WORKDIR /home/realgan

# Install system dependencies
USER root
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Switch back to non-root user
USER realgan

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir --user torch torchvision torchaudio

# Copy local repository
COPY --chown=realgan:realgan . /home/realgan/Real-ESRGAN
WORKDIR /home/realgan/Real-ESRGAN

# Install Python dependencies
RUN pip install --no-cache-dir --user basicsr facexlib gfpgan
COPY --chown=realgan:realgan requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt
RUN pip install --no-cache-dir --user -e .

# Set read-only filesystem except for necessary paths
VOLUME ["/tmp", "/home/realgan/input", "/home/realgan/output"]

# Set container metadata
LABEL maintainer="Alistair Y. Lewars"
LABEL description="Real-ESRGAN Image Processing"
LABEL seccomp="profile.json"
LABEL selinux="container_file_t"

ENTRYPOINT ["python3", "inference_realesrgan.py"]
