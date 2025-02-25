# Neovim + Node 開發環境

這個 Docker 映像提供了一個完整配置的 Neovim 開發環境，內建 Node.js 支援。它專為跨多架構（AMD64 和 ARM64）工作而設計，可以在 Windows、macOS（Intel 或 M1/M2）和 Linux 系統上使用。

## 功能特色

- Neovim 0.10.4 搭配 LazyVim 配置
- Node.js 20.x 與 npm
- 常用開發工具（git、curl、ripgrep、fd 等）
- 透過多架構映像實現跨平台支援
- Treesitter 提供增強的語法高亮
- Lazygit 用於 Git 操作

## 使用方式

### 參數說明

- `<name>`: 專案名稱，例如 my-project
- `<port>`: 開發伺服器端口，例如 -p 5173:5173

### 執行容器

此映像設計為將所有專案檔案保留在容器內，使用 Docker 磁碟區來實現持久化，避免在主機檔案系統中產生任何雜亂。

```bash
# 建立並啟動具有持久磁碟區的容器
docker run -d --name <name> -p <port> -v application:/apps nvim-node:0.10.4-node20 tail -f /dev/null

# 進入容器
docker exec -it nvim-dev bash

# 在容器內
source ~/.bashrc  # 載入環境變數
cd /apps          # 進入應用程式目錄
nvim              # 啟動 Neovim
```

### 專案操作

所有專案和配置都將存儲在容器內的 `/apps` 目錄中，通過 Docker 磁碟區持久保存。

1. 建立新專案：

   ```bash
   # 在容器內
   cd /apps
   mkdir <name>
   cd <name>
   nvim .
   ```

2. 即使重新啟動後，容器和您的所有工作仍會保留：

   ```bash
   # 停止容器
   docker stop nvim-dev

   # 之後再次啟動
   docker start nvim-dev
   docker exec -it nvim-dev bash
   ```

## SSH 設定與授權

```bash
# 在容器內執行
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Windows PowerShell
docker cp ${env:USERPROFILE}/.ssh/id_rsa <name>:/root/.ssh/

# Linux/macOS
docker cp ~/.ssh/id_rsa <name>:/root/.ssh/

# 在容器內執行
chmod 600 /root/.ssh/id_rsa

# 測試 SSH 連接
ssh -T git@github.com
```

## 構建映像

### 單一架構構建

```bash
# 為您當前的架構構建
docker build -t nvim-node:0.10.4-node20 .
```

### 多架構構建（推薦）

```bash
# 設置 Docker Buildx（如果尚未完成）
docker buildx create --name mybuilder --use

# 構建並推送多架構映像
docker buildx build --platform linux/amd64,linux/arm64 \
  -t your-registry/nvim-node:0.10.4-node20 \
  --push .
```

## 容器化開發的優勢

- **隔離環境**：您的開發環境不會影響或受到主機系統的影響
- **一致體驗**：在所有平台上提供相同的開發體驗
- **不污染主機檔案系統**：所有專案檔案都留在容器內
- **持久性**：您的工作安全地存儲在 Docker 磁碟區中
- **可攜性**：通過推送/拉取 Docker 映像，可以在不同機器上處理相同的專案

## 進階用法

### 自定義 Neovim 配置

LazyVim 已預先安裝作為起點。您可以通過編輯配置檔案來自定義它：

```bash
# 在容器內
nvim ~/.config/nvim/lua/config/options.lua  # 基本選項
nvim ~/.config/nvim/lua/config/keymaps.lua  # 按鍵映射
nvim ~/.config/nvim/lua/plugins/            # 插件配置
```

### 添加新語言或工具

您可以在容器內安裝額外的開發工具：

```bash
# 範例：安裝 Python 開發工具
pip install pylint black

# 範例：安裝 TypeScript 支援
npm install -g typescript typescript-language-server
```

### 備份您的配置

如果您想備份自定義配置，可以：

1. 在容器內建立 Git 倉庫
2. 推送到遠端倉庫
3. 或使用 Docker cp 將配置複製到另一個位置：
   ```bash
   docker cp nvim-dev:/root/.config/nvim ./my-nvim-config
   ```
