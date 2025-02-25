FROM ubuntu:24.04

# Set build arguments
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Taipei
ARG NODE_VERSION=20
ARG NVIM_VERSION=0.10.4
ARG TARGETARCH

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
    g++ \
    make \
    cmake \
    pkg-config \
    fd-find \
    ripgrep \
    xclip \
    build-essential \
    python3 \
    python3-pip \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for fd-find to use fd command
RUN mkdir -p ~/.local/bin && \
    ln -s $(which fdfind) ~/.local/bin/fd && \
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
    apt-get update && apt-get install -y \
    nodejs \
    && npm install -g npm@latest \
    && rm -rf /var/lib/apt/lists/*

# Set architecture mapping for binary downloads
RUN if [ "$TARGETARCH" = "amd64" ]; then \
      NVIM_ARCH="x86_64"; \
      LG_ARCH="x86_64"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
      NVIM_ARCH="aarch64"; \
      LG_ARCH="arm64"; \
    else \
      echo "Unsupported architecture: $TARGETARCH"; \
      exit 1; \
    fi && \
    # Install Neovim
    wget https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz && \
    tar -zxvf nvim-linux-${NVIM_ARCH}.tar.gz && \
    cp -r nvim-linux-${NVIM_ARCH}/bin/nvim /usr/bin/ && \
    cp -r nvim-linux-${NVIM_ARCH}/lib/nvim /usr/lib/ && \
    cp -r nvim-linux-${NVIM_ARCH}/share/nvim /usr/share/ && \
    rm -rf nvim-linux-${NVIM_ARCH}.tar.gz nvim-linux-${NVIM_ARCH} && \
    # Install Lazygit
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    mv lazygit /usr/local/bin/ && \
    rm lazygit.tar.gz

# Setup directories and permissions
RUN mkdir -p ~/.local/share/nvim/lazy/nvim-treesitter/parser && \
    mkdir -p ~/.local/state/nvim && \
    chmod -R 755 ~/.local/share/nvim && \
    chmod -R 755 ~/.local/state/nvim

# Setup LazyVim
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim && \
    rm -rf ~/.config/nvim/.git

# Add metadata
LABEL description="Neovim ${NVIM_VERSION} with Node.js ${NODE_VERSION} development environment" \
      version="1.0"