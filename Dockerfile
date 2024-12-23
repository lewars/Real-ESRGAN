FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# System dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set non-root user environment variables
ENV HOME=/home/realgan
ENV PATH=$HOME/.local/bin:$PATH
WORKDIR $HOME

# Install PyTorch with CUDA support
RUN pip install --no-cache-dir torch torchvision torchaudio

# Copy local repository
COPY . $HOME/Real-ESRGAN
WORKDIR $HOME/Real-ESRGAN

# Install Python dependencies
RUN pip install --no-cache-dir basicsr facexlib gfpgan
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -e .

# Set read-only filesystem except for necessary paths
VOLUME ["/tmp", "$HOME/input", "$HOME/output"]

# Container metadata
LABEL maintainer="Alistair Y. Lewars"
LABEL description="Real-ESRGAN Image Processing with GPU Support"
LABEL seccomp="seccomp-profile.json"
LABEL selinux="container_file_t"

# Run as non-root user
USER 1000:1000

ENTRYPOINT ["python3", "inference_realesrgan.py"]