FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    jq \
    wget \
    unzip \
    ripgrep \
    fd-find \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Rename existing ubuntu user to gaz, fix home dir
RUN usermod -l gaz -d /home/gaz -m ubuntu \
    && groupmod -n gaz ubuntu \
    && echo "gaz ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gaz
USER gaz
WORKDIR /home/gaz
