FROM ubuntu:24.04

# Set build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Taipei
ARG NODE_VERSION=20
ARG NVIM_VERSION=0.10.4

# Set environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=${TZ}

# Install base system packages
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    tar \
    unzip \
    vim \
    fzf \
    gcc \
    fd-find \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && apt-get install -y \
    nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*

# Install Neovim
RUN wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-x86_64.tar.gz && \
    tar -zxvf nvim-linux-x86_64.tar.gz && \
    cp -r nvim-linux-x86_64/bin/nvim /usr/bin/ && \
    cp -r nvim-linux-x86_64/lib/nvim /usr/lib/ && \
    cp -r nvim-linux-x86_64/share/nvim /usr/share/ && \
    rm -rf nvim-linux-x86_64.tar.gz nvim-linux-x86_64

# Install Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    mv lazygit /usr/local/bin/ && \
    rm lazygit.tar.gz

# Setup LazyVim
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim

# Add metadata
LABEL description="Neovim ${NVIM_VERSION} with Node.js ${NODE_VERSION} development environment" \
      version="1.0"