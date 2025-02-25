###############################################################################
# Simplified Neovim + LazyVim Dockerfile (without Perl and Ruby configurations)
# Usage:
# - docker build --progress plain --tag docker.io/myuser/nvim-terminal:latest -f Dockerfile .
# - docker run --rm -it --name nvim-terminal docker.io/myuser/nvim-terminal:latest
###############################################################################
FROM ubuntu:22.04
LABEL description="Terminal Neovim Development Environment with LazyVim"
SHELL ["/bin/bash", "-c", "-e"]

#################################################################################
# Environment Variables

# Set locale to en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
# Disable timezone prompts
ENV TZ=UTC
# Disable package manager prompts
ENV DEBIAN_FRONTEND=noninteractive
# Set PATH
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Set default installation directory
ENV BIN="/usr/local/bin"
# 
# Common Dockerfile Container Build Functions
ENV apt_update="apt-get update"
ENV apt_install="TERM=linux DEBIAN_FRONTEND=noninteractive apt-get install -q --yes --no-install-recommends"
ENV apt_clean="apt-get clean && apt-get autoremove -y && apt-get purge -y --auto-remove"
ENV curl="/usr/bin/curl --silent --show-error --tlsv1.2 --location"
ENV curl_github="/usr/bin/curl --silent --show-error --tlsv1.2 --request GET --url"
ENV dir_clean="\
  rm -rf \
  /var/lib/{apt,cache,log} \
  /usr/share/{doc,man,locale} \
  /var/cache/apt \
  /home/*/.cache \
  /root/.cache \
  /var/tmp/* \
  /tmp/* \
  "

#################################################################################
# Base Package Installation and User Configuration
#################################################################################

# Apt Packages
ARG APT_PKGS="\
  tar \
  gcc \
  curl \
  locales \
  ripgrep \
  fd-find \
  xclip \
  python3 \
  python3-pip \
  git \
  jq \
  "

# Install Base Packages and Remove Unnecessary Ones
RUN echo \
  && export TEST="echo" \
  && ${apt_update} \
  && bash -c "${apt_install} software-properties-common ca-certificates" \
  && bash -c "${apt_install} ${APT_PKGS}" \
  && ln -s $(which fdfind) /usr/local/bin/fd \
  && apt-get remove -y --purge nano \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Install lazygit
RUN echo \
  && export NAME="lazygit" \
  && export TEST="${NAME} --version" \
  && export REPOSITORY="jesseduffield/lazygit" \
  && export VERSION="$(${curl} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && export ARCH=$(uname -m | awk '{ if ($1 == "x86_64") print "x86_64"; else if ($1 == "aarch64" || $1 == "arm64") print "arm64"; else print "unknown" }') \
  && export PKG="${NAME}_${VERSION#v}_Linux_${ARCH}.tar.gz" \
  && export URL="https://github.com/${REPOSITORY}/releases/download/${VERSION}/${PKG}" \
  && echo "---------------------------------------------------------"\
  && echo "INFO[${NAME}] Installation Info:" \
  && echo "INFO[${NAME}]   Command:        ${NAME}" \
  && echo "INFO[${NAME}]   Package:        ${PKG}" \
  && echo "INFO[${NAME}]   Latest Release: ${VERSION}" \
  && echo "INFO[${NAME}]   Architecture:   ${ARCH}" \
  && echo "INFO[${NAME}]   Source:         ${URL}" \
  && echo "---------------------------------------------------------"\
  && ${curl} ${URL} | tar xzvf - --directory /tmp \
  && chmod 755 /tmp/${NAME} \
  && chown root:root /tmp/${NAME} \
  && mv /tmp/${NAME} /usr/local/bin/ \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Generate and Set Locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && update-locale LANG=en_US.UTF-8

# Install Python Neovim Package
RUN pip3 install --no-cache-dir pynvim

#################################################################################
# Install Node.js Tooling
# - nodejs
# - npm
#################################################################################
RUN echo \
    && export NODE_MAJOR=20 \
    && apt-get remove -y nodejs npm libnode-dev \
    && mkdir -p /etc/apt/keyrings \
    && curl -L https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean \
    && apt-get autoremove -y \
    && apt-get purge -y --auto-remove \
    && ${dir_clean} \
    && node --version \
    && npm --version \
    && echo

#################################################################################
# Build and Install Neovim from Source
#################################################################################

# Build Packages
ARG BUILD_PKGS="\
make \
wget \
build-essential \
ninja-build \
gettext \
libtool \
libtool-bin \
autoconf \
automake \
cmake \
pkg-config \
unzip \
doxygen \
"

RUN echo \
  && export NAME="neovim" \
  && export TEST="nvim --version" \
  && export REPOSITORY="neovim/neovim" \
  && export VERSION="$(${curl_github} https://api.github.com/repos/${REPOSITORY}/releases/latest | jq --raw-output .tag_name)" \
  && echo "---------------------------------------------------------" \
  && echo "INFO[${NAME}] Building Neovim Version: ${VERSION}" \
  && echo "---------------------------------------------------------" \
  && ${apt_update} \
  && bash -c "${apt_install} ${BUILD_PKGS}" \
  && git clone --depth 1 --branch ${VERSION} https://github.com/${REPOSITORY}.git /tmp/neovim \
  && cd /tmp/neovim \
  && make CMAKE_BUILD_TYPE=Release \
  && make install \
  && rm -rf /tmp/neovim \
  && bash -c "${apt_clean}" \
  && ${dir_clean} \
  && ${TEST} \
  && echo

# Create non-root user
RUN useradd -m -s /bin/bash nvimuser \
  && mkdir -p /home/nvimuser/.config \
  && chown -R nvimuser:nvimuser /home/nvimuser

# Switch to non-root user to install LazyVim
USER nvimuser
RUN set -ex \
  && git clone https://github.com/LazyVim/starter ~/.config/nvim \
  && nvim --headless "+Lazy! sync" +qa \
  && true

# Install Node.js Neovim extension and tree-sitter-cli
USER root
RUN npm install -g neovim tree-sitter-cli


# Set default command
CMD ["bash"]