# 個人開發環境設置指南

這個專案包含了個人開發環境的 Docker 配置，主要設置了 Neovim (LazyVim)、Node.js。

## 環境內容

- Ubuntu 24.04
- Neovim 0.10.4 (LazyVim)
- Node.js 20.x
- 開發工具：git, curl, wget, fzf, fd-find, ripgrep, lazygit 等

## 環境設定

### 時區

預設時區設置為 Asia/Taipei，如需修改可透過建構參數更改：

```bash
docker build --build-arg TZ=Your/Timezone -t nvim-node:0.10.4-node20 .
```

## 使用方式

### 參數說明

- `<name>`: 專案名稱，例如 my-project
- `<port>`: 開發伺服器端口，例如 -p 5173:5173

### 1. 建構基礎映像

```bash
# 建構 nvim-node 基礎映像
docker build -t nvim-node:0.10.4-node20 -f Dockerfile .
```

### 2. 啟動開發環境

```bash
docker run -d --name <name> -p <port> -v application:/apps/<name> nvim-node:0.10.4-node20 tail -f /dev/null
docker exec -it <name> bash -c "cd /apps/<name> && bash"
```

### 3. 在容器中開發

```bash
# 啟動開發服務器
npm run dev -- --host

# 使用 Neovim 編輯檔案
nvim .
```

## SSH 設定與授權

第一次使用時，需要確保 SSH 配置有正確的權限：

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
