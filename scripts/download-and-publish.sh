#!/bin/bash

# 脚本：从 excel2x 仓库的 dist 目录下载构建包并自动发布
# 用法: ./scripts/download-and-publish.sh [VERSION] [--publish]
# 示例: ./scripts/download-and-publish.sh v1.0.9 --publish

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认值
VERSION=""
REPO="RobinYang11/excel2x"
PUBLISH=false

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --publish)
      PUBLISH=true
      shift
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    *)
      if [ -z "$VERSION" ]; then
        VERSION="$1"
      else
        echo -e "${RED}未知参数: $1${NC}"
        exit 1
      fi
      shift
      ;;
  esac
done

# 如果没有提供版本，获取最新版本
if [ -z "$VERSION" ]; then
  VERSION="latest"
fi

# 检查必要的工具
check_dependencies() {
  local missing=()
  
  if ! command -v curl &> /dev/null; then
    missing+=("curl")
  fi
  
  if ! command -v jq &> /dev/null; then
    missing+=("jq")
  fi
  
  if [ ${#missing[@]} -ne 0 ]; then
    echo -e "${RED}错误: 缺少必要的工具: ${missing[*]}${NC}"
    exit 1
  fi
}

# 获取 dist 目录中的文件列表
get_dist_files() {
  local version=$1
  
  echo -e "${GREEN}正在获取 dist 目录文件列表...${NC}"
  
  # 从仓库的 dist 目录获取文件
  local api_url="https://api.github.com/repos/${REPO}/contents/dist"
  local response
  response=$(curl -s "$api_url")
  
  if echo "$response" | jq -e 'type == "array"' > /dev/null 2>&1; then
    # 如果指定了版本，过滤文件
    if [ "$version" != "latest" ]; then
      # 确保有 v 前缀
      if [[ "$version" != v* ]]; then
        version="v$version"
      fi
      echo "$response" | jq -r --arg version "$version" '.[] | select(.type == "file" and (.name | contains($version))) | "\(.name)|\(.download_url)|\($version)"'
    else
      # 获取最新版本（从文件名中提取版本号）
      local latest_version=$(echo "$response" | jq -r '.[] | select(.type == "file") | .name' | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
      if [ -z "$latest_version" ]; then
        echo -e "${RED}错误: 无法从文件名中提取版本号${NC}"
        exit 1
      fi
      echo "$response" | jq -r --arg version "$latest_version" '.[] | select(.type == "file" and (.name | contains($version))) | "\(.name)|\(.download_url)|\($version)"'
    fi
  else
    echo -e "${RED}错误: 无法获取 dist 目录信息${NC}"
    echo "API URL: $api_url"
    echo "响应: $response" | jq '.' 2>/dev/null || echo "$response"
    exit 1
  fi
}

# 下载 release asset
download_asset() {
  local asset_name=$1
  local download_url=$2
  local output_dir=$3
  
  echo -e "${GREEN}正在下载: $asset_name${NC}"
  
  # 确定目标路径
  local target_path=""
  case "$asset_name" in
    *linux*amd64*|*linux*x64*)
      target_path="$output_dir/linux/x64/excel2json"
      ;;
    *linux*arm64*|*linux*aarch64*)
      target_path="$output_dir/linux/arm64/excel2json"
      ;;
    *macos*arm64*|*macos*arm*|*darwin*arm64*)
      target_path="$output_dir/macos/arm64/excel2json"
      ;;
    *macos*intel*|*macos*amd64*|*darwin*amd64*|*darwin*x64*)
      target_path="$output_dir/macos/intel/excel2json"
      ;;
    *windows*|*.exe*)
      target_path="$output_dir/windows/excel2json.exe"
      ;;
    *)
      echo -e "${YELLOW}警告: 无法识别平台，跳过: $asset_name${NC}"
      return 0
      ;;
  esac
  
  # 创建目标目录
  mkdir -p "$(dirname "$target_path")"
  
  # 使用 curl 直接下载（GitHub Releases 的 browser_download_url 可以直接下载，无需认证）
  echo "  下载 URL: $download_url"
  if curl -sL -f "$download_url" -o "$target_path"; then
    if [ ! -s "$target_path" ]; then
      echo -e "${RED}错误: 下载的文件为空${NC}"
      rm -f "$target_path"
      return 1
    fi
  else
    echo -e "${RED}错误: 下载失败${NC}"
    rm -f "$target_path"
    return 1
  fi
  
  # 设置执行权限（Windows 除外）
  if [[ "$target_path" != *.exe ]]; then
    chmod +x "$target_path"
  fi
  
  echo -e "${GREEN}✅ 已下载到: $target_path${NC}"
}

# 主函数
main() {
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}从 excel2x 仓库下载构建包${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  
  check_dependencies
  
  # 获取项目根目录
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  BIN_DIR="$PROJECT_ROOT/bin"
  
  echo -e "${GREEN}项目根目录: $PROJECT_ROOT${NC}"
  echo -e "${GREEN}Bin 目录: $BIN_DIR${NC}"
  echo -e "${GREEN}版本: $VERSION${NC}"
  echo ""
  
  # 创建 bin 目录结构
  mkdir -p "$BIN_DIR/linux/x64"
  mkdir -p "$BIN_DIR/linux/arm64"
  mkdir -p "$BIN_DIR/macos/arm64"
  mkdir -p "$BIN_DIR/macos/intel"
  mkdir -p "$BIN_DIR/windows"
  
  # 获取 dist 目录文件
  echo -e "${GREEN}正在获取 dist 目录文件...${NC}"
  files=$(get_dist_files "$VERSION")
  
  if [ -z "$files" ]; then
    echo -e "${RED}错误: 未找到任何文件${NC}"
    exit 1
  fi
  
  # 提取版本号
  TAG_NAME=$(echo "$files" | head -1 | cut -d'|' -f3)
  echo -e "${GREEN}版本: $TAG_NAME${NC}"
  echo ""
  
  echo -e "${GREEN}找到以下文件:${NC}"
  echo "$files" | while IFS='|' read -r name url version; do
    echo "  - $name"
  done
  echo ""
  
  # 下载每个文件
  echo "$files" | while IFS='|' read -r name url version; do
    download_asset "$name" "$url" "$BIN_DIR"
  done
  
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}下载完成！${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  
  # 显示下载的文件
  echo -e "${GREEN}已下载的文件:${NC}"
  find "$BIN_DIR" -type f -name "excel2json*" | while read -r file; do
    if [ -f "$file" ]; then
      size=$(ls -lh "$file" | awk '{print $5}')
      echo "  ✅ $file ($size)"
    fi
  done
  echo ""
  
  # 如果需要发布
  if [ "$PUBLISH" = true ]; then
    echo -e "${GREEN}准备发布...${NC}"
    
    cd "$PROJECT_ROOT"
    
    # 检查 git 状态
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
      echo -e "${RED}错误: 当前目录不是 git 仓库${NC}"
      exit 1
    fi
    
    # 检查是否有未提交的更改
    if ! git diff-index --quiet HEAD --; then
      echo -e "${YELLOW}警告: 有未提交的更改${NC}"
      git status --short
      read -p "是否继续提交并发布? (y/n) " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
      fi
      
      # 提交更改
      git add bin/
      git commit -m "chore: update binaries from excel2x $TAG_NAME"
    fi
    
    # 获取当前版本
    CURRENT_VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | tr -d ' ')
    echo -e "${GREEN}当前版本: $CURRENT_VERSION${NC}"
    
    # 创建并推送 tag
    TAG="v$CURRENT_VERSION"
    if git rev-parse "$TAG" > /dev/null 2>&1; then
      echo -e "${YELLOW}警告: Tag $TAG 已存在${NC}"
      read -p "是否删除并重新创建? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        git tag -d "$TAG" 2>/dev/null || true
        git push origin ":refs/tags/$TAG" 2>/dev/null || true
      else
        echo -e "${RED}取消发布${NC}"
        exit 1
      fi
    fi
    
    # 创建 tag
    git tag -a "$TAG" -m "Version $CURRENT_VERSION - binaries from excel2x $TAG_NAME"
    
    # 推送代码和 tag
    echo -e "${GREEN}正在推送代码和 tag...${NC}"
    git push origin main
    git push origin "$TAG"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✅ 发布完成！${NC}"
    echo -e "${GREEN}Tag $TAG 已推送，GitHub Actions 将自动触发发布流程${NC}"
    echo -e "${GREEN}========================================${NC}"
  else
    echo -e "${YELLOW}提示: 使用 --publish 参数可以自动发布${NC}"
    echo "例如: $0 $VERSION --publish"
  fi
}

# 运行主函数
main
