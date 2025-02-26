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
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    tar \
    fzf \
    gcc \
    fd-find \
    ripgrep \
    xclip \
    python3 \
    python3-pip \
    python3-pynvim \
    luarocks \
    libmsgpack-dev \
    unzip \
    gettext \
    xauth \
    fontconfig \
    locales \
    imagemagick \
    ghostscript \
    fish \
    sqlite3 \
    libsqlite3-dev


# Create symbolic link for fd
RUN ln -s $(which fdfind) /usr/local/bin/fd

# Set up locale
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
RUN apt-get update
RUN apt-get install -y nodejs
RUN npm install -g npm@latest
RUN npm install -g tree-sitter-cli
RUN npm install -g neovim
RUN npm install -g @mermaid-js/mermaid-cli

# Download and install Neovim
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      export NVIM_ARCH="arm64"; \
    else \
      export NVIM_ARCH="x86_64"; \
    fi && \
    wget -q https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz && \
    tar -zxf nvim-linux-${NVIM_ARCH}.tar.gz && \
    cp -r nvim-linux-${NVIM_ARCH}/bin/nvim /usr/bin/ && \
    cp -r nvim-linux-${NVIM_ARCH}/lib/nvim /usr/lib/ && \
    cp -r nvim-linux-${NVIM_ARCH}/share/nvim /usr/share/ && \
    rm -rf nvim-linux-${NVIM_ARCH}.tar.gz nvim-linux-${NVIM_ARCH}

# Download and install Lazygit
RUN if [ "$TARGETARCH" = "arm64" ]; then \
      export LG_ARCH="arm64"; \
    else \
      export LG_ARCH="x86_64"; \
    fi && \
    export LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    mv lazygit /usr/local/bin/ && \
    rm lazygit.tar.gz

# Install LazyVim
RUN mkdir -p /root/.config/nvim
RUN git clone --depth 1 https://github.com/LazyVim/starter /root/.config/nvim
RUN rm -rf /root/.config/nvim/.git

# Clean up unnecessary files to reduce image size
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/*
RUN rm -rf ~/.cache

# Set default command
CMD ["bash"]

# Add metadata
LABEL description="Optimized Neovim ${NVIM_VERSION} with Node.js ${NODE_VERSION} and LazyVim"

# Use:
# - docker build -t nvim-node:0.10.4-node20 .
# - d
# - docker exec -it <name> bash