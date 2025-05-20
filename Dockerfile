#FROM nvidia/cuda:12.6.0-devel-ubuntu22.04
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04
# Set user/group IDs to match host user (default 1000 for first user)
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    VIRTUAL_ENV=/app/venv \
    PATH="/app/venv/bin:$PATH" \
    USER=appuser

# Create system user and group
RUN groupadd -g $GID appuser && \
    useradd -u $UID -g $GID -m -s /bin/bash appuser

# Install dependencies as root first
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    apt-utils \
    python3.10 \
    python3.10-venv \
    python3.10-dev \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    ninja-build \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && echo "appuser ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers

# Create and configure directories before switching user
RUN mkdir -p /app && \
    chown -R $UID:$GID /app
    
# Switch to non-root user
USER $UID:$GID

# Clone repository
RUN git clone https://github.com/lllyasviel/FramePack.git /app
WORKDIR /app

# Create virtual environment as user
RUN python3.10 -m venv $VIRTUAL_ENV

# Install Python dependencies
RUN pip install --no-cache-dir \
    torch==2.6.0 \
    torchvision \
    torchaudio \
    --index-url https://download.pytorch.org/whl/cu126

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir triton sageattention

EXPOSE 7860

CMD ["python", "demo_gradio.py", "--share"]
