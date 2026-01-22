# 下载和发布脚本

## 脚本说明

`download-and-publish.sh` 用于从 [excel2x](https://github.com/RobinYang11/excel2x) 的 GitHub Releases 下载构建包到 `bin` 目录，并可选择自动发布到 pub.dev。

## 使用方法

### 基本用法

```bash
# 下载最新版本的构建包
./scripts/download-and-publish.sh

# 下载指定版本的构建包
./scripts/download-and-publish.sh v1.0.9

# 下载并自动发布
./scripts/download-and-publish.sh v1.0.9 --publish
```

### 参数说明

- `VERSION` (可选): 要下载的版本号，如 `v1.0.9` 或 `1.0.9`。如果不指定，默认下载最新版本。
- `--publish`: 下载完成后自动发布到 pub.dev（需要创建并推送 git tag）

## 功能

1. **自动下载构建包**: 从 GitHub Releases 下载所有平台的二进制文件
   - macOS Intel (`bin/macos/intel/excel2json`)
   - macOS ARM64 (`bin/macos/arm64/excel2json`)
   - Windows (`bin/windows/excel2json.exe`)
   - Linux x64 (`bin/linux/x64/excel2json`)
   - Linux ARM64 (`bin/linux/arm64/excel2json`)

2. **自动发布** (使用 `--publish` 参数):
   - 提交二进制文件更改
   - 创建并推送 git tag
   - 触发 GitHub Actions 自动发布到 pub.dev

## 依赖要求

脚本只需要两个工具，非常简单：

- `curl`: 用于下载文件和调用 GitHub API
- `jq`: 用于解析 JSON（GitHub API 响应）
- `git`: 用于版本控制和发布（仅在 `--publish` 时使用）

### 安装依赖 (macOS)

```bash
brew install jq
```

### 安装依赖 (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y curl jq
```

**注意**: 脚本使用 GitHub 公开 API，无需任何认证或 token。

## 示例

### 示例 1: 下载最新版本

```bash
./scripts/download-and-publish.sh
```

### 示例 2: 下载指定版本

```bash
./scripts/download-and-publish.sh v1.0.9
```

### 示例 3: 下载并发布

```bash
./scripts/download-and-publish.sh v1.0.9 --publish
```

## 注意事项

1. **发布前检查**: 使用 `--publish` 参数前，请确保：
   - 已更新 `pubspec.yaml` 中的版本号
   - 已更新 `CHANGELOG.md`
   - 所有更改已测试通过

2. **Git 状态**: 脚本会检查未提交的更改，并在发布前询问确认

3. **Tag 冲突**: 如果 tag 已存在，脚本会询问是否删除并重新创建

4. **发布流程**: 推送 tag 后，GitHub Actions 会自动触发发布流程（见 `.github/workflows/dart.yml`）

## 故障排除

### 下载失败

- 检查网络连接
- 确认版本号正确
- GitHub 公开 API 有速率限制（每小时 60 次请求），通常足够使用

### 发布失败

- 确认已配置 `PUB_DEV_REFRESH_TOKEN` secret（在 GitHub Actions 中）
- 检查 git 仓库状态
- 确认有推送权限

