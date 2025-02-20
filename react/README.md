# 個人開發環境設置指南

這個專案包含了個人開發環境的 Docker 配置，主要設置了 Neovim (LazyVim)、Node.js 和 SSH 環境。

## 檔案結構

```
docker-dev-env/
├── Dockerfile.dev    # 開發環境 Dockerfile
└── docker-compose.yml # Docker Compose 配置
```

## 環境內容

- Ubuntu 24.04
- Neovim 0.10.4 (LazyVim)
- Node.js 20.x
- SSH 客戶端
- 開發工具：git, curl, wget, fzf 等

## 使用方式

### 1. 建構基礎映像

```bash
# 建構 nvim-node 基礎映像
docker build -t nvim-node:0.10.4-node20 -f Dockerfile.nvim-node .

# 建構 ssh-base 基礎映像
docker build -t ssh-base:1.0 -f Dockerfile.ssh-base .
```

### 2. 啟動開發環境

```bash
# 使用 --env 參數指定專案路徑
docker-compose up -d --env PROJECT_PATH=<your-project-path>

# 例如：
docker-compose up -d --env PROJECT_PATH=D:/Documents/code-personal/react-router-test

# 進入容器
docker-compose exec dev-environment bash
```

### 3. 在容器中開發

```bash
# 啟動開發服務器
npm run dev -- --host

# 使用 Neovim 編輯檔案
nvim .
```

## Neovim (LazyVim) 基本使用

- `<Space>` 是 leader 鍵
- `<Space>ff` 尋找文件
- `<Space>fg` 搜尋文字
- `<Space>e` 打開/關閉文件樹
- `gcc` 註釋/取消註釋
- `i` 進入插入模式
- `<Esc>` 或 `jk` 返回普通模式

## 注意事項

1. 這是個人開發環境配置，不建議加入專案的版本控制
2. 確保本機的 SSH 配置正確
3. 容器中的 /workspace 目錄會映射到指定的專案目錄
4. 開發服務器會運行在 http://localhost:5173

## SSH 設定與授權

### SSH 目錄權限設定

第一次使用時，需要確保 SSH 配置有正確的權限：

```bash
# 在容器內執行
chmod 700 /root/.ssh
chmod 600 /root/.ssh/config
chmod 600 /root/.ssh/id_rsa
chmod 644 /root/.ssh/id_rsa.pub
chmod 600 /root/.ssh/id_rsa_home
chmod 644 /root/.ssh/id_rsa_home.pub

# 測試 SSH 連接
ssh -T git@personal.github.com
```

### 常見的 SSH 問題

1. `Bad owner or permissions on /root/.ssh/config`

   - 原因：SSH 配置文件權限不正確
   - 解決：執行上述的權限設定命令

2. `Permission denied (publickey)`
   - 原因：SSH 金鑰未在 GitHub/GitLab 註冊
   - 解決：確保公鑰已添加到您的 Git 帳號

## 常用指令

```bash
# 重建容器
docker-compose down
docker-compose up -d --env PROJECT_PATH=<your-project-path>

# 查看容器日誌
docker-compose logs

# 停止環境
docker-compose down
```
