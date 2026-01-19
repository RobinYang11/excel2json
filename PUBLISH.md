# 发布到 pub.dev 指南

## 发布前准备

### 1. 完善项目信息

确保以下文件已正确配置：

- ✅ `pubspec.yaml` - 已更新版本号、描述、homepage 和 repository
- ✅ `README.md` - 已完善文档
- ✅ `CHANGELOG.md` - 已更新版本变更记录
- ✅ `LICENSE` - 已添加许可证（MIT License）
- ✅ `analysis_options.yaml` - 已配置代码分析选项

### 2. 更新 GitHub 仓库信息

在 `pubspec.yaml` 中，将以下占位符替换为实际的 GitHub 仓库地址：

```yaml
homepage: https://github.com/your-username/excel2json
repository: https://github.com/your-username/excel2json
```

### 3. 提交代码到 Git

```bash
# 检查当前状态
git status

# 添加所有更改
git add .

# 提交更改
git commit -m "Prepare for pub.dev release v1.0.5"

# 推送到远程仓库
git push
```

### 4. 创建 Git 标签（可选但推荐）

```bash
# 创建版本标签
git tag v1.0.5

# 推送标签
git push origin v1.0.5
```

## 发布步骤

### 1. 登录 pub.dev

首先需要注册 pub.dev 账号（如果还没有）：

1. 访问 https://pub.dev
2. 点击右上角 "Sign in"
3. 使用 Google 账号登录

### 2. 获取发布令牌

1. 登录后，访问 https://pub.dev/settings
2. 在 "Uploaders" 部分，点击 "Create token"
3. 复制生成的令牌（只显示一次，请妥善保存）

### 3. 配置发布令牌

在项目根目录运行：

```bash
dart pub token add https://pub.dev
```

然后粘贴刚才复制的令牌。

### 4. 预发布检查

在正式发布前，先进行预发布检查：

```bash
flutter pub publish --dry-run
```

这会检查：
- ✅ 包名是否可用
- ✅ 文件结构是否正确
- ✅ 依赖是否有效
- ✅ 文档是否完整

**注意**：如果有 git 未提交的更改，会有警告，但不影响发布。建议先提交代码。

### 5. 正式发布

确认预发布检查通过后，执行正式发布：

```bash
flutter pub publish
```

系统会提示确认，输入 `y` 确认发布。

### 6. 验证发布

发布成功后：

1. 访问 https://pub.dev/packages/excel2json
2. 确认包信息正确显示
3. 等待几分钟让包索引更新

## 发布后

### 更新版本号

每次发布新版本时，需要：

1. 更新 `pubspec.yaml` 中的版本号（遵循语义化版本）
2. 更新 `CHANGELOG.md` 添加新版本的变更记录
3. 提交并推送代码
4. 创建新的 Git 标签
5. 重复发布步骤

### 版本号规则

- **主版本号**（1.x.x）：不兼容的 API 变更
- **次版本号**（x.1.x）：向后兼容的功能新增
- **修订号**（x.x.1）：向后兼容的问题修复

## 常见问题

### Q: 发布失败，提示包名已被占用？
A: 包名在 pub.dev 上必须唯一。如果 `excel2json` 已被占用，需要：
- 在 `pubspec.yaml` 中更改包名
- 确保新包名未被使用

### Q: 二进制文件太大，发布失败？
A: pub.dev 对包大小有限制（通常为 100MB）。当前二进制文件约 23MB，在限制范围内。如果将来需要减小大小，可以考虑：
- 压缩二进制文件
- 使用外部下载方式

### Q: 如何撤销已发布的版本？
A: pub.dev 不允许删除已发布的版本，但可以：
- 发布新版本修复问题
- 在 README 中标注已弃用

### Q: 如何更新已发布的包？
A: 
1. 更新版本号
2. 更新 CHANGELOG.md
3. 提交代码
4. 运行 `flutter pub publish` 发布新版本

## 发布检查清单

发布前请确认：

- [ ] `pubspec.yaml` 中的版本号已更新
- [ ] `pubspec.yaml` 中的 homepage 和 repository 已设置为实际 GitHub 地址
- [ ] `README.md` 已完善，包含使用说明
- [ ] `CHANGELOG.md` 已更新当前版本的变更
- [ ] `LICENSE` 文件已添加
- [ ] 所有代码已提交到 Git
- [ ] 测试已通过（`flutter test`）
- [ ] 预发布检查通过（`flutter pub publish --dry-run`）
- [ ] 已登录 pub.dev 并配置发布令牌

## 参考链接

- [pub.dev 发布指南](https://dart.dev/tools/pub/publishing)
- [pubspec.yaml 规范](https://dart.dev/tools/pub/pubspec)
- [语义化版本](https://semver.org/)

