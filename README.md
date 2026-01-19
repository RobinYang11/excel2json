# Excel 转 JSON 和 Dart 自动化工具

## 项目描述

这是一个 Flutter 开发依赖工具，用于将 Excel 文件转换为 JSON 文件和 Dart LocaleKeys 类。特别适合需要国际化配置和多语言支持的 Flutter 项目。

**主要功能：**
- 📊 读取 Excel 表格数据
- 🔤 使用拼音库自动转换中文 key 为拼音
- 📄 为每一行数据生成独立的 JSON 文件
- 🎯 自动生成 Dart 语言的 LocaleKeys 类文件
- 🔧 跨平台支持（macOS、Windows）
- 📦 作为 Flutter 开发依赖使用，无需手动下载二进制文件

---

## 快速开始

### 安装

在 Flutter 项目的 `pubspec.yaml` 中添加开发依赖：

```yaml
dev_dependencies:
  excel2json: ^1.0.5
```

然后运行：

```bash
flutter pub get
```

安装完成后，可以使用 `dart run excel2json` 或直接使用 `excel2json` 命令。

### 基本使用

```bash
# 使用默认参数
dart run excel2json

# 或者直接使用
excel2json -file=./assets/abc.xlsx
```

---

## 参数说明

### 必需参数

无（所有参数都有默认值）

### 可选参数

| 参数 | 简写 | 默认值 | 说明 |
|------|------|--------|------|
| `-file` | - | `./assets/abc.xlsx` | 输入的 Excel 文件路径 |
| `-output_path` | - | `./` | JSON 文件的输出目录路径 |
| `-dart_file` | - | `./locale_keys.dart` | 生成的 Dart 文件路径 |
| `-version` | - | `false` | 显示版本信息、构建时间和 Git 提交哈希 |

### 参数详细说明

#### `-file`
指定要转换的 Excel 文件路径。文件必须是 `.xlsx` 格式，且包含名为 `Sheet1` 的工作表。

**示例：**
```bash
dart run excel2json -file=/path/to/your/file.xlsx
dart run excel2json -file=./data/translations.xlsx
```

#### `-output_path`
指定生成的 JSON 文件的输出目录。如果目录不存在，程序会尝试创建（需要权限）。

**示例：**
```bash
dart run excel2json -output_path=./output/
dart run excel2json -output_path=/tmp/json_files/
```

#### `-dart_file`
指定生成的 Dart LocaleKeys 类文件的完整路径（包括文件名）。

**示例：**
```bash
dart run excel2json -dart_file=./lib/locale_keys.dart
dart run excel2json -dart_file=./generated/locale_keys.dart
```

#### `-version`
显示程序的版本信息，包括版本号、构建时间和 Git 提交哈希。

**示例：**
```bash
dart run excel2json -version
```

**输出示例：**
```
Version: 1.0.5
Build Time: 2026-01-16 10:30:45
Git Commit: a1b2c3d
```

---

## 使用示例

### 示例 1：使用默认参数

```bash
# 使用默认参数（assets 目录下的 abc.xlsx）
dart run excel2json
```

### 示例 2：指定输入文件和输出目录

```bash
# 指定 Excel 文件和输出目录
dart run excel2json -file=./data/translations.xlsx -output_path=./output/
```

### 示例 3：完整参数配置

```bash
# 指定所有参数
dart run excel2json \
  -file=./data/translations.xlsx \
  -output_path=./output/json/ \
  -dart_file=./lib/locale_keys.dart
```

### 示例 4：Windows 使用

```bash
# Windows 命令行
dart run excel2json -file=C:\data\translations.xlsx -output_path=C:\output\
```

---

## Excel 文件格式要求

### 文件结构

Excel 文件必须包含名为 `Sheet1` 的工作表，格式要求如下：

1. **第一行（表头）**：作为 JSON 的 key，支持中文，程序会自动转换为拼音
2. **第一列**：作为输出 JSON 文件的文件名（不含扩展名）
3. **数据区域**：从第二行开始，每行对应一个 JSON 文件

### 示例 Excel 结构

| 文件名 | 中文标题 | English Title | 日本語タイトル |
|--------|---------|---------------|----------------|
| zh | 你好 | Hello | こんにちは |
| en | 世界 | World | 世界 |
| ja | 测试 | Test | テスト |

### 转换结果

**生成的 JSON 文件：**

`zh.json`:
```json
{"zhongwenbiaoti":"你好","EnglishTitle":"Hello","日本語タイトル":"こんにちは"}
```

`en.json`:
```json
{"zhongwenbiaoti":"世界","EnglishTitle":"World","日本語タイトル":"世界"}
```

`ja.json`:
```json
{"zhongwenbiaoti":"测试","EnglishTitle":"Test","日本語タイトル":"テスト"}
```

**生成的 Dart 文件 (`locale_keys.dart`):**
```dart
class LocaleKeys {
  static const zhongwenbiaoti = 'zhongwenbiaoti';
  static const EnglishTitle = 'EnglishTitle';
  static const 日本語タイトル = '日本語タイトル';
}
```

---

## 输出说明

### JSON 文件

- 文件名：使用 Excel 第一列的值作为文件名（`.json` 扩展名）
- 内容：每行数据转换为一个 JSON 对象，key 为第一行表头（中文转拼音），value 为对应单元格的值
- 位置：保存在 `-output_path` 指定的目录中

### Dart 文件

- 文件名：`locale_keys.dart`（可通过 `-dart_file` 参数自定义）
- 内容：包含所有表头转换后的拼音 key，作为静态常量
- 用途：用于 Flutter/Dart 项目的国际化配置

---

## 平台支持

本工具支持以下平台：

- ✅ **macOS** (Intel 和 Apple Silicon/M1/M2/M3)
- ✅ **Windows**
- ❌ Linux（暂不支持）

工具会自动检测运行平台并选择对应的二进制文件执行。

---

## 常见问题

### Q: 程序提示找不到 Excel 文件？
A: 检查 `-file` 参数指定的路径是否正确，使用绝对路径或相对路径都可以。

### Q: 生成的 JSON 文件 key 是拼音，如何自定义？
A: 目前程序自动将中文表头转换为拼音。如需自定义 key，建议在 Excel 第一行直接使用英文或拼音。

### Q: 支持哪些 Excel 格式？
A: 目前仅支持 `.xlsx` 格式（Excel 2007 及以上版本）。

### Q: 如何查看程序版本？
A: 使用 `-version` 参数：`dart run excel2json -version`

### Q: 如何在 Flutter 项目中使用？
A: 将本包添加为 `dev_dependencies`，然后使用 `dart run excel2json` 命令执行。

---

## 开发说明

### 环境要求

- Flutter SDK >= 1.17.0
- Dart SDK ^3.9.0

### 本地开发

```bash
# 克隆项目
git clone https://github.com/your-username/excel2json.git
cd excel2json

# 安装依赖
flutter pub get

# 运行测试
flutter test

# 本地测试执行
dart run bin/excel2json.dart -file=./assets/abc.xlsx
```

### 构建和发布

本工具使用预编译的二进制文件（Go 语言编写），二进制文件位于：
- `bin/macos/arm64/excel2json` - macOS Apple Silicon
- `bin/macos/intel/excel2json` - macOS Intel
- `bin/windows/excel2json.exe` - Windows

---

## 许可证

查看 [LICENSE](LICENSE) 文件了解详情。
